
local Tool = gui.Node:extend()
Tool.className = "Tool"

local config = require "config"
local scenes = require "scenes"
local EditorObject = require "objects.EditorObject"

function Tool.set(self, ruu)
	Tool.super.set(self, 1, 1, "C", "C", "fill")
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput
	self.widget.press = self.press
	self.widget.release = self.release
	self.widget.drag = self.drag
end

local function startDrag(self)
	self.isDragging = true
	self.ruu:startDrag(self.widget)

	local objPos = self.hoverObj.pos
	local wmx, wmy = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	self.dragOX, self.dragOY = objPos.x - wmx, objPos.y - wmy
end

local function stopDrag(self)
	self.isDragging = false
	self.ruu:stopDraggingWidget(self.widget)
end

function Tool.drag(wgt, dx, dy)
	local self = wgt.object
	local x, y = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	x, y = x + self.dragOX, y + self.dragOY
	self.hoverObj.pos.x, self.hoverObj.pos.y = x, y
end

function Tool.press(wgt, depth, mx, my, isKeyboard)
	if depth ~= 1 then  return  end
	if scenes.active and not isKeyboard then
		local self = wgt.object

		if Input.isPressed("add") then
			local wx, wy = Camera.current:screenToWorld(mx, my)
			scenes.active:add(EditorObject(wx, wy, 0.2, 2, 1))
		elseif self.hoverObj then
			startDrag(self)
		end
	end
end

function Tool.release(wgt, depth, dontFire, mx, my, isKeyboard)
	if depth ~= 1 then  return  end
	local self = wgt.object
	if self.isDragging then
		stopDrag(self)
	end
end

function Tool.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat, x, y, dx, dy, isTouch, presses)
	if action == wgt.ruu.MOUSE_MOVED then
		local self = wgt.object
		if self.isDragging then  return  end
		self.hoverObj = nil
		local scene = scenes.active
		if scene then
			local wx, wy = Camera.current:screenToWorld(x, y)
			for i,child in ipairs(scene.children) do
				if child:touchesPoint(wx, wy) then
					self.hoverObj = child
				end
			end
		end
	end
end

-- Rotates around center, not top left corner.
local function drawRotatedRectangle(mode, x, y, width, height, angle)
	love.graphics.push()
	love.graphics.translate(x + width/2, y + height/2)
	love.graphics.rotate(angle)
	love.graphics.rectangle(mode, -width/2, -height/2, width, height) -- origin in the top left corner
	love.graphics.pop()
end

function Tool.draw(self)
	love.graphics.setColor(1, 0, 0, 1)
	if self.hoverObj then
		love.graphics.setLineWidth(config.highlightLineWidth)

		local obj = self.hoverObj
		local scrnX, scrnY = Camera.current:worldToScreen(obj.pos.x, obj.pos.y)
		local lx, ly = self:toLocal(scrnX, scrnY)
		local angle, sx, sy, kx, ky = matrix.parameters(obj._to_world)

		love.graphics.setColor(config.hoverHighlightColor)
		local objLineWidth = 1
		local r = (obj.hitRadius + objLineWidth/2) * Camera.current.zoom
		local pad = config.highlightPadding
		local hw, hh = r*sx + pad, r*sy + pad
		local x, y = lx - hw, ly - hh

		if angle ~= 0 then
			--[[
			local dx, dy = math.cos(angle), math.sin(angle)
			local pdx, pdy = -dy, dx
			local wx, wy = hw*dx, hw*dy
			local hx, hy = hh*pdx, hh*pdy
			local x1, y1 = lx - wx - hx, ly - wy - hy
			local x2, y2 = lx + wx - hx, ly + wy - hy
			local x3, y3 = lx + wx + hx, ly + wy + hy
			local x4, y4 = lx - wx + hx, ly - wy + hy
			love.graphics.line(x1, y1, x2, y2, x3, y3, x4, y4, x1, y1)
			--]]
			drawRotatedRectangle("line", x, y, hw*2, hh*2, angle)
		else
			love.graphics.rectangle("line", x, y, hw*2, hh*2)
		end


		love.graphics.setLineWidth(1)
	end
end

return Tool
