all: build

build:  tv_lib_read_jpeg

tv_lib_read_jpeg: tv_lib_read_jpeg.o port_lib.o
	gcc -o tv_lib_read_jpeg tv_lib_read_jpeg.o port_lib.o -ljpeg

clean:
	rm -f *~ *.o
