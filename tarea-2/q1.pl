
odia(perro, gato).
odia(gato, hamster).

s([[], _],_) :- !.
s([Casa1, Casa2],[Casa1_Nueva, [X|Casa2]]) :-
    member(X, Casa1),
    mover(X, Casa1, Casa1_Nueva),
    not(estado_invalido(Casa1_Nueva, [X|Casa2])).

meta([[], [perro, gato, hamster]]).

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


% mover([Top|Tail], R) :-
