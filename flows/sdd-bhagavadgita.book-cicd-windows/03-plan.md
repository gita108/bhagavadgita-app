# Implementation Plan: bhagavadgita.book CI/CD (Windows build + portable)

> Version: 1.0  
> Status: DRAFT  
> Last Updated: 2026-04-30  
> Specifications: `flows/sdd-bhagavadgita.book-cicd-windows/02-specifications.md`

## Summary

Добавить Windows job в существующий workflow сборки артефактов, который собирает Windows release и публикует **portable zip**.

## Task Breakdown

### Task 1: Create SDD flow docs (this directory)
- **Files**:
  - `flows/sdd-bhagavadgita.book-cicd-windows/_status.md`
  - `flows/sdd-bhagavadgita.book-cicd-windows/01-requirements.md`
  - `flows/sdd-bhagavadgita.book-cicd-windows/02-specifications.md`
  - `flows/sdd-bhagavadgita.book-cicd-windows/03-plan.md`
  - `flows/sdd-bhagavadgita.book-cicd-windows/04-implementation-log.md`
- **Verification**: все файлы присутствуют, ссылки корректны

### Task 2: Index flow in `CLAUDE.md`
- **Files**: `CLAUDE.md`
- **Verification**: в таблице SDD flows есть строка `sdd-bhagavadgita.book-cicd-windows`

### Task 3: Implement `build-windows` job in GitHub Actions
- **Files**: `.github/workflows/build-artifacts.yml`
- **Implementation notes**:
  - Use `windows-latest`
  - Set `working-directory` to `${{ env.APP_DIR }}`
  - Package `build/windows/x64/runner/Release` into zip via PowerShell `Compress-Archive`
- **Verification**:
  - YAML valid
  - Artifact uploaded in workflow run

### Task 4: Smoke-check paths and outputs
- **Verification**:
  - Ensure zip contains `*.exe`, `flutter_windows.dll`, `data/`
  - Ensure artifact naming matches `${{ github.ref_name }}`

## Rollback Strategy

1. Remove `build-windows` job from `.github/workflows/build-artifacts.yml`
2. Optionally keep SDD docs (no runtime impact)

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]

