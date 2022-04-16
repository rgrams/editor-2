
local Tool = gui.Node:extend()
Tool.className = "Tool"

local config = require "config"
local scenes = require "scenes"
local EditorObject = require "objects.EditorObject"
local objectFn = require "commands.functions.object-functions"
local modkeys = require "modkeys"

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

function Tool.init(self)
	Tool.super.init(self)
	self.propertyPanel = self.tree:get("/Window/UI/PropertyPanel")
end

function Tool.updatePropertiesPanel(self)
	local enclosures = scenes.active.selection
	self.propertyPanel:updateProperties(enclosures)
end

local function startDrag(self, dragType)
	self.isDragging = true
	self.ruu:startDrag(self.widget, dragType)

	local wmx, wmy = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	self.lastDragX, self.lastDragY = wmx, wmy
	self.dragStartX, self.dragStartY = wmx, wmy
end

local function stopDrag(self)
	self.isDragging = false
	self.isBoxSelecting = false
	self.ruu:stopDraggingWidget(self.widget)
	self.startedDragCommand = false
end

function Tool.drag(wgt, dx, dy, dragType)
	local self = wgt.object
	local scene = scenes.active

	local x, y = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	local wdx, wdy = x - self.lastDragX, y - self.lastDragY
	self.lastDragX, self.lastDragY = x, y

	if dragType == "drag selection" then
		if not self.startedDragCommand then
			self.startedDragCommand = true
			local enclosures = scene.selection:copyList()
			scene.history:perform("offsetPropertyOnMultiple", enclosures, "pos", wdx, wdy)
			self:updatePropertiesPanel()
		else
			-- TODO: Make sure the last command in the history is still ours.
			local enclosures = scene.selection:copyList()
			objectFn.offsetPropertyOnMultiple(enclosures, "pos", wdx, wdy)
			local totalDX, totalDY = x - self.dragStartX, y - self.dragStartY
			scene.history:update(enclosures, "pos", totalDX, totalDY)
			self:updatePropertiesPanel()
		end
	elseif dragType == "box select" then
		self.isBoxSelecting = true
		local lt, top = math.min(x, self.dragStartX), math.min(y, self.dragStartY)
		local w, h = math.abs(x - self.dragStartX), math.abs(y - self.dragStartY)
		local selectedEnclosures = {}
		for i,child in ipairs(scene.children) do
			local cx, cy = child:toWorld(0, 0)
			if cx >= lt and cx <= lt+w and cy >= top and cy <= top+h then
				table.insert(selectedEnclosures, child.enclosure)
			end
		end
		if not self.startedDragCommand then
			self.startedDragCommand = true
			scene.history:perform("setSelection", scene.selection, selectedEnclosures)
			self:updatePropertiesPanel()
		else
			scene.selection:setTo(selectedEnclosures)
			scene.history:update(scene.selection, selectedEnclosures)
		end
	end
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
			local shouldToggle = modkeys.isPressed("shift")
			local isSelected = self.hoverObj.isSelected
			local selection = scenes.active.selection
			local history = scenes.active.history

			if not isSelected then
				if shouldToggle then
					history:perform("addToSelection", selection, self.hoverObj.enclosure)
					self:updatePropertiesPanel()
				else
					history:perform("setSelection", selection, { self.hoverObj.enclosure })
					self:updatePropertiesPanel()
				end
			elseif isSelected and shouldToggle then
				history:perform("removeFromSelection", selection, self.hoverObj.enclosure)
				self:updatePropertiesPanel()
			end
			if self.hoverObj.isSelected then
				startDrag(self, "drag selection")
			end
		else -- Clicked on nothing.
			local selection = scenes.active.selection
			if selection[1] and not modkeys.isPressed("shift") then
				scenes.active.history:perform("clearSelection", selection)
				self:updatePropertiesPanel()
			end
			startDrag(self, "box select")
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
	elseif action == "delete" and change == 1 then
		local scene = scenes.active
		if scene then
			if scene.selection[1] then
				local enclosures = scene.selection:copyList()
				scene.history:perform("deleteObjects", scene, enclosures)
				wgt.object:updatePropertiesPanel()
			end
		end
	end
end

function Tool.draw(self)
	if self.isBoxSelecting then
		local sx1, sy1 = Camera.current:worldToScreen(self.dragStartX, self.dragStartY)
		local sx2, sy2 = Camera.current:worldToScreen(self.lastDragX, self.lastDragY)
		local lx1, ly1 = self:toLocal(sx1, sy1)
		local lx2, ly2 = self:toLocal(sx2, sy2)
		local sw, sh = lx2 - lx1, ly2 - ly1
		local col = config.selectedHighlightColor
		love.graphics.setColor(col)
		love.graphics.rectangle("line", lx1, ly1, sw, sh)
		love.graphics.setColor(col[1], col[2], col[3], 0.02)
		love.graphics.rectangle("fill", lx1, ly1, sw, sh)
	end
end

return Tool
