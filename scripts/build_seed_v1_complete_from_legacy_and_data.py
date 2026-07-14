#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Optional, Tuple


def utc_now_iso_compact() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace(":", "").replace("-", "")


def read_text(path: Path) -> str:
    # Keep internal newlines as-is; only strip trailing/leading whitespace.
    return path.read_text(encoding="utf-8").strip()


def legacy_null(v: Optional[str]) -> Optional[str]:
    if v is None:
        return None
    v = v.strip()
    if not v or v.upper() == "NULL":
        return None
    return v


@dataclass(frozen=True)
class LegacySlokaRow:
    sloka_text: Optional[str]
    transcription: Optional[str]
    translation: Optional[str]
    comment: Optional[str]
    audio: Optional[str]
    audio_sanskrit: Optional[str]


def parse_chapter_num_from_sloka_name(sloka_name: str) -> int:
    # sloka_name examples: "1.1", "1.4-6", "13.7"
    m = re.match(r"^(\d+)\.", sloka_name)
    if not m:
        raise ValueError(f"Unexpected sloka name format: {sloka_name!r}")
    return int(m.group(1))


def resolve_data_language_code(seed_language_code: str) -> str:
    # Legacy seed uses "spa", but data/original uses "es".
    return {"spa": "es"}.get(seed_language_code, seed_language_code)


