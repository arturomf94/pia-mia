;;; En el primer caso, la segunda lista esta vacia
;;; y el resultado es nil. En el segundo, la
;;; primera lista esta vacia y se regresa el valor T
;;; Por ultimo, si la cabeza de la primera es miembro
;;; de la segunda se llama recursivamente la funcion
;;; con el cuerpo de la primera y la segunda.

(defun subset (lst1 lst2)
  (cond ((null lst2) nil)
    ((null lst1) T)
    ((member (car lst1) lst2) (subset (cdr lst1) lst2))))

;;; En el primer caso si cualquier lista esta vacia
;;; se regresa la lista vacia. En el segundo caso si
;;; la cabeza de la primera lista esta en la segunda
;;; entonces se juntan la cabeza de la primera y el
;;; resultado de una llamada recursiva a inter con el
;;; cuerpo de la primera lista y la segunda completa.
;;; Por ultimo, en cualquier otro caso se hace la
;;; llamada recursiva con el cuerpo de la primera y la
;;; segunda completa.

(defun inter (lst1 lst2)
  (cond ((or (null lst1) (null lst2)) '())
    ((member (car lst1) lst2) (append (list(car lst1)) (inter (cdr lst1) lst2)))
    (t (inter (cdr lst1) lst2))))

;;; Si la primera lista esta vacia se regresa la segunda
;;; lista. Si la segunda esta vacia se regresa la primera.
;;; Si la cabeza de la primera esta en la segunda, entonces
;;; se hace una llamada recursiva con el cuerpo de la
;;; primera y la segunda. En cualquier otro caso se junta
;;; la cabeza de la primera con una llamada recursiva
;;; igual a la anterior.

(defun myunion (lst1 lst2)
  (cond ((null lst1) lst2)
    ((null lst2) lst1)
    ((member (car lst1) lst2) (myunion (cdr lst1) lst2))
    (t (append (list(car lst1)) (myunion (cdr lst1) lst2)))))

;;; Si la primera lista esta vacia se regresa la lista
;;; vacia. Si la segunda esta vacia se regresa la primera.
;;; En el caso en el cual la cabeza de la primera esta
;;; en la segunda, se hace la llamada recursiva con
;;; el cuerpo de la primera y la segunda (eliminando la
;;; cabeza de la primera). En cualquier otro caso se junta
;;; la cabeza de la primera lista con la llamada recursiva
;;; del cuerpo de la primera lista y la segunda.

(defun dif (lst1 lst2)
  (cond ((null lst1) '())
    ((null lst2) lst1)
    ((member (car lst1) lst2) (dif (cdr lst1) (remove (car lst1) lst2)))
    (t (append (list(car lst1)) (dif (cdr lst1) lst2)))))
