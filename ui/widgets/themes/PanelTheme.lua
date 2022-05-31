
local EmptyTheme = require(GetRequireFolder(...) .. "EmptyTheme")
local PanelTheme = EmptyTheme:extend()

local value = 0.22

function PanelTheme.init(self, themeData)
	PanelTheme.super.init(self, themeData)
	self.object.color = { value, value, value, 1 }
end

function PanelTheme.draw(self, obj)
	love.graphics.setColor(obj.color)
	local w, h = obj.w, obj.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		w, h = w - lineWidth, h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return PanelTheme
