;;;   cl-id3-algorithm.lsp
;;;      The implementation of ID3
;;;      Stop criteria: same values for all examples
;;;      Metrics: information gain
;;;      Discretize: none
;;;
;;;   Alejandro Guerra Hernandez
;;;   Departamento de Inteligencia Artificial
;;;   Universidad Veracruzana
;;;   Facultad de F�sica e Inteligencia Artificial
;;;
;;;   12/01/2010 The system can generate cl-id3.app
;;;   06/01/2010 The system has a GUI
;;;   10/12/2009 The system is ASDF instalable
;;;   21/01/2009 File lecture is done without using grep. It is not
;;;              necessary anymore to use trivial-shell
;;;   19/01/2009 Verifies if the arff files exists before loading it
;;;   19/01/2009 It works in Lispworks 5.1.2
;;;   10/07/2008 The package uses split-sequence and trivial-shell to read ARFF
;;;   01/02/2007 The package works with ARFF files as input
;;;   11/03/2007 It runs in OpenMCL and LispWorks 5.0

(in-package :cl-id3)

;;; macros

(defmacro while (test &body bodys)
  `(do ()
       ((not ,test))
     ,@bodys))

;;; global variables

(defvar *examples* nil "The training set")
(defvar *attributes* nil "The attributes of the problem")
(defvar *data* nil "The values of the atributes of all *examples*")
(defvar *domains* nil "The domain of the attributes")
(defvar *target* nil "The target concept")
(defvar *trace* nil "Trace the computations")
(defvar *current-tree* "The tree being processed")

;;; functions on decision trees

(defun root (tree)
  "It gets the root of TREE"
  (car tree))

(defun children (tree)
  "It gets the braches/sub-trees of a TREE"
  (cdr tree))

(defun sub-tree (tree value)
  "It gets sub-tree of TREE computed by following the branch VALUE"
  (second (assoc value (cdr tree))))

(defun leaf-p (tree)
  "Is TREE a leaf ?"
  (atom tree))

;;; Se agrego la funcion count-instance
;;; para contar todas las instancias de un
;;; atomo en una lista.
(defun count-instance (a L)
  (cond
   ((null L) 0)
   ((equal a (car L)) (+ 1 (count-instance a (cdr L))))
   (t (count-instance a (cdr L)))))

;;; La funcion count-instance-prop expresa
;;; el conteo de count-instance como proporcion
;;; de la longitud de la lista.
(defun count-instance-prop (a L)
  (/ (count-instance a L) (list-length L)))

;;; La funcion list-to-string formatea
;;; una lista para poder expresarla como
;;; cadena.
(defun list-to-string (lst)
  (format nil "~A~%" lst))

;;; id3

(defun id3 (examples attribs)
  "It induces a decision tree running id3 over EXAMPLES and ATTRIBS)"
  ;;; Se agrego la variable vals que crea la lista de todos los
  ;;; valores de *target* en examples
  (let ((class-by-default (get-value *target*
				     (car examples)))
        (vals (mapcar #'(lambda(x) (get-value *target* x)) examples)))
    (cond
      ;; Stop criteria
      ;;; Se modifico este criterio para que regresara la clase en
      ;;; cuestion y la propocion de clasificaciones de esa clase.
      ;;; En este caso la proporcion siempre sera 1.
      ((same-class-value-p *target*
			   class-by-default
			   examples) (list-to-string
                 (list class-by-default
                       (count-instance-prop class-by-default vals))))
      ;; Failure
      ;;; Tambien se modifico este criterio para que regresara
      ;;; la clase en cuestion y la proporcion que representa esa
      ;;; clase en ese nodo. En este caso esa proporcion siempre es
      ;;; menor que 1.
      ((null attribs) (list-to-string
              (list class-by-default
                    (count-instance-prop class-by-default vals))))
      ;; Recursive call
      (t (let* ((partition (best-partition attribs examples))
		(node (first partition)))
	   (cons node
		 (loop for branch in (cdr partition) collect
		       (list (first branch)
			     (id3 (cdr branch)
				  (remove node attribs))))))))))

(defun same-class-value-p (attrib value examples)
  "Do all EXAMPLES have the same VALUE for a given ATTRIB ?"
  (every #'(lambda(e)
	     (eq value
		 (get-value attrib e)))
	 examples))

(defun target-most-common-value (examples)
  "It gets the most common value for *target* in EXAMPLES"
  (let ((domain (get-domain *target*))
	(vals (mapcar #'(lambda(x) (get-value *target* x))
		      examples)))
    (caar (sort (loop for v in domain collect
		     (list v (count v vals)))
		#'(lambda(x  y) (>= (cadr x)
				    (cadr y)))))))

(defun get-domain (attribute)
  "It gets the domain of an ATTRIBUTE"
  (nth (position attribute *attributes*)
       *domains*))

(defun get-partition (attrib examples)
  "It gets the partition induced by ATTRIB in EXAMPLES"
  (let (result vlist v)
    (loop for e in examples do
          (setq v (get-value attrib e))
          (if (setq vlist (assoc v result))
	      ;;; value v existed, the example e is added
	      ;;; to the cdr of vlist
	      (rplacd vlist (cons e (cdr vlist)))
	      ;;; else a pair (v e) is added to result
	      (setq result (cons (list v e) result))))
    (cons attrib result)))

(defun entropy (examples attrib)
  "It computes the entropy of EXAMPLES with respect to an ATTRIB"
  (let ((partition (get-partition attrib examples))
	(number-of-examples (length examples)))
    (apply #'+
	   (mapcar #'(lambda(part)
		       (let* ((size-part (count-if #'atom
						   (cdr part)))
			      (proportion
			       (if (eq size-part 0) 0
				   (/ size-part
				      number-of-examples))))
			 (* -1.0 proportion (log proportion 2))))
		   (cdr partition)))))

(defun information-gain (examples attribute)
  "It computes information-gain for an ATTRIBUTE in EXAMPLES"
  (let ((parts (get-partition attribute examples))
	(no-examples (count-if #'atom examples)))
    (- (entropy examples *target*)
       (apply #'+
	      (mapcar
	       #'(lambda(part)
		   (let* ((size-part (count-if #'atom
					       (cdr part)))
			  (proportion (if (eq size-part 0) 0
					  (/ size-part
					     no-examples))))
		     (* proportion (entropy (cdr part) *target*))))
	       (cdr parts))))))

(defun best-partition (attributes examples)
  "It computes one of the best partitions induced by ATTRIBUTES over EXAMPLES"
  (let* ((info-gains
	  (loop for attrib in attributes collect
	       (let ((ig (information-gain examples attrib))
		     (p (get-partition attrib examples)))
		 (when *trace*
		   (format t "Partici�n inducida por el atributo ~s:~%~s~%"
			   attrib p)
		   (format t "Ganancia de informaci�n: ~s~%"
			   ig))
		 (list ig p))))
	 (best (cadar (sort info-gains #'(lambda(x y) (> (car x) (car y)))))))
    (when *trace* (format t "Best partition: ~s~%-------------~%" best))
    best))

(defun induce (&optional (examples *examples*))
  "It induces the decision tree using learning sertting"
  (when (not (member *target* *attributes*))
    (error "The target is defined incorrectly: Maybe Weka modified your ARFF"))
  (id3 examples (remove *target* *attributes*)))

;;; Printing

(defun print-tree (tree &optional (depth 0))
  (mytab depth)
  (format t "~A~%" (first tree))
  (loop for subtree in (cdr tree) do
        (mytab (+ depth 1))
        (format t "- ~A" (first subtree))
        (if (atom (second subtree))
	    (format t " -> ~A~%" (second subtree))
	    (progn (terpri)(print-tree (second subtree) (+ depth 5))))))

(defun mytab (n)
  (loop for i from 1 to n do (format t " ")))
