(defun subset (lst1 lst2)
  (cond ((null lst2) nil)
    ((null lst1) T)
    ((member (car lst1) lst2) (subset (cdr lst1) lst2))))
