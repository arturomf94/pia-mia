(defun subset (lst1 lst2)
  (cond ((null lst2) nil)
    ((null lst1) T)
    ((member (car lst1) lst2) (subset (cdr lst1) lst2))))

(defun inter (lst1 lst2)
  (cond ((or (null lst1) (null lst2)) '())
    ((member (car lst1) lst2) (append (list(car lst1)) (inter (cdr lst1) lst2)))
    (t (inter (cdr lst1) lst2))))
