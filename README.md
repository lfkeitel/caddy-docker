# Caddy in Docker

**Base Image**: Alpine Edge

**Caddy Version**: 0.11.0

**Github Repository**: https://github.com/lfkeitel/caddy-docker

This is and up-to-date build of [Caddy](https://caddyserver.com/) in Alpine.

## Telemetry

This build has a few changes to the telemetry "feature". Telemetry is disabled by default. It can be enabled
by setting the environment variable `CADDY_TELEMETRY_ENABLE` to either "1", "t", or "true". The telemetry
server endpoint can also be changed by setting the variable `CADDY_TELEMETRY_ENDPOINT`.

## CADDYPATH

**CADDYPATH** is set to `/caddy` by default.

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
