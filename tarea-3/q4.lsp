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

(defun in_order (tree)
  (if (not (null (lbranch tree))) (in_order (lbranch tree)))
  (print (root tree))
  (if (not (null (rbranch tree))) (in_order (rbranch tree))))

(defun pre_order (tree)
  (print (root tree))
  (if (not (null (lbranch tree))) (pre_order (lbranch tree)))
  (if (not (null (rbranch tree))) (pre_order (rbranch tree))))
