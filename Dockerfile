#############################################################################
###   Build Phase   #########################################################
#############################################################################
FROM lfex/lfe-x11:1.3-23.0-alpine AS builder

ADD . /tmp/tv
WORKDIR /tmp/tv
RUN apk add --update make gcc libc-dev libjpeg jpeg-dev
RUN make

#############################################################################
###   Build Phase   #########################################################
#############################################################################
FROM lfex/lfe-x11:1.3-23.0-alpine

COPY --from=builder /tmp/tv /opt/erlang/lfe-machine/tv
COPY priv/docker/xterm /root/xterm
COPY priv/docker/emacs.el /root/.emacs

RUN apk add xsetroot xev kbd make emacs-nox ca-certificates

WORKDIR /opt/erlang/lfe-machine/tv
