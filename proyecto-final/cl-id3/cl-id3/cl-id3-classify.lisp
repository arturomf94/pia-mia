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
