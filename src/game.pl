/* -*- Mode:Prolog; coding:utf-8; indent-tabs-mode:nil; prolog-indent-width:4; prolog-paren-indent:4; tab-width:8; -*- */

:- use_module(library(random)).

:- consult(controller).

%=================== GAME.PL ===================%
% Game handler- responsible for the game's model.
%===============================================%


/* ===== play/0 =====
Display the main menu and allow for
choosing the game mode & other parameters.
==================== */
play :-
    % display main menu
    print_welcome_message,
    % prompt user for game mode
    get_game_mode(GameMode),
    handle_game_mode(GameMode).


/* ===== handle_game_mode(+Choice) =====
Handle the user's input for the game mode
and delegate control to the next game action.
==================== */

% human v human
handle_game_mode(1) :-
    GameConfig = config(white(human,1), black(human,1)),
    start_game(GameConfig).

% human v computer
handle_game_mode(2) :-
    % prompt user for difficulty level
    print_difficulty_message,
    get_difficulty('Human', Difficulty),
    % prompt user for starting player
    print_starting_player_message,
    get_starting_player(StartingPlayer),
    % start game
    set_config(StartingPlayer, Difficulty, GameConfig),
    start_game(GameConfig).

% computer v computer
handle_game_mode(3) :-
    print_difficulty_message,
    % difficulty for computers #1 and #2
    get_difficulty('Computer 1', Lb),
    get_difficulty('Computer 2', Lw), !,
    % start game
    GameConfig = config(white(computer,Lw),
                        black(computer,Lb)),
    start_game(GameConfig).


/* ===== set_config(+StartingPlayer, +DifficultyForHuman, -GameConfig) =====
Set the game configuration based on all user provided parameters.
(only needed in mode 2 (H v C), others can be created directly)
==================== */
set_config(human, Difficulty,
           config(white(human, _), black(computer, Difficulty))) :- !.
set_config(computer, Difficulty,
           config(white(computer, Difficulty), black(human, _))) :-  !.


/* ===== initial_state(+GameConfig, -GameState) =====
Return the initial game state based on
the provided game configuration.
==================== */
initial_state(Config, state(white, Board, Config)) :- game_board(Board).


/* ===== start_game(+GameConfig) =====
Get the initial game state based on the 
configuration and start the game loop.
==================== */
start_game(GameConfig) :-
    initial_state(GameConfig, GameState),
    game_loop(GameState).


/* ===== game_loop(+GameState) =====
Get the initial game state based on the 
configuration and start the game loop.
==================== */

% game over
game_loop(state(Player, Board, Config)) :-
    game_over(state(Player, Board, Config), Winner),
    print_game_over_message(Board, Winner).

% game NOT over, Human's turn
game_loop(GameState) :-
    % get difficulty level
    current_player(GameState, Player),
    player_details(GameState, Player, human, Level),
    display_game(GameState),
    % choose and handle next move-
    % handle_move will hand back control
    % when a valid move is chosen
    choose_move(GameState, Level, Move),
    value(GameState, Player, Value),
    write('value -> '), write(Value),nl, 
    handle_move(GameState, Move).

% game NOT over, Computer's turn
game_loop(GameState) :-
    current_player(GameState, Player),
    player_details(GameState, Player, computer, Level),
    choose_move(GameState, Level, Move),
    move(GameState, Move, NewGameState),
    % wait until player acknowledgement
    display_game(GameState),
    print_move(Player, Move),
    wait_for_enter, !,
    game_loop(NewGameState).


/* ===== handle_move(+GameState, +Move) =====
Helper function for the game loop. Handles invalid moves gracefully ands
lets the user try again. When a valid move is executed, hands back control.
==================== */
% success
handle_move(GameState, Move) :-
    move(GameState, Move, NewGameState), !,
    game_loop(NewGameState). % back to game loop

% failed, invalid move
handle_move(GameState, _) :-
    nl, write('** Can\'t perform move, retry! **'), nl,
    get_move(From, To, _), !,
    % retry until valid mode
    handle_move(GameState, move_(From, To, _)).


