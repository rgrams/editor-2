
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
			local properties = { pos = { wx, wy } }
			local scene = scenes.active
			local Class = EditorObject
			scenes.active.history:perform("addObject", scene, Class, {}, properties)
		elseif self.hoverObj then
			local shouldToggle = Input.isPressed("shift")
			local isSelected = self.hoverObj.isSelected
			local selection = scenes.active.selection
			local history = scenes.active.history

			if not isSelected then
				if shouldToggle then
					history:perform("addToSelection", selection, self.hoverObj.enclosure)
				else
					history:perform("setSelection", selection, { self.hoverObj.enclosure })
				end
			elseif isSelected and shouldToggle then
				history:perform("removeFromSelection", selection, self.hoverObj.enclosure)
			end
			startDrag(self)
		else -- Clicked on nothing.
			local selection = scenes.active.selection
			if selection[1] and not Input.isPressed("shift") then
				scenes.active.history:perform("clearSelection", selection)
			end
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
		if self.hoverObj then  self.hoverObj.isHovered = false  end
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
		if self.hoverObj then
			self.hoverObj.isHovered = true
		end
	end
end

function Tool.draw(self)
end

return Tool
