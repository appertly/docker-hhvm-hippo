FROM appertly/hhvm:latest
MAINTAINER Jonathan Hawk <jonathan@appertly.com>

# Install and build hippo extension
RUN mkdir /tmp/builds \
    && buildDeps="git-core libtool make wget hhvm-dev=$HHVM_VERSION libdouble-conversion-dev liblz4-dev" \
    && set -x \
    && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
    && git clone https://github.com/mongodb/mongo-hhvm-driver.git /tmp/builds/hippo \
    && cd /tmp/builds/hippo \
    && git submodule update --init --recursive \
    && hphpize \
    && cmake . \
    && make configlib \
    && make -j $(nproc --all) \
    && make install \
    && cd / && rm -rf /tmp/builds \
    && apt-get purge -y --auto-remove $buildDeps libgd2-xpm-dev \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/apt/* \
    && rm -rf /var/log/dpkg.log \
    && rm -rf /var/log/bootstrap.log \
    && rm -rf /var/log/alternatives.log

RUN echo "hhvm.dynamic_extension_path = /usr/lib/x86_64-linux-gnu/hhvm/extensions/20150212" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extensions[mongodb] = mongodb.so" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extension_path = /usr/lib/x86_64-linux-gnu/hhvm/extensions/20150212" >> /etc/hhvm/php.ini \
    && echo "hhvm.dynamic_extensions[mongodb] = mongodb.so" >> /etc/hhvm/php.ini
