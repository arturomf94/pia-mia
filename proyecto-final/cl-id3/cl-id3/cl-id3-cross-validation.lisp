(in-package :cl-id3)

;;; cl-id3-cross-validation

(defun cross-validation (k)
  (let* ((long (length *examples*)))
    (loop repeat k do
	 (let* ((trainning-data (folding (- long k) long))
		(test-data (difference trainning-data *examples*))
		(tree (induce trainning-data)))
           ;; Agrega elementos a las variables para su cálculo
	   (progn 
             (report tree test-data)
             (print *classified-int*)
             (print *c-classified-int*))))))

(defun report (tree data)
  (let ((positives (count-positives tree data)))
    (progn
      (print-tree tree)
      (print (format t 
                     "~%Instances classified correctly: ~S~%Instances classified incorrectly: ~S~%~%"
                     positives 
                     (- (length data) positives)))
      (setf *classified-int* (append *classified-int* (list (length data)) ))
      (setf *c-classified-int* (append *c-classified-int* (list positives))) )))

(defun count-positives (tree data)
  (apply #'+
	 (mapcar #'(lambda (e) 
		     (if (eql (classify e tree)
			      (get-value *target* e))
			 1 0)) data)))

(defun folding (n size)
  (let ((buffer nil))
    (loop repeat n 
       collect (nth (let ((r (random size)))
		      (progn
			(while (member r buffer) (setf r (random size)))
			(push r buffer)
			r)) *examples*))))

(defun difference (list1 list2)
  (loop for i in list1 collect
       (setf list2 (remove i list2)))
  list2)