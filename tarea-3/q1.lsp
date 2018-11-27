(defun perms (lst)
  (cond ((null lst) nil)
        ((null (cdr lst)) (lst lst))
        (t (loop for atom in lst
             append (mapcar (lambda (l) (cons atom l))
                            (perms (remove atom lst)))))))
