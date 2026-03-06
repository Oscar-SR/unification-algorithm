;;;; =====================================================
;;;; Unification algorithm tests using FiveAM
;;;; =====================================================

(ql:quickload :fiveam)

(defpackage :tests
  (:use :cl :fiveam)
  ;; Import functions and special symbols directly from the default package
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
  (is (equalp (unify 'f 'f) :EMPTY)))

(test different-atoms
  (is (equalp (unify 'a 'b) :FAIL))
  (is (equalp (unify 'A 'B) :FAIL)))

;;;; =====================================================
;;;; Variable with constant
;;;; =====================================================

(test variable-constant
  (is (equalp (unify '(? x) 'a) '(/ A (? X))))
  (is (equalp (unify '(? x) 'A) '(/ A (? X)))))

(test constant-variable
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
  (is (equalp (unify '(f (? X)) '(f A)) '(/ A (? X)))))

(test structure-multiple-variables
  (is (equalp (unify '(f (? X) (? Y)) '(f A B))
              '((/ A (? X)) (/ B (? Y))))))

(test structure-repeated-variables
  (is (equalp (unify '(f (? X) (g (? X))) '(f A (g A)))
              '(/ A (? X)))))

(test cross-reference-variables
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