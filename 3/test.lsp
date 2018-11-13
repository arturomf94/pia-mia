(defun tercero (lst)
  (caddr lst))

(defun suma-mayor-que (x y z)
  (> (+ x y) z))

(defun miembro (obj lst)
  (if (null lst)
      nil
      (if (eql (car lst) obj)
	  lst
	  (miembro obj (cdr lst)))))

(defun miembro1 (elt lst)
  (cond ((null lst) nil)
	((eql elt (car lst)) lst)
	(t (miembro elt (cdr lst)))))
