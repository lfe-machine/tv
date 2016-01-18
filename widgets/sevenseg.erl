-module(sevenseg).
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
    		do_figure(Fig,Dot,Display,Win,Pen0),xFlush(Display),
    		?MODULE:loop(Parent,Display,Win,Pen0);
 		{'EXIT', _Pid, _Why} -> true;
		_Any -> ?MODULE:loop(Parent,Display,Win,Pen0)
	end.


do_figure(Fig,Dot,Display,Win,Pen0) ->
	case Fig of
		0 -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_20(Display,Win,Pen0),
			seg_40(Display,Win,Pen0),seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		1 -> seg_20(Display,Win,Pen0),seg_50(Display,Win,Pen0);
		2 -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_30(Display,Win,Pen0),
			seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		3 -> seg_0(Display,Win,Pen0),seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),
			seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		4 -> seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),
			seg_50(Display,Win,Pen0);
		5 -> seg_0(Display,Win,Pen0),seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),
			seg_40(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		6 -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_20(Display,Win,Pen0),
			seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		7 -> seg_20(Display,Win,Pen0),seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		8 -> seg_0(Display,Win,Pen0),seg_10(Display,Win,Pen0),seg_20(Display,Win,Pen0),
			seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),seg_50(Display,Win,Pen0),
			seg_60(Display,Win,Pen0);
		9 -> seg_20(Display,Win,Pen0),seg_30(Display,Win,Pen0),seg_40(Display,Win,Pen0),
			seg_50(Display,Win,Pen0),seg_60(Display,Win,Pen0);
		"-" -> seg_30(Display,Win,Pen0)
	end,
	case Dot of
		true -> seg_dot(Display,Win,Pen0);
		_ -> ok
	end.

%% Processing binary file: "7seg.dxf"
%% Title: "7seg.dxf"
% BoundingBox: 0 0 80 120
seg_dot(Display,Win,Pen0) ->
%	xDo(Display,ePolyFillArc(Win, Pen0, [mkArc(67,110,6,6,0,64*360)])).
	xDo(Display,ePolyFillArc(Win, Pen0, [mkArc(64,104,12,12,0,64*360)])).


seg_0(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(55,111),
mkPoint(50,116),
mkPoint(15,116),
mkPoint(10,111),
mkPoint(15,106),
mkPoint(50,106)
])).

seg_10(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(14,105),
mkPoint(14,66),
mkPoint(9,61),
mkPoint(4,66),
mkPoint(4,105),
mkPoint(9,110)
])).

seg_20(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(51,66),
mkPoint(51,105),
mkPoint(56,110),
mkPoint(61,105),
mkPoint(61,66),
mkPoint(56,61)
])).

seg_30(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(10,60),
mkPoint(15,55),
mkPoint(50,55),
mkPoint(55,60),
mkPoint(50,65),
mkPoint(15,65)
])).

seg_40(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(9,59),
mkPoint(4,54),
mkPoint(4,15),
mkPoint(9,10),
mkPoint(14,15),
mkPoint(14,54)
])).

seg_50(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(56,10),
mkPoint(61,15),
mkPoint(61,54),
mkPoint(56,59),
mkPoint(51,54),
mkPoint(51,15)
])).

seg_60(Display,Win,Pen0) ->
xDo(Display,eFillPoly(Win, Pen0, complex, origin, [mkPoint(15,14),
mkPoint(50,14),
mkPoint(55,9),
mkPoint(50,4),
mkPoint(15,4),
mkPoint(10,9)
])).
%% END