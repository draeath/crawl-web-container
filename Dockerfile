FROM docker.io/library/alpine AS base
RUN apk --no-interactive update && apk --no-interactive --latest upgrade
ARG LOCALE_LANG="en_US.UTF-8"
ARG LC_ALL="C.utf8"
ENV LANG ${LOCALE_LANG}
ENV LC_ALL ${LC_ALL}

FROM base AS build
RUN apk --no-interactive add advancecomp binutils bison ca-certificates flex font-dejavu gcc g++ git freetype-dev lua5.1-dev ncurses-dev pcre2-dev libpng-dev sqlite-dev make patch perl pkgconf python3 py3-yaml zlib-dev 
ARG GIT_URL="https://github.com/crawl/crawl.git"
ARG GIT_BRANCH="master"
ARG GIT_REF="HEAD"
RUN git clone -v -b ${GIT_BRANCH} ${GIT_URL} /opt/crawl
WORKDIR /opt/crawl/crawl-ref/source
RUN git checkout ${GIT_REF}
COPY musl-compat.patch /tmp/musl-compat.patch
RUN git apply /tmp/musl-compat.patch
RUN make -j$(nproc) LTO=y WEBTILES=y
RUN strip --strip-unneeded crawl
RUN rm -Rf /opt/crawl/.git

FROM base AS runtime
RUN apk --no-interactive add tini ncurses-libs sqlite-libs lua5.1-libs python3 py3-yaml py3-tornado
COPY --from=BUILD /opt/crawl /opt/crawl
VOLUME /opt/crawl/crawl-ref/source/webserver
VOLUME /opt/crawl/crawl-ref/source/rcs
WORKDIR /opt/crawl/crawl-ref/source
EXPOSE 8080
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/python3", "webserver/server.py"]