def normalize_sloka_name_for_data(sloka_name: str) -> str:
    """
    data/sanskrit и data/original используют более компактное имя для диапазонов:
    пример: seed может содержать "1.4-1.6", а файл в data называется "1.4-6".
    """
    m = re.match(r"^(\d+)\.(\d+)-\1\.(\d+)$", sloka_name)
    if not m:
        return sloka_name
    chap = m.group(1)
    a = m.group(2)
    b = m.group(3)
    return f"{chap}.{a}-{b}"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", default=".", help="Repo root (default: current dir)")
    parser.add_argument(
        "--seed-json",
        default="app/bhagavadgita.book/assets/seed/seed_v1_minimal.json",
        help="Seed JSON to update (default: seed_v1_minimal.json)",
    )
    parser.add_argument("--dry-run", action="store_true", help="Do not write output")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    seed_path = (repo_root / args.seed_json).resolve()

    data_sanskrit_root = repo_root / "data" / "sanskrit"
    data_original_root = repo_root / "data" / "original"

    legacy_root = repo_root / "legacy" / "legacy_bhagavadgita.book_db" / "Books"
    legacy_slokas_csv = legacy_root / "Gita_Slokas.csv"

    print(f"Reading seed: {seed_path}")
    seed = json.loads(seed_path.read_text(encoding="utf-8"))

    slokas = seed["slokas"]
    chapters = seed["chapters"]
    books = seed["books"]
    languages = seed["languages"]

    chapters_by_id = {c["id"]: c for c in chapters}
    books_by_id = {b["id"]: b for b in books}
    languages_by_id = {l["id"]: l for l in languages}

    # Legacy coverage provides audio/comment/audioSanskrit when available.
    print(f"Reading legacy slokas CSV: {legacy_slokas_csv}")
    legacy_slokas: Dict[int, LegacySlokaRow] = {}
    with legacy_slokas_csv.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f, delimiter=";")
        def get_field(row: Dict[str, Optional[str]], logical_name: str) -> Optional[str]:
            # Some CSV exports may contain a UTF-8 BOM on the first header field.
            for k, v in row.items():
                if k is None:
                    continue
                if k.lstrip("\ufeff") == logical_name:
                    return v
            return None

        for row in reader:
            sloka_id_raw = get_field(row, "Id")
            if sloka_id_raw is None:
                raise KeyError(
                    f"Legacy CSV header does not contain 'Id' (after stripping BOM). Found keys: {list(row.keys())[:20]}"
                )
            sloka_id = int(sloka_id_raw)
            legacy_slokas[sloka_id] = LegacySlokaRow(
                sloka_text=legacy_null(get_field(row, "Text")),
                transcription=legacy_null(get_field(row, "Transcription")),
                translation=legacy_null(get_field(row, "Translation")),
                comment=legacy_null(get_field(row, "Comment")),
                audio=legacy_null(get_field(row, "Audio")),
                audio_sanskrit=legacy_null(get_field(row, "AudioSanskrit")),
            )

    # Caches for data file reads.
    sanskrit_cache: Dict[str, str] = {}
    translit_cache: Dict[Tuple[str, str], str] = {}
    translation_cache: Dict[Tuple[str, str], str] = {}
    comment_cache: Dict[Tuple[str, str], str] = {}

    def data_sanskrit_path(sloka_name: str) -> Path:
        data_sloka_name = normalize_sloka_name_for_data(sloka_name)
        chap_num = parse_chapter_num_from_sloka_name(sloka_name)
        chap_dir = f"chapter-{chap_num:02d}-sanskrit"
        file_name = f"chapter-{chap_num:02d}-{data_sloka_name}-sanskrit_sloka.txt"
        return data_sanskrit_root / chap_dir / file_name

    def data_original_paths(seed_lang_code: str, sloka_name: str) -> Tuple[Path, Path, Path]:
        data_lang_code = resolve_data_language_code(seed_lang_code)
        data_sloka_name = normalize_sloka_name_for_data(sloka_name)
        chap_num = parse_chapter_num_from_sloka_name(sloka_name)
        chap_dir = f"chapter-{chap_num:02d}-{data_lang_code}"
        base = data_original_root / data_lang_code / chap_dir
        # Note: filenames repeat chap_num prefix and use the full sloka_name, e.g. chapter-04-4.1-...
        translit = base / f"chapter-{chap_num:02d}-{data_sloka_name}-{data_lang_code}_translit.txt"
        sloka = base / f"chapter-{chap_num:02d}-{data_sloka_name}-{data_lang_code}_sloka.txt"
        comment = base / f"chapter-{chap_num:02d}-{data_sloka_name}-{data_lang_code}_comment.txt"
        return translit, sloka, comment

    # Update slokas in-place.
    changed = 0
    missing_slokas_text_after = 0
    missing_comment_after = 0

    for s in slokas:
        sloka_id = int(s["id"])
        sloka_name = s["name"]
        chap_id = int(s["chapterId"])
        book_id = int(chapters_by_id[chap_id]["bookId"])
        lang_id = int(books_by_id[book_id]["languageId"])
        lang_code = languages_by_id[lang_id]["code"]

        legacy = legacy_slokas.get(sloka_id)

        if s.get("slokaText") is None:
            # Prefer legacy text if present; else read from data/sanskrit.
            new_val = legacy.sloka_text if legacy else None
            if new_val is None:
                cache_key = sloka_name
                if cache_key in sanskrit_cache:
                    new_val = sanskrit_cache[cache_key]
                else:
                    path = data_sanskrit_path(sloka_name)
                    if path.exists():
                        new_val = read_text(path)
                        sanskrit_cache[cache_key] = new_val
                    else:
                        new_val = None
            if new_val is not None:
                s["slokaText"] = new_val
                changed += 1

        if s.get("comment") is None:
            # Prefer legacy comment if present; else read from data/original/*_comment.txt.
            new_val = legacy.comment if legacy else None
            if new_val is None:
                cache_key = (lang_code, sloka_name)
                if cache_key in comment_cache:
                    new_val = comment_cache[cache_key]
                else:
                    _, _, comment_path = data_original_paths(lang_code, sloka_name)
                    if comment_path.exists():
                        new_val = read_text(comment_path)
                        comment_cache[cache_key] = new_val
            if new_val is not None:
                s["comment"] = new_val
                changed += 1

        if s.get("transcription") is None:
            new_val = legacy.transcription if legacy else None
            if new_val is None:
                cache_key = (lang_code, sloka_name)
                if cache_key in translit_cache:
                    new_val = translit_cache[cache_key]
                else:
                    translit_path, _, _ = data_original_paths(lang_code, sloka_name)
                    if translit_path.exists():
                        new_val = read_text(translit_path)
                        translit_cache[cache_key] = new_val
            if new_val is not None:
                s["transcription"] = new_val
                changed += 1

        if s.get("translation") is None:
            new_val = legacy.translation if legacy else None
            if new_val is None:
                cache_key = (lang_code, sloka_name)
                if cache_key in translation_cache:
                    new_val = translation_cache[cache_key]
                else:
                    _, sloka_path, _ = data_original_paths(lang_code, sloka_name)
                    if sloka_path.exists():
                        new_val = read_text(sloka_path)
                        translation_cache[cache_key] = new_val
            if new_val is not None:
                s["translation"] = new_val
                changed += 1

        # audio fields: only fill from legacy if missing (data has no audio assets).
        if s.get("audio") is None and legacy and legacy.audio is not None:
            s["audio"] = legacy.audio
            changed += 1
        if s.get("audioSanskrit") is None and legacy and legacy.audio_sanskrit is not None:
            s["audioSanskrit"] = legacy.audio_sanskrit
            changed += 1

    # Post-check coverage counts.
    for s in slokas:
        if s.get("slokaText") is None:
            missing_slokas_text_after += 1
        if s.get("comment") is None:
            missing_comment_after += 1

    print(f"Updated fields (approx): {changed}")
    print(f"Missing slokaText after: {missing_slokas_text_after}/{len(slokas)}")
    print(f"Missing comment after: {missing_comment_after}/{len(slokas)}")

    seed["contentHash"] = f"legacy-db+data-full-{utc_now_iso_compact()}"

    if args.dry_run:
        print("Dry-run: not writing output.")
        return

    print(f"Writing updated seed: {seed_path}")
    seed_path.write_text(
        json.dumps(seed, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()

