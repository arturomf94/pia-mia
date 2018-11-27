;;; Automatically generated delivery script

(in-package :cl-user)

(load-all-patches)

;;; Load the application:

(load "/Users/aguerra/.lispworks")
(load "cl-id3.asd")
(asdf:operate 'asdf:load-op  :split-sequence)
(asdf:load-system :cl-id3)
(compile-file "cl-id3-main")
(load "cl-id3-main")

;;; Load the example file that defines WRITE-MACOS-APPLICATION-BUNDLE
;;; to create the bundle.

(compile-file (sys:example-file "configuration/macos-application-bundle.lisp") :load t)

(deliver 'main
	 (when (save-argument-real-p)
	   (write-macos-application-bundle
	    "/Users/aguerra//Desktop/cl-id3.app"))
         0
         :interface :capi)
