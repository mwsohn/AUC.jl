using AUC
using Base.Test

y = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1]
y_score = [0.3, 0.2, 0.3, 0.23, 0.5, 0.34, 0.45, 0.54, 0.6, 0.7, 0.8, 0.65, 0.5, 0.4, 0.3, 0.2, 0.6, 0.7, 0.5, 0.2, 0.1, 0.7, 0.2, 0.7, 0.4]

res = auc(y, y_score)

@test isequal(res, 0.7266666666666667)



res2 = AUC._auc(y, y_score, reorder = true)

@test isequal(res2, 0.44999999999999996)

res3 = AUC._auc(y, y_score,reorder = false)         # should throw error

res4 = auc(randn(25), rand(25))
@test res4 == -Inf
