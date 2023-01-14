
local Class = require "core.philtre.core.base-class"
local PanelTheme = Class:extend()

local style = require "core.ui.style"

PanelTheme.bevelLighten = style.panelBevelLighten
PanelTheme.bevelDarken = style.panelBevelDarken
PanelTheme.bevelDepth = style.panelBevelDepth

function PanelTheme.init(self, themeData)
	self.object = themeData
	themeData.widget = self
	self.object.color = style.panelColor
end

function PanelTheme.hover(self)  end
function PanelTheme.unhover(self)  end
function PanelTheme.focus(self, isKeyboard)  end
function PanelTheme.unfocus(self, isKeyboard)  end
function PanelTheme.press(self, mx, my, isKeyboard)  end
function PanelTheme.release(self, dontFire, mx, my, isKeyboard)  end

local function drawBevel(w, h, depth, color, lighten, darken)
	local r, g, b, a = color[1], color[2], color[3], color[4]
	if depth < 0 then
		depth, lighten, darken = -depth, -darken, -lighten
	end
	love.graphics.setColor(r+lighten, g+lighten, b+lighten, a)
	love.graphics.rectangle("fill", -w/2, -h/2, w, depth)
	love.graphics.setColor(r-darken, g-darken, b-darken, a)
	love.graphics.rectangle("fill", -w/2, h/2 - depth, w, depth)
end

function PanelTheme.draw(self, obj)
	love.graphics.setColor(obj.color)
	local w, h = obj.w, obj.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	local thm = self.theme
	drawBevel(w, h, thm.bevelDepth, obj.color, thm.bevelLighten, thm.bevelDarken)

	if self.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		w, h = w - lineWidth, h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return PanelTheme
