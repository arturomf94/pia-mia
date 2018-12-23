nodo(1,cielo=lluvioso,raiz).
nodo(2,viento=fuerte,1).
nodo(hoja,[no/2],2).
nodo(3,viento=debil,1).
nodo(hoja,[si/3],3).
nodo(4,cielo=nublado,raiz).
nodo(hoja,[si/4],4).
nodo(5,cielo=soleado,raiz).
nodo(6,humedad=normal,5).
nodo(hoja,[si/2],6).
nodo(7,humedad=alta,5).
nodo(hoja,[no/3],7).


%Ejemplo:[cielo=soleado,temperatura=alta,humedad=alta,viento=debil].


jugarTenis(Ejemplo) :- member(X=Y,Ejemplo), nodo(N,X=Y,raiz), jugarTenis(Ejemplo,N),!.

jugarTenis(Ejemplo,N) :- member(X=Y,Ejemplo), nodo(N2,X=Y,N), jugarTenis(Ejemplo,N2).

jugarTenis(_,N) :- nodo(hoja,[X/_],N), write(X).
