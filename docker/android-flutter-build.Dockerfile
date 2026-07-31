# Build image for the Flutter-embedded Android variant (android/), modern toolchain.
# Matches the pattern established in flows/sdd-vpnclient-design-prototype-build's
# android-build.Dockerfile — no NDK (pure Dart, no native-compiled plugins requiring it).

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        git \
        unzip \
        xz-utils \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Java 17 (Temurin) — matches actions/setup-java's `distribution: temurin` in build.yml/release.yml.
RUN curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/trusted.gpg.d/adoptium.asc \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/VERSION_CODENAME/{print $2}' /etc/os-release) main" \
        > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update && apt-get install -y --no-install-recommends temurin-17-jdk \
    && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Flutter 3.44.6 — same version pinned across build.yml/release.yml/docker-build.yml.
ENV FLUTTER_VERSION=3.44.6
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        -o /tmp/flutter.tar.xz \
    && tar -xJf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:${PATH}"
# --system (not --global): the image is built as root, but `docker run` uses --user <host uid> with
# HOME=/tmp — a different user/HOME than build time, so a --global (per-user) config wouldn't be
# read at runtime. --system writes /etc/gitconfig, read regardless of the active user. Wildcard (not
# just /opt/flutter) since /workspace is also bind-mounted at `docker run` time with host ownership,
# which trips the same git "dubious ownership" safety check.
RUN git config --system --add safe.directory '*' \
    && flutter config --no-analytics && flutter precache --android

# Android SDK — Flutter's own Gradle plugin resolves the exact compileSdk/build-tools versions it
# needs on first `flutter pub get`/build; this just provides the base SDK + licenses.
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"
RUN yes | sdkmanager --licenses > /dev/null && sdkmanager "platform-tools"

WORKDIR /workspace
