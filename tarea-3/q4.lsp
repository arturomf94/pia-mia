;;; Regresa la cabeza de la lista tree
(defun root (tree)
  (car tree))

;;; Regresa la cabeza del cuerpo de la lista tree
(defun lbranch (tree)
  (car (cdr tree)))

;;; Regresa la cabesa del cuerpo del cuerpo de tree
(defun rbranch (tree)
  (car (cdr (cdr tree))))

;;; Esta funcion convierte una lista a un arbol.
;;; Si la lista esta vacia regresa nil. Si el cuerpo
;;; de la lista esta vacio, regresa una lista con la
;;; cabeza de la lista y dos elementos nil. En cualquier
;;; otro caso se regresa la lista compuesta de la cabeza
;;; de la lista, nil y la llamada recursiva con el cuerpo
;;; de la lista.
(defun list2tree (lst)
  (cond ((null lst) nil)
    ((null (cdr lst)) (list (car lst) nil nil))
    (t (list (car lst) nil (list2tree (cdr lst))))))

;;; Esta funcion agrega una hoja al arbol. Si la rama
;;; derecha del arbol esta vacia entonces regresa el mismo
;;; arbol pero con (elt nil nil) como rama derecha. En otro
;;; caso regresa el mismo arbol pero la rama derecha se
;;; sustituye con una llamada recursiva con la rama derecha
;;; del arbol.
(defun add_elt_tree (elt tree)
  (cond
    ((null (rbranch tree))
     (list (root tree) (lbranch tree) (list elt nil nil)))
    (t
     (list (root tree) (lbranch tree) (add_elt_tree elt (rbranch tree))))))

;;; Las funciones in_order, pre_order y post_order
;;; imprimen los elementos del arbol en ordenes diferentes.


;;; in_order imprime primero la rama izquierda del arbol
;;; luego la raiz y finalmente la rama derecha. Este orden
;;; se repite en las llamadas recursivas para imprimir las
;;; ramas.
(defun in_order (tree)
  (if (not (null (lbranch tree))) (in_order (lbranch tree)))
  (print (root tree))
  (if (not (null (rbranch tree))) (in_order (rbranch tree))))

;;; pre_order imprime primero la raiz del arbol
;;; luego la rama izquierda y finalmente la rama derecha. Este orden
;;; se repite en las llamadas recursivas para imprimir las
;;; ramas.
(defun pre_order (tree)
  (print (root tree))
  (if (not (null (lbranch tree))) (pre_order (lbranch tree)))
  (if (not (null (rbranch tree))) (pre_order (rbranch tree))))

;;; post_order imprime primero la rama izquierda del arbol
;;; luego la rama derecha y finalmente la raiz. Este orden
;;; se repite en las llamadas recursivas para imprimir las 
;;; ramas.
(defun post_order (tree)
  (if (not (null (lbranch tree))) (post_order (lbranch tree)))
  (if (not (null (rbranch tree))) (post_order (rbranch tree)))
  (print (root tree)))
