-module(sevensegsmall).
-author(skvamme).
-export([make/5,init/5,loop/4]).
-define (WT,80).
-define (HT,120).
-include("ex11_lib.hrl").
-import(ex11_lib, [xColor/2,xCreateSimpleWindow/10,xClearArea/2,mkArc/6,eFillPoly/5,ePolyFillArc/3,eMapWindow/1,xDo/2,xFlush/1,xCreateGC/2,
    ePolyLine/4,mkPoint/2,xClearArea/2]).

% Segment names same as thicknes in cad drawing
%   ---60---
%   40    50
%   ---30---
%   10   20
%   ---0---

make(Parent,Display,PWin,X,Y) -> 
    spawn_link(?MODULE,init,[Parent,Display,PWin,X,Y]).


init(Parent,Display,PWin,X,Y) ->
    Win = xCreateSimpleWindow(Display,PWin,X,Y,?WT,?HT,0,?XC_cross,xColor(Display,?black),
        ?EVENT_BUTTON_PRESS bor ?EVENT_BUTTON_RELEASE bor ?EVENT_STRUCTURE_NOTIFY), 
    xDo(Display, eMapWindow(Win)),
    xFlush(Display),        
    Pen0 = xCreateGC(Display, [{function,copy},{line_width,1},{foreground, xColor(Display, 16#FF0000)}]),  
    xFlush(Display),
    loop(Parent,Display,Win,Pen0).

loop(Parent,Display,Win,Pen0) ->
    receive
    	{new,Fig,Dot} -> xClearArea(Display,Win),
    		do_figure(Fig,Dot,Display,Win,Pen0),
    		xFlush(Display),
    		?MODULE:loop(Parent,Display,Win,Pen0);
    	{clear} -> xClearArea(Display,Win),
    		xFlush(Display),
    		?MODULE:loop(Parent,Display,Win,Pen0);
 		{'EXIT', _Pid, _Why} -> true;
		_Any -> ?MODULE:loop(Parent,Display,Win,Pen0)
	end.


do_figure(Fig,Dot,Display,Win,Pen0) ->
	case Fig of
		X when X == 0 orelse X == "0" -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_20(Display,Win,Pen0),
			seg_40(Display,Win,Pen0),seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		X when X == 1 orelse X == "1" -> seg_20(Display,Win,Pen0),seg_50(Display,Win,Pen0);
		X when X == 2 orelse X == "2" -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_30(Display,Win,Pen0),
			seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		X when X == 3 orelse X == "3" -> seg_0(Display,Win,Pen0),seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),
			seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		X when X == 4 orelse X == "4" -> seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),
			seg_50(Display,Win,Pen0);
		X when X == 5 orelse X == "5" -> seg_0(Display,Win,Pen0),seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),
			seg_40(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		X when X == 6 orelse X == "6" -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_20(Display,Win,Pen0),
			seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		X when X == 7 orelse X == "7" -> seg_20(Display,Win,Pen0),seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		X when X == 8 orelse X == "8" -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_20(Display,Win,Pen0),
			seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),seg_50(Display,Win,Pen0),
			seg_60(Display,Win,Pen0);
		X when X == 9 orelse X == "9" -> seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),
			seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		"-" -> seg_30(Display,Win,Pen0);
		Any -> io:format("Got: ~p~n",[Any])
	end,
	case Dot of
		true -> seg_dot(Display,Win,Pen0);
		_ -> ok
	end.



%% Processing ascii file: "7segsmall.dxf"
%% Title: "7segsmall.dxf"
seg_dot(Display,Win,Pen0) ->
	xDo(Display,ePolyFillArc(Win, Pen0, [mkArc(33,52,6,6,0,64*360)])).

seg_0(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(28,57),
mkPoint(31,54),
mkPoint(28,51),
mkPoint(12,51),
mkPoint(9,54),
mkPoint(12,57)])).

seg_10(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(11,34),
mkPoint(8,31),
mkPoint(5,34),
mkPoint(5,50),
mkPoint(8,53),
mkPoint(11,50)])).

seg_20(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(35,34),
mkPoint(32,31),
mkPoint(29,34),
mkPoint(29,50),
mkPoint(32,53),
mkPoint(35,50)])).

seg_30(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(28,33),
mkPoint(31,30),
mkPoint(28,27),
mkPoint(12,27),
mkPoint(9,30),
mkPoint(12,33)])).

seg_40(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(11,10),
mkPoint(8,7),
mkPoint(5,10),
mkPoint(5,26),
mkPoint(8,29),
mkPoint(11,26)])).

seg_50(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(35,10),
mkPoint(32,7),
mkPoint(29,10),
mkPoint(29,26),
mkPoint(32,29),
mkPoint(35,26)])).

seg_60(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(28,9),
mkPoint(31,6),
mkPoint(28,3),
mkPoint(12,3),
mkPoint(9,6),
mkPoint(12,9)])).
%% END

