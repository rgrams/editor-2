
local EmptyTheme = require(GetRequireFolder(...) .. "EmptyTheme")
local PanelTheme = EmptyTheme:extend()

local value = 0.22

PanelTheme.bevelLighten = 0.1
PanelTheme.bevelDarken = 0.1
PanelTheme.bevelDepth = 1

function PanelTheme.init(self, themeData)
	PanelTheme.super.init(self, themeData)
	self.object.color = { value, value, value, 1 }
end

function PanelTheme.draw(self, obj)
	love.graphics.setColor(obj.color)
	local w, h = obj.w, obj.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	local val, alpha = obj.color[1], obj.color[4]
	local Theme = self.wgtTheme
	local v1 = val + Theme.bevelLighten
	local v2 = val - Theme.bevelDarken
	local depth = Theme.bevelDepth
	love.graphics.setColor(v1, v1, v1, alpha)
	love.graphics.rectangle("fill", -w/2, -h/2, w, depth)
	love.graphics.setColor(v2, v2, v2, alpha)
	love.graphics.rectangle("fill", -w/2, h/2 - depth, w, depth)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		w, h = w - lineWidth, h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return PanelTheme
