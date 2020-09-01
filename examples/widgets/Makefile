SRC = ../../src
INCL_PATH = ../../

all: build

build:
	erlc -I $(INCL_PATH) *.erl
	erl -pa $(SRC)

clean:
	rm -f *~ *.beam erl_crash.dump
