%% Copyright (C) 2009 by S Kvamme
%% All rights reserved.
%% The copyright holder hereby grants the rights of usage, distribution
%% and modification of this software to everyone and for any purpose, as
%% long as this license and the copyright notice above are preserved and
%% not modified. There is no warranty for this software.

-module(dxf2erl).
-author(skvamme).
-vsn("$Id: dxf2erl.erl 94 2009-08-13 21:46:30Z skvamme $").
-compile(export_all).
-import(lists, [reverse/1]).
-import(ets,[lookup/2,insert/2]).
-import(math,[pi/0,pow/2,sqrt/1,atan2/2]).
-define(DOUBLE, 64/little-float).
-define(DWORD, 32/unsigned-little-integer).
-define(WORD, 16/unsigned-little-integer).
-define(BYTE, 8/unsigned-little-integer).
-define(absolute,ok).  %% Define 'absolute' to place graphic at an absolute position in the window coordinate system
% If absolute is undefined, each X-coordinate and Y-coordinate will be paired together with an X+ and an Y+ to make
% it simple to relocate (translate) the drawing in the window.
-ifdef(absolute).
	-define(DX, "").
	-define(DY, "").
-else.
	-define(DX, "X+").
	-define(DY, "Y+").
-endif.

%% ToDo: SEQEND don't have a thickness, so it is not sorted correctly.
%%	More entity types eg POINT
%% Done:
%% 081213	Bug in setting of Color fixed								S Kvamme
%% 081213	Bug in sorting fixed. Changed to sort Thicknes (was Elevation).	S Kvamme
%% 081215	Added X+ and Y+ to every point coordinate, see definition above.	S Kvamme
%% 090909	Added support for ASCII DXF								S Kvamme


%****************************************************************************
% Read a binary dxf file and otput corresponding erlang source for EX11 graphics
%****************************************************************************
start(Dxf) -> % Dxf is "filename.dxf"
	Etable = ets:new(entity,[duplicate_bag,private]), % Store all the entities in this table
	Ttable = ets:new(tmp,[set,private]), % Store temporary group values here
	Arctable = ets:new(arc,[bag,private]),
	case read_dxf_tag(Dxf) of
		error -> io:format("%% Cannot read file: ~p~n",[Dxf]),
			erlang:halt();
		ascii ->  io:format("%% Processing ascii file: ~p~n",[Dxf]),
			io:format("%% Title: ~p~n",[Dxf]),
			{ok, F} = file:open(Dxf, read),
			find_entities_ascii(F),
			io:get_line(F, ''), % get rid of "  0"
			entities_ascii(F,Etable,io:fread(F,'',"~s"));
		bin -> io:format("%% Processing binary file: ~p~n",[Dxf]),
			{ok, B} = file:read_file(Dxf),
			{_,B1} = split_binary(B, 22),
			io:format("%% Title: ~p~n",[Dxf]),
			B2 = find_header(B1),
			limits(B2),
			B3 = find_entities(B2),
			entities(Etable,B3)
		end,
			prints_entities(Etable,Ttable,Arctable),
			Arclist = ets:lookup(Arctable,arc),
			print_arclist(Arclist),
			io:format("%% END~n").


%****************************************************************************************
% Function find_entities_ascii(F1), 
%****************************************************************************************
find_entities_ascii(F) ->
	fea(F,"").
fea(_F,"ENTITIES") -> ok;
fea(_F,eof) -> io:format("Didn't find entities section~n",[]),erlang:halt();
fea(F,_) ->
	fea(F,trim(io:get_line(F, ''))).
	
%****************************************************************************************
% Function entities_ascii(Etable,F1)
%****************************************************************************************
entities_ascii(_F,_Etable,{ok,["ENDSEC"]}) -> ok; 
entities_ascii(_F,_Etable,eof) -> ok;
entities_ascii(F,Etable,E) ->
	entity_ascii(F,Etable,E),
	entities_ascii(F,Etable,io:fread(F,'',"~s")).

%****************************************************************************************
% Function entity_ascii(F,Etable,Entity);
%****************************************************************************************
entity_ascii(F,Etable,E) ->
	Gtable = ets:new(group,[duplicate_bag,private]),
	reset_all(Gtable),
	e_a(F,Etable,Gtable,E, io:fread(F,'',"~s")).

