
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
# function sortperm2(x, y; rev = false)
#     n = length(x)
#     no_ties = n == length(Set(x))
#     if no_ties
#         res = sortperm(x, rev = rev)
#     else
#         ord1 = sortperm(x, rev = rev)
#         x_sorted = x[ord1]
#         i = 1
#         while i < n

#             # println("x_i is $(x_sorted[i]) and x_(i+1) is $(x_sorted[i+1])")
#             if x_sorted[i] == x_sorted[i+1]
#                 if rev && y[ord1][i] < y[ord1][i+1]
#                     #println("(1.) Switching $(y[ord1][i]) with $(y[ord1][i+1])")
#                     ord1[i], ord1[i+1] = ord1[i+1], ord1[i]
#                     i = i > 1 ? i - 1 : i
#                     continue
#                 elseif !rev && y[ord1][i] > y[ord1][i+1]
#                     #println("(2.) Switching $(y[ord1][i]) with $(y[ord1][i+1])")
#                     ord1[i], ord1[i+1] = ord1[i+1], ord1[i]
#                     i = i > 1 ? i - 1 : i
#                     continue
#                 end
#             end
#             i += 1
#         end
#         res = ord1
#     end
#     res
# end


function sortperm2(x, y; rev=false)
    n = length(x)
    if n != length(y)
        error("two input vectors are not the same length")
    end
    lev = sort(collect(Set(x)))

    # no ties
    if n == length(lev)
        return sortperm(x, rev = rev)
    end

    ord1 = sortperm(x, rev = rev)
    x_sorted = x[ord1]
    y_sorted = y[ord1]

    # ranges of x_sorted that are tied
    # we will sort ord1 by y_sorted
    f = 1
    @inbounds for val in lev
        l = findlast(x_sorted[f:end],val) + f - 1
        ord2 = sortperm(y_sorted[f:l],rev = rev)
        ord1[f:l] = ord1[f:l][ord2]
        f = l + 1
     end

    ord1

end

# In tests below, sortperm3 is the new sortperm2
# a = [1, 5, 1, 4, 3, 4, 4, 3, 1, 4, 5, 3, 5]
# b = [9, 4, 0, 4, 0, 2, 1, 2, 1, 3, 2, 1, 1]
#
# sortperm2(a,b) == sortperm3(a,b) -> true
#
# using BenchmarkTools
#
# @benchmark sortperm2(a,b) -> mean time: 7.7 μs
# @benchmark sortperm3(a,b) -> mean time: 5.5 μs
#
# For binary variable and its predicted values as in logistic regressions
# sortperm3 performs well, while sortperm2 is very slow with a sample > 1000
#
# using Distributions
#
# prob = rand(Distributions.Uniform(0,1),1000)
# obs = prob .> .5
#
# @benchmark sortperm2(obs,prob) -> mean time: 1.084 sec
# @benchmark sortperm3(obs,prob) -> mean time: 160.895 μs
#

# a = [1, 5, 1, 4, 3, 4, 4, 3, 1, 4, 5, 3, 5]
# b = [9, 4, 0, 4, 0, 2, 1, 2, 1, 3, 2, 1, 1]
#
# ord = sortperm2(a, b, rev = true)
# hcat(a[ord], b[ord])
#
# ord = sortperm2(a, b)
# hcat(a[ord], b[ord])
