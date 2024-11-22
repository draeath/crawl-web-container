FROM docker.io/library/debian:stable as BASE

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get dist-upgrade -y && apt-get autoremove -y \
 && apt-get install --no-install-recommends -y locales \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && echo "LANG=en_US.UTF-8" >> /etc/default/locale \
 && locale-gen
ENV LANG en_US.UTF-8
ENV LC_ALL C.utf8

FROM BASE as BUILD
RUN apt-get install --no-install-recommends -y advancecomp bison ca-certificates flex fonts-dejavu gcc g++ git libfreetype6-dev liblua5.1-0-dev libncursesw5-dev libpcre2-dev libpng-dev libsqlite3-dev make patch perl-base pkg-config python3-minimal python3-yaml zlib1g-dev
ARG GIT_URL="https://github.com/crawl/crawl.git"
ARG GIT_BRANCH="master"
ARG GIT_REF="HEAD"
RUN git clone -b ${GIT_BRANCH} ${GIT_URL} /opt/crawl
WORKDIR /opt/crawl/crawl-ref/source
RUN git checkout ${GIT_REF}
RUN make -j$(nproc) LTO=y WEBTILES=y
RUN strip --strip-unneeded crawl
RUN rm -Rf /opt/crawl/.git

FROM BASE as RUNTIME
RUN apt-get install --no-install-recommends -y tini libncursesw6 libsqlite3-0 liblua5.1-0 python3-minimal python3-tornado python3-yaml
COPY --from=BUILD /opt/crawl /opt/crawl
VOLUME /opt/crawl/crawl-ref/source/webserver
VOLUME /opt/crawl/crawl-ref/source/rcs
WORKDIR /opt/crawl/crawl-ref/source
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/bin/python3", "webserver/server.py"]
