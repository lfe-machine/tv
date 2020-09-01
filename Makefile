all: ex11-lib demo dxf-examples widgets-examples

demo:
	cd examples/demo; make

ex11-lib:
	cd src; make

dxf-examples:
	cd examples/dxf; make

widgets-examples:
	cd examples/widgets; make

clean:
	cd src; make clean
	cd examples/demo; make clean
	cd examples/dxf; make clean
	cd examples/widgets; make clean

docker:
	@docker build -t lfe-machine .

run-docker:
	@docker run -p 5900:5900 -e DISPLAY=:0 lfe-machine

bash-docker:
	@docker run -it --entrypoint=bash lfe-machine

PHONEY: all clean
