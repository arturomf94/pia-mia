;;; Esta funcion toma un atomo y una lista
;;; Se implementa un cond y se consideran
;;; los casos donde la lista esta vacia,
;;; donde la cabeza de la lista es igual
;;; al atomo y un caso que siempre se
;;; cumple. El primero regresa la lista
;;; inalterada. El segundo hace una llamada
;;; recursiva con solo el cuerpo de la lista.
;;; El tercero concatena la cabeza de la
;;; lista con una llamada recursiva limitada
;;; al cuerpo.

(defun eliminar (atom lst)
  (cond ((null lst) lst)
    ((eql (car lst) atom) (eliminar atom (cdr lst)))
    (t (append (list(car lst)) (eliminar atom (cdr lst))))))
