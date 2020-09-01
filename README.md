# tv

[![Build Status][gh-actions-badge]][gh-actions] [![LFE Versions][lfe badge]][lfe] [![Erlang Versions][erlang badge]][versions] [![Tags][github tags badge]][github tags]

[![][logo]][logo-large]

*An X11 library for LFE Machines*

This library is based on Joe Armstrong's implementation of the X11 protocol for Erlang (and the subsequent work on it done by skvamme). As a nod to LFE's herritage, the project now uses the same name as the Lisp Machines windowing system.

## Compatibility

This library is tested against the following:

* CI/CD: Ubuntu 16.04 and Erlang 19-23
* Local development:
  * x11vnc and Erlang 23 (Docker)
  * Debian 9 (Stretch) and Erlang 23

## Development Environments

* [Docker-based](docs/dev/docker-x11-vnc.md) (running X11 and a VNC server)
* [Debian-based](docs/dev/debian.md)

## Sources

* https://3e8.org/pub/scheme/doc/p1-armstrong.pdf
* https://tumbleweed.nu/r/lm-3/uv/wind.html

## Development Tools

* [X11 Events](docs/X-events.md)

<!-- Named page links below: /-->

[logo]: priv/images/tv-logo.jpg
[logo-large]: priv/images/tv-logo-large.jpg
[github]: https://github.com/lfe-machine/tv
[gitlab]: https://gitlab.com/lfe-machine/tv
[gh-actions-badge]: https://github.com/lfe-machine/tv/workflows/ci%2Fcd/badge.svg
[lfe]: https://github.com/rvirding/lfe
[gh-actions]: https://github.com/lfe-machine/tv/actions
[lfe badge]: https://img.shields.io/badge/lfe-1.3.0-blue.svg
[erlang badge]: https://img.shields.io/badge/erlang-19%20to%2023-blue.svg
[versions]: https://github.com/lfe-machine/tv/blob/master/.github/workflows/cicd.yml
[github tags]: https://github.com/lfe-machine/tv/tags
[github tags badge]: https://img.shields.io/github/tag/lfe-machine/tv.svg
