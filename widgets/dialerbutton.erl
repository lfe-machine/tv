-module(dialerbutton).
-author(skvamme).
-export([make/6,init/6,loop/8]).
-define (WT,150).
-define (HT,150).
-include("ex11_lib.hrl").
-import(ex11_lib, [ePolyText8/5, rpc/2, sleep/1, xClearArea/1,map/2,eFillPoly/5,eCopyArea/9,
    eConfigureWindow/2,ePolyFillRectangle/3,ePolyLine/4,ePolyRectangle/3,ePolyFillArc/3,
    mkArc/6,ePolyArc/3,mkPoint/2,mkRectangle/4,xClearArea/1,xColor/2,xCreateGC/2,xCreatePixmap/4,
    xDo/2, xFlush/1,xVar/2,ePutImage/9,xCreateSimpleWindow/10,eMapWindow/1]).

make(Parent,Display,PWin,X,Y,Figure) -> 
    spawn_link(?MODULE,init,[Parent,Display,PWin,X,Y,Figure]).

init(_Parent,Display,PWin,X,Y,Figure) ->
    Win = xCreateSimpleWindow(Display,PWin,X,Y,?WT,?HT,0,?XC_cross,xColor(Display,?white),
        ?EVENT_EXPOSURE bor ?EVENT_BUTTON_PRESS bor ?EVENT_BUTTON_RELEASE), 
    xDo(Display, eMapWindow(Win)),
    xFlush(Display),        
    Face =  xCreatePixmap(Display,Win,?WT,?HT),
    Black = xCreateGC(Display, [{function,copy},{line_width,15},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, ?black)}]),
    Grey = xCreateGC(Display, [{function,copy},{line_width,1},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, ?grey)}]),
    Green = xCreateGC(Display, [{function,copy},{line_width,15},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, ?green)}]),
    Red = xCreateGC(Display, [{function,copy},{line_width,15},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, ?red)}]),
 
   Pen0 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#FF0000)}]),
   Pen1 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#F81313)}]),
   Pen2 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#F22626)}]),
   Pen3 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#EB3939)}]),
   Pen4 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#E54C4C)}]), 
   Pen5 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#DE5F5F)}]),
   Pen6 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#D87272)}]),
   Pen7 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#D18585)}]),
   Pen8 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#CB9898)}]),
   Pen9 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#C4ABAB)}]),
   Pen10 = xCreateGC(Display, [{function,copy},{line_width,20},{arc_mode,chord},{line_style,solid},
    {graphics_exposures, false},{foreground, xColor(Display, 16#BEBEBE)}]),

    xDo(Display, ePolyFillRectangle(Face, Grey,[mkRectangle(0,0,?WT,?HT)])),
    draw_figure(Display, Face, Black, Red, Green, Figure),
    Bin = eCopyArea(Face,Win,Black,0,0,0,0,?WT,?HT),
    xDo(Display, Bin),
    xFlush(Display),
    %F = fun() -> blang() end,
    Pen = [Pen0,Pen0,Pen0,Pen0,Pen0,Pen1,Pen1,Pen1,
        Pen2,Pen2,Pen2,Pen3,Pen3,Pen4,Pen4,Pen5,Pen5,Pen5,
        Pen6,Pen6,Pen6,Pen7,Pen7,Pen7,Pen8,Pen8,Pen8,Pen8,
        Pen9,Pen9,Pen9,Pen9,Pen9,Pen10,Pen10,Pen10,Pen10,
        Pen10,Pen10,Pen10,Pen10,Pen10,Pen10,Pen10,Pen10,
        Pen10,Pen10,Pen10],
     F = fun() -> null end,
    loop(Display, Win, Pen, ?WT, Bin, F,infinity,Figure).

loop(Display, Win, Pen, Size, Bin, F, Delay, Figure) ->
    receive
    {event,_, buttonPress, _} ->
       F1 = fun() -> bling(Display, Win, Pen, Size, 20, Bin) end,
        loop(Display, Win, Pen, Size, Bin, F1, 10, Figure);
    {event,_, buttonRelease, _} -> io:fwrite("buttonRelease~n", []),
        loop(Display, Win, Pen, Size, Bin, F, Delay, Figure);
    {event,_,expose, _} ->
        %F(),
         xDo(Display, Bin),xFlush(Display),
        loop(Display, Win, Pen, Size, Bin, F, Delay, Figure);
    {infinity} -> loop(Display, Win, Pen, Size, Bin, F, infinity, Figure);
    {'EXIT', _Pid, _Why} ->
        true;
    _ ->
        loop(Display, Win, Pen, Size, Bin, F, Delay, Figure)
    after Delay ->
        F1 = F(),
        xFlush(Display),
        loop(Display, Win, Pen, Size, Bin, F1, Delay, Figure)
   end.

% Copy the face bitmap to the top rectangle, this will have the effect of erasing the previous ring
% Draw the new ring
bling(Display, Win, [Pen|T], Max, Size, Bin) -> 
    xDo(Display, Bin),
    xDo(Display,ePolyArc(Win, Pen, [mkArc(round((Max/2)-(Size/2)),round((Max/2)-(Size/2)),Size,Size,0,64*360)])),
    case T of
    [] ->
         self() ! {infinity};
    _ ->
        fun() -> bling(Display, Win, T, Max, Size+4, Bin) end
    end.

draw_figure(Display, Win, Pen0, _, _, "0") ->
%% Title: mok_0.dxf
% BoundingBox: 38 14 114 135
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(51,103),mkPoint(51,47)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(51,28,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(71,28),mkPoint(82,28)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(62,28,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(101,47),mkPoint(101,103)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(62,83,39,39,-23040,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(82,122),mkPoint(71,122)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(51,83,39,39,-5760,-5760)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "1") ->
%% Title: mok_1.dxf
% BoundingBox: 67 21 82 130
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(75,130),mkPoint(75,21)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "2") ->
%% Title: mok_2.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(108,123),mkPoint(42,123),mkPoint(42,92)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(42,73,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(62,73),mkPoint(89,73)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,34,39,39,0,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(108,54),mkPoint(108,49)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,29,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(89,29),mkPoint(39,29)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "3") ->
%% Title: mok_3.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(35,28),mkPoint(89,28)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,28,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(108,47),mkPoint(108,55)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,35,39,39,0,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(89,74),mkPoint(35,74)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,73,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(108,92),mkPoint(108,104)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,84,39,39,0,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(89,123),mkPoint(35,123)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "4") ->
%% Title: mok_4.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(41,87),mkPoint(88,25)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(35,92),mkPoint(116,92)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(88,92),mkPoint(88,130)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(88,21),mkPoint(88,70)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "5") ->
%% Title: mok_5.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(37,123),mkPoint(89,123)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,84,39,39,-23040,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(108,104),mkPoint(108,87)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(69,68,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(89,68),mkPoint(42,68),mkPoint(42,28),mkPoint(108,28)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "6") ->
%% Title: mok_6.dxf OBS EXTRA linje i ritningen
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(67,69),mkPoint(81,69)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(61,69,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(100,88),mkPoint(100,105)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(61,85,39,39,-23040,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(81,124),mkPoint(69,124)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(50,85,39,39,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(50,105),mkPoint(50,49)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(50,29,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(69,29),mkPoint(105,29)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "7") ->
%% Title: mok_7.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(41,125),mkPoint(103,28)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(109,28),mkPoint(33,28)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "8") ->
%% Title: mok_8.dxf
% BoundingBox: 36 14 109 126
xDo(Display,ePolyArc(Win, Pen0, [mkArc(66,84,39,39,0,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(66,70,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(66,32,39,39,0,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(66,28,39,39,-17280,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(45,84,39,39,-5760,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(45,70,39,39,-11520,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(45,32,39,39,-5760,-5760)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(45,28,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(64,123),mkPoint(86,123)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(64,71),mkPoint(86,71)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(64,28),mkPoint(86,28)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(45,52),mkPoint(45,47)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(105,52),mkPoint(105,47)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(45,104),mkPoint(45,90)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(105,104),mkPoint(105,90)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "9") ->
%% Title: mok_9.dxf OBS Extra linje i ritning
% BoundingBox: 0 0 150 150
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(83,74),mkPoint(70,74)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(50,35,39,39,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(50,55),mkPoint(50,47)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(50,28,39,39,-11520,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(70,28),mkPoint(81,28)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(61,28,39,39,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(100,47),mkPoint(100,104)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(61,84,39,39,-23040,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(81,123),mkPoint(46,123)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen1, _Red, Pen0, "dial") ->
%% Title: mokophone_green.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyArc(Win, Pen1, [mkArc(45,49,101,101,-10950,-6991)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(31,15),mkPoint(119,15)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(102,15,33,33,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(135,31),mkPoint(135,119)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(102,102,33,33,0,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(119,135),mkPoint(31,135)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(15,102,33,33,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(15,119),mkPoint(15,31)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(15,15,33,33,-11520,-5760)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "#") ->
%% Title: mok_hash.dxf
% BoundingBox: 20 21 129 130
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(20,90),mkPoint(129,90)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(20,60),mkPoint(129,60)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(90,130),mkPoint(90,21)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(60,130),mkPoint(60,21)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen1, Pen0, _Green, "cancel") ->
%% Title: mokophone_red.dxf
% BoundingBox: 0 0 150 150
xDo(Display,ePolyArc(Win, Pen1, [mkArc(24,63,101,101,-13785,-6991)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(31,15),mkPoint(119,15)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(102,15,33,33,-17280,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(135,31),mkPoint(135,119)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(102,102,33,33,0,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(119,135),mkPoint(31,135)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(15,102,33,33,-5760,-5760)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(15,119),mkPoint(15,31)])),
xDo(Display,ePolyArc(Win, Pen0, [mkArc(15,15,33,33,-11520,-5760)])),
%% END
xFlush(Display);

draw_figure(Display, Win, Pen0, _, _, "*") ->
%% Title: mok_star.dxf
% BoundingBox: 23 21 126 130
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(75,130),mkPoint(75,21)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(27,48),mkPoint(122,102)])),
xDo(Display,ePolyLine(Win, Pen0, origin, [mkPoint(122,48),mkPoint(27,102)])),
%% END
xFlush(Display).


