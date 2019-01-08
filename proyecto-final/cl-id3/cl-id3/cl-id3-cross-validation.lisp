(in-package :cl-id3)

;;; cl-id3-cross-validation

(defun cross-validation (k)
  (let* ((long (length *examples*))(k-validation-trees '()))
    (loop repeat k do
	 (let* ((trainning-data (folding (- long k) long))
		(test-data (difference trainning-data *examples*))
		(tree (induce trainning-data)))
    (setf *k-validation-trees* (append *k-validation-trees* (list tree))) ;;Agregado por mi
           ;; Agrega elementos a las variables para su c�lculo
	   (progn
             (report tree test-data)
             (print "Classified-int") ;;Agregada por mi
             (print *classified-int*)
             (print "c-classified-int") ;;Agregada por mi
             (print *c-classified-int*)
             )))
             (setf *best-tree* (nth (select-bt *c-classified-int*) *k-validation-trees*))
             (print *best-tree*)
             ))
(defun traducir2 (arbol padre etiqueta)

  ;Hacer que los símbolos se muestren en minúsculas.
  (let ((*print-case* :downcase))

  ;Verifica si el argumento es un árbol o un SI/NO.
  (if (listp arbol)

     ;Hacer un loop en los valores del atributo en cuestión para generar los nodos del árbol de Prolog.
     (loop for i in (cdr (atributo-valores arbol)) do
        (progn

        ;Escribir los nodos del árbol de Prolog.
        (if (eq padre 0)
           (escribir (setf etiqueta (+ etiqueta 1)) (car (atributo-valores arbol)) i 'raiz)
           (escribir (setf etiqueta (+ etiqueta 1)) (car (atributo-valores arbol)) i padre)
        )

        ;Hacer un loop en los subárboles que están después de cada valor del atributo correspondiente
        ;para aplicarles esta misma función de manera recursiva.
        (loop for j in (cdr arbol) do
           (if (equal i (car j))
              (if (> (length j) 1)
                 (setf etiqueta (traducir2 (cadr j) etiqueta etiqueta))
                 (setf etiqueta (traducir2 (car j) etiqueta etiqueta))
              )
           )
        )
        )
        ;Retornar la etiqueta del último nodo creado para que su valor no se pierda después de cada
        ;llamada recursiva.
        finally (return etiqueta)
     )
     (progn
     ;Si el argumento es de la forma SI/NO escribir un nodo hoja.
     (escribir 'a arbol 'c etiqueta)
     etiqueta
     )
  )
  )
)

;Función que a partir de un árbol, crea una lista con el atributo "raíz" del árbol actual, seguido de sus valores.

(defun atributo-valores (lista)
   (loop for i in lista collect
      (if (listp i) (car i) i)
   )
)

;Función para escribir los nodos en el formato de Prolog.

(defun escribir (a b c d)

   (with-open-file (str "~/quicklisp/local-projects/cl-id3/cl-id3/arbol.pl"
               :direction :output
               :if-exists :append
               :if-does-not-exist :create)

      (if (or (equal b 'si) (equal b 'no))
         (format str "nodo(hoja,[~A/_],~A). ~%" b d)
         (format str "nodo(~A,~A=~A,~A).~%" a b c d)
      )
   )
)

;Función que sirve como interfaz de "traducir2" y escribe el programa de Prolog que clasifica.

(defun traducir (arbol)

   (progn
   (traducir2 arbol 0 0)
   (with-open-file (str "~/quicklisp/local-projects/cl-id3/cl-id3/arbol.pl"
               :direction :output
               :if-exists :append
               :if-does-not-exist :create)
   (format str "~%~%%Ejemplo:[cielo=soleado,temperatura=alta,humedad=alta,viento=debil].~%
jugarTenis(Ejemplo) :- member(X=Y,Ejemplo), nodo(N,X=Y,raiz), jugarTenis(Ejemplo,N),!.~%
jugarTenis(Ejemplo,N) :- member(X=Y,Ejemplo), nodo(N2,X=Y,N), jugarTenis(Ejemplo,N2).~%
jugarTenis(_,N) :- nodo(hoja,[X/_],N), write(X)."))
   )
)

(defun report (tree data)
  (let ((positives (count-positives tree data)))
    (progn
      (print-tree tree)
      (print (format t
                     "~%Instances Classified Correctly: ~S~%Instances Classified Incorrectly: ~S~%~%"
                     positives
                     (- (length data) positives)))
      (setf *classified-int* (append *classified-int* (list (length data)) ))
      (setf *c-classified-int* (append *c-classified-int* (list positives))) )))

(defun calculate-voting-accuracy (trees)
  (/ (count-voting-positives trees *examples*) (length *examples*)))

(defun calculate-best-tree-accuracy (best-tree)
  (/ (count-positives best-tree *examples*) (length *examples*)))

(defun count-positives (tree data)
  (apply #'+
	 (mapcar #'(lambda (e)
		     (if (eql (classify e tree)
			      (get-value *target* e))
			 1 0)) data)))

 (defun count-voting-positives (tree data)
  (apply #'+
 	 (mapcar #'(lambda (e)
 		     (if (eql (classify-new-instance-votacion e tree)
 			      (get-value *target* e))
 			 1 0)) data)))

(defun folding (n size)
  (let ((buffer nil))
    (loop repeat n
       collect (nth (let ((r (random size)))
		      (progn
			(while (member r buffer) (setf r (random size)))
			(push r buffer)
			r)) *examples*))))

(defun difference (list1 list2)
  (loop for i in list1 collect
       (setf list2 (remove i list2)))
  list2)

;;; Agregado por DHE

;;; Funcion para obtener los elementos mas repetidos de una lista
(defun repetidos (lst &optional (resultado '()))
 "Funcion que obtiene los elementos que mas se repiten en la lista lst, almacenandolos en la lista resultado"
 (if (null lst)
   (reverse resultado)
   (if (member (first lst) (rest lst))
     (repetidos (rest lst) (adjoin (first lst) resultado))
     (repetidos (rest lst) resultado))))
;;; Selecciona el mejor árbol
(defun select-bt (lst)
  (let ((cont 0) (index 0) (acc 0))
   (progn
     (loop for x in lst
           do (progn
                (when (> x acc) (and (setf acc x) (setf index cont)))
                (setf cont (+ cont 1))))
     index)))
