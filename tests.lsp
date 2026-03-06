;;;; =====================================================
;;;; Unification algorithm tests using FiveAM
;;;; =====================================================

(ql:quickload :fiveam)

(defpackage :tests
  (:use :cl :fiveam)
  ;; Importamos las funciones y símbolos especiales directamente del paquete por defecto
  (:import-from :cl-user #:unificar #:aplicarSustitucion #:? #:/)
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
  (is (equalp (unificar 'a 'a) :EMPTY))
  ;; Nuevo: (unificar 'f 'f)
  (is (equalp (unificar 'f 'f) :EMPTY)))

(test different-atoms
  (is (equalp (unificar 'a 'b) :FAIL))
  ;; Nuevo: (unificar 'A 'B)
  (is (equalp (unificar 'A 'B) :FAIL)))

;;;; =====================================================
;;;; Variable with constant
;;;; =====================================================

(test variable-constant
  (is (equalp (unificar '(? x) 'a) '(/ A (? X))))
  ;; Nuevo: (unificar '(? x) 'A)
  (is (equalp (unificar '(? x) 'A) '(/ A (? X)))))

(test constant-variable
  ;; Nuevo: (unificar 'A '(? x))
  (is (equalp (unificar 'A '(? x)) '(/ A (? X)))))

;;;; =====================================================
;;;; Variable with structure
;;;; =====================================================

(test variable-structure
  (is (equalp (unificar '(? x) '(f a))
              '(/ (F A) (? X)))))

;;;; =====================================================
;;;; Occurs check
;;;; =====================================================

(test occurs-check
  (is (equalp (unificar '(? x) '(f (? x))) :FAIL))
  ;; Nuevo: (unificar '(? x) '(g (? x)))
  (is (equalp (unificar '(? x) '(g (? x))) :FAIL)))

;;;; =====================================================
;;;; Simple structures
;;;; =====================================================

(test identical-structure
  (is (equalp (unificar '(f a) '(f a)) :EMPTY)))

(test different-function-symbol
  (is (equalp (unificar '(f a) '(g a)) :FAIL)))

;;;; =====================================================
;;;; Structure containing variable(s)
;;;; =====================================================

(test structure-with-variable
  (is (equalp (unificar '(f (? x)) '(f a)) '(/ A (? X))))
  ;; Nuevo: (unificar '(f (? X)) '(f A))
  (is (equalp (unificar '(f (? X)) '(f A)) '(/ A (? X)))))

(test structure-multiple-variables
  ;; Nuevo: (unificar '(f (? X) (? Y)) '(f A B))
  ;; Nota: Si tu algoritmo agrupa múltiples sustituciones en una lista de listas,
  ;; el resultado esperado debería ser algo como esto:
  (is (equalp (unificar '(f (? X) (? Y)) '(f A B))
              '((/ A (? X)) (/ B (? Y))))))

(test structure-repeated-variables
  ;; Nuevo: (unificar '(f (? X) (g (? X))) '(f A (g A)))
  ;; En este caso, con resolver X = A es suficiente para unificar todo.
  (is (equalp (unificar '(f (? X) (g (? X))) '(f A (g A)))
              '(/ A (? X)))))

(test cross-reference-variables
  ;; Nuevo: (unificar '(f (? Y) A) '(f (? X) (? X)))
  ;; X unifica con A, y por lo tanto Y debe unificar con A también.
  (is (equalp (unificar '(f (? Y) A) '(f (? X) (? X)))
              '((/ A (? Y)) (/ A (? X))))))

;;;; =====================================================
;;;; Two variables
;;;; =====================================================

(test variable-variable
  (is (not (equalp (unificar '(? x) '(? y))
                   :FAIL))))

;;;; =====================================================
;;;; Run test suite
;;;; =====================================================

(defun run-tests ()
  (run! 'unification-suite))