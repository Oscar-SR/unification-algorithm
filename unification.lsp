(defpackage :unification
  (:use :cl)
  (:export #:unificar #:aplicarsustitucion))

(in-package :unification)

(defun unificar (e1 e2)
	(prog (f1 f2 t1 t2 g1 g2 z1  z2 temp)
		(when (or (esAtomo e1) (esAtomo e2))
			; Intercambiar valores de los parámetros, si es necesario, para que e1 sea átomo
			(unless (esAtomo e1)
				(setf temp e1)
				(setf e1 e2)
				(setf e2 temp)
			)
			(if (equalp e1 e2)
				(return-from unificar :NADA)
			)
			(if (esVariable e1)
				(if (aparece e1 e2)
					(return-from unificar :FALLO)
					(return-from unificar (formarSustitucion e2 e1))
				)
			)
			(if (esVariable e2)
				(return-from unificar (formarSustitucion e1 e2))
				(return-from unificar :FALLO)
			)
		)
		(setf f1 (first e1))
		(setf t1 (rest e1))
		(setf f2 (first e2))
		(setf t2 (rest e2))
		(setf z1 (unificar f1 f2))
		(if(equalp z1 :FALLO)
			(return-from unificar :FALLO)
		)
		(setf g1 (aplicarSustitucion z1 t1))
		(setf g2 (aplicarSustitucion z2 t2))
		(setf z2 (unificar g1 g2))
		(if (equalp z2 :FALLO)
			(return-from unificar :FALLO)
		)
		(return-from unificar (componer z1 z2))
	)
)

(defun esVariable (var)
	(if (and (listp var) (eq (first var) '?))
		T
	)
)

(defun esAtomo (var)
	(cond ((atom var) T)
		((eq (first var) '?) T)
		(T NIL)
	)
)

(defun aparece (var lista)
	(cond
		; La lista está vacía
		((null lista) NIL)
		; Es átomo
		((atom lista)
			(if (eq var lista)
				T
				NIL
			)
		)
		; El primer elemento es una lista
		((listp (first lista)) (or (aparece var (first lista)) (aparece var (rest lista))))
		; La lista es igual a la variable
		((equalp var lista) T)
		; Sigue recorriendo la lista
		(T (aparece var (rest lista)))
	)
)

(defun formarSustitucion (e1 e2)
	(if (equalp e1 e2)
		:NADA
		(list '/ e1 e2)
	)
)

(defun aplicarSustitucion (s p)
	(cond ((equalp s :NADA) p)
		((null p) '())
		(T (sustituir s p))
	)
)

(defun sustituir (s p)
	(cond
		; La lista está vacía
		((null p) '())
		; Es un átomo
		((atom p) p)
		; Se ha encontrado una sustitución
		((and (listp (first p)) (eq (first (first p)) '?) (eq (first (rest (first (last s)))) (first (rest (first p)))))
			(cons (first (rest s)) (sustituir s (rest p)))
		)
		; Se ha encontrado una sublista
		((listp (first p))
			(cons (sustituir s (first p)) (sustituir s (rest p)))
		)
		; Se ha encontrado una variable
		((and (listp p) (eq (first p) '?) (eq (first (rest (first (last s)))) (first (rest p))))
			(first (rest s))
		)
		; Si no es una lista o variable, devolver el elemento tal como está y continuar
		(T (cons (first p) (sustituir s (rest p))))
	)
)

(defun componer (s1 s2)
	(cond
		((and (equalp s1 :NADA) (equalp s2 :NADA)) :NADA)
		((equalp s1 :NADA) s2)
		((equalp s2 :NADA) s1)
		(t 
			(if (equalp (first s1) '/)
				(setf s1 (list s1))
			)
			(if (equalp (first s2) '/)
				(setf s2 (list s2))
			)
			; Paso 1
			(setf s1s2 s1)
			(dolist (s s2)
				(setf s1s2 (sustituirComponer s s1s2))
			)
			; Paso 2
			(setf noAparecen '())
			(dolist (i s2)
				(setf saltar NIL)
		    		(dolist (j s1s2)
		      			(when (or (aparece (first (last i)) (first (rest j))) (aparece (first (last i)) (first (last j))))
						(setf saltar T)
						(return)
					)  ; Marca que se debe saltar a la siguiente iteración
		      		)
		    		(unless saltar
		      			; Una variable no aparece en Z1Z2
		      			(setf noAparecen (append noAparecen (list i)))
		      		)
		    	)
		    	(unless (null noAparecen)
		    		(setf s1s2 (append s1s2 noAparecen))
		    	)
			s1s2
		)
	)
)

(defun sustituirComponer (s p)
	(cond
		; La lista está vacía
		((null p) '())
		; Sustituye dentro del elemento i
		(T (cons (list '/ (sustituir s (first (rest (first p)))) (first (last (first p)))) (sustituirComponer s (rest p))))
	)
)
