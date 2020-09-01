CC = gcc
CFLAGS = -I/usr/local/X11/include -I/opt/X11/include
LIBS = -L/usr/X11R6/lib -L/opt/X11/lib -lX11

## make
## make demo

## Note rgb.erl does compile but it takes a very long time???

.SUFFIXES: .erl .beam

.erl.beam:
	erlc -I ../ -W $<

MODS = tv_lib tv_lib_driver tv_lib_read_jpeg tv_lib_connect \
       tv_lib_control \
       tv_lib_keyboard_driver tv_lib_rgb tv_lib_xauth tv_lib_utils \
       tv_lib_xauth dxf2erl

all: build

build: ${MODS:%=%.beam} tv_lib_read_jpeg

test: all
	erl -s hello_world start

test1: all
	erl -s hello_buttons start

tv_lib_read_jpeg:
	cd ../c_src && make

clean:
	rm -f *~ *.beam erl_crash.dump tv_lib_read_jpeg
	rm -f tv_lib_read_jpeg.o port_lib.o
