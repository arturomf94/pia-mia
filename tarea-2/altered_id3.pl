:- dynamic
       ejemplo/3,
       nodo/3.

%%% id3.pl
%%% An implementation of the ID3 algorithm for inducing decision trees
%%% from data

% main call to id3

id3 :- id3(1).	% Umbral = 1, por default.

id3(Umbral) :-
    reset,
    write('Con que archivo CSV desea trabajar: '),
    read(ArchCSV),
    cargaEjs(ArchCSV,Atrs),
    findall(N,ejemplo(N,_,_),Inds), % Obtiene indices Inds de los ejemplos
    write('Tiempo de inducción:'),
    time(inducir(Inds,raiz,Atrs,Umbral)),
    imprimeArbol, !.

% Caso 1. El número de ejemplos a clasificar es menor que el umbral.
% Se crea un nodo hoja con las distribución Distr, apuntando al padre
% del nodo.

inducir(Ejs,Padre,_,Umbral) :-
    length(Ejs,NumEjs),
    NumEjs=<Umbral,
    distr(Ejs, Distr),
    assertz(nodo(hoja,Distr,Padre)), !. % Se agrega al final de los nodos.

% Caso 2. Todos los ejemplos a clasificar son de la misma clase.
% Se crea un nodo hoja con la distribución [Clase], apuntando al padre
% del nodo.

inducir(Ejs,Padre,_,_) :-
    distr(Ejs, [Clase]),
    assertz(nodo(hoja,[Clase],Padre)).

% Caso 3. Se debe decidir que atributo es el mejor clasificador para
% los ejemplos dados.

inducir(Ejs,Padre,Atrs,Umbral) :-
    eligeAtr(Ejs,Atrs,Atr,Vals,Resto), !,
    particion(Vals,Atr,Ejs,Padre,Resto,Umbral).

% Caso 4. Los datos son inconsistentes, no se pueden particionar.

% inducir(_Ejs,_Padre,_,_).
inducir(Ejs,Padre,_,_) :- !,
    nodo(Padre,_Test,_),
    findall(Ej,(member(Ej,Ejs),ejemplo(Ej,si,_)),EjsEnClase),
    length(EjsEnClase,NumEjsEnClase), !,
    length(Ejs,NumEjs), !,
    Prop is NumEjsEnClase / NumEjs,
    assertz(nodo(hoja,[si/Prop],Padre)).

% eligeAtr(+Ejs,+Atrs,-Atr,-Vals,-Resto)
% A partir de un conjunto de ejemplos Ejs y atributos Atrs, computa
% el atributo Atr \in Atrs con mayor ganancia de información, sus Vals
% y el Resto de atributos en Atrs.

eligeAtr(Ejs,Atrs,Atr,Vals,RestoAtrs) :-
    length(Ejs,NumEjs),
    contenidoInformacion(Ejs,NumEjs,I), !,
    findall((Atr-Vals)/Gain,
            (member(Atr,Atrs),
             vals(Ejs,Atr,[],Vals),
             separaEnSubConjs(Vals,Ejs,Atr,Parts),
             informacionResidual(Parts,NumEjs,IR),
             Gain is I - IR),
            Todos),
    maximo(Todos,(Atr-Vals)/_),
    eliminar(Atr,Atrs,RestoAtrs), !.

separaEnSubConjs([],_,_,[]) :- !.
separaEnSubConjs([Val|Vals],Ejs,Atr,[Part|Parts]) :-
    subconj(Ejs,Atr=Val,Part), !,
    separaEnSubConjs(Vals,Ejs,Atr,Parts).

informacionResidual([],_,0) :- !.
informacionResidual([Part|Parts],NumEjs,IR) :-
    length(Part,NumEjsPart),
    contenidoInformacion(Part,NumEjsPart,I), !,
    informacionResidual(Parts,NumEjs,R),
    IR is R + I * NumEjsPart/NumEjs.

