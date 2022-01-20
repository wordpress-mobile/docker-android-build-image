# syntax=docker/dockerfile:1
FROM debian:stable

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install system commands, Android SDK, and Ruby
RUN apt-get update  \
    && apt-get install -y coreutils git wget locales android-sdk android-sdk-build-tools bzip2 \
	&& apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev \
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

# Install Ruby (for release tooling)
# Install rbenv
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv
RUN echo '# rbenv setup' > /etc/profile.d/rbenv.sh
RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN chmod +x /etc/profile.d/rbenv.sh

# Install ruby-build
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:${PATH}"

# Install Ruby 2.7.4
RUN rbenv install 2.7.4 \
	&& rbenv global 2.7.4
