using AUC
using PlotlyJS


y = [0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1]
y_score = [0.3, 0.2, 0.3, 0.23, 0.5, 0.34, 0.45, 0.54, 0.6, 0.7, 0.8, 0.65, 0.5, 0.4, 0.3, 0.2, 0.6, 0.7, 0.5, 0.2, 0.1, 0.7, 0.2, 0.7, 0.4]

y_score2 = [0.1, 0.1, 0.1, 0.23, 0.25, 0.24, 0.45, 0.54, 0.6, 0.7, 0.8, 0.65, 0.1, 0.95, 0.3, 0.1, 0.9, 0.8, 0.75, 0.5, 0.1, 0.65, 0.82, 0.95, 0.94]


res = auc(y, y_score)
res = auc(y, y_score2)

roc1 = ROC(y, y_score)
roc2 = ROC(y, y_score2)


function rocplot(roc::ROC; col = "#87CEEB")
    trace1 = scatter(x = roc.fpr,
                     y = roc.tpr,
                     mode = "line",
                     marker_color = col)

    trace2 = scatter(x = [0.0, 1.0],
                     y = [0.0, 1.0],
                     mode = "line",
                     marker_color = "#BBBBBB")

    layout1 = Layout(plot_bgcolor = "white",
                     xaxis = attr(gridcolor = "#E2E2E2"),
                     yaxis = attr(gridcolor = "#E2E2E2"))

    plot([trace1, trace2], layout1)
end

rocplot(roc1)



function rocplot(roc::ROC; model = "Model", col = "#87CEEB")
    trace1 = scatter(x = [0.0, 1.0],
                     y = [0.0, 1.0],
                     name = "Random",
                     mode = "line",
                     marker_color = "#BBBBBB")

    trace2 = scatter(x = [0.0; roc.fpr],
                     y = [0.0; roc.tpr],
                     name = model,
                     mode = "line",
                     marker_color = col)

    layout1 = Layout(paper_bgcolor = "rgb(255, 255, 255)",
                     plot_bgcolor = "rgb(229, 229, 229)",
                     yaxis_title = "Sensitivity",
                     xaxis_title = "1 - Specificity",
                     xaxis = attr(gridcolor = "rgb(255, 255, 255)",
                                  range = [-0.01, 1.01],
                                  showgrid = true,
                                  showline = false,
                                  showticklabels = true,
                                  tickcolor = "rgb(127, 127, 127)",
                                  ticks = "outside",
                                  zeroline = false),

                     yaxis = attr(gridcolor="rgb(255, 255, 255)",
                                  range = [-0.01, 1.01],
                                  showgrid = true,
                                  showline = false,
                                  showticklabels = true,
                                  tickcolor = "rgb(127, 127, 127)",
                                  ticks = "outside",
                                  zeroline = false))


    plot([trace1, trace2], layout1)
end

rocplot(roc2, model = "Boosted Trees", col = "navy")

# auc(y, y_score2)
