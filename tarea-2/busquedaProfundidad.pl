%%% Sucesor y meta son predicados dinámicos.

:- dynamic
   s/2,
   meta/1.

%%% Búsqueda Primero en Profundidad

solucion(Nodo,[Nodo]) :-
    meta(Nodo).

xsolucion(Nodo, [Nodo|Sol1]) :-
    s(Nodo,Nodo1),
    solucion(Nodo1,Sol1).

%%% Búsqueda Primero en Profundidad evitando ciclos

solucion2(Nodo,Sol) :-
    primeroProfundidad([],Nodo,Sol).

primeroProfundidad(Camino, Nodo, [Nodo|Camino]) :-
    meta(Nodo).

primeroProfundidad(Camino, Nodo, Sol) :-
    s(Nodo,Nodo1),
    \+ member(Nodo1, Camino),
    primeroProfundidad([Nodo|Camino],Nodo1,Sol).

imprime_edos([]) :- write('Fin'),nl.
imprime_edos([Edo|Edos]) :- write(Edo), nl, imprime_edos(Edos).

%%% Búsqueda Primero en Profundidad evitando ciclos y con máxima prof.

solucion3(Nodo,Sol,MaxProf) :-
    primeroProfundidad2(Nodo,Sol,MaxProf).

primeroProfundidad2(Nodo,[Nodo],_) :-
    meta(Nodo).

primeroProfundidad2(Nodo,[Nodo|Sol],MaxProf):-
    MaxProf > 0,
    s(Nodo,Nodo1),
    Max1 is MaxProf-1,
    primeroProfundidad2(Nodo1,Sol,Max1).

%%% Reset para llamar un nuevo problema

reset :-
    retractall(s/2),
    retractall(meta/1).