e_a(_F,_Etable,_Gtable,_E,eof) -> ok;
e_a(_F,Etable,Gtable,{ok,[E]},{ok,["0"]}) -> % end of this entity
	params(Gtable,Etable,E,'end',0);
e_a(F,Etable,Gtable,E,{ok,[G]}) ->
	G1 = list_to_integer(G),
	{ok,[S]} = io:fread(F,'',"~s"),
	V = format_value(G1,S), 
	params(Gtable,Etable,E,V,G1),
	e_a(F,Etable,Gtable,E, io:fread(F,'',"~s")).
	
%****************************************************************************************
% Function format_value(G,io:get_line(F, ''))
%****************************************************************************************
format_value(G,S) when G >= 0, G =< 9 -> S; %String
format_value(G,S) when G >= 10, G =< 59 -> {V,_} = string:to_float(S),V;
format_value(G,S) when G >= 60, G =< 79 -> list_to_integer(S);
format_value(G,S) when G >= 90, G =< 99 -> list_to_integer(S);
format_value(100,S) -> S; %String
format_value(102,S) -> S; %String
format_value(105,S) -> S; %String
format_value(G,S) when G >= 140, G =< 147 -> {V,_} = string:to_float(S),V;
format_value(G,S) when G >= 170, G =< 175 -> list_to_integer(S);
format_value(G,S) when G >= 210, G =< 230 -> {V,_} = string:to_float(S),V; % ellipse, ej i standard
format_value(G,S) when G >= 280, G =< 289 -> list_to_integer(S);
format_value(G,S) when G >= 300, G =< 369 -> S; %String
format_value(G,S) when G >= 370, G =< 389 -> list_to_integer(S);
format_value(G,S) when G >= 390, G =< 399 -> S; %String
format_value(G,S) when G >= 400, G =< 409 -> list_to_integer(S);
format_value(G,S) when G >= 410, G =< 419 -> S; %String
format_value(999,S) -> S; %String
format_value(G,S) when G >= 1000, G =< 1009 -> S; %String
format_value(G,S) when G >= 1010, G =< 1059 -> {V,_} = string:to_float(S),V;
format_value(G,S) when G >= 1060, G =< 1071 -> list_to_integer(S).
%format_value(G,S) -> io:format("Group: ~p, Value:  ~p~n",[G,S]).


%****************************************************************************************
% Function trim(String) 
%****************************************************************************************
trim(String) ->
    reverse(strip(reverse(strip(String)))).

strip([$   | Cs]) -> strip(Cs);
strip([$\t | Cs]) -> strip(Cs);
strip([$\r | Cs]) -> strip(Cs);
strip([$\n | Cs]) -> strip(Cs);
strip(Cs) -> Cs.

%****************************************************************************************
% Function print_arclist([])
%****************************************************************************************
print_arclist([]) -> ok;
print_arclist([H|T]) -> {arc,S} = H,
	io:format("~s",[S]),
	print_arclist(T).

%****************************************************************************
% Check that this is a binary DXF
%****************************************************************************
read_dxf_tag(File) -> 
	case file:open(File, [read,binary,raw]) of
		{ok, S} ->
			{ok, B2} = file:pread(S, 0, 18),
			Result = parse_tag(B2),
			file:close(S);
		 _ -> 	
			Result = error
	end,		 
	Result.

	parse_tag(<<$A,$u,$t,$o,$C,$A,$D,$\s,$B,$i,$n,$a,$r,$y,$\s,$D,$X,$F>>) -> bin; 	
	parse_tag(_) -> ascii. 

%****************************************************************************
% Print all the entities, lowest thickness first
%****************************************************************************
prints_entities(Etable,Ttable,Arctable) ->
	Elevlist = elevations(Etable), % print the entities lowest elevation first
	prints_entities1(Elevlist,Etable,Ttable,Arctable).
	
