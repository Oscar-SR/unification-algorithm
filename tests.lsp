;;;; =====================================================
;;;; Unification algorithm tests using FiveAM
;;;; =====================================================

(ql:quickload :fiveam)

(defpackage :tests
  (:use :cl :fiveam)
  ;; Importamos las funciones y símbolos especiales directamente del paquete por defecto
  (:import-from :cl-user #:unify #:? #:/)
  (:export :run-tests))

(in-package :tests)

;;;; =====================================================
;;;; Main test suite
;;;; =====================================================

(def-suite unification-suite
  :description "Tests for the unification algorithm")

(in-suite unification-suite)

;;;; =====================================================
;;;; Basic atom tests
;;;; =====================================================

(test equal-atoms
  (is (equalp (unify 'a 'a) :EMPTY))
  ;; Nuevo: (unify 'f 'f)
  (is (equalp (unify 'f 'f) :EMPTY)))

(test different-atoms
  (is (equalp (unify 'a 'b) :FAIL))
  ;; Nuevo: (unify 'A 'B)
  (is (equalp (unify 'A 'B) :FAIL)))

;;;; =====================================================
;;;; Variable with constant
;;;; =====================================================

(test variable-constant
  (is (equalp (unify '(? x) 'a) '(/ A (? X))))
  ;; Nuevo: (unify '(? x) 'A)
  (is (equalp (unify '(? x) 'A) '(/ A (? X)))))

(test constant-variable
  ;; Nuevo: (unify 'A '(? x))
  (is (equalp (unify 'A '(? x)) '(/ A (? X)))))

;;;; =====================================================
;;;; Variable with structure
;;;; =====================================================

(test variable-structure
  (is (equalp (unify '(? x) '(f a))
              '(/ (F A) (? X)))))

;;;; =====================================================
;;;; Occurs check
;;;; =====================================================

(test occurs-check
  (is (equalp (unify '(? x) '(f (? x))) :FAIL))
  ;; Nuevo: (unify '(? x) '(g (? x)))
  (is (equalp (unify '(? x) '(g (? x))) :FAIL)))

;;;; =====================================================
;;;; Simple structures
;;;; =====================================================

(test identical-structure
  (is (equalp (unify '(f a) '(f a)) :EMPTY)))

(test different-function-symbol
  (is (equalp (unify '(f a) '(g a)) :FAIL)))

;;;; =====================================================
;;;; Structure containing variable(s)
;;;; =====================================================

(test structure-with-variable
  (is (equalp (unify '(f (? x)) '(f a)) '(/ A (? X))))
  ;; Nuevo: (unify '(f (? X)) '(f A))
  (is (equalp (unify '(f (? X)) '(f A)) '(/ A (? X)))))

(test structure-multiple-variables
  ;; Nuevo: (unify '(f (? X) (? Y)) '(f A B))
  ;; Nota: Si tu algoritmo agrupa múltiples sustituciones en una lista de listas,
  ;; el resultado esperado debería ser algo como esto:
  (is (equalp (unify '(f (? X) (? Y)) '(f A B))
              '((/ A (? X)) (/ B (? Y))))))

(test structure-repeated-variables
  ;; Nuevo: (unify '(f (? X) (g (? X))) '(f A (g A)))
  ;; En este caso, con resolver X = A es suficiente para unificar todo.
  (is (equalp (unify '(f (? X) (g (? X))) '(f A (g A)))
              '(/ A (? X)))))

(test cross-reference-variables
  ;; Nuevo: (unify '(f (? Y) A) '(f (? X) (? X)))
  ;; X unifica con A, y por lo tanto Y debe unificar con A también.
  (is (equalp (unify '(f (? Y) A) '(f (? X) (? X)))
              '((/ A (? Y)) (/ A (? X))))))

;;;; =====================================================
;;;; Two variables
;;;; =====================================================

(test variable-variable
  (is (not (equalp (unify '(? x) '(? y))
                   :FAIL))))

;;;; =====================================================
;;;; Run test suite
;;;; =====================================================

(defun run-tests ()
  (run! 'unification-suite))