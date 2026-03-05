;;;; =====================================================
;;;; Unification algorithm tests using FiveAM
;;;; =====================================================

(ql:quickload :fiveam)

(defpackage :tests
  (:use :cl :fiveam :unification)
  (:export :run-tests))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (import 'unification::? :tests))

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
  (is (equalp (unificar 'a 'a) :NADA)))

(test different-atoms
  (is (equalp (unificar 'a 'b) :FALLO)))

;;;; =====================================================
;;;; Variable with constant
;;;; =====================================================

(test variable-constant
  (is (equalp (unificar '(? x) 'a)
              '(/ A (? X)))))

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
  (is (equalp (unificar '(? x) '(f (? x)))
              :FALLO)))

;;;; =====================================================
;;;; Simple structures
;;;; =====================================================

(test identical-structure
  (is (equalp (unificar '(f a) '(f a))
              :NADA)))

(test different-function-symbol
  (is (equalp (unificar '(f a) '(g a))
              :FALLO)))

;;;; =====================================================
;;;; Structure containing variable
;;;; =====================================================

(test structure-with-variable
  (is (equalp (unificar '(f (? x)) '(f a))
              '(/ A (? X)))))

;;;; =====================================================
;;;; Two variables
;;;; =====================================================

(test variable-variable
  (is (not (equalp (unificar '(? x) '(? y))
                   :FALLO))))

;;;; =====================================================
;;;; Multiple substitutions
;;;; =====================================================

(test multiple-substitutions
  (is (equalp
       (unificar '(f (? x) (? y))
                 '(f a b))
       '((/ A (? X)) (/ B (? Y))))))

;;;; =====================================================
;;;; Functional test: apply substitution
;;;; =====================================================

(test apply-substitution-correctly
  (let* ((substitution (unificar '(f (? x)) '(f a)))
         (result (aplicarSustitucion substitution '(f (? x)))))
    (is (equalp result '(f a)))))

;;;; =====================================================
;;;; Run test suite
;;;; =====================================================

(defun run-tests ()
  (run! 'unification-suite))