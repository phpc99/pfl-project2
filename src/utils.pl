/* -*- Mode:Prolog; coding:utf-8; indent-tabs-mode:nil; prolog-indent-width:4; prolog-paren-indent:4; tab-width:8; -*- */

:- use_module(library(lists)).

%=========== UTILS.PL ===========%
% Utilities for the game code.
%================================%


/* ===== newl(?N) =====
Print N empty lines.
==================== */
newl(0) :- !.
newl(N) :-
    nl,
    N1 is N-1,
    newl(N1).


/* ===== replace(+Index, +List, +Element, -NewList) =====
Replace a value in a list at an index.
(from stackoverflow, referenced @README)
==================== */
replace(I, L, E, NL) :-
  nth1(I, L, _, R),
  nth1(I, NL, E, R).


/* ===== game_board(?Board) =====
Get the game board.
==================== */
game_board([
       [b,w,b,w,b,w,b,w,b],
       [w,.,.,.,.,.,.,.,w],
       [.,.,.,.,.,.,.,.,.],
       [b,.,.,.,.,.,.,.,b],
       [w,b,w,b,w,b,w,b,w]
    ]).


/* ===== get_cell(+Board, +X, +Y, -Element) =====
Get cell at position (X,Y) of a 2D board.
==================== */
get_cell(Board, X, Y, E) :-
    length(Board, LengthB),
    % (1,1) at lower left corner
    FlippedY is LengthB +1 -Y,
    nth1(FlippedY, Board, Row),
    nth1(X, Row, E).


/* ===== set_cell(+Board, +X, +Y, +NewValue, -NewBoard) =====
Set cell at position (X,Y) of a 2D board.
==================== */
set_cell(Board, X, Y, NewValue, NewBoard) :-
    length(Board, LengthB),
    % flip Y
    FlippedY is LengthB +1 -Y,
    nth1(FlippedY, Board, Row),
    replace(X, Row, NewValue, NewRow),
    replace(FlippedY, Board, NewRow, NewBoard).


% ===== Extra utilities =====

% other_player(?Player, ?Player)
other_player(white, black).
other_player(black, white).

% get current player from state
% current_player(?GameState, ?CurrentPlayer)
current_player(state(CurrentPlayer,
               _Board,
               _Config),
               CurrentPlayer).

% get player details
% player_details(+GameState, +Player, -Type, -DifficultyLevel)
player_details(state(_Player, _Board,
               config(white(TypeW, Lw), black(_TypeB, _Lb))),
               white, TypeW, Lw).
player_details(state(_Player, _Board,
               config(white(_TypeW, _Lw), black(TypeB, Lb))),
               black, TypeB, Lb).

% atom -> cell
% cell_atom(?atom, ?cell)
cell_atom(black, b).
cell_atom(white, w).

% direction(?X, ?Y)
direction(1, 0).
direction(-1, 0).
direction(0, 1).
direction(0, -1).
direction(1, 1).
direction(-1, 1).
direction(1, -1).
direction(-1, -1).

% within_bounds(?X, ?Y)
within_bounds(X, Y) :-
    X >= 1,
    X =< 9,
    Y >= 1,
    Y =< 5.

% corner_piece(?X,?Y)
corner_piece(1,1).
corner_piece(1,5).
corner_piece(9,1).
corner_piece(9,5).

% edge_piece(?X,?Y)
edge_piece(1,Y) :- % left edge
    Y > 1,
    Y < 5.
edge_piece(9,Y) :- % right edge
    Y > 1,
    Y < 5.
edge_piece(X,1) :- % top edge
    X > 1,
    X < 9.
edge_piece(X,5) :- % bottom edge
    X > 1,
    X < 9.

