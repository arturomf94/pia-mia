%%% SETS

subset([], _L2) :- !.

subset([Head|Tail], L2) :-
    member(Head, L2),
    subset(Tail, L2),
    !.

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
