all: build

build:
	erlc -I ../lib *.erl
	erl -pa '../lib'

clock:
	erl -noshell -pa '../lib' -s clock init

clean:
	rm -f *~ *.beam erl_crash.dump
