;;;   cl-id3-load.lsp
;;;      Loading a trainning environment from an ARFF or CSV file
;;;
;;;   Alejandro Guerra Hernandez
;;;   Departamento de Inteligencia Artificial
;;;   Universidad Veracruzana
;;;   Facultad de Física e Inteligencia Artificial
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

;;; Auxiliar functions


(defun read-lines-from-file (file)
  "It reads the FILE into a list of strings"
  (remove-if (lambda (x) (equal x "")) 
	     (with-open-file (in file) 
	       (loop for line = (read-line in nil 'end) 
		  until (eq line 'end) collect line))))

;;; Load

(defun load-file (file)
  "It initializes the learning setting from FILE"
  (labels ((get-examples (data)
	     (loop for d in data do
		  (let ((ej (gensym "ej")))
		    (setf *examples* (cons ej *examples*))
		    (loop for attrib in *attributes*
		       as v in d do
			 (put-value attrib ej v))))))	     
    (if (probe-file file)
	(let ((file-ext (car (last (split-sequence #\. file))))
	      (file-lines (read-lines-from-file file)))
	  (reset)
	  (cond
	    ((equal file-ext "arff") 
	     (let ((attribs-doms (arff-get-attribs-doms file-lines)))
	       (setf *attributes* (mapcar #'car attribs-doms))
	       (setf *domains* (mapcar #'cadr attribs-doms))
	       (setf *target* (arff-get-target file-lines))
	       (setf *data* (arff-get-data file-lines))
	       (get-examples *data*)
	       (format t "Training set initialized after ~s.~%" file)))
	    ((equal file-ext "csv") 
	     (let ((attribs-doms (csv-get-attribs-doms file-lines)))
	       (setf *attributes* (mapcar #'car attribs-doms))
	       (setf *domains* (mapcar #'cadr attribs-doms))
	       (setf *target* (csv-get-target file-lines))
	       (setf *data* (csv-get-data file-lines))
	       (get-examples *data*)
	       (format t "Training set initialized after ~s.~%" file)))
	    (t (error "File's ~s extension can not be determined." file))))
	(error "File ~s does not exist.~%" file))))

(defun put-value (attr inst val)
  "It inks the VAL of an ATTR in an INST"
  (setf (get inst attr) val))

(defun get-value (attr inst)
  "It gets the value of an ATTR for a given INST"
  (get inst attr))

;;; Reset

(defun reset ()
  "It resets the learning environment"
  (setf *data* nil 
	*examples* nil
	*target* nil
	*attributes* nil
	*domains* nil
        *root* nil
	*gensym-counter* 1)
  (format t "The ID3 setting has been reset.~%"))

;;; ARFF files

(defun arff-get-target (lines)
  "It extracts the value for *target* from the lines of a ARFF file"
  (read-from-string
   (cadr (split-sequence 
	  #\Space
	  (car (remove-if-not 
		(lambda (x) (or (string-equal "@r" (subseq x 0 2))
				(string-equal "@R" (subseq x 0 2)))) 
		lines))))))

(defun arff-get-data (lines)
  "It extracts the value for *data* from the lines of a ARFF file"
  (mapcar #'(lambda(x)
	      (mapcar #'read-from-string
		      (split-sequence #\, x)))
	  (remove-if
	   (lambda (x) (string-equal "@" (subseq x 0 1)))
	   lines)))

(defun arff-get-attribs-doms (lines)
  " It extracts the list (attibutes domains) from an ARFF file"
  (mapcar #'(lambda(x)
	      (list (read-from-string (car x))
		    (mapcar #'read-from-string
			    (split-sequence 
			     #\,
			     (remove-if (lambda(x)
					  (or (string-equal "{" x)
					      (string-equal "}" x)))
					(cadr x))))))	      
	  (mapcar #'(lambda(x) 
		      (cdr (split-sequence 
			    #\Space x)))
		  (remove-if-not 
		   (lambda (x) 
		     (or (string-equal "@a" (subseq x 0 2))
			 (string-equal "@A" (subseq x 0 2)))) 
		   lines))))

;;; CSV files

(defun csv-get-target (lines)
  "It extracts the value for *target* from the lines of a CSV file"
  (read-from-string
   (car (last (split-sequence #\, (car lines))))))

(defun csv-get-data (lines)
  "It extracts the value for *data* from the lines of a CSV file"
  (mapcar #'(lambda(x)
	      (mapcar #'read-from-string
		      (split-sequence #\, x))) 
	  (cdr lines)))

(defun csv-get-attribs-doms (lines)
  "It extracts the list (attibutes domains) from an CSV file"
  (labels ((csv-get-values (attribs data)
	     (loop for a in attribs collect
		  (remove-duplicates
		   (mapcar #'(lambda(l)
			       (nth (position a attribs) l))
			   data)))))
    (let* ((attribs (mapcar #'read-from-string
			    (split-sequence #\, (car lines))))
	   (data (csv-get-data lines))
	   (values (csv-get-values attribs data)))
      (mapcar #'list attribs values))))

