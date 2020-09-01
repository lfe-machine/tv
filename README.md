# tv

*An X11 library for LFE Machines*

This library is based on Joe Armstrong's implementation of the X11 protocol for Erlang (and the subsequent work on it done by skvamme). As a nod to LFE's herritage, the project now uses the same name as the Lisp Machines windowing system.

## Compatibility

This library is tested against the following:

* CI/CD: Ubuntu 16.04 and Erlang 19-23
* Local development:
  * Debian 9 (Stretch) and Erlang 23

## Development Environments

* [Docker-based](docs/dev/docker-x11-vnc.md) (running X11 and a VNC server)
* [Debian-based](docs/dev/debian.md)

## Sources

* https://3e8.org/pub/scheme/doc/p1-armstrong.pdf
* https://tumbleweed.nu/r/lm-3/uv/wind.html
