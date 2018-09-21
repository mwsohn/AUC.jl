
module AUC

using SortingAlgorithms, CategoricalArrays

export auc, ROC

include("utils.jl")
include("roc.jl")
include("auc_functions.jl")

# package code goes here

end # module