prints_entities1([],_Etable,_Ttable,_Arctable) -> true;
prints_entities1([E|Tail],Etable,Ttable,Arctable) ->
	Entitytuplelist = ets:lookup(Etable,E),
	lists:foreach(fun (Entity) -> print_entity(Entity,Ttable,Arctable) end, Entitytuplelist),
	prints_entities1(Tail,Etable,Ttable,Arctable).

%****************************************************************************
% Create a sorted list with all unique elevations
%****************************************************************************
elevations(Etable) -> 
	Key = ets:first(Etable),
	Elevlist = elevation1(Etable,[],Key),
	lists:usort(Elevlist).

elevation1(_,Elevlist,'$end_of_table') -> Elevlist;
elevation1(Etable,Elevlist,Key) ->
	Key1 = ets:next(Etable,Key),
	elevation1(Etable,[Key|Elevlist],Key1).


%****************************************************************************
% Math functions
%****************************************************************************
rtod(R) -> R * 180 / pi().

rtodfix(R)-> R1 = R * 180 / pi(),
	 case R1 > 360 of
		true -> R1 - 360;
		_ -> R1
		end.

cotbce(B) -> ((1 / B) - B) / 2.

xcenter(X1,X2,Y1,Y2,Cbce) -> (((Y2 - Y1) * Cbce * -1) + X1 + X2) / 2.

ycenter(X1,X2,Y1,Y2,Cbce) -> (((X2 - X1) * Cbce) + Y1 + Y2) / 2.	

radius(X1,Y1,Xcen,Ycen) -> T = pow((Xcen - X1),2) + pow((Ycen - Y1),2),
	sqrt(T).

ang(X1,Y1,Xcen,Ycen) -> atan2((Y1 - Ycen),(X1 - Xcen)).

fixang(Ang) when Ang < 0.0 -> Ang + (2 * pi());
fixang(Ang) -> Ang.

fixang1(Ang) when Ang > 0 -> Ang * -1;
fixang1(Ang) -> Ang.

fixangelips(Ang,R)when Ang > 0, R < 0 -> Ang * -1;
fixangelips(Ang,_R) -> Ang.

fixang2(Stang,Endang) when Stang > Endang -> Endang + 360;
fixang2(_,Endang) -> Endang.

angle(B1,Angle) when B1 < 0 -> 360 - (-1*Angle);
angle(_,Angle) -> Angle.

%****************************************************************************
% Fill or stroke a polyline
%****************************************************************************
doPoly(Ttable,1,_Flags,Bulge,_Bulge1,Pen,X1,Y1) when Bulge /= 0 -> % This is FirstVertex of an Arc
	insert(Ttable,{10,X1}),    % Save point
	insert(Ttable,{20,Y1}),
	insert(Ttable,{42,Bulge}), % Save bulge
	insert(Ttable,{firstvertex,0}),
	io:format("xDo(Display,ePolyFillArc(Win, Pen~p, [",[Pen]);
doPoly(Ttable,1,1,0,_,Pen,X1,Y1) -> % This is FirstVertex of a closed pline
	io:format("xDo(Display,eFillPoly(Win, Pen~B, complex, origin, [mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++"~B),~n",[Pen,round(X1),round(Y1)]),
	insert(Ttable,{firstvertex,0});
doPoly(Ttable,1,_,0,_,Pen,X1,Y1) -> % This is FirstVertex of an open pline
	io:format("xDo(Display,ePolyLine(Win, Pen~B, origin, [mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),~n",[Pen,round(X1),round(Y1)]),	
	insert(Ttable,{firstvertex,0});
