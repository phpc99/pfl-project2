/* -*- Mode:Prolog; coding:utf-8; indent-tabs-mode:nil; prolog-indent-width:4; prolog-paren-indent:4; tab-width:8; -*- */

:- consult(utils).

%=========== VIEW.PL ===========%
% Views to be displayed during the game.
%================================%


/* ===== print_welcome_message/0 =====
Display the game's welcome message.
==================== */
print_welcome_message :-
    newl(50),
    % credit to the creator
    write('============ % ============'), nl,
    write(' COLLAPSE, by Kanare Kato'), nl,
    write('============ % ============'),
    newl(2),
    % print welcome message
    write('Please select a game mode.'), nl,
    write('To quit, enter Q.'),
    newl(2),
    write('1- Human vs Human️ (default)'), nl,
    write('2- Human vs Computer'), nl,
    write('3- Computer vs Computer'),
    newl(2),
    write('------------ % ------------'), nl,
    !.


/* ===== print_difficulty_message/0 =====
Display the difficulty mode selection menu.
==================== */
print_difficulty_message :-
    newl(50),
    write('------------ % ------------'), nl,
    write('Choose the difficulty mode.'),
    newl(2),
    write('    1- Easy (default)'), nl,
    write('    2- Hard'),
    newl(2),
    write('------------ % ------------'), nl,
    !.


/* ===== print_starting_player_message/0 =====
Display the "starting player" message, prompting the
user to choose which computer will go play first.
==================== */
print_starting_player_message :-
    newl(50),
    write('------------ % ------------'), nl,
    write('Select the starting player.'), nl,
    write('White pieces move first.'),
    newl(2),
    write('    1- Human (default)'), nl,
    write('    2- Computer 2'),
    newl(2),
    write('------------ % ------------'), nl,
    !.


/* ===== print_quit_message/0 =====
Display the game's farewell (quit) message.
==================== */
print_quit_message :-
    newl(50),
    write('------------ % ------------'), nl,
    write('Exiting, goodbye.'), nl,
    write('------------ % ------------'), nl,
    !.


/* ===== display_game(+GameState) =====
Display the game board to the user, along with
some additional game state information.
==================== */
display_game(state(CurrentPlayer, Board, _Config)) :-
    newl(50),
    write('-------------- % --------------'),
    newl(2),
    format('   --> It\'s ~w\'s turn! <--', CurrentPlayer),
    newl(2),
    print_board(Board),
    newl(2),
    write('-------------- % --------------'),
    nl,
    !.


% print_board(+Board)
% assuming a 9x5 board
print_board([]) :-
    write('     (1)(2)(3)(4)(5)(6)(7)(8)(9)'),
    nl.
print_board([Row | Rest]) :-
    length(Rest, Idx),
    Idx1 is Idx+1,
    format(' (~w)  ', Idx1),
    print_row(Row),
    nl, nl,
    print_board(Rest).


% print_row(+BoardRow)
print_row([]) :- !.
print_row([w | Rest]) :-
    write('W  '),
    print_row(Rest).
print_row([b | Rest]) :-
    write('B  '),
    print_row(Rest).
print_row([X | Rest]) :-
    write(X),
    write('  '),
    print_row(Rest).


/* ===== print_game_over_message(+Board, +Winner) =====
Print the game over message, which includes the
final game board along with the winner.
==================== */

% Enemy trapped
print_game_over_message(Board, winner(Winner, enemytrapped)) :-
    newl(50),
    write('--------------- % ---------------'),
    newl(2),
    print_board(Board),
    nl,
    write('============== % ==============='),
    newl(2),
    format('   < GAME OVER, ~w wins! >', Winner),
    newl(2),
    other_player(Winner, Loser),
    format('   Because ~w cannot move!', Loser),
    newl(2),
    write('=============== % ==============='),
    nl,
    !.

% No enemy pieces
print_game_over_message(Board, winner(Winner, noenemypieces)) :-
    newl(50),
    write('--------------- % ---------------'),
    newl(2),
    print_board(Board),
    nl,
    write('=============== % ==============='),
    newl(2),
    format('   < GAME OVER, ~w wins! >', Winner),
    newl(2),
    other_player(Winner, Loser),
    format('   Because ~w has no pieces!', Loser),
    newl(2),
    write('=============== % ==============='),
    nl,
    !.


/* ===== print_move(+Player, +Move) =====
Broadcast a computer move to the user.
==================== */
print_move(Player, move_(From, To, _)) :-
    write('Player '),
    write(Player),
    write(' moved from '),
    write(From),
    write(' -> '),
    write(To),
    write('.'),
    nl.

