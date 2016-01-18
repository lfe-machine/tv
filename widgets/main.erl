-module(main). 
-author(skvamme).
-export([start/0,init/0,loop/0]).
-import(ex11_lib,[xColor/2,xCreateSimpleWindow/7,eMapWindow/1,xDo/2,xFlush/1,xSetScreenSaver/2]).
-include("ex11_lib.hrl").
-define(WT,800).
-define(HT,480).

start() -> spawn(?MODULE,init,[]).

init() ->
	Pid = self(),
	{ok, Display} = ex11_lib:xStart("3.1"),
    xSetScreenSaver(Display,0),
	Win = xCreateSimpleWindow(Display,0,0,?WT,?HT,?XC_arrow,xColor(Display,?white)),
	xDo(Display, eMapWindow(Win)),
	xFlush(Display),
%	circleslider:make(Pid,Display,Win,100,100),
	BPid = barcode:make(Pid,Display,Win,20,20),
	Seg = sevenseg:make(Pid,Display,Win,500,20),
    dialerbutton:make(Pid, Display,Win,  20, 320,"3"),
    dialerbutton:make(Pid, Display,Win, 180, 320,"4"),
    dialerbutton:make(Pid, Display,Win, 340, 320,"5"),
    dialerbutton:make(Pid, Display,Win, 500, 320,"6"),
    dialerbutton:make(Pid, Display,Win, 660, 320,"7"),
	sleep(1000),
	BPid ! {new,"1234567890"},
	Seg ! {new,0,true},
	sleep(1000),
	Seg ! {new,1,true},
	sleep(1000),
	Seg ! {new,2,true},
	sleep(1000),
	Seg ! {new,3,true},
	sleep(1000),
	Seg ! {new,4,true},
	sleep(1000),
	Seg ! {new,5,true},
	sleep(1000),
	Seg ! {new,6,true},
	sleep(1000),
	Seg ! {new,7,true},
	sleep(1000),
	Seg ! {new,8,true},
	sleep(1000),
	Seg ! {new,9,true},
	sleep(1000),
	
	loop().

loop() ->
    receive
		Any -> io:format("~p got unknown msg: ~p~n",[?MODULE, Any]),
		?MODULE:loop()
	end.


%% T is in milliseconds
sleep(T) ->
    receive
    after T ->
       true
    end.


