-module(barcode).
-author(skvamme).
-export([start/0,init/0,loop/4]).
-define (WT,800).
-define (HT,480).
-include("ex11_lib.hrl").
-import(ex11_lib, [xDo/2,xPen/3,xClearArea/1,xFlush/1,xColor/2,eFillPoly/5,xCreateSimpleWindow/7,eMapWindow/1,mkPoint/2,xSetScreenSaver/2]).

% 0 narrow black % 1 wide black % 2 narrow white % 3 wide white

start() -> spawn(?MODULE,init,[]).

init() ->
    {ok, Display} = ex11_lib:xStart("3.1"),
    xSetScreenSaver(Display,0),
    Window = xCreateSimpleWindow(Display,0,0,?WT,?HT,?XC_arrow,xColor(Display,?white)),
    xDo(Display, eMapWindow(Window)),
    xFlush(Display),
    Black = xPen(Display,0,?black),
    xFlush(Display),
    self() ! {new,"1234567890"},
	Figures = {[0,2,0,3,1,2,1,2,0],[1,2,0,3,0,2,0,2,1],[0,2,1,3,0,2,0,2,1],[1,2,1,3,0,2,0,2,0],[0,2,0,3,1,2,0,2,1],
		[1,2,0,3,1,2,0,2,0],[0,2,1,3,1,2,0,2,0],[0,2,0,3,0,2,1,2,1],[1,2,0,3,0,2,1,2,0],[0,2,1,3,0,2,1,2,0]},
    loop(Display,Window,Figures,Black).

loop(Display,Window,{Zero,One,Two,Three,Four,Five,Six,Seven,Eight,Nine},Black) ->
    receive
    	{new,Str} -> Codearray = lists:map(fun(Char) -> case Char of
	    		48 -> Zero;
	    		49 -> One;
	    		50 -> Two;
	    		51 -> Three;
	    		52 -> Four;
	    		53 -> Five;
	    		54 -> Six;
	    		55 -> Seven;
	    		56 -> Eight;
	    		57 -> Nine
	    	end end,Str),
    		draw_new(Display,Window,Codearray,Black),
    		?MODULE:loop(Display,Window,{Zero,One,Two,Three,Four,Five,Six,Seven,Eight,Nine},Black);
    	Any -> io:format("~p got unknown msg: ~p~n",[?MODULE, Any]),
			?MODULE:loop(Display,Window,{Zero,One,Two,Three,Four,Five,Six,Seven,Eight,Nine},Black)
	end.

draw_new(Display,Window,Codearray,Black) ->
	xClearArea(Window),
	Codearray1 = [[0,3,0,2,1,2,1,2,0]|lists:reverse(Codearray)],
	Codearray2 = [[0,3,0,2,1,2,1,2,0]|Codearray1],
	d_n(Display,Window,Black,Codearray2,1).

d_n(Display,_,_,[],_) -> xFlush(Display);
d_n(Display,Window,Black,[Head|Tail],X) ->
	X1 = d_n_n(Display,Window,Black,Head,X),
	xFlush(Display),
	d_n(Display,Window,Black,Tail,X1).

d_n_n(_,_,_,[],X) -> X;
d_n_n(Display,Window,Black,[Head|Tail],X) ->
	X1 = case Head of
		0 -> xDo(Display,eFillPoly(Window,Black,convex,origin,[mkPoint(X,0),mkPoint(X+3,0),mkPoint(X+3,200),mkPoint(X,200)])), 3;
		1 -> xDo(Display,eFillPoly(Window,Black,convex,origin,[mkPoint(X,0),mkPoint(X+9,0),mkPoint(X+9,200),mkPoint(X,200)])), 9;
		2 -> 3;
		3 -> 9
	end,
	d_n_n(Display,Window,Black,Tail,X+X1).


