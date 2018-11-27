(defun eliminar (atom lst)
  (cond ((null lst) lst)
    ((eql (car lst) atom) (cdr lst))))
