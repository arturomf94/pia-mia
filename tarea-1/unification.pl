%%% UNIFICACION

%%% Caso 1: ambos terminos son constantes.
%%% Esta clausula prueba si ambos terminos son constantes
%%% Tambien se revisa si hay igualdad entre los terminos.
unify(T1, T2) :-
    atomic(T1),
    atomic(T2),
    T1 == T2,
    !.

%%% Caso 2: al menos un termino es variable.
%%% En esta clausula se verifica si el primer termino es
%%% una variable. Tambien se verifica si hay igualdad
%%% entre terminos.
unify(T1, T2) :-
    var(T1),
    T1 == T2,
    !.

%%% En esta clausula se verifica si el primer termino es
%%% una variable. Tambien se verifica si hay una diferencia
%%% en los terminos, Si ambas condiciones se cumplen
%%% entonces el primer termino (variable) toma el valor del
%%% segundo
unify(T1, T2) :-
    var(T1),
    \+ (T1 == T2),
    T1 = T2,
    !.


%%% En esta clausula se verifica si el segundo termino es
%%% una variable. Tambien se verifica si hay una diferencia
%%% en los terminos, Si ambas condiciones se cumplen
%%% entonces el primer termino (variable) toma el valor del
%%% segundo
unify(T1, T2) :-
    var(T2),
    \+ (T1 == T2),
    T2 = T1,
    !.

%%% Caso 3: ambos terminos son compuestos.
%%% En esta clausula se verifica que ambos terminos sean
%%% compuestos. Se obtiene el numero de argumentos y
%%% se utiliza este numero para unificar los argumentos.
unify(T1, T2) :-
    compound(T1),
    compound(T2),
    functor(T1, Functor, Numargs),
    functor(T2, Functor, Numargs),
    sub_unify(T1, T2, Numargs).

%%% Las siguientes dos clausulas se encargan de unificar
%%% los argumentos de los funtores.
%%% En el caso base cuando el numero de argumentos es 0,
%%% tenemos lo siguiente:
sub_unify(_, _, 0) :- !.

%%% En cualquier otro caso, se obtienen los ultimos argumentos
%%% del funtor y se unifican con 'unify'. Luego se hace una
%%% llamada recursiva a 'sub_unify' con el numero de argumentos
%%% menos uno.
sub_unify(T1, T2, Numargs) :-
    arg(Numargs, T1, Arg1),
    arg(Numargs, T2, Arg2),
    unify(Arg1, Arg2),
    NewNumargs is Numargs - 1,
    sub_unify(T1, T2, NewNumargs).
