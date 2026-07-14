#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import os
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Set, Tuple


CONTENT_TYPES = [
    "sloka",
    "translit",
    "comment",
    "vocabulary",
    "meta",
    "audioRefs",
    "quotes",
]

LANG_CODE_RE = re.compile(r"^[a-z]{2}(-[A-Z]{2})?$")


DATA_FILE_TYPE_BY_SUFFIX = {
    "_sloka.txt": "sloka",
    "_translit.txt": "translit",
    "_comment.txt": "comment",
    "_vocabulary.json": "vocabulary",
    "_meta.json": "meta",
}


CHAPTER_DIR_RE = re.compile(r"^chapter-(\d{2})-(.+)$")
DATA_ROOTS = {
    "sanskrit": "data/sanskrit",
    "original": "data/original",
    "translated": "data/translated",
}


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def sorted_natural(items: Iterable[str]) -> List[str]:
    def key(s: str):
        parts: List[Any] = []
        for chunk in re.split(r"(\d+)", s):
            if chunk.isdigit():
                parts.append(int(chunk))
            else:
                parts.append(chunk)
        return parts

    return sorted(list(items), key=key)


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def safe_listdir(path: Path) -> List[Path]:
    try:
        return list(path.iterdir())
    except FileNotFoundError:
        return []


@dataclass(frozen=True)
class CoverageCell:
    present_types: Set[str]
    missing_types: Set[str]


def scan_data_source(repo_root: Path) -> Dict[str, Any]:
    """
    Scans /data directory for language/chapter coverage based on files present.
    """
    data_root = repo_root / "data"
    result: Dict[str, Any] = {
        "source": "data",
        "languages": {},
        "notes": [],
    }

    def ensure_lang(lang: str) -> Dict[str, Any]:
        langs = result["languages"]
        if lang not in langs:
            langs[lang] = {"chapters": {}}
        return langs[lang]

    # Sanskrit
    sanskrit_root = data_root / "sanskrit"
    for chap_dir in safe_listdir(sanskrit_root):
        if not chap_dir.is_dir():
            continue
        m = CHAPTER_DIR_RE.match(chap_dir.name)
        if not m:
            continue
        chap = m.group(1)
        lang = "sanskrit"
        lang_obj = ensure_lang(lang)
        types_present = set()
        for file in safe_listdir(chap_dir):
            if not file.is_file():
                continue
            for suffix, t in DATA_FILE_TYPE_BY_SUFFIX.items():
                if file.name.endswith(suffix):
                    types_present.add(t)
        # sanskrit uses *_sloka.txt and *_meta.json
        cell = {
            "present": sorted_natural(types_present),
            "missing": sorted_natural(set(CONTENT_TYPES) - types_present),
        }
        lang_obj["chapters"][chap] = cell

    # original + translated
    for group, rel in (("original", "original"), ("translated", "translated")):
        group_root = data_root / rel
        for lang_dir in safe_listdir(group_root):
            if not lang_dir.is_dir():
                continue
            lang = lang_dir.name
            lang_obj = ensure_lang(lang)
            for chap_dir in safe_listdir(lang_dir):
                if not chap_dir.is_dir():
                    continue
                m = CHAPTER_DIR_RE.match(chap_dir.name)
                if not m:
                    continue
                chap = m.group(1)
                types_present = set()
                for file in safe_listdir(chap_dir):
                    if not file.is_file():
                        continue
                    for suffix, t in DATA_FILE_TYPE_BY_SUFFIX.items():
                        if file.name.endswith(suffix):
                            types_present.add(t)
                cell = {
                    "present": sorted_natural(types_present),
                    "missing": sorted_natural(set(CONTENT_TYPES) - types_present),
                    "group": group,
                }
                lang_obj["chapters"][chap] = cell

    # meta listing check (do not fail if absent)
    meta_languages = data_root / "meta" / "languages.json"
    if meta_languages.exists():
        try:
            meta = read_json(meta_languages)
            listed = set(meta.keys())
            present = set(result["languages"].keys())
            extra = listed - present
            missing = present - listed
            if extra:
                result["notes"].append(
                    {
                        "type": "meta_languages_extra",
                        "path": str(meta_languages),
                        "languages": sorted_natural(extra),
                    }
                )
            if missing:
                result["notes"].append(
                    {
                        "type": "meta_languages_missing",
                        "path": str(meta_languages),
                        "languages": sorted_natural(missing),
                    }
                )
        except Exception as e:
            result["notes"].append(
                {"type": "meta_languages_parse_error", "path": str(meta_languages), "error": str(e)}
            )

    return result


