# tv

*An X11 library for LFE Machines*

This library is based on Joe Armstrong's implementation of the X11 protocol for Erlang (and the subsequent work on it done by skvamme). As a nod to LFE's herritage, the project now uses the same name as the Lisp Machines windowing system.

## Compatibility

This library is tested against the following:

* CI/CD: Ubuntu 16.04 and Erlang 19-23
* Local development:
  * Debian 9 (Stretch) and Erlang 23

## Development Environment

* Download a Linux ISO image (e.g., [Debian Stretch]() and install it
  * Don't set up a desktop environment, just a bare-bones machine
* Install the dependencies:

    ```
    sudo apt-get install -y \
        xorg twm curl build-essential autoconf git \
        libncurses5 libncurses5-dev libjpeg-dev \
        xsltproc fop libxml2-utils \
        macs25
    curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl && \
        sudo mv kerl /usr/local/bin
    curl -O https://s3.amazonaws.com/rebar3/rebar3 && \
        chmod +x rebar3 && \
        sudo mv rebar3 /usr/local/bin
    kerl build 23.0.3 23.0.3
    kerl install 23.0.3 /opt/erlang/23.0.3
    git clone https://github.com/rvirding/lfe && \
        cd lfe && \
        make && \
        sudo make install
    ```

## Sources

* https://3e8.org/pub/scheme/doc/p1-armstrong.pdf
* https://tumbleweed.nu/r/lm-3/uv/wind.html
