"""
Given 2 vectors, `x` and `y`, this function returns the indices that
sort the elements by `x`, with `y` breaking ties. See the example below.

julia> a = [2, 1, 3, 2]
julia> b = [3, 4, 1, 0]
julia> order = sortperm2(a, b)
4-element Array{Int64,1}:
 2
 4
 1
 3

julia> hcat(a[order], b[order]
4×2 Array{Int64,2}:
 1  4
 2  0
 2  3
 3  1
"""

function sortperm2(x,y;rev=false,alg=RadixSort)

    n = length(x)

    # find the number of elements from the first 100 in x
    if n < 1000 && !(typeof(x) <: CategoricalArray)
        nlev = length(unique(x))
    else
        nlev = length(unique(x[1:1000]))
        if nlev < 100
             nlev = length(unique(x))
        end
    end

    # binary
    if nlev == 2
        return _sortperm2b(x,y;rev=rev,alg=alg)
    end

    # discrete < 1000 levels
    if nlev < 1000
        return _sortperm2c(x,y;rev=rev,alg=alg)
    end

    # all others
    return _sortperm2d(x,y;rev=rev) # Use QuickSort
end

# x is binary
function _sortperm2b(x,y;rev=false,alg=RadixSort)
    
    function fsortperm2(idx,y;rev=false,alg=RadixSort)
        return first.(sort(Pair.(idx,y), by=x->x.second, alg=alg, rev=rev))
    end

    n = length(x)

    # levels
    lev = sort(unique(x),rev=rev)

    # range
    idx = 1:n

    # allocate memory
    ord = Vector{Int}(undef,n)

    f = 1
    @inbounds @simd for val in lev
        @inbounds ba = x .== val
        len = count(ba)
        @inbounds ord[f:f+len-1] = fsortperm2(idx[ba],y[ba],rev=rev,alg=alg)
        f += len
    end

    return ord
end

# x is discrete with 3 - 999 levels
function _sortperm2c(x,y;rev=false,alg=RadixSort)
    # levels
    len = length(x)

    # from FreqTables.jl/src/freqtable.jl
    d = Dict{eltype(x),Int64}()
    @inbounds @simd for i = 1:len
        index = Base.ht_keyindex(d, x[i])

        if index > 0
            @inbounds d.vals[index] += 1
        else
            @inbounds d[x[i]] = 1
        end
    end

    # construct labels
    alev = sort(collect(keys(d)),rev=rev)

    cnt = Vector{Int64}(undef,length(alev))
    @inbounds @simd for i=1:length(alev)
        cnt[i] = d[alev[i]]
    end

    # permutation sort on x
    ord = sortperm(x,alg=alg,rev=rev)
    y_sorted = y[ord]

    f = 1
    for i = 1:length(cnt)
        l = f+cnt[i]-1
        ord[f:l] = ord[f:l][sortperm(y_sorted[f:l],rev=rev,alg=alg)]
        f = l + 1
    end

    return ord
end

# uint_mapping stolen from SortingAlgorithms.jl
uint_mapping(x::Float64)  = (y = reinterpret(Int64, x); reinterpret(UInt64, ifelse(y < 0, ~y, xor(y, typemin(Int64)))))

# other arrays - this is almost twice faster than the old version
function _sortperm2d(x,y;rev=false,alg=QuickSort)

    # combine index, x, and y using tuples
    # A is an array of tuples
    A = tuple.(1:length(x),uint_mapping.(x),uint_mapping.(y))

    # sort A by second and then third elements
    sort!(A,by=x->(x[2],x[3]),alg=alg,rev=rev)

    # return the first element in tuples
    return [x[1] for x in A]
end


# #----------------------------------------
# # performance tests
# using BenchmarkTools, Distributions
# aa = rand(Uniform(0,1),1000000)
#
# #----------------------------------------
# # Test sortperm2 under various conditions
# # binary integer
# bb = Int64.(aa .> .5)
# @btime sortperm2(bb,aa) # 78.780 ms
#
# # binary float
# bb = round.(rand(Uniform(0,1),1000000))
# @btime sortperm2(bb,aa) # 80.660 ms
#
# # discrete values 3 level integers
# bb = floor.(Int,rand(Uniform(1,4),1000000))
# @btime sortperm2(bb,aa) # 65.300 ms
#
# # discrete values 3 level floats
# bb = round.(rand(Uniform(1,3),1000000))
# @btime sortperm2(bb,aa) # 88.661
#
# # discrete values 5 level integers
# bb = floor.(Int,rand(Uniform(1,6),1000000))
# @btime sortperm2(bb,aa) # 62.945 ms
#
# # discrete values 5 level floats
# bb = round.(rand(Uniform(1,5),1000000))
# @btime sortperm2(bb,aa) # 77.366
#
# # discrete values 10 level integers
# bb = floor.(Int,rand(Uniform(1,11),1000000))
# @btime sortperm2(bb,aa) # 54.325 ms
#
# # discrete values 10 level floats
# bb = round.(rand(Uniform(1,10),1000000))
# @btime sortperm2(bb,aa) # 75.698
#
# # discrete values 100 level integers
# bb = floor.(Int,rand(Uniform(1,101),1000000))
# @btime sortperm2(bb,aa) # 49.393 ms
#
# # discrete values 100 level floats
# bb = round.(rand(Uniform(1,100),1000000))
# @btime sortperm2(bb,aa) # 79.595
#
# # discrete values 999 level integers
# bb = floor.(Int,rand(Uniform(1,1000),1000000))
# @btime sortperm2(bb,aa) # 69.586 ms
#
# # discrete values 999 level floats
# bb = round.(rand(Uniform(1,999),1000000))
# @btime sortperm2(bb,aa) # 96.585
#
# # discrete values 10000 level integers
# bb = floor.(Int,rand(Uniform(1,10001),1000000))
# @btime sortperm2(bb,aa) # 105.432
#
# # discrete values 10000 level floats
# bb = round.(rand(Uniform(1,10000),1000000))
# @btime sortperm2(bb,aa) # 161.063

# a = [1, 5, 1, 4, 3, 4, 4, 3, 1, 4, 5, 3, 5]
# b = [9, 4, 0, 4, 0, 2, 1, 2, 1, 3, 2, 1, 1]
#
# ord = sortperm2(a, b, rev = true)
# hcat(a[ord], b[ord])
#
# ord = sortperm2(a, b)
# hcat(a[ord], b[ord])
