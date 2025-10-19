/* -*- Mode:Prolog; utf-8; indent-tabs-mode:nil; prolog-indent-width:4; prolog-paren-indent:4; tab-width:8; -*- */

:- consult(view).

%=========== CONTROLLER.PL ===========%
% Logic for the game's controller, that is, logic involving user input.
% It follows a consistent structure:
% "get" functions prompt the user for input, and "set" functions validate it.
% It also handles quit signals (when a user wants to quit) and fails the predicate.
%=====================================%

/* ===== get_game_mode(-GameMode) =====
Prompt the user to input the game mode to be played.
==================== */
get_game_mode(GameMode) :-
    write('Enter mode -> '),
    flush_output,
    read_line(Choice),
    set_game_mode(Choice, GameMode), !,
    GameMode \= quitsignal. % handle quit signal


/* ===== set_game_mode(+Choice, -GameMode) =====
Validate the user's input for game mode and return it.
==================== */
set_game_mode("1", 1).
set_game_mode("2", 2).
set_game_mode("3", 3).
% default, hit ENTER
set_game_mode("", 1).
% wants to quit, send back a "quit" signal
set_game_mode("q", quitsignal) :- print_quit_message.
set_game_mode("Q", quitsignal) :- print_quit_message.
% invalid choice, recursion
set_game_mode(_, GameMode) :-
    nl, write('/!\\ Invalid mode, please retry /!\\'), nl,
    get_game_mode(GameMode).


/* ===== get_difficulty(+PlayerName, -GameDifficulty) =====
Prompt the user to input the difficulty mode for a specific player.
==================== */
get_difficulty(PlayerName, GameDifficulty) :-
    write('Enter difficulty for '),
    write(PlayerName),
    write(' -> '),
    flush_output,
    read_line(Choice),
    set_difficulty(Choice, PlayerName, GameDifficulty), !,
    GameDifficulty \= quitsignal.


/* ===== set_difficulty(+Choice, +PlayerName, -GameDifficulty) =====
Validate the user's input for difficulty level and
return the game's difficulty (as Int, easier to manage).
==================== */
set_difficulty("1", _, 1).
set_difficulty("2", _, 2).
% default
set_difficulty("", _, 1).
% quit
set_difficulty("q", _, quitsignal) :- print_quit_message.
set_difficulty("Q", _, quitsignal) :- print_quit_message.
% invalid
set_difficulty(_, PlayerName, GameDifficulty) :-
    nl, write('/!\\ Invalid mode, please retry /!\\'), nl,
    get_difficulty(PlayerName, GameDifficulty).


/* ===== get_starting_player(-StartingPlayer) =====
Prompt the user to specify which player will start the game.
(used in Human v Computer mode to determine the starting player)
==================== */
get_starting_player(StartingPlayer) :-
    write('Enter starting player -> '),
    flush_output,
    read_line(Choice),
    set_starting_player(Choice, StartingPlayer), !,
    StartingPlayer \= quitsignal.


/* ===== set_starting_player(+Choice, -StartingPlayer) =====
Validate the user's input for starting player and return the parsed value.
==================== */ 
set_starting_player("1", human).
set_starting_player("2", computer).
% default
set_starting_player("", human).
% quit
set_starting_player("q", quitsignal) :- print_quit_message.
set_starting_player("Q", quitsignal) :- print_quit_message.
% invalid
set_starting_player(_, StartingPlayer) :-
    nl, write('/!\\ Invalid option, please retry /!\\'), nl,
    get_starting_player(StartingPlayer).


/* ===== get_move(-From, -To) =====
Prompt the user to specify the next move in the game.
==================== */
get_move(From, To) :-
    write('Enter coordinates as XY. (example: 12)'), nl,
    get_move(From, To, _).

% omits initial message
get_move(From, To, _) :-
    get_point('From', From),
    get_point('To', To).

/* ===== get_point(+PointName, -Point) =====
Prompt the user to specify a point in 2d space.
Recursive if input is invalid.
==================== */
get_point(PointName, Point) :-
    write(PointName),
    write(' -> '),
    flush_output,
    read_line(Choice),
    set_point(Choice, PointName, Point), !,
    Point \= quitsignal.


/* ===== set_point(+Choice, +PointName, -Point) =====
Validate the user's input for a point in 2d space.
Called twice per move (points From and To).
==================== */ 
% quit
set_point("q", _, quitsignal) :- print_quit_message.
set_point("Q", _, quitsignal) :- print_quit_message.
% valid input
set_point(Choice, _, (X,Y)) :-
                           % check length
                           length(Choice, 2),
                           % check if int
                           Choice = [Code1,Code2],
                           Code1 >= 0'0, Code1 =< 0'9,
                           Code2 >= 0'0, Code2 =< 0'9,
                           % convert to int
                           X is Code1 - 0'0,
                           Y is Code2 - 0'0,
                           % check range
                           member(X, [1,2,3,4,5,6,7,8,9]),
                           member(Y, [1,2,3,4,5]).
% invalid
set_point(_, PointName, Point) :-
    nl, write('/!\\ Invalid cell, try again. /!\\'), nl,
    get_point(PointName, Point). % recursive, until valid point


/* ===== wait_for_enter() =====
Returns when the player pressed ENTER, i.e. a newline.
Any other input along with it is also accepted.
==================== */ 
wait_for_enter :-
    write('Press ENTER to view this move.'), nl,
    read_line(Input),
    % everything except 'q' or 'Q'
    \+ is_quit_signal(Input).


/* ===== is_quit_signal(+Input) =====
Returns if the input provided is a quit signal ("q" or "Q").
==================== */ 
is_quit_signal("q") :- print_quit_message.
is_quit_signal("Q") :- print_quit_message.

