module Experimental
using ExtendableSparse, SparseArrays
import ExtendableSparse: flush!, reset!, rawupdateindex!
using ExtendableSparse: ColEntry, AbstractPreconditioner, @makefrommatrix, phash
using DocStringExtensions
using Metis
using Base.Threads
using LinearAlgebra

include(joinpath(@__DIR__, "..", "matrix", "ExtendableSparseMatrixParallel", "ExtendableSparseParallel.jl"))

include(joinpath(@__DIR__, "..", "factorizations","ilu_Al-Kurdi_Mittal.jl"))
#using .ILUAM
include(joinpath(@__DIR__, "..", "factorizations","pilu_Al-Kurdi_Mittal.jl"))
#using .PILUAM

include(joinpath(@__DIR__, "..", "factorizations","iluam.jl"))
include(joinpath(@__DIR__, "..", "factorizations","piluam.jl"))

@eval begin
    @makefrommatrix ILUAMPreconditioner
    @makefrommatrix PILUAMPreconditioner
end

function factorize!(p::PILUAMPreconditioner, A::ExtendableSparseMatrixParallel)
    p.A = A
    update!(p)
    p
end
                
export ExtendableSparseMatrixParallel, SuperSparseMatrixLNK
export addtoentry!, reset!, dummy_assembly!, preparatory_multi_ps_less_reverse, fr, addtoentry!,  compare_matrices_light
export     ILUAMPreconditioner,    PILUAMPreconditioner
export     reorderlinsys, nnz_noflush


include("parallel_testtools.jl")
export part2d, showgrid, partassemble!

end

