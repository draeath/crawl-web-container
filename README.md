This is a minimal container to build and run [DCSS](https://github.com/crawl/crawl) [webtiles](https://github.com/crawl/crawl). It does not use [crawl/dgamelaunch-config](https://github.com/crawl/dgamelaunch-config) at all and so is suitable for single-version local deployments only.

Please note the following build arguments - override them if you need to:
 - `GIT_URL="https://github.com/crawl/crawl.git"`
 - `GIT_BRANCH="master"`
 - `GIT_REF="HEAD"`

Two volumes are required for user data persistence:
  - `/opt/crawl/crawl-ref/source/webserver`
  - `/opt/crawl/crawl-ref/source/rcs`

Note that you *must* allow the `webserver` volume to be populated, [it should look like this.](https://github.com/crawl/crawl/tree/master/crawl-ref/source/webserver) If you use the following example invocation without precreating the volumes, docker or podman will automatically copy the content from the image for you. Remember, this data may be changed from release-to-release, you should backup it's contents and erase the volume between releases. Allow the files to be recreated, stop the container, and restore/merge the relevant files.

Here's an example invocation:

    # podman build -t craw-web --build-arg GIT_BRANCH=stone_soup-0.32 . 
    podman run --rm -it -p 127.0.0.1:8080:8080 \
      -v crawl-webserver:/opt/crawl/crawl-ref/source/webserver:rw \
      -v crawl-rcs:/opt/crawl/crawl-ref/source/rcs:rw \
      localhost/crawl-web:latest

The git repository that's cloned in this build is pretty heavy, and [fails to build with a shallow clone](https://github.com/crawl/crawl/blob/5fac02aaea415d1dcc78f8a9bf6f9a12e4abf406/crawl-ref/source/Makefile#L1283-L1285) (I have tried populating `util/release_ver` as documented, but the command returns a fatal error anyway). If your disk space is constrained, be sure to clean out the build cache once you're satisfied.
