(defun perms (list)
  (cond ((null list) nil)
        ((null (cdr list)) (list list))
        (t (loop for atom in list
             append (mapcar (lambda (l) (cons atom l))
                            (perms (remove atom list)))))))