doPoly(Ttable,0,_,_,B2,Pen,X1,Y1) when B2 > 0 -> % This is SecondVertex of an Arc
	[{_,X2}|_] = lookup(Ttable, 10), 
	[{_,Y2}|_] = lookup(Ttable, 20), 
	insert(Ttable,{10,X1}),    % Save point
	insert(Ttable,{20,Y1}),
	insert(Ttable,{42,B2}), % Save bulge
	Cbce = cotbce(B2), 
	Ycen = ycenter(X1,X2,Y1,Y2,Cbce),
	Xcen = xcenter(X1,X2,Y1,Y2,Cbce), 
	Rad = radius(X1,Y1,Xcen,Ycen),
	St_ang1 = ang(X1,Y1,Xcen,Ycen), 
	End_ang1 = ang(X2,Y2,Xcen,Ycen),
	St_ang = fixang(St_ang1), 
	End_ang = fixang(End_ang1),	
	StAng = rtod(St_ang), 
	EnAng = rtod(End_ang),
	% Now we have a start and an end angle in degrees	
	EndAng1 = fixang2(StAng,EnAng), % fix end angle if start is more than end
	StAng1 = fixang1(StAng), % Do the angles negative
	Ang = fixang1(EndAng1 - StAng),
	Ang1 = angle(B2,Ang), % same as PostScript arcn if bulge is negative
	Xbbox = Xcen - Rad, Ybbox = Ycen - Rad,
	Method = closeArc(0),	
	io:format("xDo(Display,~s(Win, Pen~B, [mkArc(" ++ ?DX ++ "~B," ++ ?DY ++ "~B,~B,~B,~B,~B)])),~n",
	  [Method,Pen,round(Xbbox),round(Ybbox),round(Rad*2),round(Rad*2),round(64*StAng1),round(64*Ang1)]); 
doPoly(_Ttable,0,_,_,_,_Pen,X1,Y1) -> % This is a vertex of a pline
	io:format("mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),~n",[round(X1),round(Y1)]).


%****************************************************************************
% Write an arc
%****************************************************************************
tryArc(Pen,Closed,[{10,X1}|[{10,X2}|_]],[{20,Y1}|[{20,Y2}|_]],[{42,B1}|_],Arctable) when B1 /= 0 ->
	io:format("mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),~n",[round(X1),round(Y1)]),
	Cbce = cotbce(B1), 
	Ycen = ycenter(X1,X2,Y1,Y2,Cbce),
	Xcen = xcenter(X1,X2,Y1,Y2,Cbce),
	Rad = radius(X1,Y1,Xcen,Ycen),
	St_ang1 = ang(X1,Y1,Xcen,Ycen), 
	End_ang1 = ang(X2,Y2,Xcen,Ycen),
	St_ang = fixang(St_ang1), 
	End_ang = fixang(End_ang1),	
	StAng = rtod(St_ang), 
	EnAng = rtod(End_ang),
	% Now we have a start and an end angle in degrees
	EndAng1 = fixang2(StAng,EnAng), % fix end angle if start is more than end
	StAng1 = fixang1(StAng), % Do the start ang negative
	Ang = fixang1(EndAng1 - StAng),
	Ang1 = angle(B1,Ang), % same as PostScript arcn if bulge is negative
	Xbbox = Xcen - Rad, Ybbox = Ycen - Rad,
	insert(Arctable,{arc, io_lib:format("xDo(Display,~s(Win, Pen~B, [mkArc(" ++ ?DX ++ "~B," ++ ?DY++ "~B,~B,~B,~B,~B)])),~n",
	  [closeArc(Closed),Pen,round(Xbbox),round(Ybbox),round(Rad*2),round(Rad*2),round(64*StAng1),round(64*Ang1)])}); 
tryArc(_Pen,_Closed,[{10,X1}|_],[{20,Y1}|_],_,_) -> io:format("mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),~n",[round(X1),round(Y1)]).

firstVertex(1,1,Pen) ->
	io:format("xDo(Display,eFillPoly(Win, Pen~B, complex, origin, [",[Pen]);
firstVertex(1,0,Pen) ->
	io:format("xDo(Display,ePolyLine(Win, Pen~B, origin, [",[Pen]);	
firstVertex(0,_,_) -> ok.

closeArc(1) -> "ePolyFillArc";
closeArc(_) -> "ePolyArc".

%****************************************************************************
% Fill or stroke an LWpolyline
%****************************************************************************
doLWPoly(_Pen,_Closed,_FirstVertex,[],[],[],_) -> io:format("])),~n",[]);
doLWPoly(Pen,Closed,FirstVertex,G42list,G10list,G20list,Arctable) ->	
	firstVertex(FirstVertex,Closed,Pen),
	tryArc(Pen,Closed,G10list,G20list,G42list,Arctable),
	[_|G42tail] = G42list,[_|G10tail] = G10list,[_|G20tail] = G20list,
	doLWPoly(Pen,Closed,0,G42tail,G10tail,G20tail,Arctable).