contenidoInformacion(Ejs,NumEjs,I) :-
    setof(Clase,Ej^AVs^(member(Ej,Ejs),ejemplo(Ej,Clase,AVs)),Clases), !,
    sumaTerms(Clases,Ejs,NumEjs,I).

sumaTerms([],_,_,0) :- !.
sumaTerms([Clase|Clases],Ejs,NumEjs,Info) :-
    findall(Ej,(member(Ej,Ejs),ejemplo(Ej,Clase,_)),EjsEnClase),
    length(EjsEnClase,NumEjsEnClase),
    sumaTerms(Clases,Ejs,NumEjs,I),
    Info is I - (NumEjsEnClase/NumEjs)*(log(NumEjsEnClase/NumEjs)/log(2)).

vals([],_,Vals,Vals) :- !.
vals([Ej|Ejs],Atr,Vs,Vals) :-
    ejemplo(Ej,_,AVs),
    member(Atr=V,AVs), !,
    (member(V,Vs), !, vals(Ejs,Atr,Vs,Vals);
     vals(Ejs,Atr,[V|Vs],Vals)
    ).

subconj([],_,[]) :- !.
subconj([Ej|Ejs],Atr,[Ej|RestoEjs]) :-
    ejemplo(Ej,_,AVs),
    member(Atr,AVs), !,
    subconj(Ejs,Atr,RestoEjs).
subconj([_|Ejs],Atr,RestoEjs) :-
    subconj(Ejs,Atr,RestoEjs).

% particion(+Vals,+Atr,+Ejs,+Padre,+Resto,+Umbral)
% Por acada Valor del atributo Atr en Vals, induce una partición
% en los ejemplos Ejs de acuerdo a Valor, para crear un nodo del
% árbol y llamar recursivamente a inducir.

particion([],_,_,_,_,_) :- !.
particion([Val|Vals],Atr,Ejs,Padre,RestoAtrs,Umbral) :-
    subconj(Ejs,Atr=Val,SubEjs), !,
    generaNodo(Nodo),
    assertz(nodo(Nodo,Atr=Val,Padre)),
    inducir(SubEjs,Nodo,RestoAtrs,Umbral), !,
    particion(Vals,Atr,Ejs,Padre,RestoAtrs,Umbral).

%%% distr(+Ejs,-DistrClaseEjs)
%%% Computa la Distributción de clases para el conjunto de ejemplos S.
%%% La notación X^Meta causa que X no sea instanciada al solucionar la Meta.

distr(Ejs,DistClaseEjs) :-
    % Extrae Valores de clase Cs de los ejemplos S
    setof(Clase,Ej^AVs^(member(Ej,Ejs),ejemplo(Ej,Clase,AVs)),Clases),
    % Cuenta la distribución de los valores para la Clase
    cuentaClases(Clases,Ejs,DistClaseEjs).

cuentaClases([],_,[]) :- !.
cuentaClases([Clase|Clases],Ejs,[Clase/Test|RestoCuentas]) :-
    % Extrae los ejemplos con clase Clase en la lista Cuentas
    findall(Ej,(member(Ej,Ejs),ejemplo(Ej,Clase,_)),EjsEnClase),
    % Computa cuantos ejemplos hay en la Clase
    length(EjsEnClase,NumEjsEnClase), !,
    Test is NumEjsEnClase / NumEjsEnClase,
    % Cuentas para el resto de los valores de la clase
    cuentaClases(Clases,Ejs,RestoCuentas).

/*--------------------- Imprime Arbol --------------------*/

imprimeArbol :-
    imprimeArbol(raiz,0).

imprimeArbol(Padre,_) :-
    nodo(hoja,Clase,Padre), !,
    write(' => '),write(Clase).

imprimeArbol(Padre,Pos) :-
    findall(Hijo,nodo(Hijo,_,Padre),Hijos),
    Pos1 is Pos+2,
    imprimeLista(Hijos,Pos1).

imprimeLista([],_) :- !.

imprimeLista([N|T],Pos) :-
    nodo(N,Test,_),
    nl, tab(Pos), write(Test),
    imprimeArbol(N,Pos),
    imprimeLista(T,Pos).

