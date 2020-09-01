CC = gcc
CFLAGS = -I/usr/local/X11/include -I/opt/X11/include
LIBS = -L/usr/X11R6/lib -L/opt/X11/lib -lX11
SRC = ../../src
INCL_PATH = ../../

## make
## make demo

## Note rgb.erl does compile but it takes a very long time???

.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -I $(INCL_PATH) -W $<

.yrl.erl:
	echo "yecc:yecc($*,$*), halt()." | erl

MODS =  sw swTopLevel swBlinker swButton swCanvas swClock swColorButton \
        swColorText\
        swDragBox swEdText swEmacs swEntry \
        swFlashButton swLabel swLifts swProgressBar swRectangle \
        swScrollbar swSelector swText test1 emacs emacs1 lines map\
        example0 example1 example2 example3 example4 example5 example6\
	example7 example8 example9 example10 example11 example12 example13\
        example14\
	example15 example16 example17 example18 example19 example20\
	example21 example22 example23 example24 example25 example26 example27\
        example28 example29 example30 example31 example32\
	swErlPoint fontSelector lib_emacs lifts lift_socket_server lift_socket_client

# make      - build and run the stable demo
# make test - run new experimental tests

build: ${MODS:%=%.beam} mapdata.bin

all: build

run: build
	erl -pa $(SRC) -pa -s example0 start

bang: erl_parse.beam

mapdata.bin: mapdata.dat map.beam
	echo "map:reformat(), erlang:halt(). " | erl

test: build
	erl -pa $(SRC) -s sw_tests start

lifts: build
	erl -pa $(SRC) -s lifts start

lift_socket_server: build
	erl -pa $(SRC) -s lift_socket_server start

lift_socket_client: build
	erl -noshell -pa $(SRC) -s lift_socket_client start

demo: build
	erl -pa $(SRC) -s demo start

clean:
	rm -f *~ *.beam erl_crash.dump erl_parse.erl
