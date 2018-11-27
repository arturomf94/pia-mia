(defun eliminar (atom lst)
  (cond ((null lst) lst)
    ((eql (car lst) atom) (eliminar atom (cdr lst)))
    (t (append (list(car lst)) (eliminar atom (cdr lst))))))
