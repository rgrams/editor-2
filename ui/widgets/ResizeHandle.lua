
local ResizeHandle = gui.Node:extend()

local theme = require "ui.widgets.themes.resize-handle"

ResizeHandle.width = 6

function ResizeHandle.set(self, target, dir, isYAxis, width)
	width = width or self.width
	ResizeHandle.super.set(self, width, width, "C", "C", "none", "fill")
	self.target = target
	self.dir = dir or -1
	self.isXAxis = not isYAxis
	self.layer = "gui"
	self.color = theme.normalColor
end

function ResizeHandle.init(self)
	ResizeHandle.super.init(self)
	if type(self.target) == "string" then
		self.target = self.tree:get(self.target)
		assert(self.target:is(gui.Node), "ResizeHandle target is not a node - "..tostring(self.target))
	end
end

function ResizeHandle.initRuu(self, ruu)
	self.ruu = ruu
	self.widget = ruu:Panel(self, theme)
	self.widget.press = self.press
	self.widget.release = self.release
	self.widget.drag = self.drag
end

function ResizeHandle.destroyRuu(self)
	self.ruu:destroy(self.widget)
end

function ResizeHandle.press(wgt, depth, mx, my, isKeyboard)
	wgt.super.press(wgt, depth, mx, my, isKeyboard)
	if isKeyboard or depth ~= 1 then  return  end
	wgt.ruu:startDrag(wgt, "resize")
end

function ResizeHandle.release(wgt, depth, mx, my, isKeyboard)
	wgt.super.release(wgt, depth, mx, my, isKeyboard)
	wgt.ruu:stopDraggingWidget(wgt)
end

function ResizeHandle.drag(wgt, dx, dy, dragType)
	local self = wgt.object
	if self.target then
		if self.isXAxis and dx ~= 0 then
			local curW = self.target._designRect.w
			self.target:size(curW + dx * self.dir, nil, true)
			self.target.parent:call("allocateChildren")
		elseif not self.isXAxis and dy ~= 0 then
			local curH = self.target._designRect.h
			self.target:size(nil, curH + dy * self.dir, true)
			self.target.parent:call("allocateChildren")
		end
	end
end

function ResizeHandle.draw(self)
	love.graphics.setColor(self.color)
	local w, h = self.w, self.h
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

	if self.widget and self.widget.isFocused then
		local lineWidth = 1
		love.graphics.setColor(1, 1, 1, 0.2)
		w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return ResizeHandle
