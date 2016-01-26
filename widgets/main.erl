-module(main). 
-author(skvamme).
-export([start/0,init/0,loop/6]).
-import(ex11_lib,[xColor/2,xCreateSimpleWindow/7,eMapWindow/1,xDo/2,xFlush/1,xSetScreenSaver/2]).
-include("ex11_lib.hrl").
-define(WT,800).
-define(HT,480).

start() -> spawn(?MODULE,init,[]).

init() ->
	Pid = self(),
	{ok, Display} = ex11_lib:xStart("3.1"),
    xSetScreenSaver(Display,0),
	Win = xCreateSimpleWindow(Display,0,0,?WT,?HT,?XC_arrow,xColor(Display,?black)),
	xDo(Display, eMapWindow(Win)),
	xFlush(Display),
	Port = open_port({spawn, "../priv/atlast -i../priv/kwh.atl"}, [{line,127}]),
	loop(Pid,Port,Display,Win,false,{null,null,null,null,null}).

loop(Pid,Port,Display,Win,Ready,Widgets) ->
    receive
    	{event,_,expose,expose} when Ready == false -> % The window is ready for use
			Digit10000 = sevensegsmall:make(Pid,Display,Win,20,20), % Place the sevensegments
			Digit1000 = sevensegsmall:make(Pid,Display,Win,100,20), 
			Digit100 = sevensegsmall:make(Pid,Display,Win,180,20),
			Digit10 = sevensegsmall:make(Pid,Display,Win,260,20),
			Digit1 = sevensegsmall:make(Pid,Display,Win,340,20),
			Widgets1 = {Digit10000,Digit1000,Digit100,Digit10,Digit1},
			show_off("88888",Widgets1),
			timer:send_interval(5000, poll),
		    ?MODULE:loop(Pid,Port,Display,Win,true,Widgets1);
		poll -> Port ! {self(), {command, "w\n"}},
			 ?MODULE:loop(Pid,Port,Display,Win,Ready,Widgets);
		{Port,{data,{eol,Data1}}} when Data1 /= [] ->	              % Data from ATLAST Forth
			show_off(Data1,Widgets),
			xFlush(Display),
			?MODULE:loop(Pid,Port,Display,Win,Ready,Widgets);
		Any -> io:format("~p got unknown msg: ~p~n",[?MODULE, Any]),
			?MODULE:loop(Pid,Port,Display,Win,Ready,Widgets)
	end.

show_off(Number,{Digit10000,Digit1000,Digit100,Digit10,Digit1}) ->
	Ilist = string:strip(Number),
	io:format("~n~p Load is: ~p at ~p UTC",[?MODULE, Ilist, time()]),
	case Ilist of
		[A] -> Digit1 ! {new,[A],false}, Digit10000 ! Digit1000 ! Digit100 ! Digit10 ! {clear};
		[A,B] -> Digit10 ! {new,[A],false}, Digit1 ! {new,[B],false}, Digit10000 ! Digit1000 ! Digit100 ! {clear};
		[A,B,C] -> Digit100 ! {new,[A],false}, Digit10 ! {new,[B],false}, Digit1 ! {new,[C],false}, Digit10000 ! Digit1000 ! {clear};
		[A,B,C,D] -> Digit1000 ! {new,[A],false}, Digit100 ! {new,[B],false}, Digit10 ! {new,[C],false}, Digit1 ! {new,[D],false}, Digit10000 ! {clear};
		[A,B,C,D,E] -> Digit10000 ! {new,[A],false}, Digit1000 ! {new,[B],false}, Digit100 ! {new,[C],false}, Digit10 ! {new,[D],false}, Digit1 ! {new,[E],false}
	end.














