# syntax=docker/dockerfile:1
FROM wordpressmobile/android-build-image:latest

RUN mkdir -p /root/gradle/.gradle_ro_dep_cache/caches/modules-2
ENV GRADLE_RO_DEP_CACHE=/root/.gradle_ro_dep_cache

RUN git clone https://github.com/wordpress-mobile/WordPress-Android.git /var/wordpress-android --depth 1 \
    && pushd /var/wordpress-android \
    && git submodule update --init --recursive \
    && cp gradle.properties-example gradle.properties \
    && ./gradlew assembleWordPressVanillaDebug \
    && popd \
    && rm -rf /var/wordpress-android

RUN mv /root/.gradle/caches/modules-2 $GRADLE_RO_DEP_CACHE/caches/modules-2
RUN rm $GRADLE_RO_DEP_CACHE/caches/modules-2/*.lock $GRADLE_RO_DEP_CACHE/caches/modules-2/gc.properties || true
RUN rm -rf /root.gradle/caches/modules-2