/*------------------- Auxiliares --------------------------*/

generaNodo(M) :-
    retract(id(N)),
    M is N+1,
    assert(id(M)), !.

generaNodo(1) :-
    assert(id(1)).

eliminar(X,[X|T],T) :- !.

eliminar(X,[Y|T],[Y|Z]) :-
   eliminar(X,T,Z).

subconjunto([],_) :- !.

subconjunto([X|T],L) :-
    member(X,L), !,
    subconjunto(T,L).

maximo([X],X) :- !.
maximo([X/M|T],Y/N) :-
    maximo(T,Z/K),
    (M>K,Y/N=X/M ; Y/N=Z/K), !.

% elimina las ocurrencias de ejemplo y nodo en el espacio de trabajo

reset :-
    retractall(ejemplo(_,_,_)),
    retractall(nodo(_,_,_)),
    retractall(id(_)).

/*----------------------- Lectura de CSV --------------------------*/

% cargaEjs(ArchCSV): carga ArchCSV como hechos estilo
% ejemplo(Ind,Clase,[Atr=Val]).

cargaEjs(ArchCSV,Atrs) :-
    csv2ejs(ArchCSV,Ejs,Atrs),
    maplist(assertz,Ejs).

% csv2ejs(ArchCSV,Ejs,Atrs): transforma las lista de salida de leerCSV/2 en una lista de
% ejemplos(Ind,Clase,[Atr=Val]) y otra lista de atributos.

csv2ejs(ArchCSV,Ejs,Atrs) :-
    leerCSV(ArchCSV,Atrs,EjsCSV),
    butlast(Atrs,AtrsSinUltimo),
    procEjs(1,AtrsSinUltimo,EjsCSV,Ejs).

procEjs(_,_,[],[]).

procEjs(Ind,AtrsSinUltimo,[Ej|Ejs],[ejemplo(Ind,Clase,EjAtrsVals)|Resto]) :-
    last(Ej,Clase),
    butlast(Ej,EjSinUltimo),
    maplist(procAtrVal,AtrsSinUltimo,EjSinUltimo,EjAtrsVals),
    IndAux is Ind + 1,
    procEjs(IndAux,AtrsSinUltimo,Ejs,Resto).

procAtrVal(Atr,Val,Atr=Val).

% leerCSV(ArchivoCSV,Ats,Ejs): lee el archivo CSV para obtener una lista
% de atributs Ats, y una de valores para cada ejemplo Ejs

leerCSV(ArchCSV,Atrs,Ejs) :-
    csv_read_file(ArchCSV,[AtrsAux|EjsAux], [strip(true)]),
    AtrsAux =.. [_|Atrs],
    maplist(procEj,EjsAux,Ejs),
    length(Ejs,NumEjs),
    write(NumEjs), write(' ejemplos de entrenamiento cargados.'), nl.

% procEj(Ej,Args): regresa los argumento Args del ejempl Ej.

procEj(Ej,Args) :-
    Ej =.. [_|Args].

% dominios(Atrs,Ejs,Doms): regresa los dominios Doms de los atributos
% Ats, dados los ejemplos Ejs.

dominios(Atrs,Ejs,Doms) :-
    findall([Atr,Dom],(member(Atr,Atrs),
		 nth0(Ind,Atrs,Atr),
		 column(Ind,Ejs,Vals),
		 list_to_set(Vals,Dom)),
	    Doms).

% column(N,Ejs,Vals): regresa los valores Vals del N-ésimo atributo en
% los ejemplos Ejs.

column(N,Ejs,Vals) :-
    maplist(nth0(N),Ejs,Vals).

%%% last(L,E): E es el último elemento de la lista L.

last([],[]).
last(L,E) :-
    append(_,[E],L).

%%% butLast(L1,L2): L2 es L1 sin el último elemento.

butlast([],[]).
butlast(L1,L2) :-
    last(L1,Last),
    append(L2,[Last],L1).
