(defun root (tree)
  (car tree))

(defun lbranch (tree)
  (car (cdr tree)))

(defun rbranch (tree)
  (car (cdr (cdr tree))))

(defun list2tree (lst)
  (cond ((null lst) nil)
    ((null (cdr lst)) (list (car lst) nil nil))
    (t (list (car lst) nil (list2tree (cdr lst))))))

(defun add_elt_tree (elt tree)
  (cond
    ((null (rbranch tree))
     (list (root tree) (lbranch tree) (list elt nil nil)))
    (t
     (list (root tree) (lbranch tree) (add_elt_tree elt (rbranch tree))))))

(defun in_order_tree (tree)
  (if (not (null (lbranch tree))) (in_order_tree (lbranch tree)))
  (print (root tree))
  (if (not (null (rbranch tree))) (in_order_tree (rbranch tree))))
