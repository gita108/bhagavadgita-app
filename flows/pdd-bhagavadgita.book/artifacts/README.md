# PDD artifacts — Bhagavad Gita Book

## Canonical codebase (product)

| Path | Role |
|------|------|
| `app/bhagavadgita.book/` | **Single Flutter app** — iOS, Android, desktop, web from one Dart codebase |

## Legacy archive (parity reference only)

| Tree | Role |
|------|------|
| `legacy/legacy_bhagavadgita.book_swift/` | Historical **iOS** UIKit app — use only to verify behavior/API edge cases when migrating |
| `legacy/legacy_bhagavadgita.book_java/` | Historical **Android** Java app — same |

**No new features** are implemented in Swift/Java; they are **not** store submission targets once Flutter reaches parity.

Place IA / user-flow diagrams for the **Flutter** app under this folder and link from `03-product-ux-specification.md`.
