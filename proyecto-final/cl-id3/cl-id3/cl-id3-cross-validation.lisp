(in-package :cl-id3)

;;; cl-id3-cross-validation

(defun cross-validation (k)
  (let* ((long (length *examples*))(k-validation-trees '()))
    (loop repeat k do
	 (let* ((trainning-data (folding (- long k) long))
		(test-data (difference trainning-data *examples*))
		(tree (induce trainning-data)))
    (setf *k-validation-trees* (append *k-validation-trees* (list tree))) ;;Agregado por mi
           ;; Agrega elementos a las variables para su c�lculo
	   (progn
             (report tree test-data)
             (print "Classified-int") ;;Agregada por mi
             (print *classified-int*)
             (print "c-classified-int") ;;Agregada por mi
             (print *c-classified-int*)
             )))
             (setf *best-tree* (nth (maximum-idx *c-classified-int*) *k-validation-trees*))
             (print *best-tree*)
             ))

(defun report (tree data)
  (let ((positives (count-positives tree data)))
    (progn
      (print-tree tree)
      (print (format t
                     "~%Instances Classified Correctly: ~S~%Instances Classified Incorrectly: ~S~%~%"
                     positives
                     (- (length data) positives)))
      (setf *classified-int* (append *classified-int* (list (length data)) ))
      (setf *c-classified-int* (append *c-classified-int* (list positives))) )))

(defun calculate-voting-accuracy (trees)
  (/ (count-voting-positives trees *examples*) (length *examples*)))

(defun calculate-best-tree-accuracy (best-tree)
  (/ (count-positives best-tree *examples*) (length *examples*)))

(defun count-positives (tree data)
  (apply #'+
	 (mapcar #'(lambda (e)
		     (if (eql (classify e tree)
			      (get-value *target* e))
			 1 0)) data)))

 (defun count-voting-positives (tree data)
  (apply #'+
 	 (mapcar #'(lambda (e)
 		     (if (eql (classify-new-instance-votacion e tree)
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

;;; Agregado por DHE

;;; Funcion para obtener los elementos mas repetidos de una lista
(defun repetidos (lst &optional (resultado '()))
 "Funcion que obtiene los elementos que mas se repiten en la lista lst, almacenandolos en la lista resultado"
 (if (null lst)
   (reverse resultado)
   (if (member (first lst) (rest lst))
     (repetidos (rest lst) (adjoin (first lst) resultado))
     (repetidos (rest lst) resultado))))

;;; maximum-idx es la Funcion para obtener el maximo elemento de una lista
;;; y su indice (iota y maximum son complementos de maximum-idx)
(defun maximum-idx (lst)
  (cadr (multiple-value-list (maximum lst))))
(defun maximum (lst)
  (let ((max-idx 0)
        (max-val (car lst)))
  (mapcar #'(lambda (x y) (if (> x max-val)
                            (progn
                              (setf max-val x)
                              (setf max-idx y))))
          lst (iota (length lst)))
  (values max-val max-idx)))
(defun iota (n &optional (start-at 0))
  (if (<= n 0) nil (cons start-at (iota (- n 1) (+ start-at 1)))))
