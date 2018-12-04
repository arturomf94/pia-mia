;;; Esta funcion tiene como atomo una lista
;;; Funciona con un cond, cuyo primer caso
;;; es cuando la lista esta vacia. En el
;;; segundo caso el cuerpo de la lisa esta
;;; vacia y el tercer caso se cumple siempre
;;; En el primero se regresa nil. En el
;;; segundo se regresa una lista que contiene
;;; la lista original. El tercero hace un loop
;;; sobre los atomos de la lista y para cada
;;; caso hace una llamada recursiva con el
;;; resto de la lista. Estos resultados se unen.

(defun perms (lst)
  (cond ((null lst) nil)
        ((null (cdr lst)) (list lst))
        (t (loop for atom in lst
             append (mapcar (lambda (l) (cons atom l))
                            (perms (remove atom lst)))))))
