%%% Sucesor, heurística y meta son predicados dinámicos.

:- dynamic
       s/3,
       h/2,
       meta/1.

% primeroMejor(Inicio, Sol): Sol es un camino de Inicio a la meta
% Asumimos 9999 > que todo f-valor

primeroMejor(Inicio, Sol) :-
  expandir([], l(Inicio,0/0),  9999, _, si, Sol).

% expandir(Camino, Arbol, Umbral, Arbol1, Resuelto, Sol):
%   Camino entre Inicio y Arbol,
%   Arbol1 es Arbol expandido bajo la Umbral,
%   Si meta es encontrada Sol es la solución y  Resuelto = si

%  Caso 1: nodo hoja meta, construir camino solución

expandir(Camino, l(Nodo, _), _, _, si, [Nodo|Camino])  :-
   meta(Nodo).

% Caso 2: nodo hoja, f-valor < Umbral
% Generar suscesores y expandir bajo la Umbral.

expandir(Camino, l(Nodo,F/G), Umbral, Arbol1, Resuelto, Sol)  :-
  F =< Umbral,
  ( bagof( Nodo2/C, (s(Nodo,Nodo2,C), \+ member(Nodo2,Camino) ), Succ),
    !,                                    % N tiene sucesores
    listaSucs(G, Succ, As),               % Construir subárboles As
    mejorF(As, F1),                       % f-valor del mejor sucesor
    expandir(Camino, t(Nodo,F1/G,As), Umbral, Arbol1, Resuelto, Sol)
  ;
    Resuelto = nunca                      % N sin sucesores
  ).

%  Caso 3: no hoja, f-valor < Umbral
%  Expandir el subárbol más promisorio; dependiendo de
%  resultados, continuar decidirá como proceder.

expandir(Camino, t(Nodo,F/G,[A|As]), Umbral, Arbol1, Resuelto, Sol)  :-
  F =< Umbral,
  mejorF(As, MejorF), min(Umbral, MejorF, Umbral1),          % Umbral1 = min(Umbral,MejorF)
  expandir([Nodo|Camino], A, Umbral1, A1, Resuelto1, Sol),
  continuar(Camino, t(Nodo,F/G,[A1|As]), Umbral, Arbol1, Resuelto1, Resuelto, Sol).

%  Caso 4: no hoja con subárboles vacío
%  Fallo

expandir( _, t(_,_,[]), _, _, nunca, _) :- !.

%  Caso 5:  f-valor > Umbral
%  Arbol debe crecer.

expandir( _, Arbol, Umbral, Arbol, no, _)  :-
  f(Arbol, F), F > Umbral.

% continuar( Camino, Arbol, Umbral, NuevoArbol, SubarbolResuelto, ArbolResuelto, Sol)

continuar( _, _, _, _, si, si, _Sol).

continuar(Camino, t(Nodo,_/G,[A1|As]), Umbral, Arbol1, no, Resuelto, Sol)  :-
  insertar(A1, As, NAs),
  mejorF(NAs, F1),
  expandir(Camino, t(Nodo,F1/G,NAs), Umbral, Arbol1, Resuelto, Sol).

continuar(Camino, t(Nodo,_/G,[_|As]), Umbral, Arbol1, nunca, Resuelto, Sol)  :-
  mejorF(As, F1),
  expandir(Camino, t(Nodo,F1/G,As), Umbral, Arbol1, Resuelto, Sol).

% listaSucs(G0, [ Nodo1/Costo1, ...], [ l(MejorNodo,MejorF/G), ...]):
% ordena la lista de hojas por F-valor

listaSucs( _, [], []).

listaSucs(G0, [N/C|NCs], As)  :-
  G is G0 + C,
  h(N, H),                             % Heuristica h(N)
  F is G + H,
  listaSucs(G0, NCs, As1),
  insertar(l(N,F/G), As1, As).

% Insertar A en una lista de arboles As, preservando orden por
% f-valor.

insertar(A, As, [A|As])  :-
  f(A, F), mejorF(As, F1),
  F =< F1, !.

insertar(A, [A1|As], [A1|As1])  :-
  insertar(A, As, As1).

% Extraer f-value

f(l(_,F/_),F).        % f-valor de una hoja

f(t(_,F/_,_),F).      % f-valor de un árbol

mejorF([A|_],F)  :-   % mejor F de una lista de árboles
  f(A,F).

mejorF([],9999).

min(X,Y,X)  :-
  X =< Y, !.

min(_,Y,Y).

%%% Reset para llamar un nuevo problema

reset :-
    retractall(s/3),
    retractall(h/2),
    retractall(meta/1).
