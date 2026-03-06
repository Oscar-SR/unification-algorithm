;;;; =====================================================
;;;; Auxiliary functions
;;;; =====================================================

(defun is-variable (var)
  "Returns T if var is a variable of the form (? X)"
  (if (and (listp var) (eq (first var) '?))
      T))

(defun is-atom (var)
  "Returns T if var is an atom or a variable"
  (cond ((atom var) T)
        ((eq (first var) '?) T)
        (T NIL)))

(defun occurs (var lst)
  "Checks if the variable var occurs inside lst (Occurs Check)"
  (cond
    ((null lst) NIL)
    ((atom lst)
     (if (eq var lst) T NIL))
    ((listp (first lst)) (or (occurs var (first lst)) (occurs var (rest lst))))
    ((equalp var lst) T)
    (T (occurs var (rest lst)))))

(defun form-substitution (e1 e2)
  "Creates a substitution of e2 for e1"
  (if (equalp e1 e2)
      :EMPTY
      (list '/ e1 e2)))

(defun substitute-term (subst expr)
  "Auxiliary function to apply a single substitution"
  (cond
    ((null expr) '())
    ((atom expr) expr)
    ((and (listp (first expr)) (eq (first (first expr)) '?) (eq (first (rest (first (last subst)))) (first (rest (first expr)))))
     (cons (first (rest subst)) (substitute-term subst (rest expr))))
    ((listp (first expr))
     (cons (substitute-term subst (first expr)) (substitute-term subst (rest expr))))
    ((and (listp expr) (eq (first expr) '?) (eq (first (rest (first (last subst)))) (first (rest expr))))
     (first (rest subst)))
    (T (cons (first expr) (substitute-term subst (rest expr))))))

(defun apply-substitution (subst expr)
  "Applies the substitution subst to the expression expr"
  (cond ((equalp subst :EMPTY) expr)
        ((null expr) '())
        (T (substitute-term subst expr))))

(defun substitute-compose (subst expr)
  "Auxiliary function for compose-substitutions"
  (cond
    ((null expr) '())
    (T (cons (list '/ (substitute-term subst (first (rest (first expr)))) (first (last (first expr)))) 
             (substitute-compose subst (rest expr))))))

(defun compose-substitutions (s1 s2)
  "Composes two substitutions s1 and s2"
  (let (s1s2 not-appearing skip)
    (cond
      ((and (equalp s1 :EMPTY) (equalp s2 :EMPTY)) :EMPTY)
      ((equalp s1 :EMPTY) s2)
      ((equalp s2 :EMPTY) s1)
      (t 
       (if (equalp (first s1) '/)
           (setf s1 (list s1)))
       (if (equalp (first s2) '/)
           (setf s2 (list s2)))
       ; Step 1: apply substitute-compose to each element of s2 over s1
       (setf s1s2 s1)
       (dolist (s s2)
         (setf s1s2 (substitute-compose s s1s2)))
       ; Step 2: add elements of s2 that do not appear in s1s2
       (setf not-appearing '())
       (dolist (i s2)
         (setf skip NIL)
         (dolist (j s1s2)
           (when (or (occurs (first (last i)) (first (rest j))) (occurs (first (last i)) (first (last j))))
             (setf skip T)
             (return))) 
         (unless skip
           (setf not-appearing (append not-appearing (list i)))))
       (unless (null not-appearing)
         (setf s1s2 (append s1s2 not-appearing)))
       s1s2))))

;;;; =====================================================
;;;; Main function
;;;; =====================================================

(defun unify (e1 e2)
  "Main unification algorithm"
  (prog (f1 f2 t1 t2 g1 g2 z1 z2 temp)
    (when (or (is-atom e1) (is-atom e2))
      ; Swap parameter values if necessary so that e1 is the atom
      (unless (is-atom e1)
        (setf temp e1)
        (setf e1 e2)
        (setf e2 temp))
      (if (equalp e1 e2)
          (return-from unify :EMPTY))
      (if (is-variable e1)
          (if (occurs e1 e2)
              (return-from unify :FAIL)
              (return-from unify (form-substitution e2 e1))))
      (if (is-variable e2)
          (return-from unify (form-substitution e1 e2))
          (return-from unify :FAIL)))
    
    (setf f1 (first e1))
    (setf t1 (rest e1))
    (setf f2 (first e2))
    (setf t2 (rest e2))
    
    (setf z1 (unify f1 f2))
    (if (equalp z1 :FAIL)
        (return-from unify :FAIL))
        
    (setf g1 (apply-substitution z1 t1))
    (setf g2 (apply-substitution z1 t2)) 
    
    (setf z2 (unify g1 g2))
    (if (equalp z2 :FAIL)
        (return-from unify :FAIL))
        
    (return-from unify (compose-substitutions z1 z2))))