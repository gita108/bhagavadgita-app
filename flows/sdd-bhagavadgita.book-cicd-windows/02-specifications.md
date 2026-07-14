# Specifications: bhagavadgita.book CI/CD (Windows build + portable)

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-30  
> Requirements: `flows/sdd-bhagavadgita.book-cicd-windows/01-requirements.md`

## Overview

Добавляем Windows job в GitHub Actions, который:

- Запускается на `windows-latest`.
- Собирает Windows desktop release: `flutter build windows --release`.
- Упаковывает release bundle в **portable zip**.
- Загружает zip в artifacts workflow run’а.

## Affected Systems

| System | Impact | Notes |
|--------|--------|------|
| `.github/workflows/build-artifacts.yml` | Modify | Add `build-windows` job |
| `flows/sdd-bhagavadgita.book-cicd-windows/*` | Create | Traceability for this change |
| `CLAUDE.md` | Modify | Add active SDD flow row |

## Workflow / Job Specification

### Triggers

Reuse existing workflow triggers:

- `workflow_dispatch`
- `push` to tags `v*`

### Steps (Windows)

1. Checkout repo
2. Set up Flutter (`subosito/flutter-action@v2`)
3. Enable Windows desktop (`flutter config --enable-windows-desktop`) — idempotent
4. `flutter pub get`
5. `flutter analyze`
6. `flutter test`
7. `flutter build windows --release`
8. Create portable zip from:
   - `app/bhagavadgita.book/build/windows/x64/runner/Release/`
9. Upload artifact:
   - name: `windows-portable-${ref_name}`
   - path: generated zip

### Portable zip content

Zip root must contain:

- `bhagavadgita_book.exe`
- `flutter_windows.dll`
- `data/` (contains `flutter_assets`, icudtl, etc.)
- any plugin DLLs emitted next to exe (as built by Flutter)

## Behavior Specifications

### Happy path

Tag push `vX.Y.Z` creates a downloadable portable artifact that runs when unzipped.

### Failure modes

| Failure | Cause | Expected behavior |
|--------|-------|-------------------|
| Build fails | missing Windows dependencies | job fails with build logs |
| Packaging fails | build output path changed | job fails with clear step error |

## Testing Strategy

- Run `flutter analyze` and `flutter test` before packaging.
- No UI/integration tests in this iteration.

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]

