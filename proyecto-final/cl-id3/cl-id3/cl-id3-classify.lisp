(in-package :cl-id3)

;;; classify
;;;   classify the instance accordingly the decision tree.
;;;      Ex. (classify (car *examples*) tree))
;;;   where tree is an induced decision tree.

(defun classify (instance tree)
  (let* ((val (get-value (first tree) instance))
         (branch (second (assoc val (cdr tree)))))
    (if (atom branch) branch
      (classify instance branch))))

;;; classify-new-instance
;;;   classify an instance beyond the training data, it is
;;;   necessary to pass the function the values for the
;;;   attributes describing the problem
;;;     Ex. (classify-new-instance '(sunny mild normal strong) attributes tree)

(defun classify-new-instance (values tree)
  (loop for attrib in (remove *target* *attributes*)
      as value in values do
        (put-value attrib 'instance value))
  (classify 'instance tree))


;;; Agregado por DHE

;;; classify-new-instance-votacion
;;;   Clasifica un nuevo ejemplo por votación,
;;;   es necesario parale a la función el nuevo ejemplo y
;;;   la lista de los k arboles creados durante Cross-Validation
;;;   Ejemplo
;;;   (cl-id3:classify-new-instance '(COMMON-LISP-USER::nublado COMMON-LISP-USER::calor COMMON-LISP-USER::normal COMMON-LISP-USER::debil) cl-id3::*best-tree*)
;;;   (cl-id3::classify-new-instance-votacion '(COMMON-LISP-USER::nublado COMMON-LISP-USER::calor COMMON-LISP-USER::normal COMMON-LISP-USER::debil) cl-id3::*k-validation-trees*)

(defun classify-new-instance-votacion (ninstance arboles)
  (car (repetidos
    (loop for x in arboles
      collect (classify ninstance x)
    )
  ))
)
