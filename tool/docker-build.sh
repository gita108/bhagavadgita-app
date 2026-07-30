#!/usr/bin/env bash
# tool/docker-build.sh <flutter|native> [command...]
#
# Builds and runs the matching Android Docker image locally, mirroring exactly what
# .github/workflows/docker-build.yml runs in CI. Without a trailing command, runs the default
# verification sequence for that target. With one, replaces it (e.g. `bash` for interactive debugging).
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but not found on PATH" >&2
  exit 1
fi

TARGET="${1:-}"
shift || true

case "$TARGET" in
  flutter)
    DOCKERFILE="docker/android-flutter-build.Dockerfile"
    IMAGE="bgita-flutter-build:local"
    DEFAULT_CMD="flutter pub get && flutter build apk --release"
    ;;
  native)
    DOCKERFILE="docker/android-native-build.Dockerfile"
    IMAGE="bgita-native-build:local"
    DEFAULT_CMD="gradle --init-script docker/android-native-jcenter-init.gradle -p native/android assembleDebug"
    ;;
  *)
    echo "usage: $0 <flutter|native> [command...]" >&2
    exit 1
    ;;
esac

docker build --platform linux/amd64 -f "$DOCKERFILE" -t "$IMAGE" .

CMD=("$@")
if [ ${#CMD[@]} -eq 0 ]; then
  CMD=(bash -c "$DEFAULT_CMD")
fi

USER_FLAGS=()
if [ -z "${CI:-}" ]; then
  USER_FLAGS=(--user "$(id -u):$(id -g)")
fi

docker run --rm --platform linux/amd64 \
  -v "$(pwd):/workspace" -w /workspace \
  --env HOME=/tmp \
  "${USER_FLAGS[@]}" \
  "$IMAGE" "${CMD[@]}"
