
local M = {}

M.zoomRate = 0.1

M.translateSnapIncrement = 4

M.viewportBackgroundColor = { 0.1, 0.1, 0.1 }
M.gridColor = { 0.3, 0.3, 0.3, 0.06 }
M.bigGridColor = { 0.3, 0.3, 0.3, 0.28 }
M.gridNumberColor = { 0.5, 0.5, 0.5, 0.5 }
M.xAxisColor = { 0.8, 0.4, 0.4, 0.4 }
M.yAxisColor = { 0.4, 0.8, 0.4, 0.4 }

-- M.hoverHighlightColor = {1, 0.9, 0.8, 0.4}
M.hoverHighlightColor = {1, 0.9, 0.8, 1}
M.selectedHighlightColor = {0.9, 0.5, 0.0, 0.9}
M.latestSelectedHighlightColor = {1, 0.9, 0.45, 1}
M.highlightLineWidth = 3
M.highlightPadding = 3

return M
