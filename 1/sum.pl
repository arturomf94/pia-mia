:- use_module(library(statistics)).

sum_list([],0).

sum_list([Top|Tail], Total) :-
	sum_list(Tail, TotalRest), 
	Total is Top + TotalRest.

sum_listTR([],X,X).

sum_listTR([Top|Tail], Sum, Total) :- 
	TotalNow is Top + Sum,
	sum_listTR(Tail,TotalNow, Total).

nlist(1,[1]) :- !.
nlist(N,[N|Ns]) :- N1 is N - 1, nlist(N1, Ns).

sum1(L,R) :- nlist(L,X), sum_list(X,R).

sum2(L,R) :- nlist(L,X), sum_listTR(X,0,R).