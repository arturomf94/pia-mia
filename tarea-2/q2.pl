%%% sucesor incluye costos

costo(tuxpan, poza_rica, 100).
costo(poza_rica, xalapa, 100).
costo(xalapa, veracruz, 100).
costo(xalapa, cordoba, 100).
costo(cordoba, orizaba, 100).
costo(cordoba, veracruz, 100).
costo(cordoba, minatitlan, 100).
costo(veracruz, boca_del_rio, 100).
costo(boca_del_rio, minatitlan, 100).
costo(minatitlan, coatzacoalcos, 100).

s(X, Y, C) :- costo(X,Y, C).
s(X, Y, C) :- costo(Y,X, C).

distancia_aux(tuxpan, poza_rica, 56).
distancia_aux(poza_rica, xalapa, 221).
distancia_aux(xalapa, veracruz, 107).
distancia_aux(xalapa, cordoba, 140).
distancia_aux(cordoba, orizaba, 25).
distancia_aux(cordoba, veracruz, 110).
distancia_aux(cordoba, minatitlan, 286).
distancia_aux(veracruz, boca_del_rio, 10).
distancia_aux(boca_del_rio, minatitlan, 288).
distancia_aux(minatitlan, coatzacoalcos, 21).

distancia(X, Y, D) :- distancia_aux(X, Y, D).
distancia(X, Y, D) :- distancia_aux(Y, X, D).

h(X, Y, D) :-
    h_aux(X, Y, [X], D), !.

h_aux(X, Y, _, D) :- distancia(X, Y, D), !.
h_aux(X, Y, _, D) :- distancia(Y, X, D), !.
h_aux(X, Z, V, D) :-
    distancia(X, Y, D1),
    \+ member(Y, V),
    h_aux(Y, Z, [Y|V], D2),
    D is D1 + D2.
