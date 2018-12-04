;;; Esta macro esta basada en el macro for
;;; de las notas largas del curso. Para
;;; modificarlo se fijo la variable start
;;; en 1 y la variable stop ahora es n. 
(defmacro nreps (x n &body body)
  (let ((gstop (gensym)))
    `(do ((,x 1 (1+ ,x))
          (,gstop ,n))
          ((> ,x ,gstop))
        (print ,@body))))
