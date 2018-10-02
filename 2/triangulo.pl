
triangulo(N) :-
	triangulo_aux(N, 0).

triangulo_aux(0,_) :- !.

triangulo_aux(N,M) :-
	E is N - 1,
	A is M + 1,
	lista_espaciada(E, A, L),
	string_to_list(S,L),
	write(S),
	nl,
	M1 is M + 1,
	N1 is N - 1,
	triangulo_aux(N1, M1).

crea_lista(0,[]) :- !.

crea_lista(N, L) :- 
	N1 is N - 1,
	crea_lista(N1, L1),
	append([42,32], L1, L).

crea_lista_vacia(0,[]) :- !.

crea_lista_vacia(N, L) :- 
	N1 is N - 1,
	crea_lista_vacia(N1, L1),
	append([32], L1, L).

lista_espaciada(E, A, R):-
	crea_lista_vacia(E, L1),
	crea_lista(A, L2),
	append(L1, L2, R).