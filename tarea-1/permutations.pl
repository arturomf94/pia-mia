%%% PERMUTATIONS

%%% Esta clausula utiliza 'findall' para encontrar
%%% todas los resultados de aplicar la clausula
%%% 'permutation' a la lista de entrada L.

permute(L,R) :-
    findall(P, permutation(L,P), R).
