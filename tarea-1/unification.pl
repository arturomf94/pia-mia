%% Unification

unify(T1, T2) :-
    atomic(T1),
    atomic(T2),
    T1 == T2.

unify(T1, T2) :-
    var(T1),
    T1 == T2.

unify(T1, T2) :-
    var(T1),
    \+ (T1 == T2),
    write(T1), write(' = '), write(T2).
