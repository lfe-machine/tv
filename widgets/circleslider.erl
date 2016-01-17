-module(circleslider).
-author(skvamme).
-export([make/5,init/5,loop/7]).
-define (WT,340).
-define (HT,340).
-include("ex11_lib.hrl").
-import(ex11_lib, [xColor/2,xCreateSimpleWindow/10,eMapWindow/1,xDo/2,xFlush/1,
    xCreateGC/2,ePolyArc/3,mkArc/6,eListFonts/2]).

make(Parent,Display,PWin,X,Y) -> 
    spawn_link(?MODULE,init,[Parent,Display,PWin,X,Y]).

init(Parent,Display,PWin,X,Y) ->
    Win = xCreateSimpleWindow(Display,PWin,X,Y,?WT,?HT,0,?XC_cross,xColor(Display,?black),
        ?EVENT_BUTTON_PRESS bor?EVENT_BUTTON_RELEASE bor ?EVENT_BUTTON1_MOTION), 
    xDo(Display, eMapWindow(Win)),
    xFlush(Display),        
    White = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display,?white)}]),  
    xFlush(Display),
    Slider8 = [{1,[{234,170},{333,170},{321,232},{285,285},{215,215},{229,194}]},
		{2,[{215,215},{285,285},{232,321},{170,333},{170,234},{194,229}]},
		{3,[{170,234},{170,333},{108,321},{55,285},{125,215},{146,229}]},
		{4,[{125,215},{55,285},{19,232},{7,170},{106,170},{111,194}]},
		{5,[{106,170},{7,170},{19,108},{55,55},{125,125},{111,146}]},
		{6,[{125,125},{55,55},{108,19},{170,7},{170,106},{146,111}]},
		{7,[{170,106},{170,7},{232,19},{285,55},{215,125},{194,111}]},
		{8,[{215,125},{285,55},{321,108},{333,170},{234,170},{229,146}]}],
    draw_static(Display,Win,White),
    xFlush(Display),
    loop(Parent,Display,Win,White,Slider8,0,0).


    loop(Parent,Display,Win,White,Slider,Value,Last) ->
        receive
            {onMove, _F1} ->
                loop(Parent,Display,Win,White,Slider,Value,Last);
            {event,_, buttonPress, {_,Xr1,Yr1,_,_}} ->
                Pos = slider_pos({Xr1,Yr1},Slider),
                loop(Parent,Display,Win,White,Slider,Value,Pos);
            {event,_,motionNotify, {_,Xr1,Yr1,_,_}} ->
                case Pos = slider_pos({Xr1,Yr1},Slider) of
                    0 -> Value1 = Value,Pos1 = Last;
                    1   when Last == 8 ->
                            Value1 = Value + 1,Pos1 = Pos,
                            sound ! {volume, left};
                    8   when Last == 1 ->					
                        Value1 = Value - 1,Pos1 = Pos,
                        sound ! {volume, right};
                    Pos when Pos < Last -> 
                        Value1 = Value - 1,Pos1 = Pos,
                        sound ! {volume, right};
                    Pos when Pos > Last -> 
                        Value1 = Value + 1,Pos1 = Pos,
                        sound ! {volume, left};
                    _ -> Value1 = Value,Pos1 = Pos
                end,
                loop(Parent,Display,Win,White,Slider,Value1,Pos1);
            {'EXIT', _Pid, _Why} -> true;
            _ ->
                loop(Parent,Display,Win,White,Slider,Value,Last)
    end.

%% slider_pos takes a point and an array of convex polygons and returns the length
%% of the tail when the polygon with the point inside is found.
slider_pos(_,[]) -> 0;
slider_pos(Point,[H|T]) ->
	case is_inside(Point,H) of
		true -> length(T)+1;
		false -> slider_pos(Point,T)
	end.

draw_static(Display,Win,Pen) ->
    xDo(Display,ePolyArc(Win, Pen, [mkArc(7,7,326,326,0,64*360)])),
    xDo(Display,ePolyArc(Win, Pen, [mkArc(106,106,127,127,0,64*360)])).

%% is_inside/2 takes a point and a convex polygon of any number of sides (in this case 6)
%% It returns true if the point is inside the polygon.
is_inside(Point,{_Name,[P1,P2,P3,P4,P5,P6]}) -> 
    is_inside(Point,[P1,P2,P3,P4,P5,P6,P1],[]);

%% is_inside/2 takes a point and a convex polygon of any number of sides (in this case 4)
%% It returns true if the point is inside the polygon.
is_inside(Point,{_Name,[P1,P2,P3,P4]}) -> 
    is_inside(Point,[P1,P2,P3,P4,P1],[]).

is_inside(_,[_|[]],R) -> L = lists:partition(fun(A) -> A > 0 end,R),
    case L of
        {_,[]} -> true;
        {[],_} -> true;
        _      -> false
    end;
is_inside({X,Y},[{P1X,P1Y}|T],R) ->
    [{P2X,P2Y}|_] = T,
    R1 = (P1X * P2Y) - (P1Y * P2X) - (X * P2Y) + (Y * P2X) + (X * P1Y) - (Y * P1X),
    is_inside({X,Y},T,[R1|R]).  



	