def scan_bak_source(repo_root: Path) -> Dict[str, Any]:
    """
    Scans /bak for:
    - bak/chapters/original/chapter-XX.json : rich multi-language chapter json
    - bak/chapters/generated/* (language presence only)
    - bak/chapters/asian/chapter-XX-asian-translations.json (presence only)
    """
    bak_root = repo_root / "bak"
    result: Dict[str, Any] = {
        "source": "bak",
        "languages": {},
        "chapter_json": {"path": "bak/chapters/original", "chapters": {}},
        "notes": [],
    }

    def ensure_lang(lang: str) -> Dict[str, Any]:
        langs = result["languages"]
        if lang not in langs:
            langs[lang] = {"chapters": {}}
        return langs[lang]

    def is_plausible_lang_code(code: str) -> bool:
        # Handle a few known legacy variants
        if code in {"zhcn", "spa"}:
            return True
        return bool(LANG_CODE_RE.match(code))

    chapter_json_root = bak_root / "chapters" / "original"
    chapter_files = sorted(
        [p for p in safe_listdir(chapter_json_root) if p.is_file() and p.name.startswith("chapter-") and p.suffix == ".json"]
    )
    for p in chapter_files:
        m = re.match(r"chapter-(\d{2})\.json$", p.name)
        if not m:
            continue
        chap = m.group(1)
        try:
            obj = read_json(p)
        except Exception as e:
            result["notes"].append({"type": "chapter_json_parse_error", "path": str(p), "error": str(e)})
            continue

        # best-effort: inspect translations keys + vocabulary + audio fields existence
        translations: Dict[str, Any] = {}
        # expected: slokas list with translations map
        slokas = obj.get("slokas") if isinstance(obj, dict) else None
        if isinstance(slokas, list) and slokas:
            first = slokas[0]
            if isinstance(first, dict):
                translations = first.get("translations") or {}

        lang_keys = set()
        if isinstance(translations, dict):
            lang_keys = {k for k in translations.keys() if isinstance(k, str) and is_plausible_lang_code(k)}
        # Always include sanskrit as a conceptual language for this source
        lang_keys = set(lang_keys)

        # Compute chapter-level types: meta, audioRefs, vocabulary, comment (if any), sloka/translit inferred
        chapter_types: Set[str] = set()
        if isinstance(obj, dict):
            chapter_types.add("meta")
            # presence, not completeness
            if "audio" in obj:
                chapter_types.add("audioRefs")
        # scan slokas for vocabulary/comment/audio refs
        any_vocab = False
        any_comment = False
        any_audio = False
        any_sloka = False
        any_translit = False
        if isinstance(slokas, list):
            for s in slokas:
                if not isinstance(s, dict):
                    continue
                if s.get("sanskrit") or s.get("text"):
                    any_sloka = True
                if s.get("transliteration") or s.get("transcription"):
                    any_translit = True
                if s.get("vocabulary"):
                    any_vocab = True
                if s.get("comment") or (isinstance(s.get("comments"), dict) and s.get("comments")):
                    any_comment = True
                aud = s.get("audio")
                if isinstance(aud, dict) and aud:
                    any_audio = True
        if any_sloka:
            chapter_types.add("sloka")
        if any_translit:
            chapter_types.add("translit")
        if any_vocab:
            chapter_types.add("vocabulary")
        if any_comment:
            chapter_types.add("comment")
        if any_audio:
            chapter_types.add("audioRefs")

        result["chapter_json"]["chapters"][chap] = {
            "present": sorted_natural(chapter_types),
            "missing": sorted_natural(set(CONTENT_TYPES) - chapter_types),
            "languages_inferred": sorted_natural(lang_keys),
        }

        for lang in lang_keys:
            lang_obj = ensure_lang(lang)
            # For bak rich JSON we only record chapter-level types
            lang_obj["chapters"][chap] = {
                "present": sorted_natural(chapter_types),
                "missing": sorted_natural(set(CONTENT_TYPES) - chapter_types),
                "group": "bak/chapters/original",
            }

    # generated markdown presence (language-only + chapter count)
    gen_root = bak_root / "chapters" / "generated"
    for lang_dir in safe_listdir(gen_root):
        if not lang_dir.is_dir():
            continue
        lang = lang_dir.name
        chapters: Set[str] = set()
        for f in safe_listdir(lang_dir):
            if not f.is_file():
                continue
            m = re.match(r"chapter-(\d{2})\.md$", f.name)
            if m:
                chapters.add(m.group(1))
        if chapters:
            if not is_plausible_lang_code(lang):
                continue
            lang_obj = ensure_lang(lang)
            for chap in chapters:
                lang_obj["chapters"].setdefault(
                    chap,
                    {
                        "present": ["sloka"],
                        "missing": sorted_natural(set(CONTENT_TYPES) - {"sloka"}),
                        "group": "bak/chapters/generated",
                    },
                )

    # asian translations presence only (chapters 01-06 likely)
    asian_root = bak_root / "chapters" / "asian"
    for f in safe_listdir(asian_root):
        if not f.is_file():
            continue
        m = re.match(r"chapter-(\d{2})-asian-translations\.json$", f.name)
        if not m:
            continue
        chap = m.group(1)
        try:
            obj = read_json(f)
        except Exception as e:
            result["notes"].append({"type": "asian_translations_parse_error", "path": str(f), "error": str(e)})
            continue
        # Keys in this JSON tend to be language codes
        if isinstance(obj, dict):
            for lang in obj.keys():
                if not isinstance(lang, str) or not is_plausible_lang_code(lang):
                    continue
                lang_obj = ensure_lang(lang)
                lang_obj["chapters"].setdefault(
                    chap,
                    {
                        "present": ["sloka"],
                        "missing": sorted_natural(set(CONTENT_TYPES) - {"sloka"}),
                        "group": "bak/chapters/asian",
                    },
                )

    return result


