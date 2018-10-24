
:- dynamic
    ubicacion/2.

odia(perro, gato).
odia(gato, hamster).

ubicacion(perro, depa1).
ubicacion(gato, depa1).
ubicacion(hamster, depa1).

s([perro,gato,hamster], [])

mover(X, [X|Tail], [Tail]).
mover(X, [Y|Tail], [Y|NewTail]) :-
    mover(X, Tail, NewTail).
meta([], [perro, gato, hamster]).

estado_invalido(depa1, depa2) :-
    ubicacion(X, depa1),
    ubicacion(Y, depa1),
    (odia(X,Y);
    odia(Y,X)).

estado_invalido(depa1, depa2) :-
    ubicacion(X, depa2),
    ubicacion(Y, depa2),
    (odia(X,Y);
    odia(Y,X)).

% mover([Top|Tail], R) :-
