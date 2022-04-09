
local Viewport = gui.Node:extend()
Viewport.className = "Viewport"

local config = require "config"
local BackgroundGrid = require "ui.BackgroundGrid"
local Tool = require "tools.Tool"

local maxLineWidth = 1

function Viewport.set(self, ruu)
	Viewport.super.set(self, 50, 600, "C", "C", "fill")
	self.isGreedy = true
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.scroll = Viewport.scroll
	self.widget.ruuInput = Viewport.ruuInput
	self.widget.drag = Viewport.drag
	ruu.isHoverAction["pan camera"] = true
	self.children = {
		Tool(ruu)
	}
end

function Viewport.init(self)
	Viewport.super.init(self)
	self.tree:add(BackgroundGrid(self))
end

function Viewport.allocate(self, ...)
	Viewport.super.allocate(self, ...)
	-- TODO: Debug what's going on with Node allocations and make this non-hard-coded.
	Camera.current:setViewport(0, 0, self.w, self.h)
end

function Viewport.scroll(wgt, dx, dy)
	Camera.current:zoomIn(config.zoomRate*dy, love.mouse.getPosition()) -- dy is actual, signed, mouse wheel dy.
end

function Viewport.drag(wgt, dx, dy, dragType)
	if dragType == "pan" then
		local wdx, wdy = Camera.current:screenToWorld(dx, dy, true)
		local pos = Camera.current.pos
		pos.x, pos.y = pos.x - wdx, pos.y - wdy
	end
end

function Viewport.ruuInput(wgt, action, value, change, rawChange, isRepeat, x, y, dx, dy, isTouch, presses)
	if action == "pan camera" then
		if change == 1 then
			wgt.ruu:startDrag(wgt, "pan")
		elseif change == -1 then
			wgt.ruu:stopDrag("pan")
		end
	elseif action == "scroll" then
		wgt:scroll(dx, dy)
	end
end

function Viewport.draw(self)
	if self.widget.isFocused then
		local depth = self.panelIndex or 0
		local lineWidth = maxLineWidth / (depth + 1)
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setColor(1, 1, 1, 0.5)

		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)

		love.graphics.setLineWidth(1)
	end
end

return Viewport
