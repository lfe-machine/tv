all: build

build:
	erlc -I ../ *.erl
	erl -pa ../src

clock:
	erl -noshell -pa ../src -s clock init

clean:
	rm -f *~ *.beam erl_crash.dump
