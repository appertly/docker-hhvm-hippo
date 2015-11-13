FROM appertly/hhvm:3.10.1
MAINTAINER Jonathan Hawk <jonathan@appertly.com>

ENV HHVM_DEV_VERSION 3.10.1~jessie

# Install and build hippo extension
RUN mkdir /tmp/builds \
    && buildDeps="git-core libtool make hhvm-dev=$HHVM_DEV_VERSION" \
    && set -x \
    && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
    && git clone https://github.com/mongodb/mongo-hhvm-driver.git /tmp/builds/hippo \
    && cd /tmp/builds/hippo \
    && git submodule update --init \
    && cd libbson \
    && ./autogen.sh \
    && cd .. \
    && cd libmongoc \
    && ./autogen.sh \
    && cd .. \
    && hphpize \
    && cmake . \
    && make \
    && mkdir -p /usr/lib/hhvm/extensions \
    && cp /tmp/builds/hippo/mongodb.so /usr/lib/hhvm/extensions/mongodb.so \
    && cd / && rm -rf /tmp/builds \
    && apt-get purge -y --auto-remove $buildDeps libgd2-xpm-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN echo "hhvm.dynamic_extension_path = /usr/lib/hhvm/extensions" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extensions[mongodb] = mongodb.so" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extension_path = /usr/lib/hhvm/extensions" >> /etc/hhvm/php.ini \
    && echo "hhvm.dynamic_extensions[mongodb] = mongodb.so" >> /etc/hhvm/php.ini
