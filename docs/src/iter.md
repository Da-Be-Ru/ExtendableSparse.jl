# Factorizations & Preconditioners

This functionality is deprecated as of version 1.6 an will be removed
with  version 2.0. Use the  [integration with LinearSolve.jl](/linearsolve/#Integration-with-LinearSolve.jl)


## Factorizations

In this package, preconditioners and LU factorizations are both seen
as complete or approximate _factorizations_. Correspondingly we provide a common  API for them.


ExtendableSparse.AbstractLUFactorization
```@autodocs
Modules = [ExtendableSparse]
Pages = ["factorizations.jl"]
Order = [:function, :type]
Private = false
```

## LU Factorizations

Handling of the LU factorizations is meant to support
a workflow where sequences of problems are solved based
on the same matrix, where one possibly wants to re-use
existing symbolic factorization data.

The support comes in two flavors.

  - Using [`factorize!`](@ref) which can work as a drop-in replacement for `lu!`:

```@example
using ExtendableSparse, LinearAlgebra
A = fdrand(20, 20, 1; matrixtype = ExtendableSparseMatrix)
n = size(A, 1)
b = rand(n)
factorization = SparspakLU()
factorize!(factorization, A)
nm1 = norm(factorization \ b)

# mock update from Newton etc.
for i = 4:(n - 3)
    A[i, i + 3] -= 1.0e-4
end
factorize!(factorization, A)
nm2 = norm(factorization \ b)
nm1, nm2
```

  - Using [`update!`](@ref), where the matrix only needs to be given at construction time:

```@example
using ExtendableSparse, LinearAlgebra
A = fdrand(20, 20, 1; matrixtype = ExtendableSparseMatrix)
n = size(A, 1)
b = rand(n)
factorization = CholeskyFactorization(A)
nm1 = norm(factorization \ b)

# mock update from Newton etc.
for i = 4:(n - 3)
    A[i, i + 3] -= 1.0e-4
    A[i - 3, i] -= 1.0e-4
end
update!(factorization)
nm2 = norm(factorization \ b)
nm1, nm2
```

```@autodocs
Modules = [ExtendableSparse]
Pages = ["umfpack_lu.jl",  "sparspak.jl"]
```

```@docs
ExtendableSparse.AbstractLUFactorization
ExtendableSparse.CholeskyFactorization
Base.:\
```

## Preconditioners

The API is similar to that for LU factorizations.

The support comes in two flavors.

  - Using [`factorize!`](@ref):

```@example
using ExtendableSparse, LinearAlgebra
using IterativeSolvers, IncompleteLU
A = fdrand(20, 20, 1; matrixtype = ExtendableSparseMatrix)
n = size(A, 1)
b = rand(n)
preconditioner = ILUTPreconditioner(; droptol = 1.0e-2)
factorize!(preconditioner, A)

# mock update from Newton etc.
nm1 = norm(bicgstabl(A, b, 1; Pl = preconditioner))
for i = 4:(n - 3)
    A[i, i + 3] -= 1.0e-4
end
factorize!(preconditioner, A)
nm2 = norm(bicgstabl(A, b, 1; Pl = preconditioner))
nm1, nm2
```

  - Using [`update!`](@ref):

```@example
using ExtendableSparse, LinearAlgebra
using IterativeSolvers
A = fdrand(20, 20, 1; matrixtype = ExtendableSparseMatrix)
n = size(A, 1)
b = rand(n)
preconditioner = ILU0Preconditioner(A)
nm1 = norm(cg(A, b; Pl = preconditioner))

# mock update from Newton etc.
for i = 4:(n - 3)
    A[i, i + 3] -= 1.0e-4
    A[i - 3, i] -= 1.0e-4
end
update!(preconditioner)
nm2 = norm(cg(A, b; Pl = preconditioner))
nm1, nm2
```

```@docs
ExtendableSparse.AbstractPreconditioner
```

```@autodocs
Modules = [ExtendableSparse]
Pages = ["iluzero.jl","ilut.jl","amg.jl","blockpreconditioner.jl"]
```

```@docs
ExtendableSparse.AMGCL_AMGPreconditioner
ExtendableSparse.AMGCL_RLXPreconditioner
ExtendableSparse.SA_AMGPreconditioner
ExtendableSparse.RS_AMGPreconditioner
ILUTPreconditioner
```


## Experimental/deprecated


```@docs
PardisoLU
MKLPardisoLU
ExtendableSparse.AMGPreconditioner
```


```@autodocs
Modules = [ExtendableSparse]
Pages = ["jacobi.jl","parallel_jacobi.jl","ilu0.jl",]
```

## Iteration schemes
```@docs
ExtendableSparse.simple!
```
