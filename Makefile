all: ex11-lib old-widgets ex11-util ex11-widgets

old-widgets:
	cd old_widgets; make

ex11-lib:
	cd src; make

ex11-util:
	cd util; make

ex11-widgets:
	cd widgets; make

clean:
	cd src; make clean
	cd old_widgets; make clean
	cd util; make clean
	cd widgets; make clean

docker:
	@docker build -t lfe-machine .

run-docker:
	@docker run -p 5900:5900 -e DISPLAY=:0 lfe-machine

bash-docker:
	@docker run -it --entrypoint=bash lfe-machine

PHONEY: all clean
