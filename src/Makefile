CC = gcc
CFLAGS = -I/usr/local/X11/include -I/opt/X11/include
LIBS = -L/usr/X11R6/lib -L/opt/X11/lib -lX11

## make
## make demo

## Note rgb.erl does compile but it takes a very long time???

.SUFFIXES: .erl .beam

.erl.beam:
	erlc -I ../ -W $<

MODS = ex11_lib ex11_lib_driver ex11_lib_read_jpeg ex11_lib_connect \
       ex11_lib_control \
       ex11_lib_keyboard_driver ex11_lib_rgb ex11_lib_xauth ex11_lib_utils \
       ex11_lib_xauth dxf2erl

all: build

build: ${MODS:%=%.beam} ex11_lib_read_jpeg

test: all
	erl -s hello_world start

test1: all
	erl -s hello_buttons start

ex11_lib_read_jpeg:
	cd ../c_src && make

clean:
	rm -f *~ *.beam erl_crash.dump ex11_lib_read_jpeg
	rm -f ex11_lib_read_jpeg.o port_lib.o
