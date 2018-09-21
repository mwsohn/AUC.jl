
struct ROC
    fpr::Array{Float64, 1}
    tpr::Array{Float64, 1}
    thresholds::Array{Float64, 1}

    function ROC(y_true, y_score)
        fps, tps, thresholds = _binary_clf_curve(y_true, y_score)
        fpr = fps/last(fps)
        tpr = tps/last(tps)
        res = new(fpr, tpr, thresholds)
        return res
    end
end


# function roc_curve(y_true, y_score)
#     fps, tps, thresholds = _binary_clf_curve(y_true, y_score)
#     fpr = fps/last(fps)
#     tpr = tps/last(tps)
#     return (fpr, tpr, thresholds)
# end

# roc_curve(y, y_score)


function _binary_clf_curve(y_true, y_score)
    y_true = y_true .== 1       # make y_true a boolean vector
    desc_score_indices = sortperm(y_score, rev = true)

    y_score = y_score[desc_score_indices]
    y_true = y_true[desc_score_indices]

    distinct_value_indices = findall(x->x != 0.0,diff(y_score))
    threshold_idxs = push!(distinct_value_indices, length(y_score))

    tps = cumsum(y_true)[threshold_idxs]
    fps = threshold_idxs - tps
    return (fps, tps, y_score[threshold_idxs])
end

# y = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1]
# y_score = [0.3, 0.2, 0.3, 0.23, 0.5, 0.34, 0.45, 0.54, 0.6, 0.7, 0.8, 0.65, 0.5, 0.4, 0.3, 0.2, 0.6, 0.7, 0.5, 0.2, 0.1, 0.7, 0.2, 0.7, 0.4]

# _binary_clf_curve(y, y_score)
