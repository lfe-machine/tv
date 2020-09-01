SRC = ../../src
INCL_PATH = ../../

all: build

build:
	erlc -I $(INCL_PATH) *.erl

world:
	erl -pa $(SRC) -s hello_world

buttons:
	erl -pa $(SRC) -s hello_buttons

clean:
	rm -f *~ *.beam erl_crash.dump
