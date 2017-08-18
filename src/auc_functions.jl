
# This set of functions is based almost entirely on the
# excellent scikit-learn package's method of calculating
# an ROC's area under the curve (AUC). The functions below
# produce the same output as scikit-learn.



function trapsum(y, x)
    d = diff(x)
    res = sum((d .* (y[2:end] + y[1:(end-1)]) ./ 2.0))
    res
end

# trapsum([1, 2, 3], [4, 6, 8])     # 8.0


function _auc(x, y; reorder = false)
    direction = 1
    if reorder
        order = sortperm2(x, y)
        x, y = x[order], y[order]
    else
        dx = diff(x)
        if any(dx .<= 0)
            if all(dx .<= 0)
                direction = -1
            else
                error("Reordering is not turned on, and the x array is not increasing: $x")
            end
        end
    end
    area = direction * trapsum(y, x)
    area
end




"""
    auc(y_true, y_score)

This function returns the area under the curve (AUC) for the receiver operating characteristic
curve (ROC). This function takes two vectors, `y_true` and `y_score`. The vector `y_true` is the
observed `y` in a binary classification problem. And the vector `y_score` is the real-valued
prediction for each observation.
"""
function auc(y_true::T, y_score::S) where {T <: AbstractArray{<:Real, 1}, S <: AbstractArray{<:Real, 1}}
    if length(Set(y_true)) == 1
        warn("Only one class present in y_true.\n
              The AUC is not defined in that case; returning -Inf.")
        res = -Inf
    elseif length(Set(y_true)) ≠ 2
        warn("More than two classes present in y_true.\n
              The AUC is not defined in that case; returning -Inf.")
        res = -Inf
    else
        xroc = ROC(y_true, y_score)
        res = _auc(xroc.fpr, xroc.tpr, reorder = true)
    end
    res
end

# auc(y, y_score)
