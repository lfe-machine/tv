all: build

build:  ex11_lib_read_jpeg

ex11_lib_read_jpeg: ex11_lib_read_jpeg.o port_lib.o
	gcc -o ex11_lib_read_jpeg ex11_lib_read_jpeg.o port_lib.o -ljpeg

clean:
	rm -f *~ *.o
