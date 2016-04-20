FROM appertly/hhvm:latest
MAINTAINER Jonathan Hawk <jonathan@appertly.com>

# Install and build hippo extension
RUN mkdir /tmp/builds \
    && buildDeps="git-core libtool make wget hhvm-dev=$HHVM_VERSION" \
    && set -x \
    && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
    && wget https://raw.githubusercontent.com/derickr/hhvm/09f4546c3859c4bccf746ca8ec6c3b80e7d2fbf7/CMake/HPHPIZEFunctions.cmake -O /usr/lib/x86_64-linux-gnu/hhvm/CMake/HPHPIZEFunctions.cmake \
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
    && make configlib \
    && make \
    && mkdir -p /usr/lib/hhvm/extensions \
    && cp /tmp/builds/hippo/mongodb.so /usr/lib/hhvm/extensions/mongodb.so \
    && cd / && rm -rf /tmp/builds \
    && apt-get purge -y --auto-remove $buildDeps libgd2-xpm-dev \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/apt/* \
    && rm -rf /var/log/dpkg.log \
    && rm -rf /var/log/bootstrap.log \
    && rm -rf /var/log/alternatives.log

RUN echo "hhvm.dynamic_extension_path = /usr/lib/hhvm/extensions" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extensions[mongodb] = mongodb.so" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extension_path = /usr/lib/hhvm/extensions" >> /etc/hhvm/php.ini \
    && echo "hhvm.dynamic_extensions[mongodb] = mongodb.so" >> /etc/hhvm/php.ini
