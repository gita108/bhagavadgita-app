# Build image for native/android — the legacy Java/Gradle app copied verbatim from
# legacy/bhagavadgita-mobile-java-v2012 (AGP 3.0.1, compileSdkVersion 26, buildToolsVersion 26.0.2).
# Pins a period-correct toolchain (JDK 8, Gradle 4.4) instead of modifying the project's own
# build.gradle files. See docker/android-native-jcenter-init.gradle for the JCenter-mirror +
# signingConfig injection that also avoids touching native/android/ directly.
#
# Two JDKs are installed: JDK 17 is needed only to *run* `sdkmanager` itself (modern cmdline-tools
# packages are compiled for Java 17+ and fail with `UnsupportedClassVersionError` under JDK 8 —
# confirmed empirically). JDK 8 is what the actual Gradle/AGP 3.0.1 build runs under, matching the
# JDK level this project was originally written for; it's the JAVA_HOME left active for `docker run`.
#
# Known risk (accepted, see flows/sdd-bhagavadgita-app-build/01-requirements.md Decision #9):
# JCenter/Bintray has been fully shut down since 2021. The mirror used here may not carry every
# old dependency native/android references. This Dockerfile builds; whether `gradle assembleDebug`
# inside it fully succeeds is verified separately (see 03-plan.md Task 2.3's Verification step).

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Installed as two separate transactions — installing both JDKs in one `apt-get install` hits a
# dpkg postinst ordering conflict on Ubuntu 20.04 (openjdk-17-jdk-headless's dependency on
# openjdk-17-jre-headless isn't configured yet when interleaved with JDK 8's own postinst hooks),
# confirmed empirically.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        unzip \
        ca-certificates \
    && apt-get install -y --no-install-recommends openjdk-8-jdk-headless \
    && apt-get install -y --no-install-recommends openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Gradle 4.4 — documented minimum-compatible range for Android Gradle Plugin 3.0.1, itself
# compatible with JDK 8.
ENV GRADLE_VERSION=4.4
RUN curl -fsSL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o /tmp/gradle.zip \
    && unzip -q /tmp/gradle.zip -d /opt \
    && rm /tmp/gradle.zip
ENV PATH="/opt/gradle-${GRADLE_VERSION}/bin:${PATH}"

# Android SDK — pinned to exactly what native/android/app/build.gradle declares
# (compileSdkVersion 26, buildToolsVersion "26.0.2"), not `latest`.
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

RUN JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 bash -c '\
        yes | sdkmanager --licenses > /dev/null && \
        sdkmanager "platform-tools" "platforms;android-26" "build-tools;26.0.2"'

# Active JAVA_HOME for `docker run` — JDK 8, matching this project's era (AGP 3.0.1 / Gradle 4.4).
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /workspace