def scan_legacy_db_source(repo_root: Path) -> Dict[str, Any]:
    """
    Scans legacy/legacy_bhagavadgitabook_db CSV snapshot.
    We provide coarse coverage signals: languages, chapters count, types.
    """
    base = repo_root / "legacy" / "legacy_bhagavadgitabook_db" / "Books"
    result: Dict[str, Any] = {
        "source": "legacy_bhagavadgitabook_db",
        "languages": {},
        "notes": [],
        "paths": {
            "languages_csv": str(base / "db_languages.csv"),
            "books_csv": str(base / "db_books.csv"),
            "chapters_csv": str(base / "db_chapters.csv"),
            "slokas_csv": str(base / "Gita_Slokas.csv"),
            "vocab_csv": str(base / "Gita_Vocabularies.csv"),
            "quotes_csv": str(base / "db_quoutes.csv"),
        },
    }

    def ensure_lang(lang: str) -> Dict[str, Any]:
        langs = result["languages"]
        if lang not in langs:
            langs[lang] = {"chapters": {}}
        return langs[lang]

    lang_path = base / "db_languages.csv"
    if lang_path.exists():
        try:
            with lang_path.open("r", encoding="utf-8", newline="") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    code = (row.get("Code") or "").strip()
                    if code:
                        ensure_lang(code)
        except Exception as e:
            result["notes"].append({"type": "csv_parse_error", "path": str(lang_path), "error": str(e)})

    # We don't rely on chapter mapping by language; instead publish a generic 01..18 coverage for main tables
    has_slokas = (base / "Gita_Slokas.csv").exists()
    has_vocab = (base / "Gita_Vocabularies.csv").exists()
    has_quotes = (base / "db_quoutes.csv").exists()

    types_present = set()
    if has_slokas:
        types_present |= {"sloka", "translit", "audioRefs"}
    if has_vocab:
        types_present |= {"vocabulary"}
    if has_quotes:
        types_present |= {"quotes"}

    for lang in list(result["languages"].keys()) or ["ru", "en", "de", "spa"]:
        lang_obj = ensure_lang(lang)
        for chap in [f"{i:02d}" for i in range(1, 19)]:
            lang_obj["chapters"][chap] = {
                "present": sorted_natural(types_present),
                "missing": sorted_natural(set(CONTENT_TYPES) - types_present),
                "group": "legacy_db_csv",
            }

    return result


def compute_full_vs_partial(data_scan: Dict[str, Any]) -> Dict[str, str]:
    """
    Heuristic: language is 'full' if chapters 01..18 exist and each has at least sloka+translit+meta.
    'seed_ok' if it has at least meta and either sloka or translit for all chapters.
    else 'partial'.
    """
    policy: Dict[str, str] = {}
    langs = data_scan.get("languages", {})
    for lang, obj in langs.items():
        chapters: Dict[str, Any] = obj.get("chapters", {})
        expected = {f"{i:02d}" for i in range(1, 19)}
        if set(chapters.keys()) != expected:
            policy[lang] = "partial"
            continue
        # Determine presence
        ok_seed = True
        ok_full = True
        for chap in expected:
            present = set(chapters[chap].get("present", []))
            if "meta" not in present:
                ok_seed = False
            if not (("sloka" in present) or ("translit" in present)):
                ok_seed = False
            if not ({"sloka", "translit", "meta"} <= present):
                ok_full = False
        if ok_full:
            policy[lang] = "full"
        elif ok_seed:
            policy[lang] = "seed_ok"
        else:
            policy[lang] = "partial"
    return policy


