-module(numdisplay).
-author(skvamme).
-export([make/5,init/5,loop/4]).
-define (WT,200).
-define (HT,60).
-include("ex11_lib.hrl").
-import(ex11_lib, [xColor/2,xCreateSimpleWindow/10,xClearArea/2,mkArc/6,eFillPoly/5,ePolyFillArc/3,eMapWindow/1,xDo/2,xFlush/1,xCreateGC/2,
    ePolyLine/4,mkPoint/2,xClearArea/2]).

make(Parent,Display,PWin,X,Y) -> 
    spawn_link(?MODULE,init,[Parent,Display,PWin,X,Y]).

init(Parent,Display,PWin,X,Y) ->
    Pid = self(),
    Win = xCreateSimpleWindow(Display,PWin,X,Y,?WT,?HT,0,?XC_cross,xColor(Display,?black),
        ?EVENT_BUTTON_PRESS bor ?EVENT_BUTTON_RELEASE bor ?EVENT_STRUCTURE_NOTIFY), 
    xDo(Display, eMapWindow(Win)),
    xFlush(Display),        
    Digit10000 = sevensegsmall:make(Pid,Display,Win,0,0), % Place the sevensegments
    Digit1000 = sevensegsmall:make(Pid,Display,Win,40,0), 
    Digit100 = sevensegsmall:make(Pid,Display,Win,80,0),
    Digit10 = sevensegsmall:make(Pid,Display,Win,120,0),
    Digit1 = sevensegsmall:make(Pid,Display,Win,160,0),
    Widgets = {Digit10000,Digit1000,Digit100,Digit10,Digit1},
    show_off("88888",Widgets),
    loop(Parent,Display,Win,Widgets).

loop(Parent,Display,Win,Widgets) ->
    receive
    	{new,Number} -> 
            show_off(Number,Widgets),
    		?MODULE:loop(Parent,Display,Win,Widgets);
    	{clear} ->
            {Digit10000,Digit1000,Digit100,Digit10,Digit1} = Widgets,
            Digit10000 ! Digit1000 ! Digit100 ! Digit10 ! Digit1 ! {clear},
    		?MODULE:loop(Parent,Display,Win,Widgets);
 		{'EXIT', _Pid, _Why} -> true;
		_Any -> ?MODULE:loop(Parent,Display,Win,Widgets)
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
