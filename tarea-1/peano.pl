%%% PEANO

peanoToNat(P, N) :-
    peanoToNatAux(P, N, 0).

peanoToNatAux(0, Acc, Acc) :- !.

peanoToNatAux(P, N, Acc) :-
    AccNew is Acc + 1,
    arg(1, P, Arg),
    peanoToNatAux(Arg, N, AccNew).

sumaPeano(P1, P2, R) :-
    peanoToNat(P2, N),
    sumaNPeano(P1, N, R).

sumaNPeano(P, 0, P) :- !.

sumaNPeano(P, N, R) :-
    Nnew is N - 1,
    sumaNPeano(s(P), Nnew, R).

restaPeano(P1, P2, R) :-
    peanoToNat(P2, N2),
    peanoToNat(P1, N1),
    N2 =< N1,
    restaNPeano(P1, N2, R).

restaNPeano(P, 0, P) :- !.

restaNPeano(P, N, R) :-
    Nnew is N - 1,
    arg(1, P, Arg),
    restaNPeano(Arg, Nnew, R).
