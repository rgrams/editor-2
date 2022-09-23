
-- Not a normal tool. Is temporarily used to select
-- a single object for object reference properties.

-- Behaves like a Dropdown - consumes all input.

local ObjectSelectorTool = gui.Node:extend()
ObjectSelectorTool.className = "ObjectSelectorTool"

local Ruu = require "core.ui.ruu.ruu"
local config = require "core.config"
local scenes = require "core.scenes"
local signals = require "core.signals"

local overlayFont = { "core/assets/font/OpenSans-Semibold.ttf", 36 }
local tooltipFont = new.font("core/assets/font/OpenSans-Semibold.ttf", 16)
local tooltipFontHeight = tooltipFont:getHeight()
local overlayColor = { 1, 1, 1, 0.2 }
local flashAlpha = 0.03
local flashDur = 0.8

function ObjectSelectorTool.set(self, callback, parentRuu)
	ObjectSelectorTool.super.set(self, 1, 1, "C", "C", "fill")
	self.callback = callback
	self.layer = "viewport"
	self.ruu = Ruu()
	self.parentRuu = parentRuu
	local overlayLabel = gui.Text("Select an Object", overlayFont, 200, "N", "N", "center", "fill")
	overlayLabel:setPos(0, 15)
	overlayLabel.color = overlayColor
	self.children = { overlayLabel }
	self.flashT = flashDur
end

function ObjectSelectorTool.init(self)
	ObjectSelectorTool.super.init(self)
	Input.enable(self)

	self.viewport = self.tree:get("/Window/UI/MainRow/VPColumn/Viewport")

	self.widget = self.ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput
	self.widget.press = self.press
	self.widget.release = self.release
	self.widget.drag = self.drag
	self.widget.scroll = self.scroll
end

function ObjectSelectorTool.final(self)
	Input.disable(self)
	self.ruu:destroy(self.widget)
	self.parentRuu:mouseMoved(love.mouse.getPosition())
end

function ObjectSelectorTool.update(self, dt)
	if self.flashT then
		self.flashT = self.flashT - dt
		if self.flashT <= 0 then
			self.flashT = nil
		end
		shouldRedraw = true
	end
end

function ObjectSelectorTool.input(self, action, value, change, ...)
	self.ruu:input(action, value, change, ...)
	if not self.tree then  return true  end
	if action == Ruu.CLICK and change == 1 then
		if not self.ruu.hoveredWgts[1] then
			self:cancel()
			return false
		end
	elseif action == Ruu.CANCEL and change == 1 then
		self:cancel()
	end
	return true
end

function ObjectSelectorTool.scroll(wgt, depth, dx, dy)
	Camera.current:zoomIn(config.zoomRate*dy, love.mouse.getPosition()) -- dy is actual, signed, mouse wheel dy.
	if scenes.active then
		scenes.active.camZoom = Camera.current.zoom
		signals.send("zoom changed", wgt.object)
	end
end

function ObjectSelectorTool.drag(wgt, dx, dy, dragType)
	if dragType == "pan" then
		local wdx, wdy = Camera.current:screenToWorld(dx, dy, true)
		local pos = Camera.current.pos
		pos.x, pos.y = pos.x - wdx, pos.y - wdy
		if scenes.active then
			scenes.active.camX, scenes.active.camY = pos.x, pos.y
			local self = wgt.object
			if self.viewport.tool.onObjectsChanged then
				self.viewport.tool:onObjectsChanged()
			end
		end
	end
end

local function hitCheckChildren(children, x, y, minDist, closestObj)
	minDist = minDist or math.huge
	for i=1,children.maxn do
		local child = children[i]
		if child then
			local hitDist = child:touchesPoint(x, y)
			if hitDist and hitDist < minDist then
				minDist, closestObj = hitDist, child
			end
			if child.children then
				closestObj, minDist = hitCheckChildren(child.children, x, y, minDist, closestObj)
			end
		end
	end
	return closestObj, minDist
end

local function updateHover(self, mx, my)
	if self.hoverObj then
		self.hoverObj.isHovered = false
	end
	self.hoverObj = nil
	if scenes.active then
		if not (mx and my) then
			mx, my = love.mouse.getPosition()
		end
		local wx, wy = Camera.current:screenToWorld(mx, my)
		local hoverObj = hitCheckChildren(scenes.active.children, wx, wy)
		self.hoverObj = hoverObj

		if self.hoverObj then
			self.hoverObj.isHovered = true
		end
	end
end

function ObjectSelectorTool.onObjectsChanged(self, sender, signal)
	if sender == self then  return  end
	updateHover(self)
end

function ObjectSelectorTool.cancel(self)
	self.tree:remove(self)
end

function ObjectSelectorTool.press(wgt, depth, mx, my, isKeyboard)
	if depth ~= 1 then  return  end
	if scenes.active and not isKeyboard then
		local self = wgt.object
		if self.hoverObj then
			-- Our job is done. Delete self and fire callback.
			self.tree:remove(self)
			self.callback(self.hoverObj)
		end
	end
end

function ObjectSelectorTool.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat, x, y, dx, dy, isTouch, presses)
	if action == wgt.ruu.MOUSE_MOVED then
		local self = wgt.object
		updateHover(self, x, y)
	elseif action == "pan camera" then
		if change == 1 then
			wgt.ruu:startDrag(wgt, "pan")
		elseif change == -1 then
			wgt.ruu:stopDrag("pan")
		end
	end
end

function ObjectSelectorTool.draw(self)
	if self.hoverObj then
		-- Draw tooltip box with class and ID of hovered object.
		love.graphics.setLineStyle("smooth")

		local lx, ly = self:toLocal(love.mouse.getPosition())
		local className = self.hoverObj.displayName
		local id = self.hoverObj:getProperty("id")
		local str = ("%s [%s]"):format(className, id)
		local padX, padY = 9, 2
		local w = tooltipFont:getWidth(str) + padX*2
		local h = tooltipFontHeight + padY*2
		local x, y = math.round(lx), math.round(ly - h)
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("line", x-0.5, y-0.5, w+1, h+1)
		love.graphics.setColor(0.2, 0.2, 0.2, 1)
		love.graphics.rectangle("fill", x, y, w, h)
		love.graphics.setColor(config.selectedHighlightColor)
		love.graphics.setFont(tooltipFont)
		love.graphics.printf(str, x, y, w, "center")

		love.graphics.setLineStyle("rough")
	end

	-- Flash viewport when object selector is activated.
	if self.flashT then
		local k = math.max(0, self.flashT) / flashDur
		love.graphics.setColor(1, 1, 1, flashAlpha * k*k*k)
		local w, h = self.w, self.h
		love.graphics.rectangle("fill", -w/2, -h/2, w, h)
	end
end

return ObjectSelectorTool
