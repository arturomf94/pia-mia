;;;   cl-id3.asd
;;;      The system definition for :cl-id3
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

(asdf:defsystem :cl-id3
    :depends-on (:split-sequence)
    :components ((:file "cl-id3-package")
		 (:file "cl-id3-algorithm"
			:depends-on ("cl-id3-package"))
		 (:file "cl-id3-load"
			:depends-on ("cl-id3-package" 
				     "cl-id3-algorithm"))
		 (:file "cl-id3-classify"
			:depends-on ("cl-id3-package" 
				     "cl-id3-algorithm" 
				     "cl-id3-load"))
		 (:file "cl-id3-cross-validation"
			:depends-on ("cl-id3-package" 
				     "cl-id3-algorithm" 
				     "cl-id3-load" 
				     "cl-id3-classify"))
		 (:file "cl-id3-gui"
			:depends-on ("cl-id3-package" 
				     "cl-id3-algorithm" 
				     "cl-id3-load" 
				     "cl-id3-classify" 
				     "cl-id3-cross-validation"))))

