%%% PEANO

%%% Esta clausula convierte numeros de peano
%%% de la forma s(s(...(0))) en su expresion
%%% decimal. La primera parte es una 'interfaz'
%%% para hacer llamada a la clausula que es
%%% recursiva a la cola 'peanoToNatAux'.
%%% Esta ultima suma 1 por cada argumento
%%% del numero de peano.

peanoToNat(P, N) :-
    peanoToNatAux(P, N, 0).

peanoToNatAux(0, Acc, Acc) :- !.

peanoToNatAux(P, N, Acc) :-
    AccNew is Acc + 1,
    arg(1, P, Arg),
    peanoToNatAux(Arg, N, AccNew).

%%% Esta clausula suma dos numeros de peano.
%%% Lo primero que sea hace es obtener la
%%% expresion decimal del segundo termino y
%%% recursivamente aplicar la clausula de
%%% sucesion al primer termino las veces
%%% correspondientes al valor del segundo
%%% numero.

sumaPeano(P1, P2, R) :-
    peanoToNat(P2, N),
    sumaNPeano(P1, N, R).

sumaNPeano(P, 0, P) :- !.

sumaNPeano(P, N, R) :-
    Nnew is N - 1,
    sumaNPeano(s(P), Nnew, R).

%%% Esta clausula resta dos numeros de peano.
%%% Lo primero que sea hace es obtener la
%%% expresion decimal del segundo termino y
%%% tambien la del primero. Si el segundo
%%% es menor o igual que el primero entonces
%%% recursivamente se obtiene el primer
%%% argumento del primer termino las veces
%%% correspondientes al valor del segundo
%%% numero.

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