isClosed([]) -> 0;
isClosed(_) -> 1.
	
%****************************************************************************
% Print an entity
%****************************************************************************
%print_entity({_,"POINT",Entity},_,_) ->
%	[{_,X1}|_] = lookup(Entity, 10),[{_,Y1}|_] = lookup(Entity, 20),
%	io:format("xDo(Display,ePolyLine(Win, Pen, origin, [mkPoint(~B,~B),mkPoint(~B,~B)])),~n",
%	  [round(X1),round(Y1),round(X1),round(Y1)]);
print_entity({_,"TRACE",Entity},_,_) -> print_entity({0,"SOLID",Entity},0,0);
print_entity({_,"SOLID",Entity},_,_) ->
	[{_,X1}|_] = lookup(Entity, 10),[{_,Y1}|_] = lookup(Entity, 20),
	[{_,X2}|_] = lookup(Entity, 12),[{_,Y2}|_] = lookup(Entity, 22),
	[{_,X3}|_] = lookup(Entity, 13),[{_,Y3}|_] = lookup(Entity, 23),
	[{_,X4}|_] = lookup(Entity, 11),[{_,Y4}|_] = lookup(Entity, 21),
	[{_,Pen}|_] = reverse(lookup(Entity, 62)),
	io:format("xDo(Display,eFillPoly(Win, Pen~B, convex, origin, [mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),
		mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B)])),~n",
	  [Pen,round(X1),round(Y1),round(X2),round(Y2),round(X3),round(Y3),round(X4),round(Y4)]);
print_entity({_,"LINE",Entity},_,_) ->
	[{_,X1}|_] = lookup(Entity, 10),[{_,Y1}|_] = lookup(Entity, 20),
	[{_,X2}|_] = lookup(Entity, 11),[{_,Y2}|_] = lookup(Entity, 21),
	[{_,Pen}|_] = reverse(lookup(Entity, 62)),
	io:format("xDo(Display,ePolyLine(Win, Pen~B, origin, [mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B),mkPoint(" ++ ?DX ++ "~B," ++ ?DY ++ "~B)])),~n",
	  [Pen,round(X1),round(Y1),round(X2),round(Y2)]);
print_entity({_,"ARC",Entity},_,_) ->
	[{_,X1}|_] = lookup(Entity, 10),[{_,Y1}|_] = lookup(Entity, 20),
	[{_,Radius}|_] = lookup(Entity, 40),
	[{_,Startangle}|_] = lookup(Entity, 50),
	[{_,Endangle}|_] = lookup(Entity, 51),
	[{_,Pen}|_] = reverse(lookup(Entity, 62)),
	Endangle1 = fixang2(Startangle,Endangle),
	Endangle2 = Endangle1 - Startangle,
	io:format("xDo(Display,ePolyArc(Win, Pen~B, [mkArc(" ++ ?DX ++ "~B," ++ ?DY ++ "~B,~B,~B,~B,~B)])),~n",
	  [Pen,round(X1 - Radius),round(Y1 - Radius),round(Radius*2),round(Radius*2),
	  	round(fixang1(Startangle)*64),round(fixang1(Endangle2)*64)]);
