# Unification algorithm

This project implements the **unification algorithm** written in **Common Lisp (CLISP)**. The algorithm compares two symbolic expressions and determines whether they can be unified, that is, whether there exists a set of variable substitutions that makes the two expressions identical. If unification is possible, the algorithm returns the substitution set; otherwise, it returns a failure.

---

## 📖 Overview

The unification process is a fundamental operation in **artificial intelligence**, **logic programming**, and **automated theorem proving**. The unification algorithm serves as the computational engine for logic programming (such as Prolog), where it resolves queries by matching patterns and binding variables to values. It is equally vital in automated theorem proving and modern software engineering, particularly for type inference in functional languages like Haskell. By identifying the most general substitution that makes two symbolic expressions identical, it enables machines to perform automated reasoning and ensure logical consistency across complex data structures.

This implementation follows a recursive approach that:
1. Checks whether two atoms (variables or constants) can be unified.
2. Generates substitutions when variables are present.
3. Recursively unifies complex list structures.
4. Composes partial substitutions into a single consistent result.

Pseudocode:

```
UNIFY(E1, E2)
IF either of them is an atom, swap them if necessary so that E1 is an atom and then DO
BEGIN
    IF E1 = E2 return NIL
    IF E1 is a variable DO
    BEGIN
        IF E1 occurs in E2 return FAILURE
        return E2/E1
    END
    IF E2 is a variable return E1/E2
    return FAILURE
END
F1 <- FIRST(E1); T1 <- REST(E1)
F2 <- FIRST(E2); T2 <- REST(E2)
Z1 <- UNIFY(F1, F2)
IF Z1 = FAILURE return FAILURE
G1 <- Apply Z1 to T1
G2 <- Apply Z1 to T2
Z2 <- UNIFY(G1, G2)
IF Z2 = FAILURE return FAILURE
return the composition of Z1 and Z2
```

---

## ⚙️ Functions

| Function | Purpose |
|----------|---------|
| **`unify`** | Main entry point. Takes two expressions (`e1` and `e2`) and tries to unify them. Returns the substitution list or `:FAIL` if unification is impossible. |
| **`is-atom`** | Checks if an expression is an atom (variable or constant). |
| **`is-variable`** | Determines whether an expression is a variable (variables start with `?`). |
| **`occurs`** | Checks if a variable appears inside another expression (occurs-check) to avoid circular substitutions. |
| **`form-substitution`** | Creates a substitution in the form `(/ value variable)`. |
| **`apply-substitution`** | Applies a substitution to an expression recursively. |
| **`substitute-term`** | Replaces variables in an expression according to a substitution. |
| **`compose-substitutions`** | Merges two substitution lists into one coherent substitution. |
| **`substitute-compose`** | Helper function for ordered substitution composition. |

---

## 🧩 Syntax and notation

The algorithm uses a **LISP-like symbolic representation** for terms, variables, and functions.

### 1. **Sets of Terms**

Sets are represented as LISP lists:
```lisp
(A B CD)        ; Represents the set {A, B, CD}
```

### 2. **Variables**

Variables are prefixed with `?`:
```lisp
(A (? x) (? y)) ; A is a constant, (? x) and (? y) are variables x and y
```

### 3. **Functions**

Functions are represented as nested lists:
```lisp
((f (? x)))          ; f(x)
((f (g (? y))))      ; f(g(y))
```

### 4. **Substitutions**

A substitution is expressed as:
```lisp
(/ A (? x))          ; Replace variable x with constant A
```

## 🚀 How to run

This project is designed to run in a **CLISP** environment.

### 1. Install CLISP

**Linux/Mac:**  
```bash
sudo apt install clisp   # Debian/Ubuntu
brew install clisp       # macOS (Homebrew)
```
**Windows:**
Download and install from [http://clisp.sourceforge.net](http://clisp.sourceforge.net)

### 2. Load the program

Open a terminal and start CLISP:
```bash
clisp
```

Then load the source file:
```lisp
(load "unification.lsp")
```

### 3. Run the algorithm

Call the main function:
```lisp
(unify '((f (? x))) '((f A)))
```

If unification is not possible, the output will be this one:
```lisp
:FAIL
```

## 🧪 Tests
To ensure the reliability of the unification process, a comprehensive test suite has been implemented using FiveAM, a popular testing framework for Common Lisp.

To execute the tests, follow these steps:

1. Ensure you have Quicklisp installed, as it is used to load the FiveAM library. If you don't have it, follow the instructions at [quicklisp.org](https://www.quicklisp.org/).

2. Start your CLISP environment and run the following commands:

```lisp
;; 1. Load the main program
(load "unification.lsp")

;; 2. Load the test file
(load "tests.lsp")

;; 3. Run the test suite
(tests:run-tests)
```
