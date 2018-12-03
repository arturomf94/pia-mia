(defmacro nreps (x n &body body)
  (let ((gstop (gensym)))
    `(do ((,x 1 (1+ ,x))
          (,gstop ,n))
          ((> ,x ,gstop))
        (print ,@body))))