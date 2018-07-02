
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


function findrange(v,start,len)
    @inbounds for i=start:len-1
        if v[i] != v[i+1]
            return i
        end
    end
    return len
end

function ident_range(v)
    i = 1
    vlen = length(v)
    tvec = Vector()
    @inbounds while i < vlen
        if v[i] != v[i+1]
            i += 1
            continue
        end
        
        # find the range of identifical values
        iend = findrange(v,i,vlen)
        if iend > i
            push!(tvec,(i,iend))
        end
        i = iend + 1
    end
    return tvec
end

function sortperm2(x, y; rev = false)
   n = length(x)
   no_ties = n == length(Set(x))
   if no_ties
       return sortperm(x, rev = rev)
   end

   ord1 = sortperm(x, rev = rev)
   x_sorted = x[ord1]
   y_sorted = y[ord1]

   # ranges of x_sorted that are tied
   # we will sort ord1 by y_sorted
   trng = ident_range(x_sorted)
   @inbounds for t in trng
       ord2 = sortperm(y_sorted[t[1]:t[2]],rev = rev)
       ord1[t[1]:t[2]] = ord1[t[1]:t[2]][ord2]
    end

   ord1
end


# tst1 = sortperm2(k,c) # old version
# tst2 = sortperm3(k,c) # new version, now renamed to sortperm2

# using Base.Test
# @test isequal(tst1,tst2)

# using Distributions, BenchmarkTools
# c = rand(Uniform(0,1),1000)
# k = [x > .5 ? 1 : 0 for x in c]

# @benchmark sortperm2(k,c) -> mean time: 2.680 s
# @benchmark sortperm3(k,c) -> mean time: 71.548 μs 


# a = [1, 5, 1, 4, 3, 4, 4, 3, 1, 4, 5, 3, 5]
# b = [9, 4, 0, 4, 0, 2, 1, 2, 1, 3, 2, 1, 1]
#
# ord = sortperm2(a, b, rev = true)
# hcat(a[ord], b[ord])
#
# ord = sortperm2(a, b)
# hcat(a[ord], b[ord])
