;;;; =====================================================
;;;; Unification algorithm tests using FiveAM
;;;; =====================================================

(ql:quickload :fiveam)

(defpackage :tests
  (:use :cl :fiveam))

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
  (is (equalp (unificar 'a 'a) 'NADA)))

(test different-atoms
  (is (equalp (unificar 'a 'b) 'FALLO)))

;;;; =====================================================
;;;; Variable with constant
;;;; =====================================================

(test variable-constant
  (is (equalp (unificar '(? x) 'a)
              '(/ a (? x)))))

;;;; =====================================================
;;;; Variable with structure
;;;; =====================================================

(test variable-structure
  (is (equalp (unificar '(? x) '(f a))
              '(/ (f a) (? x)))))

;;;; =====================================================
;;;; Occurs check
;;;; =====================================================

(test occurs-check
  (is (equalp (unificar '(? x) '(f (? x)))
              'FALLO)))

;;;; =====================================================
;;;; Simple structures
;;;; =====================================================

(test identical-structure
  (is (equalp (unificar '(f a) '(f a))
              'NADA)))

(test different-function-symbol
  (is (equalp (unificar '(f a) '(g a))
              'FALLO)))

;;;; =====================================================
;;;; Structure containing variable
;;;; =====================================================

(test structure-with-variable
  (is (equalp (unificar '(f (? x)) '(f a))
              '(/ a (? x)))))

;;;; =====================================================
;;;; Two variables
;;;; =====================================================

(test variable-variable
  (is (not (equalp (unificar '(? x) '(? y))
                   'FALLO))))

;;;; =====================================================
;;;; Multiple substitutions
;;;; =====================================================

(test multiple-substitutions
  (is (equalp
       (unificar '(f (? x) (? y))
                 '(f a b))
       '((/ a (? x)) (/ b (? y))))))

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