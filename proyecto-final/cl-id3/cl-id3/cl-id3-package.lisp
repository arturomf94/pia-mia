;;;   cl-id3-package.lisp
;;;      The package definition for :cl-id3
;;;
;;;   Alejandro Guerra Hernandez
;;;   Departamento de Inteligencia Artificial
;;;   Universidad Veracruzana
;;;   Facultad de Física e Inteligencia Artificial
;;;
;;;   11/12/2011 Running on LispWorks 6.0
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

(defpackage :cl-id3
  (:use :cl :capi :split-sequence)
  (:export :load-file
	   :induce
	   :print-tree
	   :classify
	   :classify-new-instance
	   :cross-validation
	   :gui))

