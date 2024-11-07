module ExtendableSparse

using DocStringExtensions: DocStringExtensions, SIGNATURES, TYPEDEF,TYPEDFIELDS
using ILUZero: ILUZero, ldiv!, nnz
using LinearAlgebra: LinearAlgebra, Diagonal, Hermitian, Symmetric, Tridiagonal,
    cholesky, cholesky!, convert, lu!, mul!, norm, transpose, I
using SparseArrays: SparseArrays, AbstractSparseMatrix, SparseMatrixCSC,
    dropzeros!, findnz, nzrange, sparse, spzeros
using Sparspak: Sparspak, sparspaklu, sparspaklu!
using StaticArrays: StaticArrays, SMatrix, SVector
using SuiteSparse: SuiteSparse
import SparseArrays: AbstractSparseMatrixCSC, rowvals, getcolptr, nonzeros


# Define our own constant here in order to be able to
# test things at least a little bit..
const USE_GPL_LIBS = Base.USE_GPL_LIBS

if USE_GPL_LIBS
    using SuiteSparse
end



include("matrix/sparsematrixcsc.jl")
include("matrix/abstractsparsematrixextension.jl")
include("matrix/sparsematrixlnk.jl")
include("matrix/sparsematrixdilnkc.jl")
include("matrix/abstractextendablesparsematrixcsc.jl")
include("matrix/extendable.jl")
include("matrix/genericmtextendablesparsematrixcsc.jl")
include("matrix/genericextendablesparsematrixcsc.jl")

const ExtendableSparseMatrix=ExtendableSparseMatrixCSC
const MTExtendableSparseMatrixCSC{Tv,Ti}=GenericMTExtendableSparseMatrixCSC{SparseMatrixDILNKC{Tv,Ti},Tv,Ti}
MTExtendableSparseMatrixCSC(m,n,args...)=MTExtendableSparseMatrixCSC{Float64,Int64}(m,n,args...)

const STExtendableSparseMatrixCSC{Tv,Ti}=GenericExtendableSparseMatrixCSC{SparseMatrixDILNKC{Tv,Ti},Tv,Ti}
STExtendableSparseMatrixCSC(m,n,args...)=STExtendableSparseMatrixCSC{Float64,Int64}(m,n,args...)


export ExtendableSparseMatrixCSC, MTExtendableSparseMatrixCSC, STExtendableSparseMatrixCSC, GenericMTExtendableSparseMatrixCSC
export SparseMatrixLNK, ExtendableSparseMatrix,flush!, nnz, updateindex!, rawupdateindex!, colptrs, sparse, reset!, nnznew
export partitioning!

export eliminate_dirichlet, eliminate_dirichlet!, mark_dirichlet

include("factorizations/factorizations.jl")

#include("experimental/Experimental.jl")

include("factorizations/simple_iteration.jl")
export simple, simple!

include("precs.jl")
export SparspakPrecs, UMFPACKPrecs, EquationBlockPrecs

include("matrix/sprand.jl")
export sprand!, sprand_sdd!, fdrand, fdrand!, fdrand_coo, solverbenchmark

export rawupdateindex!, updateindex!




export JacobiPreconditioner,
    ILU0Preconditioner,
    ILUZeroPreconditioner,
    PointBlockILUZeroPreconditioner,
    ParallelJacobiPreconditioner,
    ParallelILU0Preconditioner,
    BlockPreconditioner,allow_views

export AbstractFactorization, LUFactorization, CholeskyFactorization, SparspakLU
export issolver
export factorize!, update!

"""
```
ILUTPreconditioner(;droptol=1.0e-3)
ILUTPreconditioner(matrix; droptol=1.0e-3)
```

Create the [`ILUTPreconditioner`](@ref) wrapping the one 
from [IncompleteLU.jl](https://github.com/haampie/IncompleteLU.jl)
For using this, you need to issue `using IncompleteLU`.
"""
function ILUTPreconditioner end
export ILUTPreconditioner

