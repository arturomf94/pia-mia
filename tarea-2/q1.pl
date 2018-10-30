%%% Las dos primeras clausulas se encargan de
%%% definir una relacion entre los animales
%%% que represente la imposibilidad de dejarlos
%%% a ambos en el mismo lugar.

odia(perro, gato).
odia(gato, hamster).

%%% La clausula s define, por otro lado,
%%% las conexiones entre diferentes estados.
%%% Estos estados son de la siguiente forma:
%%% [Casa1, Transporte, Casa2].

s([[], [X], Y],[[],[],[X|Y]]) :- !.

s([Casa1, [], Casa2], [Casa1_Nueva, [X], Casa2]) :-
    member(X, Casa1),
    mover(X, Casa1, Casa1_Nueva),
    not(estado_invalido(Casa1_Nueva, Casa2)).

s([Casa1, [X], Casa2], [Casa1, [], [X|Casa2]]) :-
    not(estado_invalido(Casa1,[X|Casa2])).

s([Casa1, [], Casa2], [Casa1, [X], Casa2_Nueva]) :-
    member(X, Casa2),
    mover(X, Casa2, Casa2_Nueva),
    not(estado_invalido(Casa1, Casa2_Nueva)).

s([Casa1, [X], Casa2], [[X|Casa1], [], Casa2]) :-
    not(estado_invalido([X|Casa1],Casa2)).


s([Casa1, [X], Casa2],[Casa1, [Y], [X|Casa2_Nueva]]) :-
    member(Y, Casa2),
    mover(Y, Casa2, Casa2_Nueva),
    not(estado_invalido(Casa1,[X|Casa2_Nueva])).

s([Casa1, [X], Casa2],[[X|Casa1_Nueva], [Y], Casa2]) :-
    member(Y, Casa1),
    mover(Y, Casa1, Casa1_Nueva),
    not(estado_invalido([X|Casa1_Nueva],Casa2)).

%%% Definimos la meta como cualquier estado
%%% [[], [], P], donde P es cualquier permutacion
%%% se los tres animales.

meta([[],[],P]) :-
    permutation([perro,gato,hamster],P).

%%% mover es una clausula adicional que
%%% elimina un elemento de una lista.

mover(X, [X|Tail], Tail).
mover(X, [Y|Tail], [Y|NewTail]) :-
    mover(X, Tail, NewTail).

%%% La clausula estado_invalido
%%% verifica que no existan conflictos
%%% de la clausla odia en el mismo lugar.

estado_invalido(C1, C2) :-
    (estado_invalido_aux(C1);
    estado_invalido_aux(C2)).

estado_invalido_aux([Top|Tail]) :-
    (odia(Top, Other); odia(Other, Top)),
    member(Other, Tail),
    !.
