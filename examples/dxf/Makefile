SRC = ../../src
INCL_PATH = ../../


all: build

build:
	erlc -I $(INCL_PATH) *.erl

run:
	erl -pa $(SRC)

clock:
	erl -noshell -pa $(SRC) -s clock init

clean:
	rm -f *~ *.beam erl_crash.dump
