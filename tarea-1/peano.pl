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
    sumNPeano(P1, N, R).

sumNPeano(P, 0, P) :- !.

sumNPeano(P, N, R) :-
    Nnew is N - 1,
    sumNPeano(s(P), Nnew, R).
