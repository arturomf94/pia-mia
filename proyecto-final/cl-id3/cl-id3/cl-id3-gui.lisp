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
   (efficiency-pane text-input-pane 
                    :text "" 
                    :accessor e-pane
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
                         :enabled-function #'(lambda (menu) *cross-validation-on*))
    ("Prune utility" :selection-callback 'prune-utility
                         :accelerator #\p
                         :enabled-function #'(lambda (menu) *prune-on*))))
   (help-menu 
    "Help"
    (("About" :selection-callback 'gui-about)))) 
  (:menu-bar file-menu view-menu id3-menu help-menu)  
  (:layouts
   (main-layout column-layout '(panes state-pane))
   (panes row-layout '(info-pane tree-pane))
   (titles column-layout '()) ;;; Aquí van los multi-árboles
   (matrix-pane row-layout '(titles confusion) 
                :title "Confusion Matrix" :x-gap '10 :y-gap '30
                :title-position :frame :visible-min-width '200)
   (confusion grid-layout '()) ;;; Aquí va la matriz de confusión
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
			   "Efficiency" efficiency-pane)
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
    ;; Lanza la función con K
    (cross-validation (parse-integer k))
    ;; Calcula y define la eficiencia
    (setf (text-input-pane-text (e-pane interface)) 
          (princ-to-string (/ (apply #'+ *c-classified-int*) 
                              (apply #'+ *classified-int*)))) ))

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
                       :title "Clase más votada: "
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

;;;Mejora David Martínez Galicia

(defun prune-utility (data interface) 
  (declare (ignore data interface))
;;Re-incorporación de la ventana de ejemplos
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
    (define-interface prune-int () ()
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
;;Nuevos elementos de la ventana
       (texto editor-pane
              :title "Consideraciones: "
              :text "Utilidad agregada por David Martínez Galicia. Apoyo para la poda post-mortem de arboles basada en la prueba chi cuadrada. Sólo es necesario escribir el nombre atributo y el número de los ejemplos que serán usados, ej '1 2 3 4 8 9'."
              :enabled nil)
       (attr-pane text-input-pane
                  :title "Atributo: "
                  :accessor attr-pane
                  :text ""
                  :enabled t)
       (ex-pane text-input-pane
                :title "Ejemplos: "
                :accessor ex-pane
                :text ""
                :enabled t)
       (dom-pane text-input-pane
                 :title "Dominio del atributo: "
                 :accessor dom-pane
                 :text ""
                 :enabled nil)
       (df-pane text-input-pane
                :title "Grado de libertad: "
                :accessor df-pane
                :text ""
                :enabled nil)
       (vcr-pane text-input-pane
                 :title "Valor crítico: "
                 :accessor vcr-pane
                 :text "0"
                 :enabled nil)
       (vcalc-pane text-input-pane
                   :title "Valor calculado: "
                   :accessor vcalc-pane
                   :text "0"
                   :enabled nil)
       (hip-pane text-input-pane
                 :title "Hipotesis: "
                 :accessor hip-pane
                 :text ""
                 :enabled nil)
       (bttn-prune push-button
                   :text "Correr prueba"
                   :callback 'gui-prune)
       (button-pane push-button
                    :text "Close"
                    :callback 'gui-quit))
      (:default-initargs
       :title "CL-ID3:Prune Utility"))
    (display (make-instance 'prune-int))))
;;Función que se lleva a cabo con el botón "correr prueba"
(defun gui-prune (data interface)
  (declare (ignore data))
  (progn
;;Definición de variables
    (setq *vcri* '(6.635 9.210 11.345))
    (setq critico 0)
    (setq calculado 0)
;;Determinación del indice de atributos
    (cond ((equal "cielo" (text-input-pane-text (attr-pane interface)))  
           (setq option 0))
          ((equal "temperatura" (text-input-pane-text (attr-pane interface))) 
           (setq option 1))
          ((equal "humedad" (text-input-pane-text (attr-pane interface))) 
           (setq option 2))
          ((equal "viento" (text-input-pane-text (attr-pane interface))) 
           (setq option 3))
          (t (setq option 5))
          )
;;Dom-list almacena el dominio del atributo seleccionado y luego se muestra en un panel de texto
    (setq dom-list (nth option *domains*))
    (setf (text-input-pane-text (dom-pane interface)) 
          (princ-to-string dom-list))
;;Clases almacena los valores de clase
    (setq clases (nth 4 *domains*))
;;Una vez obtenidos valores anteriores se procede a realizar el calculo de variables. 
    (when dom-list
      (progn
;; El grado de libertad se calcula restando un elemento al dominio del atributo
        (setf (text-input-pane-text (df-pane interface)) 
              (princ-to-string (- (length dom-list) 1)))
;;El valor crítico se obitne de una lista.
        (setq critico 
              (nth (-(length dom-list) 2) *vcri*))
        (setf (text-input-pane-text (vcr-pane interface)) 
              (princ-to-string critico))
;;Del panel ex-list se obtiene los números de ejemplos a utilizar.
        (setq ex-list (with-input-from-string 
                          (s (text-input-pane-text (ex-pane interface)))
                        (loop for x = (read s nil :end) until (eq x :end) 
                              collect x)))
;;Los ejemplos seleccionados son guardados en la variable datos.
        (setf datos (loop for example in ex-list 
                          collect (nth example *data*)))
;;A partir de este momento se definen variables para genarar el valor esperado de cuardo al dominio del atributo y su clasificación
        (setq total (length datos))
        (setq totalsi 
              (length (loop for ej in datos 
                            when (equal (nth 4 ej) (car clases)) 
                            collect (nth 4 ej))))
        (setq totalno 
              (length (loop for ej in datos 
                            when (equal (nth 4 ej) (cadr clases)) 
                            collect (nth 4 ej))))
        (setq totaldom (loop for dom in dom-list 
                            collect (length (loop for ej in datos 
                                                  when (equal (nth option ej) dom)
                                                              collect (nth option ej)))))
        (setq vesi (loop for vdom in totaldom 
                         collect (/ (* vdom totalsi) total)))
        (setq veno (loop for vdom in totaldom
                         collect (/ (* vdom totalno) total)))
        (setq vetotal (append vesi veno))
        (setq vosi (loop for dom in dom-list
                         collect (length (loop for ej in datos
                                               when (and (equal (nth option ej) dom) 
                                                         (equal (nth 4 ej) (car clases)))
                                               collect (nth option ej)))))
        (setq vono (loop for dom in dom-list 
                         collect (length (loop for ej in datos
                                               when (and (equal (nth option ej) dom) 
                                                        (equal (nth 4 ej) (cadr clases)))
                                               collect (nth option ej)))))
        (setq vototal (append vosi vono))
;;Se utiliza la fórmula de la prueba chi cuadrada y se muestra en el cuadro de texto vcalc-pane, para finalmente decidir si se acepta o rechaza la hipótesis.
        (when (equal (length vetotal) (length vototal))
          (progn
            (setq list_sum (loop for x from 0 to (- (length vetotal) 1) 
                                 collect (/ (expt (- (nth x vototal) (nth x vetotal)) 2)
                                            (nth x vetotal))))
            (setq calculado (apply '+ list_sum))
            (setf (text-input-pane-text (vcalc-pane interface)) 
                  (princ-to-string calculado))
            (cond ((> critico calculado) 
                   (setf (text-input-pane-text (hip-pane interface)) "Rechazada"))
                  (t 
                   (setf (text-input-pane-text (hip-pane interface)) "Aceptada")))
            ))


        ))
    
    
    )
)


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
   "CL-ID3~%~%Universidad Veracruzana~%Departamento de Inteligencia Artificial~%Sebastián Camacho No 5~%Xalapa, Ver., México 91000~%http://www.uv.mx/aguerra~%aguerra@uv.mx"))

;;; main call

(defun gui ()
  (reset)
  (display (make-instance 'cl-id3-gui)))
