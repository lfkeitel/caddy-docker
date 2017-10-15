# Caddy in Docker

**Base Image**: Alpine Edge

**Caddy Version**: 0.10.10 (latest)

**Github Repository**: https://github.com/lfkeitel/caddy-docker

This is and up-to-date build of [Caddy](https://caddyserver.com/) in Alpine.

## Using the Image

The default configuration listens on port 80 (443 is also exposed on image for custom configurations) and serves the files in `/site`.

Mount your site as a volume: `docker run --rm --name caddy -v "$PWD:/site" -p 8080:80 lfkeitel/caddy`

Use the image as a base:

```Dockerfile
FROM lfkeitel/caddy:latest

ADD . /site
ADD caddy.conf /etc/caddy/caddy.conf
```

Then build and run: `docker build -t my-site . && docker run --rm --name caddy -p 8080:80 my-site`
