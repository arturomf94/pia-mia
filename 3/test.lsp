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

(defun n-elems (elem n)
  (if (> n 1)
      (list n elem)
      elem))

(defun compress (elem n lst)
  (if (null lst)
      (list (n-elems elem n))
      (let ((sig (car lst)))
        (if (eql sig elem)
            (compress elem (+ n 1) (cdr lst))
            (cons (n-elems elem n)
                  (compress sig 1 (cdr lst)))))))

(defun rle (lst)
  (if (consp lst)
      (compress (car lst) 1 (cdr lst))
      lst))

(defun mapcars (fn &rest lsts)
  (let ((result nil))
    (dolist (lst lsts)
       (dolist (obj lst)
          (push (funcall fn obj) result)))
    (nreverse result)))
