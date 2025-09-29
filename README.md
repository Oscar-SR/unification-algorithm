# Unification Algorithm

This project implements a **Unification Algorithm** written in **Common Lisp (CLISP)**.  
The algorithm compares two symbolic expressions and determines whether they can be unified—that is, whether there exists a set of variable substitutions that makes the two expressions identical.  
If unification is possible, the algorithm returns the substitution set; otherwise, it returns a failure.

---

## 📖 Overview

The unification process is a fundamental operation in **Artificial Intelligence**, **Logic Programming**, and **Automated Theorem Proving**.  
This implementation follows a recursive approach that:
1. Checks whether two atoms (variables or constants) can be unified.
2. Generates substitutions when variables are present.
3. Recursively unifies complex list structures.
4. Composes partial substitutions into a single consistent result.

---

## ⚙️ Main Functions

| Function | Purpose |
|----------|---------|
| **`unificar`** | Main entry point. Takes two expressions (`e1` and `e2`) and tries to unify them. Returns the substitution list or `FAIL` if unification is impossible. |
| **`esAtomo`** | Checks if an expression is an atom (variable or constant). |
| **`esVariable`** | Determines whether an expression is a variable (variables start with `?`). |
| **`aparece`** | Detects if a variable appears inside another expression (occurs-check) to avoid circular substitutions. |
| **`formarSustitucion`** | Creates a substitution in the form `(/ value variable)`. |
| **`aplicarSustitucion`** | Applies a substitution to an expression recursively. |
| **`sustituir`** | Replaces variables in an expression according to a substitution. |
| **`componer`** | Merges two substitution lists into one coherent substitution. |
| **`sustituirComponer`** | Helper function for ordered substitution composition. |

---

## 🧩 Syntax and Notation

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

## 🚀 How to Run

This project is designed to run in a **CLISP** environment.

### 1. Install CLISP

**Linux/Mac**  
```bash
sudo apt install clisp   # Debian/Ubuntu
brew install clisp       # macOS (Homebrew)
```
**Windows**
Download and install from [http://clisp.sourceforge.net](http://clisp.sourceforge.net)

### 2. Load the Program

Open a terminal and start CLISP:
```bash
clisp
```

Then load the source file:
```lisp
(load "unification.lisp")
```

### 3. Run the Algorithm
Call the main function:
```lisp
(unificar '((f (? x))) '((f A)))
```
If unification is not possible, the output will be this one:
```lisp
FALLO
```

There are some test inputs in the file `test`.