print_entity({_,"ELLIPSE",Entity},_,_) -> %% dxf2erl:start(dialer_slider_menu.dxf).
	[{_,X1}|_] = lookup(Entity, 10),[{_,Y1}|_] = lookup(Entity, 20),
	[{_,RadiusX}|_] = lookup(Entity, 11),
	[{_,RadiusY}|_] = lookup(Entity, 21),
	[{_,Startangle}|_] = lookup(Entity, 41),
	[{_,Endangle}|_] = lookup(Entity, 42),
	[{_,Ratio}|_] = lookup(Entity, 40),
	[{_,Pen}|_] = reverse(lookup(Entity, 62)),
	Startangle_deg = rtod(Startangle),
	Endangle_deg = rtod(Endangle),
	Endangle_deg1 = fixang2(Startangle_deg,Endangle_deg),
	Endangle_deg2 = Endangle_deg1 - Startangle_deg,
	case abs(RadiusX) < abs(RadiusY) of
	 true -> io:format("xDo(Display,ePolyArc(Win, Pen~B, [mkArc(" ++ ?DX ++ "~B," ++ ?DY ++ "~B,~B,~B,~B,~B)])),~n",
	  [Pen,round(X1 - abs(RadiusY * Ratio)),round(Y1 - abs(RadiusY)),round(abs(RadiusY*2*Ratio)),round(abs(RadiusY*2)),
	  	round(fixangelips(Startangle_deg,RadiusY)*64),round(fixangelips(Endangle_deg2,RadiusY)*64)]); 	
	 _ -> io:format("xDo(Display,ePolyArc(Win, Pen~B, [mkArc(" ++ ?DX ++ "~B," ++ ?DY ++ "~B,~B,~B,~B,~B)])),~n",
	  [Pen,round(X1 - abs(RadiusX)),round(Y1 - abs(RadiusX*Ratio)),round(abs(RadiusX*2)),round(abs(RadiusX*2*Ratio)),
	  	round(fixangelips(Startangle_deg,RadiusX)*64),round(fixangelips(Endangle_deg2,RadiusX)*64)])
	 end;

print_entity({_,"CIRCLE",Entity},_,_) ->
	[{_,X1}|_] = lookup(Entity, 10),[{_,Y1}|_] = lookup(Entity, 20),
	[{_,Radius}|_] = lookup(Entity, 40),[{_,Pen}|_] = reverse(lookup(Entity, 62)),
	io:format("xDo(Display,ePolyArc(Win, Pen~B, [mkArc(" ++ ?DX ++ "~B," ++ ?DY ++ "~B,~B,~B,0,64*360)])),~n",
	  [Pen,round(X1-Radius),round(Y1-Radius),round(Radius*2),round(Radius*2)]);
print_entity({_,"POLYLINE",Entity},Ttable,_) ->
	[{_,Pen}|_] = reverse(lookup(Entity, 62)), 
	Closed = isClosed(lookup(Entity, 70)), 
	insert(Ttable,{firstvertex,1}),
	insert(Ttable,{flags,Closed}),
	insert(Ttable,{42,0}),
	insert(Ttable,{pen,Pen});
print_entity({_,"VERTEX",Entity},Ttable,_) ->
	[{_,X1}|_] = lookup(Entity, 10),
	[{_,Y1}|_] = lookup(Entity, 20),
	case  lookup(Entity, 42) of
		[{_,Bulge}|_] -> ok;
		_ -> Bulge = 0
	end,
	[{_,FV}|_] = lookup(Ttable, firstvertex),
	[{_,Flags}|_] = lookup(Ttable, flags),
	[{_,Pen}|_] = lookup(Ttable, pen),
	[{_,Bulge1}|_] = lookup(Ttable, 42), % Bulge group on previous vertex
	doPoly(Ttable,FV,Flags,Bulge,Bulge1,Pen,X1,Y1);
print_entity({_,"SEQEND",_Entity},Ttable,_) ->
	ets:delete_all_objects(Ttable),
	io:format("])),~n",[]);
print_entity({_,"LWPOLYLINE",Entity},_,Arctable) ->
	[{_,Pen}|_] = reverse(lookup(Entity, 62)), 
	Closed = isClosed(lookup(Entity, 70)),
	G10list = lookup(Entity, 10),
	G20list = lookup(Entity, 20),
	fixBulgelist(Entity,length(lookup(Entity, 10)),length(lookup(Entity, 42))),
	Bulgelist = lookup(Entity, 42),
   doLWPoly(Pen,Closed,1,Bulgelist,G10list,G20list,Arctable);

print_entity({_,_Name,_Entity},_,_) -> ok.
%		List = ets:tab2list(Entity),
%		io:format("~p ~p~n", [Name,List]).

% Fill up with G42's until list length is same as G10's
fixBulgelist(_Entity,X,X) -> ok;
fixBulgelist(Entity,X,Y) -> insert(Entity, {42,0}), fixBulgelist(Entity,X,Y+1).
	
%****************************************************************************
% Find the header section in the dxf file
%****************************************************************************
find_header(B) -> find_header1({B,"",0}).

