;;;; =====================================================
;;;; Paquete y exportaciones
;;;; =====================================================

(defpackage :unification
  (:use :cl)
  (:export #:unificar #:aplicarSustitucion))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (import 'unification::? :tests))

(in-package :unification)

;;;; =====================================================
;;;; Funciones auxiliares
;;;; =====================================================

(defun esVariable (var)
  "Devuelve T si var es una variable de la forma (? X)"
  (and (listp var) (eq (first var) '?)))

(defun esAtomo (var)
  "Devuelve T si var es un átomo o una variable"
  (or (atom var)
      (esVariable var)))

(defun aparece (var lista)
  "Comprueba si la variable var aparece en lista"
  (cond
    ((null lista) nil)
    ((atom lista) (eq var lista))
    ((listp (first lista)) (or (aparece var (first lista)) (aparece var (rest lista))))
    ((equalp var lista) t)
    (t (aparece var (rest lista)))))

(defun formarSustitucion (e1 e2)
  "Crea una sustitución de e2 por e1"
  (if (equalp e1 e2)
      :NADA
      (list '/ e1 e2)))

(defun aplicarSustitucion (s p)
  "Aplica la sustitución s a la expresión p"
  (cond
    ((equalp s :NADA) p)
    ((null p) '())
    (t (sustituir s p))))

(defun sustituir (s p)
  "Función auxiliar para aplicarSustitucion"
  (cond
    ((null p) '())
    ((atom p) p)
    ;; Si p coincide con la variable de s
    ((and (listp (first s))
          (esVariable (first (rest (first s))))
          (equalp (first (rest (first s))) (first (rest p))))
     (cons (first (rest s)) (sustituir s (rest p))))
    ;; Si el primer elemento es una lista
    ((listp (first p))
     (cons (sustituir s (first p)) (sustituir s (rest p))))
    ;; Si p es una variable coincidente
    ((and (listp p) (esVariable p)
          (equalp (first (rest (first s))) (first (rest p))))
     (first (rest s)))
    (t (cons (first p) (sustituir s (rest p))))))

(defun sustituirComponer (s p)
  "Auxiliar de componer"
  (cond
    ((null p) '())
    (t (cons (list '/ (sustituir s (first (rest (first p)))) (first (last (first p))))
             (sustituirComponer s (rest p))))))

(defun componer (s1 s2)
  "Compone dos sustituciones s1 y s2"
  (let ((s1s2 nil)
        (noAparecen nil)
        (saltar nil))
    (cond
      ((and (equalp s1 :NADA) (equalp s2 :NADA)) :NADA)
      ((equalp s1 :NADA) s2)
      ((equalp s2 :NADA) s1)
      (t
       (when (equalp (first s1) '/) (setf s1 (list s1)))
       (when (equalp (first s2) '/) (setf s2 (list s2)))
       ;; Paso 1: aplicar sustituirComponer a cada elemento de s2 sobre s1
       (setf s1s2 s1)
       (dolist (s s2)
         (setf s1s2 (sustituirComponer s s1s2)))
       ;; Paso 2: agregar elementos de s2 que no aparezcan en s1s2
       (dolist (i s2)
         (setf saltar nil)
         (dolist (j s1s2)
           (when (or (aparece (first (last i)) (first (rest j)))
                     (aparece (first (last i)) (first (last j))))
             (setf saltar t)
             (return)))
         (unless saltar
           (setf noAparecen (append noAparecen (list i)))))
       (unless (null noAparecen)
         (setf s1s2 (append s1s2 noAparecen)))
       s1s2))))

;;;; =====================================================
;;;; Función principal: unificar
;;;; =====================================================

(defun unificar (e1 e2)
  "Algoritmo de unificación"
  (let* ((f1 nil) (f2 nil) (t1 nil) (t2 nil)
         (g1 nil) (g2 nil) (z1 nil) (z2 nil) (temp nil))
    (cond
      ;; Caso base: al menos un átomo
      ((or (esAtomo e1) (esAtomo e2))
       ;; Asegurar que e1 sea átomo si es necesario
       (unless (esAtomo e1)
         (setf temp e1)
         (setf e1 e2)
         (setf e2 temp))
       (cond
         ((equalp e1 e2) :NADA)
         ((esVariable e1)
          (if (aparece e1 e2)
              :FALLO
              (formarSustitucion e2 e1)))
         ((esVariable e2)
          (formarSustitucion e1 e2))
         (t :FALLO)))
      ;; Caso estructura
      (t
       (setf f1 (first e1))
       (setf t1 (rest e1))
       (setf f2 (first e2))
       (setf t2 (rest e2))
       (setf z1 (unificar f1 f2))
       (if (equalp z1 :FALLO)
           :FALLO
           (progn
             (setf g1 (aplicarSustitucion z1 t1))
             (setf g2 (aplicarSustitucion z1 t2))
             (setf z2 (unificar g1 g2))
             (if (equalp z2 :FALLO)
                 :FALLO
                 (componer z1 z2))))))))