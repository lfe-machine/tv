all: lib old_widgets util widgets

old_widgets:
	cd old_widgets; make

lib:
	cd lib; make

util:
	cd util; make

widgets:
	cd widgets; make

clean:
	cd lib; make clean
	cd old_widgets; make clean
	cd util; make clean
	cd widgets; make clean

PHONY: lib old_widgets util widgets
