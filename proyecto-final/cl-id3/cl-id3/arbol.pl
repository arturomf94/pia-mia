nodo(1,cielo=nublado,raiz).
nodo(hoja,[si/_],1). 
nodo(3,cielo=soleado,raiz).
nodo(4,humedad=normal,3).
nodo(hoja,[si/_],4). 
nodo(6,humedad=alta,3).
nodo(hoja,[no/_],6). 
nodo(5,cielo=lluvia,raiz).
nodo(6,viento=fuerte,5).
nodo(hoja,[no/_],6). 
nodo(8,viento=debil,5).
nodo(hoja,[si/_],8). 


%Ejemplo:[cielo=soleado,temperatura=alta,humedad=alta,viento=debil].

jugarTenis(Ejemplo) :- member(X=Y,Ejemplo), nodo(N,X=Y,raiz), jugarTenis(Ejemplo,N),!.

jugarTenis(Ejemplo,N) :- member(X=Y,Ejemplo), nodo(N2,X=Y,N), jugarTenis(Ejemplo,N2).

jugarTenis(_,N) :- nodo(hoja,[X/_],N), write(X).