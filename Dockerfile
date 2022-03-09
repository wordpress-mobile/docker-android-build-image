# syntax=docker/dockerfile:1
FROM debian:stable

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Increase the file watcher limit for node. This should not be necessary for CI builds since watchers should be disabled, but it can be useful when running this image in a local environment. 
RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf

# Install system commands, Android SDK, and Ruby
RUN apt-get update  \
    && apt-get install -y coreutils git wget locales android-sdk android-sdk-build-tools \
    && apt-get install -y curl git php-cli php-mbstring  \
    && apt-get -y autoclean

# Set up the default locale
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en"
ENV ANDROID_HOME=/usr/lib/android-sdk
ENV GRADLE_OPTS="-Xmx6G -XX:+HeapDumpOnOutOfMemoryError -Dorg.gradle.caching=true -Dorg.gradle.configureondemand=true -Dkotlin.compiler.execution.strategy=in-process -Dkotlin.incremental=false"

# Download the SDK Manager
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip \
	&& unzip commandlinetools-linux-6858069_latest.zip && rm commandlinetools-linux-6858069_latest.zip \
	&& mkdir /usr/lib/android-sdk/cmdline-tools \
	&& mv cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest

ENV PATH="//usr/lib/android-sdk/cmdline-tools/latest/bin:${PATH}"

RUN sdkmanager "platforms;android-30" "system-images;android-30;google_apis_playstore;x86_64" "build-tools;30.0.0"

RUN yes | sdkmanager --licenses

RUN mkdir scripts
COPY scripts/ scripts/
ENV PATH="/scripts/:${PATH}"

# Cache Gradle 7.4
RUN mkdir gradle-cache-tmp \
        && cd gradle-cache-tmp \
        && wget https://services.gradle.org/distributions/gradle-7.4-bin.zip \
        && unzip gradle-7.4-bin.zip \
        && touch settings.gradle \
        && gradle-7.4/bin/gradle wrapper --gradle-version 7.4 --distribution-type all \
        && ./gradlew \
        && cd .. \
        && rm -rf ./gradle-cache-tmp

SHELL ["/bin/bash", "--login", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN nvm install lts/*
