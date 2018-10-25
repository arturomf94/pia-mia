
odia(perro, gato).
odia(gato, hamster).

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

meta([[],[],P]) :-
    permutation([perro,gato,hamster],P).

mover(X, [X|Tail], Tail).
mover(X, [Y|Tail], [Y|NewTail]) :-
    mover(X, Tail, NewTail).

estado_invalido(C1, C2) :-
    (estado_invalido_aux(C1);
    estado_invalido_aux(C2)).

estado_invalido_aux([Top|Tail]) :-
    (odia(Top, Other); odia(Other, Top)),
    member(Other, Tail),
    !.
