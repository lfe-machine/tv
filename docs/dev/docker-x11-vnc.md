# Docker Dev Environment

*Running X11 and VNC server in the container*

## Prerequisites

* A local installation of Docker
* RealVNC Viewer (not tested with TightVNC)

## Version Info

The X11 Docker container for LFE is running LFE 1.3-dev and Erlang 23.0.

## Build and Run

To build the image:

```
make docker
```

To run the `tv` container:

```
make run-docker
```

To connect to X11:

1. Start the VNC Viewer
1. Enter `localhost:9200` in the text area
1. Press `<ENTER>` and click through any warning messages

## References

The Docker Hub link for the base container:
* https://hub.docker.com/r/lfex/lfe-x11/tags