/* ===== move(+GameState, +Move, -NewGameState) =====
Validate and perform a capturing move.
move is the predicate, move_ is the atom (to avoid confusion)
==================== */
move(GameState, Move, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    member(Move, ValidMoves), % check if valid
    do_move(GameState, Move, NewGameState). % helper
    

% move_((Fx, Fy), (Tx, Ty), (Cx, Cy))
% Fx,Fy -> from
% Tx,Ty -> to
% Cx, Cy -> captured


/* ===== do_move(+GameState, +Move, -NewGameState) =====
Perform a capturing move, assuming it has already been validated.
Helper function to move().
==================== */
do_move(state(CurrentPlayer, Board, Config),
        move_((Fx,Fy), (Tx,Ty), (Cx,Cy)),
        state(NextPlayer, NewBoard, Config)) :-
    % remove player's piece from old cell
    set_cell(Board, Fx, Fy, ., TmpBoard),
    % remove enemy's captured piece
    set_cell(TmpBoard, Cx, Cy, ., TmpBoard2),
    % add player piece to new cell
    cell_atom(CurrentPlayer, Cell),
    set_cell(TmpBoard2, Tx, Ty, Cell, TmpBoard3),
    % update state
    other_player(CurrentPlayer, NextPlayer),
    NewBoard = TmpBoard3.


/* ===== valid_moves(+GameState, -Moves) =====
Return all valid moves from a given game state.
==================== */
valid_moves(state(Player, Board, _Config), ValidMoves) :-
    % get all values
    findall(Move,
            valid_moves_worker(Player, Board, Move)
           , ValidMoves). 


/* ===== valid_moves_worker(+Player, +Board, ?Move) =====
Worker/ Helper function for valid_moves. Takes the current player,
the game board and a position in 2D and returns a valid move position.
==================== */
valid_moves_worker(Player, Board, move_((Fx,Fy), (Tx,Ty), (Cx, Cy))) :-
    % restrict range
    member(Fx, [1,2,3,4,5,6,7,8,9]),
    member(Fy, [1,2,3,4,5]),
    % check if cell has player piece
    get_cell(Board, Fx, Fy, Cell),
    cell_atom(Player, Cell),
    % try all directions
    direction(Dx, Dy),
    % prepare to start "stepping"
    PAtom = Cell,
    other_player(Player, Enemy),
    cell_atom(Enemy, EAtom),
    step_until_hit(Board, PAtom, EAtom, Fx, Fy, Dx, Dy, Tx, Ty),
    % check if player actually moved, otherwise not valid
    (Fx,Fy) \= (Tx,Ty),
    % recalculate captured piece
    Cx is Tx + Dx,
    Cy is Ty + Dy.


/* ===== step_until_hit(+Board, +PAtom, +EAtom, +Fx, +Fy, +Dx, +Dy, -Tx, -Ty) =====
Perform "steps" recursively in a specific direction (Dx,Dy) from a starting
position (Fx,Fy) until hitting an enemy piece. Return last step (Tx, Ty).
==================== */

% hit a blank cell- keep going
step_until_hit(Board, PAtom, OAtom, Fx, Fy, Dx, Dy, Tx, Ty) :-
    next_step(Board, Fx, Fy, Dx, Dy, Nx, Ny, Cell),
    Cell = ., % hit blank cell, continue
    step_until_hit(Board, PAtom, OAtom, Nx, Ny, Dx, Dy, Tx, Ty).

% hit enemy piece- halt
step_until_hit(Board, _PAtom, EAtom, Fx, Fy, Dx, Dy, Tx, Ty) :-
    next_step(Board, Fx, Fy, Dx, Dy, _Nx, _Ny, Cell), % get next step
    Cell = EAtom, % did hit enemy
    Tx = Fx,
    Ty = Fy.

% OTHERWISE, hit their own cell- not valid, no predicate
%--


/* ===== next_step(+Board, +Fx, +Fy, +Dx, +Dy, -Tx, -Ty, -Cell) =====
Compute the next step in a specific direction (Dx,Dy) from a starting position (Fx,Fy).
Return next step (Tx,Ty) along with its cell content on the board.
==================== */
next_step(Board, Fx, Fy, Dx, Dy, Nx, Ny, Cell) :-
    Nx is Fx + Dx, % next X
    Ny is Fy + Dy, % next Y
    within_bounds(Nx, Ny),
    get_cell(Board, Nx, Ny, Cell).


/* ===== game_over(+GameState, -Winner) =====
Check whether the game is over based on its 
current state- if true, return the winner.
==================== */
        
% current player cannot move, enemy wins
game_over(GameState, winner(WPlayer, Reason)) :-
    valid_moves(GameState, Moves),
    Moves = [],
    current_player(GameState, CurrentPlayer),
    other_player(CurrentPlayer, WPlayer),
    Reason = enemytrapped, !.

% enemy has no pieces, current player wins
game_over(state(CurrentPlayer, Board, _Config), winner(WPlayer, Reason)) :-
    other_player(CurrentPlayer, Enemy),
    cell_atom(Enemy, EAtom),
    \+ ( member(Row, Board), member(EAtom, Row) ),
    WPlayer = CurrentPlayer,
    Reason = noenemypieces, !.


/* ===== choose_move(+GameState, +Level, -Move) =====
Select the next move for the game. If it is to be played by a human,
let them choose it, otherwise use an algorithm based on the difficulty level.
==================== */
% human
choose_move(GameState, _, Move) :-
    current_player(GameState, Player),
    player_details(GameState, Player, human, _),
    % prompt user for move
    get_move(From, To), !,
    Move = move_(From, To, _).
% computer, % Level 1 => random   
choose_move(GameState, 1, Move) :-
    current_player(GameState, Player),
    player_details(GameState, Player, computer, _),
    choose_random_move(GameState, Move).
% computer, % Level 2 => greedy
choose_move(GameState, 2, Move) :-
    current_player(GameState, Player),
    player_details(GameState, Player, computer, _),
    choose_greedy_move(GameState, Move).


/* ===== get_protection_score(+Board, +Player, -Score) =====
Calculate a protection score for a player's pieces on the game board.
Pieces on edges are protected from one direction (1 point).
Pieces in corners are protected from two directions (2 points, worth double).
==================== */
get_protection_score(Board, Player, Score) :-
    % get corner pieces
    findall((X,Y), (
        member(X, [1,2,3,4,5,6,7,8,9]),
        member(Y, [1,2,3,4,5]),
        cell_atom(Player, PAtom),
        get_cell(Board, X, Y, PAtom),
        corner_piece(X,Y)
    ), CornerPieces),
    % get edge pieces (except corners)
    findall((X,Y), (
        member(X, [1,2,3,4,5,6,7,8,9]),
        member(Y, [1,2,3,4,5]),
        cell_atom(Player, PAtom),
        get_cell(Board, X, Y, PAtom),
        edge_piece(X,Y)
    ), EdgePieces),
    % get no. of corners & edges
    length(CornerPieces, Corners),
    length(EdgePieces, Edges),
    % calculate protection score
    % corners are worth double, offer more protection
    CornerScore is Corners * 2,
    Score is CornerScore + Edges.


/* ===== value(+GameState, +Player) =====
Evaluate how favorable the given game state to the Player based on
protection scores. Higher values mean better position for Player.
Value = (Player's protected pieces - Enemy's protected pieces)
==================== */
value(state(_CurP, Board, _Config), Player, Value) :-
    % get protection score for Player and Enemy
    get_protection_score(Board, Player, PlayerScore),
    other_player(Player, Enemy),
    get_protection_score(Board, Enemy, EnemyScore),
    % weigh the difference
    Value is PlayerScore - EnemyScore.


/* ===== choose_random_move(+GameState, -Move) =====
Select a move for the computer to play by randomly
choosing one out of all the valid moves available.
==================== */
choose_random_move(GameState, Move) :-
    valid_moves(GameState, ValidMoves),
    random_member(Move, ValidMoves).


/* ===== choose_greedy_move(+GameState, -Move) =====
Select a move for the computer to play using a greedy algorithm.
Evaluates available moves and selects the one that maximizes
the short-term gain based on the value/3 predicate.
==================== */
choose_greedy_move(GameState, BestMove) :-
    valid_moves(GameState, ValidMoves),
    current_player(GameState, Player),
    findall(Value_-Move_,
    (
      % for each valid move
      member(Move_, ValidMoves),
      % try move
      move(GameState, Move_, NextState),
      % check value
      value(NextState, Player, Value_)
    ),
    GreedyValueMoves),
    % sort options (uses keysort, by ASCENDING value)
    keysort(GreedyValueMoves, SortedMoves),
    write('moves ->'), write(SortedMoves),nl,
    % get last element (biggest/ best value)
    length(SortedMoves, Length),
    nth1(Length, SortedMoves, BestValue-BestMove),
    format('[DEBUG] Best greedy value is ~w~n', BestValue).


