%%% SETS


%%% Esta clausula verifica si una lista es subconjunto
%%% de otra. Para esto revisa, recursivamente, si cada
%%% elemento de la primera lista se contiene en la otra.
subset([], _L2) :- !.

subset([Head|Tail], L2) :-
    member(Head, L2),
    subset(Tail, L2),
    !.

%%% Esta clausula regresa la interseccion entre dos listas.
%%% Para los casos en los cuales cualquiera de las dos
%%% listas es vacia la interseccion es vacia tambien
%%% En cualquier otro caso, se llama la clausula
%%% 'inter_aux' que es recursiva a la cola y que acumula
%%% los elementos de la primera lista que estan tambien
%%% en la segunda.
inter([], _, []) :- !.

inter(_, [], []) :- !.

inter(L1, L2, R) :-
    inter_aux(L1, L2, R_aux, []),
    reverse(R_aux, R).

inter_aux([], _, Acc, Acc) :- !.

inter_aux([Head|Tail], L2, R, Acc) :-
    member(Head, L2),
    append([Head], Acc, AccNew),
    inter_aux(Tail, L2, R, AccNew),
    !.

inter_aux([Head|Tail], L2, R, Acc) :-
    not(member(Head,L2)),
    inter_aux(Tail, L2, R, Acc),
    !.

%%% Esta clausula regresa la union entre dos listas.
%%% Si alguna de las dos listas es vacia entonces
%%% regresa la otra lista. En cualquier otro caso se
%%% llama a la clausula 'union_aux' que agrega a la
%%% segunda lista todos los elementos de la primera
%%% que no estan ya en la segunda.

union([], L2, L2) :- !.

union(L1, [], L1) :- !.

union(L1, L2, R) :-
    union_aux(L1, L2, R, L2).

union_aux([], _, Acc, Acc) :- !.

union_aux([Head|Tail], L2, R, Acc) :-
    not(member(Head, L2)),
    append([Head], Acc, AccNew),
    union_aux(Tail, L2, R, AccNew),
    !.

union_aux([Head|Tail], L2, R, Acc) :-
    member(Head, L2),
    union_aux(Tail, L2, R, Acc),
    !.

%%% Esta clausula regresa la diferencia entre dos
%%% listas. Para los casos en los cuales la primera
%%% lista es vacia, tenemos que la diferencia es vacia
%%% para el caso en el cual la segunda es vacia, tenemos
%%% que la diferencia es la primera lista. En cualquier
%%% otro caso se calcula la interseccion y se llama a la
%%% clausula 'dif_aux' que es recursiva a la cola y
%%% crea una nueva lista con todos los elementos que
%%% estan en la primera lista pero no estan en la
%%% interseccion.

dif([], _L2, []) :- !.

dif(L1, [], L1) :- !.

dif(L1, L2, R) :-
    inter(L1, L2, NewL2),
    dif_aux(L1, NewL2, R, []).

dif_aux([], _, Acc, Acc) :- !.

dif_aux([Head|Tail], L2, R, Acc) :-
    not(member(Head, L2)),
    append([Head], Acc, AccNew),
    dif_aux(Tail, L2, R, AccNew),
    !.

dif_aux([Head|Tail], L2, R, Acc) :-
    member(Head, L2),
    dif_aux(Tail, L2, R, Acc),
    !.
