# syntax=docker/dockerfile:1
FROM wordpressmobile/android-build-image:latest

ENV GRADLE_HOME=/root/.gradle
ENV GRADLE_RO_DEP_CACHE=/root/.gradle_ro_dep_cache

RUN git clone https://github.com/wordpress-mobile/WordPress-Android.git /var/wordpress-android --depth 1 \
    && pushd /var/wordpress-android \
    && git submodule update --init --recursive \
    && cp gradle.properties-example gradle.properties \
    && ./gradlew assembleWordPressVanillaDebug -Porg.gradle.jvmargs=-Xmx6g \
    && popd \
    && rm -rf /var/wordpress-android

# Move Gradle's global dependency cache to $GRADLE_RO_DEP_CACHE for efficiency
# https://docs.gradle.org/current/userguide/dependency_resolution.html#sub:cache_copy
RUN mkdir -p $GRADLE_RO_DEP_CACHE/caches/modules-2
RUN mv $GRADLE_HOME/caches/modules-2 $GRADLE_RO_DEP_CACHE/caches/
RUN find $GRADLE_RO_DEP_CACHE/ -name '*.lock' -delete
RUN find $GRADLE_RO_DEP_CACHE/ -name 'gc.properties' -delete

# Remove Gradle build and dependency cache
# For dependency cache, we have setup a read only variant
# For build cache, we utilize remote build caching
RUN rm -rf $GRADLE_HOME/caches/build-cache-1
RUN rm -rf $GRADLE_HOME/caches/modules-2
