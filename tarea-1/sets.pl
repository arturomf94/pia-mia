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
