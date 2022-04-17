
local Tool = gui.Node:extend()
Tool.className = "Tool"

local config = require "config"
local scenes = require "scenes"
local EditorObject = require "objects.EditorObject"
local objectFn = require "commands.functions.object-functions"
local modkeys = require "modkeys"
local list = require "lib.list"

Tool.boxSelectAddKey = "shift"
Tool.boxSelectToggleKey = "ctrl"
Tool.boxSelectSubtractKey = "alt"

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

local function getObjectsInBox(parent, lt, top, w, h, hitEnclosures)
	hitEnclosures = hitEnclosures or {}
	for i=1,parent.children.maxn do
		local child = parent.children[i]
		if child then
			local cx, cy = child:toWorld(0, 0)
			if cx >= lt and cx <= lt+w and cy >= top and cy <= top+h then
				table.insert(hitEnclosures, child.enclosure)
			end
			if child.children then
				getObjectsInBox(child, lt, top, w, h, hitEnclosures)
			end
		end
	end
	return hitEnclosures
end

local function getBoxSelectMode(self)
	local curModChord = modkeys.getString()
	local mode = "set"
	if     curModChord == self.boxSelectAddKey .. " "      then  mode = "add"
	elseif curModChord == self.boxSelectToggleKey .. " "   then  mode = "toggle"
	elseif curModChord == self.boxSelectSubtractKey .. " " then  mode = "subtract"
	end
	return mode
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
		local hitEnclosures = getObjectsInBox(scene, lt, top, w, h)
		local mode = getBoxSelectMode(self)
		local curSelection = self.originalSelection
		local newSelection
		if mode == "set" then
			newSelection = hitEnclosures
		elseif mode == "add" then
			newSelection = list.getUnion(curSelection, hitEnclosures)
		elseif mode == "toggle" then
			newSelection = list.getDifference(curSelection, hitEnclosures)
		elseif mode == "subtract" then
			newSelection = list.getSubtraction(curSelection, hitEnclosures)
		end

		if not self.startedDragCommand then
			self.startedDragCommand = true
			scene.history:perform("setSelection", scene.selection, newSelection)
			self:updatePropertiesPanel()
		else
			scene.selection:setTo(newSelection)
			scene.history:update(scene.selection, newSelection)
			self:updatePropertiesPanel()
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
			if scene.selection[1] then
				local parentEnclosures = scene.selection:copyList()
				scene.history:perform("addObjectToMultiple", scene, parentEnclosures, Class, properties, false, false)
			else
				scene.history:perform("addObject", scene, Class, {}, properties, false, false)
			end
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
			if selection[1] and modkeys.getString() == "" then
				scenes.active.history:perform("clearSelection", selection)
				self:updatePropertiesPanel()
			end
			startDrag(self, "box select")
			self.originalSelection = selection:copyList() or {}
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

local function getObjectAt(scene, wx, wy)
	return hitCheckChildren(scene.children, wx, wy)
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
			self.hoverObj = getObjectAt(scene, wx, wy)
		end
		if self.hoverObj then
			self.hoverObj.isHovered = true
		end
	elseif action == "delete" and change == 1 then
		local scene = scenes.active
		if scene then
			if scene.selection[1] then
				local self = wgt.object
				local enclosures = scene.selection:copyList()
				objectFn.removeDescendantsFromList(enclosures)
				scene.history:perform("deleteObjects", scene, enclosures)
				self:updatePropertiesPanel()

				if self.hoverObj and not self.hoverObj.tree then
					self.hoverObj = nil
				end
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