def render_markdown(report: Dict[str, Any]) -> str:
    lines: List[str] = []
    lines.append("# Content Coverage Matrix")
    lines.append("")
    lines.append(f"- Generated: `{report['generatedAt']}`")
    lines.append(f"- Repo root: `{report['repoRoot']}`")
    lines.append("")

    lines.append("## Sources")
    lines.append("")
    for src in report["sources"]:
        lines.append(f"- `{src}`")
    lines.append("")

    lines.append("## V1 Language Policy (heuristic)")
    lines.append("")
    policy: Dict[str, str] = report.get("v1LanguagePolicy", {})
    for lang in sorted_natural(policy.keys()):
        lines.append(f"- **{lang}**: {policy[lang]}")
    lines.append("")

    def summarize_source(src_key: str):
        src = report["data"][src_key]
        lines.append(f"## Source: `{src_key}`")
        lines.append("")
        langs = src.get("languages", {})
        lines.append(f"- Languages: {', '.join(sorted_natural(langs.keys())) if langs else '(none)'}")
        lines.append("")
        # Compact per-language summary: chapter count and type coverage counts
        lines.append("| Language | Chapters | Notes |")
        lines.append("|----------|----------|-------|")
        for lang in sorted_natural(langs.keys()):
            chapters = langs[lang].get("chapters", {})
            chap_count = len(chapters)
            # count full coverage types across chapters (intersection)
            common: Optional[Set[str]] = None
            for cell in chapters.values():
                present = set(cell.get("present", []))
                common = present if common is None else (common & present)
            common = common or set()
            notes = f"common: {', '.join(sorted_natural(common))}" if common else ""
            lines.append(f"| `{lang}` | {chap_count} | {notes} |")
        lines.append("")

    for src_key in report["sources"]:
        summarize_source(src_key)

    lines.append("## Notes")
    lines.append("")
    notes_any = False
    for src_key in report["sources"]:
        notes = report["data"][src_key].get("notes", [])
        if notes:
            notes_any = True
            lines.append(f"### `{src_key}`")
            for n in notes:
                lines.append(f"- `{n.get('type','note')}`: {n}")
            lines.append("")
    if not notes_any:
        lines.append("- (none)")
        lines.append("")

    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Build content coverage matrix across data/bak/legacy_db.")
    parser.add_argument("--repo-root", default=".", help="Path to repository root")
    parser.add_argument(
        "--out-json",
        default="flows/sdd-bhagavadgita-book-flutter-refactoring/artifacts/content-matrix.json",
        help="Output JSON report path (relative to repo root)",
    )
    parser.add_argument(
        "--out-md",
        default="flows/sdd-bhagavadgita-book-flutter-refactoring/artifacts/content-matrix.md",
        help="Output Markdown report path (relative to repo root)",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    data_scan = scan_data_source(repo_root)
    bak_scan = scan_bak_source(repo_root)
    legacy_scan = scan_legacy_db_source(repo_root)

    report: Dict[str, Any] = {
        "generatedAt": utc_now_iso(),
        "repoRoot": str(repo_root),
        "sources": ["data", "bak", "legacy_bhagavadgitabook_db"],
        "contentTypes": CONTENT_TYPES,
        "v1LanguagePolicy": compute_full_vs_partial(data_scan),
        "data": {
            "data": data_scan,
            "bak": bak_scan,
            "legacy_bhagavadgitabook_db": legacy_scan,
        },
    }

    out_json = (repo_root / args.out_json).resolve()
    out_md = (repo_root / args.out_md).resolve()
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_md.parent.mkdir(parents=True, exist_ok=True)

    out_json.write_text(json.dumps(report, ensure_ascii=False, indent=2, sort_keys=False) + "\n", encoding="utf-8")
    out_md.write_text(render_markdown(report) + "\n", encoding="utf-8")

    print(f"Wrote JSON: {out_json}")
    print(f"Wrote MD:   {out_md}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
