-module(dialerbutton).
-author(skvamme).
-export([make/6,init/6,loop/9]).
-define (WT,120).
-define (HT,120).
-include("ex11_lib.hrl").
-import(ex11_lib, [ePutImage/9,eChangeGC/2,xColor/2,xCreateSimpleWindow/10,eGetImage/5,mkArc/6,ePolyArc/3,eMapWindow/1,xDo/2,xFlush/1,eCopyArea/9,xCreateGC/2,
    ePolyLine/4,mkPoint/2]).

make(Parent,Display,PWin,X,Y,Figure) -> 
    spawn_link(?MODULE,init,[Parent,Display,PWin,X,Y,Figure]).


init(Parent,Display,PWin,X,Y,Figure) ->
    Win = xCreateSimpleWindow(Display,PWin,X,Y,?WT,?HT,0,?XC_cross,xColor(Display,?white),
        ?EVENT_EXPOSURE bor ?EVENT_BUTTON_PRESS bor ?EVENT_BUTTON_RELEASE), 
    xDo(Display, eMapWindow(Win)),
    xFlush(Display),        
    Black = xCreateGC(Display, [{function,copy},{line_width,20},{foreground, xColor(Display, 16#000000)}]),  
    draw_figure(Display,Win,Black,Figure),
    xFlush(Display),
    % Red0 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#500000)}]),
    % Red1 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#600000)}]),
    % Red2 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#700000)}]),
    % Red3 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#800000)}]),
    % Red4 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#900000)}]),	
    Red5 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#FFEEEE)}]),
    Red6 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#FFDDDD)}]),
    Red7 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#FFCCCC)}]),
    Red8 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#FFBBBB)}]),
    Red9 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#FFAAAA)}]),
    Red10 = xCreateGC(Display, [{line_width,20},{foreground, xColor(Display, 16#FF9999)}]),
    Redlist = [Red10,Red9,Red8,Red7,Red6,Red5],
    Bling = lists:reverse([mkArc(0,0,120,120,0,64*360),mkArc(10,10,100,100,0,64*360),mkArc(20,20,80,80,0,64*360),
            mkArc(30,30,60,60,0,64*360),mkArc(40,40,40,40,0,64*360),mkArc(50,50,20,20,0,64*360)]),
    eChangeGC(Black,[{plane_mask,16#00000001}]),
    {ok,Image} = xDo(Display, eGetImage(Win,?WT,?HT,0,0)),
    xFlush(Display),
    loop(Parent,Display,Win,Image,Bling,Redlist,Black,fun() -> null end,infinity).

loop(Parent,Display,Win,Image,Bling,Redlist,Black,F,Delay) ->
    receive
        {event,_, buttonPress, _} ->
            receive
                {event,_, buttonRelease, _} ->
                    F1 = fun() -> bling(Display,Win,Image,Bling,Redlist,Black) end,
		            ?MODULE:loop(Parent,Display,Win,Image,Bling,Redlist,Black,F1,50)
            after 1000 -> 
                    F1 = fun() -> bling(Display,Win,Image,Bling,Redlist,Black) end,
		            ?MODULE:loop(Parent,Display,Win,Image,Bling,Redlist,Black,F1,50)
            end;
	{infinity} -> ?MODULE:loop(Parent,Display,Win,Image,Bling,Redlist,Black,F,infinity);
	{'EXIT', _Pid, _Why} -> true;
	_Any -> ?MODULE:loop(Parent,Display, Win,Image,Bling,Redlist,Black,F,Delay)
	after Delay ->
		F1 = F(),
		xFlush(Display),
		?MODULE:loop(Parent,Display, Win,Image,Bling,Redlist,Black,F1,Delay)
   end.

% Draw the Bling in a new colour
bling(Display,Win,{Depth,Image},[Bling|B],[Red|R],Black) -> 
    xDo(Display,ePutImage(Win, Black, ?WT, ?HT, 0, 0, 0, Depth, Image)),
    xDo(Display,ePolyArc(Win,Red,[Bling])),
    case B of
	   [] -> self() ! {infinity}, 
            xDo(Display,ePutImage(Win, Black, ?WT, ?HT, 0, 0, 0, 16, Image)),
            fun() -> null end;
	   _ -> fun() -> bling(Display,Win,{Depth,Image},B,R,Black) end
    end.


draw_figure(Display, Win, Pen0,"0") ->
%% Title: ['mok_0.dxf']
% BoundingBox: 0 0 120 120
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(54,13),mkPoint(66,13)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(66,108),mkPoint(55,108)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(35,89),mkPoint(35,33)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(35,13,39,39,-11520,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(35,69,39,39,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(85,33),mkPoint(85,89)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(46,13,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(46,69,39,39,-23040,-5760)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"1") ->
%% Title: mok_1.dxf
% BoundingBox: 0 0 160 160
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(60,115),mkPoint(60,5)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"2") ->
%% Title: ['mok_2.dxf']
% BoundingBox: 23 10 96 109
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(93,108),mkPoint(27,108),mkPoint(27,77)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,19,39,39,0,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,14,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(27,58,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(73,14),mkPoint(24,14)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(47,58),mkPoint(73,58)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(92,39),mkPoint(92,34)])),
%% END

xFlush(Display);

draw_figure(Display, Win, Pen0,"3") ->
%% Title: ['mok_3.dxf']
% BoundingBox: 20 9 96 111
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,13,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,20,39,39,0,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,58,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,69,39,39,0,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(73,58),mkPoint(20,58)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(20,13),mkPoint(73,13)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(73,108),mkPoint(20,108)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(92,33),mkPoint(92,40)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(92,78),mkPoint(92,89)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"4") ->
%% Title: mok_4.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(26,72),mkPoint(73,10)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(20,77),mkPoint(101,77)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(73,77),mkPoint(73,115)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(73,6),mkPoint(73,55)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"5") ->
%% Title: ['mok_5.dxf']
% BoundingBox: 22 13 97 111
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(22,108),mkPoint(73,108)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(73,53),
mkPoint(27,53),mkPoint(27,13),mkPoint(93,13)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,53,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(92,89),mkPoint(92,73)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(53,69,39,39,-23040,-5760)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"6") ->
%% Title: ['mok_6.dxf']
% BoundingBox: 31 10 90 111
xDo(Display,ePolyArc(Win, Pen0, [mkArc(46,69,39,39,-23040,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(54,14),mkPoint(90,14)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(46,54,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(35,89),mkPoint(35,54)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(53,54),mkPoint(66,54)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(35,14,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(35,54),mkPoint(35,34)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(66,108),mkPoint(54,108)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(35,69,39,39,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(85,73),mkPoint(85,89)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"7") ->
%% Title: mok_7.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(26,110),
mkPoint(88,13),
mkPoint(18,13)
])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"8") ->
%% Title: ['mok_8.dxf']
% BoundingBox: 26 9 94 111
xDo(Display,ePolyArc(Win, Pen0, [mkArc(51,13,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(51,17,39,39,0,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(51,55,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(51,69,39,39,0,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(30,89),mkPoint(30,75)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(30,13,39,39,-11520,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(30,17,39,39,-5760,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(30,55,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(50,13),mkPoint(71,13)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(50,55),mkPoint(71,55)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(30,37),mkPoint(30,33)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(30,69,39,39,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(50,108),mkPoint(71,108)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(90,89),mkPoint(90,75)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(90,37),mkPoint(90,33)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"9") ->
%% Title: ['mok_9.dxf']
% BoundingBox: 31 9 89 111
xDo(Display,ePolyArc(Win, Pen0, [mkArc(46,69,39,39,-23040,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(46,13,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(55,13),mkPoint(66,13)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(68,59),mkPoint(55,59)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(35,40),mkPoint(35,33)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(35,13,39,39,-11520,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(35,20,39,39,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(66,108),mkPoint(31,108)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(85,33),mkPoint(85,89)])),
%% END
xFlush(Display);

draw_figure(Display, Win,Pen0, "#") ->
%% Title: mok_hash.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(5,75),mkPoint(114,75)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(5,45),mkPoint(114,45)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(75,115),mkPoint(75,6)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(45,115),mkPoint(45,6)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0,"*") ->
%% Title: mok_star.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(60,115),mkPoint(60,6)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(12,33),mkPoint(107,87)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(107,33),mkPoint(12,87)])),
%% END
xFlush(Display).

