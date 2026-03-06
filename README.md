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

---

## ⚙️ Functions

| Function | Purpose |
|----------|---------|
| **`unificar`** | Main entry point. Takes two expressions (`e1` and `e2`) and tries to unify them. Returns the substitution list or `:FAIL` if unification is impossible. |
| **`esAtomo`** | Checks if an expression is an atom (variable or constant). |
| **`esVariable`** | Determines whether an expression is a variable (variables start with `?`). |
| **`aparece`** | Detects if a variable appears inside another expression (occurs-check) to avoid circular substitutions. |
| **`formarSustitucion`** | Creates a substitution in the form `(/ value variable)`. |
| **`aplicarSustitucion`** | Applies a substitution to an expression recursively. |
| **`sustituir`** | Replaces variables in an expression according to a substitution. |
| **`componer`** | Merges two substitution lists into one coherent substitution. |
| **`sustituirComponer`** | Helper function for ordered substitution composition. |

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
(unificar '((f (? x))) '((f A)))
```

If unification is not possible, the output will be this one:
```lisp
:FAIL
```