find_header1({B,"HEADER",2}) -> B;
find_header1({B,_,_}) -> find_header1(parse_dxf(B)).

%****************************************************************************
% Write the size of the drawing
%****************************************************************************
limits(B) -> limits1({B,"",0}).
limits1({B,"$EXTMIN",9}) -> 
	{B1,X1,_G1} = parse_dxf(B), 
	{B2,Y1,_G2} = parse_dxf(B1),
	io:format("% BoundingBox: ~B ~B ",[round(X1),round(Y1)]),
	limits1({B2,"",0});
limits1({B,"$EXTMAX",9}) -> 
	{B1,X2,_G1} = parse_dxf(B), 
	{_B2,Y2,_G2} = parse_dxf(B1),
	io:format("~B ~B~n",[round(X2),round(Y2)]);
limits1({B,_,_}) -> limits1(parse_dxf(B)).

%****************************************************************************
% Insert a new entity table Gtable in the Etable. Thickness is the key, Etype is the entity type
%****************************************************************************
doInsert(Gtable,Etable,Etype) -> 
	[{39,Elev}|_] = reverse(lookup(Gtable, 39)),
	insert(Etable, {Elev,Etype,Gtable}). 

%****************************************************************************
% Erase the previous entity from the Gtable and set some default values
%****************************************************************************
reset_all(Gtable) ->
	ets:delete_all_objects(Gtable),
	insert(Gtable, {6,"CONTINUOUS"}),
	insert(Gtable, {7,"STANDARD"}),
	insert(Gtable, {8,"0"}),
%	insert(Gtable, {11,0}),
	insert(Gtable, {38,0}),
	insert(Gtable, {39,0}),
%	insert(Gtable, {40,0}),
%	insert(Gtable, {41,0}), ELLIPSE uses this
%	insert(Gtable, {42,0}),
	insert(Gtable, {44,0}),
	insert(Gtable, {45,0}),
%	insert(Gtable, {50,0}),
%	insert(Gtable, {51,0}),
	insert(Gtable, {62,0}),
%	insert(Gtable, {70,0}),
	insert(Gtable, {71,0}),
	insert(Gtable, {72,0}).
	
%****************************************************************************
% Find the entities section in the dxf file
%****************************************************************************
find_entities(B) -> find_entities1({B,"",0}).
find_entities1({B,"ENTITIES",2}) -> B;
find_entities1({B,_,_}) -> find_entities1(parse_dxf(B)).

%****************************************************************************
% Step thru each entity in the entities section
%****************************************************************************
entities(_,<<>>) -> true;
entities(Etable,<<0:?WORD,Rest/binary>>) -> 
	Gtable = ets:new(group,[duplicate_bag,private]),
	reset_all(Gtable), 
	{B,T} = ac_text(Rest), 
	B1 = entity(Gtable,Etable,T,B), 
	entities(Etable,B1);
entities(Etable,B) -> 
	{B1,_T1,_G1} = parse_dxf(B), 
	entities(Etable,B1).

%****************************************************************************
% Step thru each Group in an entity
%****************************************************************************
entity(_,_,_,<<>>) -> <<>>;
entity(Gtable,Etable,E,<<0:?WORD,Rest/binary>>) -> 
	params(Gtable,Etable,E,'end',0), 
	<<0:?WORD,Rest/binary>>; %% Reached the end of current entity
entity(Gtable,Etable,E,B) ->
	{B1,V1,G1} = parse_dxf(B), 
	params(Gtable,Etable,E,V1,G1), 
	entity(Gtable,Etable,E,B1).

%****************************************************************************
% Insert each entity into an ets table Gtable
%****************************************************************************
params(Gtable,Etable,Etype, 'end', 0) -> doInsert(Gtable,Etable,Etype);
params(Gtable,_,_, V, 42) -> 
	insertBulge(Gtable, length(lookup(Gtable,10)),length(lookup(Gtable,42)), {42,V});
params(Gtable,_,_, V, G) -> insert(Gtable, {G,V}).