"""
```
AMGPreconditioner(;max_levels=10, max_coarse=10)
AMGPreconditioner(matrix;max_levels=10, max_coarse=10)
```

Create the  [`AMGPreconditioner`](@ref) wrapping the Ruge-Stüben AMG preconditioner from [AlgebraicMultigrid.jl](https://github.com/JuliaLinearAlgebra/AlgebraicMultigrid.jl)

!!! warning
     Deprecated in favor of [`RS_AMGPreconditioner`](@ref)

"""
function AMGPreconditioner end 
export AMGPreconditioner

@deprecate AMGPreconditioner() RS_AMGPreconditioner()
@deprecate AMGPreconditioner(A) RS_AMGPreconditioner(A)

"""
```
RS_AMGPreconditioner(;kwargs...)
RS_AMGPreconditioner(matrix;kwargs...)
```

Create the  [`RS_AMGPreconditioner`](@ref) wrapping the Ruge-Stüben AMG preconditioner from [AlgebraicMultigrid.jl](https://github.com/JuliaLinearAlgebra/AlgebraicMultigrid.jl)
For `kwargs` see there.
"""
function RS_AMGPreconditioner end 
export RS_AMGPreconditioner


"""
```
SA_AMGPreconditioner(;kwargs...)
SA_AMGPreconditioner(matrix;kwargs...)
```

Create the  [`SA_AMGPreconditioner`](@ref) wrapping the smoothed aggregation AMG preconditioner from [AlgebraicMultigrid.jl](https://github.com/JuliaLinearAlgebra/AlgebraicMultigrid.jl)
For `kwargs` see there.
"""
function SA_AMGPreconditioner end 
export SA_AMGPreconditioner




"""
```
AMGCL_AMGPreconditioner(;kwargs...)
AMGCL_AMGPreconditioner(matrix;kwargs...)
```

Create the  [`AMGCL_AMGPreconditioner`](@ref) wrapping AMG preconditioner from [AMGCLWrap.jl](https://github.com/j-fu/AMGCLWrap.jl)
For `kwargs` see there.
"""
function AMGCL_AMGPreconditioner end
export AMGCL_AMGPreconditioner


"""
```
AMGCL_RLXPreconditioner(;kwargs...)
AMGCL_RLXPreconditioner(matrix;kwargs...)
```

Create the  [`AMGCL_RLXPreconditioner`](@ref) wrapping RLX preconditioner from [AMGCLWrap.jl](https://github.com/j-fu/AMGCLWrap.jl)
"""
function AMGCL_RLXPreconditioner end
export AMGCL_RLXPreconditioner




"""
```
PardisoLU(;iparm::Vector, 
           dparm::Vector, 
           mtype::Int)

PardisoLU(matrix; iparm,dparm,mtype)
```

LU factorization based on pardiso. For using this, you need to issue `using Pardiso`
and have the pardiso library from  [pardiso-project.org](https://pardiso-project.org) 
[installed](https://github.com/JuliaSparse/Pardiso.jl#pardiso-60).

The optional keyword arguments `mtype`, `iparm`  and `dparm` are 
[Pardiso internal parameters](https://github.com/JuliaSparse/Pardiso.jl#readme).

Forsetting them, one can also access the `PardisoSolver` e.g. like
```
using Pardiso
plu=PardisoLU()
Pardiso.set_iparm!(plu.ps,5,13.0)
```
"""
function PardisoLU end
export PardisoLU


"""
```
MKLPardisoLU(;iparm::Vector, mtype::Int)

MKLPardisoLU(matrix; iparm, mtype)
```

LU factorization based on pardiso. For using this, you need to issue `using Pardiso`.
This version  uses the early 2000's fork in Intel's MKL library.

The optional keyword arguments `mtype` and `iparm`  are  
[Pardiso internal parameters](https://github.com/JuliaSparse/Pardiso.jl#readme).

For setting them you can also access the `PardisoSolver` e.g. like
```
using Pardiso
plu=MKLPardisoLU()
Pardiso.set_iparm!(plu.ps,5,13.0)
```
"""
function MKLPardisoLU end
export MKLPardisoLU

end # module
