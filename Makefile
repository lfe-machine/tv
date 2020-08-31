all: ex11-lib old-widgets ex11-util ex11-widgets

old-widgets:
	cd old_widgets; make

ex11-lib:
	cd lib; make

ex11-util:
	cd util; make

ex11-widgets:
	cd widgets; make

clean:
	cd lib; make clean
	cd old_widgets; make clean
	cd util; make clean
	cd widgets; make clean

PHONEY: all clean