% When inserting a G42, first make sure the G42 list is equally long (-1) as the G10 list 
insertBulge(Gtable,G10,G42,G) when G10 == G42+1 -> insert(Gtable, G);
insertBulge(Gtable,G10,G42,G) -> insert(Gtable, {42,0}),insertBulge(Gtable,G10,G42+1,G).


%****************************************************************************
% Parse the binary dxf file and create erlang data types
%****************************************************************************
ac_text(Thefile) -> T = parse_text(Thefile, []), {_,B1} = split_binary(Thefile, length(T)+1), {B1,T}.

parse_text(<<0:?BYTE,_R/binary>>,Text) -> reverse(Text) ; %% Terminating zero string composer	
parse_text(<<C:?BYTE,R/binary>>,R1) -> parse_text(R, [C|R1]).

ac_double(Thefile) -> <<Y:?DOUBLE,B/binary>> = Thefile, {B,Y}.

% ac_byte(Thefile) -> <<F:?BYTE,B/binary>> = Thefile, {B,F}.

ac_word(Thefile) -> <<F:?WORD,B/binary>> = Thefile, {B,F}.

ac_dword(Thefile) -> <<F:?DWORD,B/binary>> = Thefile, {B,F}.

parse_dxf(<<G0:?WORD,Rest/binary>>) when G0 >= 0, G0 =< 9 -> {B,T} = ac_text(Rest), {B,T,G0};
parse_dxf(<<G10:?WORD,Rest/binary>>) when G10 >= 10, G10 =< 59 -> {B,F} = ac_double(Rest),{B,F,G10};
parse_dxf(<<G60:?WORD,Rest/binary>>) when G60 >= 60, G60 =< 79 -> {B,W} = ac_word(Rest),{B,W,G60};
parse_dxf(<<G90:?WORD,Rest/binary>>) when G90 >= 90, G90 =< 99 -> {B,W} = ac_dword(Rest),{B,W,G90};
parse_dxf(<<G100:?WORD,Rest/binary>>) when G100 >= 100, G100 =< 105 -> {B,T} = ac_text(Rest),{B,T,G100};
parse_dxf(<<G140:?WORD,Rest/binary>>) when G140 >= 140, G140 =< 147 -> {B,F} = ac_double(Rest),{B,F,G140};
parse_dxf(<<G170:?WORD,Rest/binary>>) when G170 >= 170, G170 =< 178 -> {B,W} = ac_word(Rest),{B,W,G170};%% 176-178 not in spec
parse_dxf(<<G210:?WORD,Rest/binary>>) when G210 >= 210, G210 =< 239 -> {B,F} = ac_double(Rest),{B,F,G210};
parse_dxf(<<255:?WORD,Rest/binary>>) -> {B,W} = ac_word(Rest),{B,W,255};
parse_dxf(<<G270:?WORD,Rest/binary>>) when G270 >= 270, G270 =< 275 -> {B,W} = ac_word(Rest),{B,W,G270};%% not in spec
parse_dxf(<<G280:?WORD,Rest/binary>>) when G280 >= 280, G280 =< 289 -> {B,W} = ac_word(Rest),{B,W,G280}; %% ac_byte in spec
parse_dxf(<<G300:?WORD,Rest/binary>>) when G300 >= 300, G300 =< 369 -> {B,T} = ac_text(Rest),{B,T,G300};
parse_dxf(<<G1000:?WORD,Rest/binary>>) when G1000 >= 1000, G1000 =< 1009 -> {B,T} = ac_text(Rest),{B,T,G1000};
parse_dxf(<<G1010:?WORD,Rest/binary>>) when G1010 >= 1010, G1010 =< 1059 -> {B,F} = ac_double(Rest),{B,F,G1010};
parse_dxf(<<G1060:?WORD,Rest/binary>>) when G1060 >= 1060, G1060 =< 1069 -> {B,F} = ac_word(Rest),{B,F,G1060};
parse_dxf(<<G1071:?WORD,Rest/binary>>) when G1071 >= 1071, G1071 =< 1079 -> {B,F} = ac_dword(Rest),{B,F,G1071}.
%parse_dxf(<<G:?WORD,_Rest/binary>>) -> io:format("Missing group: ~w~n",[G]), erlang:halt().
