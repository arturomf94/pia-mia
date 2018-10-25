%%% sucesor incluye costos

costo(tuxpan, poza_rica, 1) :- !.
costo(poza_rica, xalapa, 1) :- !.
costo(xalapa, veracruz, 1) :- !.
costo(xalapa, cordoba, 1) :- !.
costo(cordoba, orizaba, 1) :- !.
costo(cordoba, minatitlan, 1) :- !.
costo(veracruz, boca_del_rio, 1) :- !.
costo(boca_del_rio, minatitlan, 1) :- !.
costo(minatitlan, coatzacoalcos, 1) :- !.

s(X, Y, C) :- costo(X,Y, C), !.
s(X, Y, C) :- costo(Y,X, C), !.

distancia_aux(tuxpan, poza_rica, 1).
distancia_aux(poza_rica, xalapa, 1).
distancia_aux(xalapa, veracruz, 1).
distancia_aux(xalapa, cordoba, 1).
distancia_aux(cordoba, orizaba, 1).
distancia_aux(veracruz, boca_del_rio, 1).
distancia_aux(boca_del_rio, minatitlan, 1).
distancia_aux(minatitlan, coatzacoalcos, 1).

distancia(X, Y, D) :- distancia_aux(X, Y, D), !.
distancia(X, Y, D) :- distancia_aux(Y, X, D), !.

h(X, Y, D) :-
    h_aux(X, Y, [], D).

h_aux(X, Y, _, D) :- distancia(X, Y, D), !.
h_aux(X, Y, _, D) :- distancia(Y, X, D), !.
h_aux(X, Z, V, D) :-
    not(member(Y, V)),
    distancia(X, Y, D1),
    h_aux(Y, Z, [X|V], D2),
    D is D1 + D2.


%%% heurística

h(a,5).
h(b,4).
h(c,4).
h(d,3).
h(e,7).
h(f,4).
h(g,2).
h(t,0).

%%% meta


meta(t).
