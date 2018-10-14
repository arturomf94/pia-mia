%% Unificación

% Caso 1: ambos términos son constantes.
% Esta cláusula prueba si ambos términos son constantes
% También se revisa si hay igualdad entre los términos.
unify(T1, T2) :-
    atomic(T1),
    atomic(T2),
    T1 == T2,
    !.

% Caso 2: al menos un término es variable.
% En esta cláusula se verifica si el primer término es
% una variable. También se verifica si hay igualdad
% entre términos.
unify(T1, T2) :-
    var(T1),
    T1 == T2,
    !.

% En esta cláusula se verifica si el primer término es
% una variable. También se verifica si hay una diferencia
% en los términos, Si ambas condiciones se cumplen
% entonces el primer término (variable) toma el valor del
% segundo
unify(T1, T2) :-
    var(T1),
    \+ (T1 == T2),
    T1 = T2,
    !.


% En esta cláusula se verifica si el segundo término es
% una variable. También se verifica si hay una diferencia
% en los términos, Si ambas condiciones se cumplen
% entonces el primer término (variable) toma el valor del
% segundo
unify(T1, T2) :-
    var(T2),
    \+ (T1 == T2),
    T2 = T1,
    !.

% Caso 3: ambos términos son compuestos.
% En esta cláusula se verifica que ambos términos sean
% compuestos. Se obtiene el número de argumentos y
% se utiliza este número para unificar los argumentos.
unify(T1, T2) :-
    compound(T1),
    compound(T2),
    functor(T1, Functor, Numargs),
    functor(T2, Functor, Numargs),
    sub_unify(T1, T2, Numargs).

% Las siguientes dos cláusulas se encargan de unificar
% los argumentos de los funtores.
% En el caso base cuando el número de argumentos es 0,
% tenemos lo siguiente:
sub_unify(_, _, 0) :- !.

% En cualquier otro caso, se obtienen los últimos argumentos
% del funtor y se unifican con 'unify'. Luego se hace una
% llamada recursiva a 'sub_unify' con el número de argumentos
% menos uno.
sub_unify(T1, T2, Numargs) :-
    arg(Numargs, T1, Arg1),
    arg(Numargs, T2, Arg2),
    unify(Arg1, Arg2),
    NewNumargs is Numargs - 1,
    sub_unify(T1, T2, NewNumargs).
