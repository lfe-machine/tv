-module(graph).
-author(skvamme).
-export([make/5,init/5,loop/5]).
-define (WT,800).
-define (HT,480).
-define (DELTA,10). % X-Distance between visible points
-define (COUNT,60). % Max Number of visible points
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
    put(x,120),        
    Pen0 = xCreateGC(Display, [{function,copy},{line_width,3},{foreground, xColor(Display, ?white)}]),  
    Pen1 = xCreateGC(Display, [{function,copy},{line_width,0},{foreground, xColor(Display, ?white)}]),  
    xFlush(Display),
    Y1 = sevensegsmall:make(Pid,Display,Win,0,371), % Place the sevensegments
    Y11 = sevensegsmall:make(Pid,Display,Win,40,371),
    Y2 = sevensegsmall:make(Pid,Display,Win,0,311),
    Y22 = sevensegsmall:make(Pid,Display,Win,40,311),
    Y3 = sevensegsmall:make(Pid,Display,Win,0,251),
    Y33 = sevensegsmall:make(Pid,Display,Win,40,251),
    Y4 = sevensegsmall:make(Pid,Display,Win,0,191),
    Y44 = sevensegsmall:make(Pid,Display,Win,40,191),
    Y5 = sevensegsmall:make(Pid,Display,Win,0,131),
    Y55 = sevensegsmall:make(Pid,Display,Win,40,131),
    Y6 = sevensegsmall:make(Pid,Display,Win,0,71),
    Y66 = sevensegsmall:make(Pid,Display,Win,40,71),
    Y7 = sevensegsmall:make(Pid,Display,Win,0,11),
    Y77 = sevensegsmall:make(Pid,Display,Win,40,11),
    Y1 ! Y2 ! Y3 ! Y4 ! {clear},
    Y11 ! {new,2,false},
    Y22 ! {new,4,false},
    Y33 ! {new,6,false},
    Y44 ! {new,8,false},
    Y5 ! {new,1,false}, Y55 ! {new,0,false},
    Y6 ! {new,1,false}, Y66 ! {new,2,false},
    Y7 ! {new,1,false}, Y77 ! {new,4,false},
    draw_static(Display,Win,Pen0),
    xFlush(Display),
    loop(Parent,Display,Win,{Pen0,Pen1},[]).

loop(Parent,Display,Win,Pen,Data) ->
    receive
        {new,D} ->
            Data2 = case length(Data) of
                L when L < ?COUNT -> [D|Data];
                _ -> Data1 = lists:reverse(tl(lists:reverse(Data))), [D|Data1]
            end,
            {Pen0,Pen1} = Pen,
            xClearArea(Display,Win),
            draw_static(Display,Win,Pen0),
            draw_dynamic(Display,Win,Pen1,Data2),
           ?MODULE:loop(Parent,Display,Win,Pen,Data2);
    	{clear} -> 
            xClearArea(Display,Win),
    		xFlush(Display),
    		?MODULE:loop(Parent,Display,Win,Pen,Data);
 		{'EXIT', _Pid, _Why} -> true;
		Any -> io:format("~p got unknown msg: ~p~n",[?MODULE, Any]),
            ?MODULE:loop(Parent,Display,Win,Pen,Data)
	end.

%% Processing ascii file: "graph.dxf"
%% Title: "graph.dxf"
draw_static(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, convex, origin, [mkPoint(104,11),mkPoint(104,448),mkPoint(84,468),mkPoint(84,11)])),
xDo(Display,eFillPoly(Win, Pen0, convex, origin, [mkPoint(104,448),mkPoint(789,448),mkPoint(789,468),mkPoint(84,468)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(80,401),mkPoint(120,401)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(80,341),mkPoint(120,341)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(80,281),mkPoint(120,281)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(80,221),mkPoint(120,221)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(80,161),mkPoint(120,161)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(80,101),mkPoint(120,101)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(80,41),mkPoint(120,41)])).
%% END

draw_dynamic(Display,Win,Pen0,Data) ->
    Data1 = lists:reverse(Data),
    Points = lists:map(fun(D) -> X = get(x), X1 = X + ?DELTA, put(x,X1), D1 = list_to_integer(string:strip(D)) div 20, mkPoint(X,?HT - D1) end, Data1),
    xDo(Display,ePolyLine(Win, Pen0, origin, Points)),
    xFlush(Display),
    put(x,120).








