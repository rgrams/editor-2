
local EmptyTheme = require(GetRequireFolder(...) .. "EmptyTheme")
local ResizeHandleTheme = EmptyTheme:extend()

ResizeHandleTheme.normalColor = { 0.17, 0.17, 0.17, 1 }
ResizeHandleTheme.hoverColor = { 0.25, 0.25, 0.25, 1 }
ResizeHandleTheme.pressColor = { 0.5, 0.5, 0.5, 1 }

local xCursor = love.mouse.getSystemCursor("sizewe")
local yCursor = love.mouse.getSystemCursor("sizens")

function ResizeHandleTheme.hover(self)
	self.object.color = ResizeHandleTheme.hoverColor
	love.mouse.setCursor(self.object.isXAxis and xCursor or yCursor)
end

function ResizeHandleTheme.unhover(self)
	self.object.color = ResizeHandleTheme.normalColor
	love.mouse.setCursor()
end

function ResizeHandleTheme.press(self)
	self.object.color = ResizeHandleTheme.pressColor
end

function ResizeHandleTheme.release(self, dontFire, mx, my, isKeyboard)
	self.object.color = self.isHovered and ResizeHandleTheme.hoverColor or ResizeHandleTheme.normalColor
end

function ResizeHandleTheme.draw(self, obj)
	love.graphics.setColor(obj.color)
	local w, h = obj.w, obj.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	-- Draw handle lines.
	love.graphics.setColor(0, 0, 0, 1)
	local padX = 2
	local left, right = -w/2 + padX, w/2 - padX
	local lineCt = 4
	local lineWidth = 1
	local spacing = 3 + lineWidth
	for i=0,lineCt-1 do
		local topY = -(lineCt - 1)/2 * spacing
		local y = topY + i*spacing
		love.graphics.line(left, y, right, y)
	end

	if self.isFocused then
		local lineWidth = 1
		love.graphics.setColor(1, 1, 1, 0.2)
		w, h = obj.w - lineWidth, obj.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return ResizeHandleTheme
