(in-package :cl-id3)

;;; Global vars

(defvar *examples-on* nil "t enables the examples menu")
(defvar *attributes-on* nil "t enables the attributes menu")
(defvar *induce-on* nil "t enables the induce menu")
(defvar *classify-on* nil "t enables the classify menu")
(defvar *cross-validation-on* nil "t enables the cross-validation menu")
(defvar *prune-on* nil "t enables the prune utility menu")
(defvar *classified-int* ())
(defvar *c-classified-int* ())

;;; Gui

(define-interface cl-id3-gui ()
  ()
  (:panes
   (source-id-pane text-input-pane
                   :accessor source-id-pane
                   :text ""
                   :enabled nil)
   (num-attributes-pane text-input-pane
                        :accessor num-attributes-pane
                        :text ""
                        :enabled nil)
   (num-examples-pane text-input-pane
                      :accessor num-examples-pane
                      :text ""
                      :enabled nil)
   (class-pane text-input-pane
               :accessor class-pane
               :text ""
               :enabled nil)
   (accuracy-pane text-input-pane
                    :text ""
                    :accessor e-pane
                    :enabled nil)
   (voting-accuracy-pane text-input-pane
                    :text ""
                    :accessor e1-pane
                    :enabled nil)
   (best-tree-accuracy-pane text-input-pane
                    :text ""
                    :accessor e2-pane
                    :enabled nil)
   (k-value-pane text-input-pane
                 :accessor k-pane
                 :text "0")
   (tree-pane graph-pane
              :title "Decision Tree"
              :title-position :frame
              :children-function 'node-children
              :edge-pane-function
              #'(lambda(self from to)
                  (declare (ignore self from))
                  (make-instance
                   'labelled-arrow-pinboard-object
                   :data (princ-to-string (node-from-label to))))
              :visible-min-width 450
              :layout-function :top-down)
   (state-pane title-pane
               :accessor state-pane
               :text "Welcome to CL-ID3."))
  (:menus
   (file-menu
    "File"
    (("Open" :selection-callback 'gui-load-file
             :accelerator #\o)
     ("Quit" :selection-callback 'gui-quit
             :accelerator #\q)))
   (view-menu
    "View"
    (("Attributes" :selection-callback 'gui-view-attributes
                   :accelerator #\a
                   :enabled-function #'(lambda (menu) *attributes-on*))
     ("Examples" :selection-callback 'gui-view-examples
                 :accelerator #\e
                 :enabled-function #'(lambda (menu) *examples-on*))))
   (id3-menu
    "id3"
    (("Induce" :selection-callback 'gui-induce
               :accelerator #\i
               :enabled-function #'(lambda (menu) *induce-on*))
     ("Classify" :selection-callback 'gui-classify
                 :accelerator #\k
                 :enabled-function #'(lambda (menu) *classify-on*))
     ("Cross-validation" :selection-callback 'gui-cross-validation
                         :accelerator #\c
                         :enabled-function #'(lambda (menu) *cross-validation-on*))))
   (help-menu
    "Help"
    (("About" :selection-callback 'gui-about))))
  (:menu-bar file-menu view-menu id3-menu help-menu)
  (:layouts
   (main-layout column-layout '(panes state-pane))
   (panes row-layout '(info-pane tree-pane))
   (titles column-layout '()) ;;; Aqu� van los multi-�rboles
   (matrix-pane row-layout '(titles confusion)
                :title "Confusion Matrix" :x-gap '10 :y-gap '30
                :title-position :frame :visible-min-width '200)
   (confusion grid-layout '()) ;;; Aqu� va la matriz de confusi�n
   (info-pane column-layout '(setting-pane id3-pane matrix-pane))
   (setting-pane grid-layout
		 '("Source File" source-id-pane
		   "No. Attributes" num-attributes-pane
		   "No. Examples" num-examples-pane
		   "Class" class-pane)
                 :y-adjust :center
                 :title "Trainning Set"
                 :title-position :frame :columns '2)
   (id3-pane grid-layout '("K value" k-value-pane
			   "Average Accuracy" accuracy-pane
         "Voting Accuracy" voting-accuracy-pane
         "Best-Tree Accuracy" best-tree-accuracy-pane)
             :y-adjust :center
             :title "Cross Validation"
             :title-position :frame :columns '2))
  (:default-initargs
   :title "CL-ID3"
   :visible-min-width 840
   :visible-min-height 600))

;;; Callbacks and Functions

;;; gui-cross-validation

(defun gui-cross-validation (data interface)
  (declare (ignore data))
  (progn
    ;; Toma K de la interfaz
    (setf k (text-input-pane-text (k-pane interface)))
    (setf *classified-int* '() *c-classified-int* '())
    ;; Lanza la funci�n con K
    (cross-validation (parse-integer k))
    ;; Calcula y define la eficiencia
    (setf (text-input-pane-text (e-pane interface))
          (princ-to-string (/ (apply #'+ *c-classified-int*)
                              (apply #'+ *classified-int*))))
    (setf (text-input-pane-text (e1-pane interface))
          (princ-to-string (calculate-voting-accuracy *k-validation-trees*)))
    (setf (text-input-pane-text (e2-pane interface))
          (princ-to-string (calculate-best-tree-accuracy *best-tree*)))))

;;; file/load

(defun gui-load-file (data interface)
  (declare (ignore data))
  (let ((file (prompt-for-file
               nil
               :filter "*.arff"
               :filters '("WEKA files" "*.arff"
                          "Comme Separated Values" "*.csv"))))
    (when file
      (let* ((path (princ-to-string file))
             (setting (car (last (split-sequence #\/ path)))))
        (load-file path)
        (setf (text-input-pane-text (source-id-pane interface))
              setting)
        (setf (text-input-pane-text (num-attributes-pane interface))
              (princ-to-string (length *attributes*)))
        (setf (text-input-pane-text (num-examples-pane interface))
              (princ-to-string (length *examples*)))
        (setf (text-input-pane-text (class-pane interface))
              (princ-to-string *target*))
        (setf (title-pane-text (state-pane interface))
              (format nil "The setting ~s has been loaded"
                      path))
        (setf *examples-on* t *attributes-on* t *induce-on* t *prune-on* t)))))

;;; file/quit

(defun gui-quit (data interface)
  (declare (ignore data))
  (quit-interface interface))


;;; view/domains

(defun gui-view-attributes (data interface)
  (declare (ignore data interface))
  (let* ((max-length-attrib (apply #'max
                                   (mapcar #'length
                                           (mapcar #'princ-to-string
                                                   *attributes*))))
         (pane-total-width (list 'character
                                 (* max-length-attrib
                                    (+ 1 (length *attributes*))))))
    (define-interface gui-domains () ()
      (:panes
       (attributes-pane multi-column-list-panel
                        :columns '((:title "Attrib/Class"
                                    :adjust :left
                                    :visible-min-width (character 10))
                                   (:title "Attributes" :adjust :left
                                    :visible-min-width (character 20))
                                   (:title "Domains" :adjust :left
                                    :visible-min-width (character 20)))
                        :items (loop for a in *attributes* collect
				    (list (if (eql *target* a) 'c 'a )
					  a
					  (get-domain a)))
                        :visible-min-width pane-total-width
                        :visible-min-height :text-height
                        :vertical-scroll t)
       (button-pane push-button
                    :text "Close"
                    :callback 'gui-quit))
      (:default-initargs
       :title "CL-ID3:attributes"))
    (display (make-instance 'gui-domains))))

;;
(defun gui-classify (data interface)
  (declare (ignore data interface))
  (define-interface new-classify-int () ()
    (:panes
     (new-ex-pane text-input-pane
                  :title "Nuevo ejemplo: "
                  :accessor new-ex-pane
                  :text ""
                  :enabled t)
     (most-voted-class text-input-pane
                       :title "Clase m�s votada: "
                       :accessor most-voted-class
                       :text ""
                       :enabled NIL)
     (bttn-classify push-button
                   :text "Clasificar"
                   :callback 'classify-new-instance2)
     (bttn-quit push-button
                    :text "Cerarr"
                    :callback 'gui-quit))
    (:default-initargs
       :title "CL-ID3: Classify"))
    (display (make-instance 'new-classify-int)))

;;; view/examples

(defun gui-view-examples (data interface)
  (declare (ignore data interface))
  (let* ((max-length-attrib
          (apply #'max
                 (mapcar #'length
                         (mapcar #'princ-to-string
                                 *attributes*))))
	 (column-width (list 'character
                             (+ 1 max-length-attrib)))
	 (pane-total-width (list 'character
                                 (* max-length-attrib
                                    (+ 1 (length *attributes*))))))
    (define-interface gui-examples () ()
      (:panes
       (examples-pane multi-column-list-panel
                      :columns (loop for a in *attributes* collect
                                     (list :title (princ-to-string a)
                                           :adjust :center
                                           :visible-min-width column-width))
                      :items (loop for d in *data* collect
                                   (mapcar #'princ-to-string d))
                      :visible-min-width pane-total-width
                      :visible-min-height :text-height
                      :vertical-scroll t)
       (button-pane push-button
                    :text "Close"
                    :callback 'gui-quit))
      (:default-initargs
       :title "CL-ID3:examples"))
    (display (make-instance 'gui-examples))))

;;; induce and display the tree

(defstruct node
  (inf nil)
  (sub-trees nil)
  (from-label nil))

(defun make-tree (tree-as-lst)
  "It makes a tree of nodes with TREE-AS-LST"
  (make-node :inf (root tree-as-lst)
             :sub-trees (make-sub-trees (children tree-as-lst))))

(defun make-sub-trees (children-lst)
  "It makes de subtrees list of a tree with CHILDREN"
  (loop for child in children-lst collect
        (let ((sub-tree (second child))
              (label (first child)))
          (if (leaf-p sub-tree)
              (make-node :inf sub-tree
                         :sub-trees nil
                         :from-label label)
            (make-node :inf (root sub-tree)
                       :sub-trees (make-sub-trees (children sub-tree))
                       :from-label label)))))

(defmethod print-object ((n node) stream)
  (format stream "~s " (node-inf n)))

(defun display-tree (root interface)
  "It displays the tree with ROOT in its pane in INTERFACE"
  (with-slots (tree-pane) interface
    (setf (graph-pane-roots tree-pane)
	  (list root))
    (map-pane-children tree-pane ;;; redraw panes correcting x/y-adjustments
                       (lambda (item)
                         (update-pinboard-object item)))))

(defun node-children (node)
  "It gets the children of NODE to be displayed"
  (let ((children (node-sub-trees node)))
    (when children
      (if (leaf-p children) (list children)
        children))))

;;; induce

(defun gui-induce (data interface)
  "It induces the decisicion tree and displays it in the INTERFACE"
  (declare (ignore data))
  (setf *current-tree* (induce) *cross-validation-on* t)
  (display-tree (make-tree *current-tree*)
                interface))

;;; classify


;;; help/about

(defun gui-about (data interface)
  "It displays the about message in INTERFACE"
  (declare (ignore data interface))
  (display-message
   "CL-ID3~%~%Universidad Veracruzana~%Departamento de Inteligencia Artificial~%Sebasti�n Camacho No 5~%Xalapa, Ver., M�xico 91000~%http://www.uv.mx/aguerra~%aguerra@uv.mx"))

;;; main call

(defun gui ()
  (reset)
  (display (make-instance 'cl-id3-gui)))
