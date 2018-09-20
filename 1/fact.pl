:- use_module(library(statistics)).

fact(1,1) :- !.

fact(N,Res) :-
	Naux is N - 1,
	fact(Naux,ResAux),
	Res is N * ResAux.

factTR(N,Res) :-
	factTRAux(N,1,Res).

factTRAux(1,Acc,Acc) :- !.

factTRAux(N,Acc,Res) :-
	AccAux is N * Acc,
	N1 is N - 1,
	factTRAux(N1,AccAux,Res).