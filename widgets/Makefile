all: build

build:
	erlc -I ../ *.erl
	erl -pa ../src

clean:
	rm -f *~ *.beam erl_crash.dump
