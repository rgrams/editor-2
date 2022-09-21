
local ResizeHandle = gui.Node:extend()

local Theme = require "core.ui.widgets.themes.ResizeHandleTheme"

ResizeHandle.width = 6

function ResizeHandle.set(self, target, dir, isYAxis, width)
	width = width or self.width
	ResizeHandle.super.set(self, width, width, "C", "C", "none", "fill")
	self.target = target
	self.dir = dir or -1
	self.isXAxis = not isYAxis
	self.layer = "gui"
	self.color = Theme.normalColor
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
	self.widget = ruu:Panel(self, Theme)
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
	local widget = self.widget
	if widget then
		widget.wgtTheme.draw(widget, self)
	end
end

return ResizeHandle
