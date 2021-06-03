# syntax=docker/dockerfile:1
FROM debian:latest

# Set up the default locale
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV ANDROID_HOME=/usr/lib/android-sdk

# Install system commands, Android SDK, and Ruby
RUN apt update && apt install -y coreutils git wget nano locales android-sdk android-sdk-build-tools rbenv ruby-dev

# Set up a base ruby and install bundler
RUN mkdir -p "$(rbenv root)"/plugins \
	&& git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build \
	&& rbenv install 2.6.4 && rbenv global 2.6.4

# Download the SDK Manager
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip \
	&& unzip commandlinetools-linux-6858069_latest.zip && rm commandlinetools-linux-6858069_latest.zip \
	&& mkdir /usr/lib/android-sdk/cmdline-tools \
	&& mv cmdline-tools /usr/lib/android-sdk/cmdline-tools/latest

# Set the full $PATH
ENV PATH="/root/.rbenv/shims:/usr/lib/android-sdk/cmdline-tools/latest/bin:$HOME/.rbenv/bin:${PATH}"

# Install bundler after setting the $PATH in order to ensure it's installed as part of the rbenv-managed ruby version
RUN gem install bundler

#################################
#                               #
#    Install SDKs we support    #
#                               #
#################################

RUN sdkmanager "platforms;android-30" "system-images;android-30;google_apis_playstore;x86_64" "build-tools;30.0.0"

RUN yes | sdkmanager --licenses
