# syntax=docker/dockerfile:1
FROM wordpressmobile/android-build-image:latest

RUN git clone https://github.com/wordpress-mobile/WordPress-Android.git /var/wordpress-android --depth 1 \
    && pushd /var/wordpress-android \
    && git submodule update --init --recursive \
    && cp gradle.properties-example gradle.properties \
    && ./gradlew \
    && popd \
    && rm -rf /var/wordpress-android
