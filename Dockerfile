# syntax=docker/dockerfile:1
FROM gradle:8.2.1-jdk17

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Increase the file watcher limit for node. This should not be necessary for CI builds since watchers should be disabled, but it can be useful when running this image in a local environment. 
RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf

# Install system commands, Android SDK, and Ruby
RUN apt-get update  \
    && apt-get install -y coreutils git wget locales \
    && apt-get install -y curl git php-cli php-mbstring  \
    && apt-get -y autoclean

# Set up the default locale
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en"
ENV ANDROID_HOME=/usr/lib/android-sdk
ENV GRADLE_OPTS="-Xmx6G -XX:+HeapDumpOnOutOfMemoryError -Dorg.gradle.caching=true -Dorg.gradle.configureondemand=true -Dkotlin.compiler.execution.strategy=in-process -Dkotlin.incremental=false"

# Download the SDK Manager
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
	&& unzip commandlinetools-linux-11076708_latest.zip && rm commandlinetools-linux-11076708_latest.zip \
	&& mkdir -p /usr/lib/android-sdk/cmdline-tools \
	&& mv cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest

ENV PATH="//usr/lib/android-sdk/cmdline-tools/latest/bin:${PATH}"

RUN yes | sdkmanager --licenses

# Uninstall '29.0.3' so that the builds won't complain about it being installed in incorrect location
RUN sdkmanager --uninstall "build-tools;29.0.3"

RUN sdkmanager --install \
  "build-tools;33.0.2" \
  "build-tools;34.0.0" \
  "platform-tools" \
  "platforms;android-33" \
  "platforms;android-34"

RUN mkdir scripts
COPY scripts/ scripts/
ENV PATH="/scripts/:${PATH}"

SHELL ["/bin/bash", "--login", "-c"]
ENV NODE_VERSION v20.11.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && source "$HOME/.nvm/nvm.sh" \
    && nvm install $NODE_VERSION
ENV PATH="//root/.nvm/versions/node/$NODE_VERSION/bin:${PATH}"

RUN which npm
