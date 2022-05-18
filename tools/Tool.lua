
local Tool = gui.Node:extend()
Tool.className = "Tool"

local config = require "config"
local scenes = require "scenes"
local EditorObject = require "objects.EditorObject"
local Vec2Property = require "objects.properties.Vec2"
local objectFn = require "commands.functions.object-functions"
local modkeys = require "modkeys"
local list = require "lib.list"
local Dropdown = require "ui.widgets.Dropdown"
local classList = _G.objClassList

Tool.boxSelectAddKey = "shift"
Tool.boxSelectToggleKey = "ctrl"
Tool.boxSelectSubtractKey = "alt"
Tool.cornerHandleSize = 8
Tool.edgeHandleSize = 6
Tool.pivotRadius = 4
Tool.rotateKey = "alt"
Tool.snapKey = "ctrl"
Tool.snapX = config.translateSnapIncrement
Tool.snapY = config.translateSnapIncrement
Tool.dragInWorldSpace = true

function Tool.set(self, ruu)
	Tool.super.set(self, 1, 1, "C", "C", "fill")
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput
	self.widget.press = self.press
	self.widget.release = self.release
	self.widget.drag = self.drag
	self.lastAddClass = EditorObject
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
	self.isRotateDragging = false
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

local function getDragStartOffsets(inWorldSpace)
	local scene = scenes.active
	local dragStartOffsets = {}
	local enclosures
	if inWorldSpace then
		enclosures = scene.selection:copyList()
		objectFn.removeDescendantsFromList(enclosures)
	else
		enclosures = scene.selection
	end
	for i,enclosure in ipairs(enclosures) do
		local obj = enclosure[1]
		local x, y
		if inWorldSpace then
			x, y = obj._to_world.x, obj._to_world.y
		else
			x, y = obj.pos.x, obj.pos.y
		end
		dragStartOffsets[i] = {
			enclosure = enclosure,
			startX = x,
			startY = y
		}
	end
	return dragStartOffsets
end

local function getDragArgList(startOffsets, dx, dy, inWorldSpace, rx, ry)
	local argList = {}
	local shouldRound = rx and ry
	for i,data in ipairs(startOffsets) do
		local _x = data.startX + dx
		local _y = data.startY + dy
		if inWorldSpace then
			local obj = data.enclosure[1]
			_x, _y = obj.parent:toLocal(_x, _y)
		end
		if shouldRound then
			_x, _y = math.round(_x, rx), math.round(_y, ry)
		end
		local args = { data.enclosure, "pos", { x = _x, y = _y } }
		argList[i] = args
	end
	return argList
end

local function getRotDragStartOffsets()
	local scene = scenes.active
	local dragStartOffsets = {}
	local enclosures = scene.selection
	for i,enclosure in ipairs(enclosures) do
		dragStartOffsets[i] = {
			enclosure = enclosure,
			startAngle = enclosure[1]:getProperty("angle") or 0
		}
	end
	return dragStartOffsets
end

local function getRotDragArgList(startOffsets, da, roundIncr)
	local argList = {}
	for i,data in ipairs(startOffsets) do
		local angle = data.startAngle + da
		if roundIncr then
			angle = math.round(angle, roundIncr)
		end
		local args = { data.enclosure, "angle", angle }
		argList[i] = args
	end
	return argList
end

function Tool.drag(wgt, dx, dy, dragType)
	local self = wgt.object
	local scene = scenes.active

	local x, y = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	self.lastDragX, self.lastDragY = x, y

	if dragType == "translate selection" then
		local totalDX, totalDY = x - self.dragStartX, y - self.dragStartY
		local inWorldSpace = self.dragInWorldSpace
		local roundX, roundY = config.roundAllPropsTo, config.roundAllPropsTo
		if modkeys.isPressed(self.snapKey) then
			roundX, roundY = self.snapX, self.snapY
		end

		if not self.startedDragCommand then
			self.startedDragCommand = true
			self.dragStartOffsets = getDragStartOffsets(inWorldSpace)
			local argList = getDragArgList(self.dragStartOffsets, totalDX, totalDY, inWorldSpace, roundX, roundY)
			scene.history:perform("setMultiPropertiesOnMultiple", argList)
			self:updatePropertiesPanel()
		else
			-- TODO: Make sure the last command in the history is still ours.
			local argList = getDragArgList(self.dragStartOffsets, totalDX, totalDY, inWorldSpace, roundX, roundY)
			objectFn.setMultiPropertiesOnMultiple(argList)
			scene.history:update(argList)
			self:updatePropertiesPanel()
		end

	elseif dragType == "rotate selection" then
		self.isRotateDragging = true
		local totalDX, totalDY = x - self.dragStartX + 1, y - self.dragStartY
		local angle = math.deg(math.atan2(totalDY, totalDX))
		local roundIncr = config.roundAllPropsTo
		if modkeys.isPressed(self.snapKey) then
			roundIncr = config.rotateSnapIncrement
		end

		if not self.startedDragCommand then
			self.startedDragCommand = true
			self.dragStartOffsets = getRotDragStartOffsets()
			local argList = getRotDragArgList(self.dragStartOffsets, angle, roundIncr)
			scene.history:perform("setMultiPropertiesOnMultiple", argList)
			self:updatePropertiesPanel()
		else
			-- TODO: Make sure the last command in the history is still ours.
			local argList = getRotDragArgList(self.dragStartOffsets, angle, roundIncr)
			objectFn.setMultiPropertiesOnMultiple(argList)
			scene.history:update(argList)
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
		self.hoverObj = hitCheckChildren(scenes.active.children, wx, wy)
		if self.hoverObj then
			self.hoverObj.isHovered = true
		end
	end
end

function Tool.addAt(self, Class, wx, wy)
	self.lastAddClass = Class
	local scene = scenes.active
	local isSelected = false -- Lets you quickly create multiple objects without parenting exponentially.
	if scene.selection[1] then
		local argsList = {}
		for i,parentEnclosure in ipairs(scene.selection) do
			local parentObj = parentEnclosure[1]
			local lx, ly = parentObj:toLocal(wx, wy)
			local properties = { pos = { { x = lx, y = ly }, Vec2Property } }
			local args = {
				scene, Class, {}, properties, isSelected, parentEnclosure
			}
			argsList[i] = args
		end
		scene.history:perform("addObjects", scene, argsList)
	else
		local properties = { pos = { { x = wx, y = wy }, Vec2Property } }
		scene.history:perform("addObject", scene, Class, {}, properties, isSelected, false)
	end
	updateHover(self)
end

function Tool.press(wgt, depth, mx, my, isKeyboard)
	if depth ~= 1 then  return  end
	if scenes.active and not isKeyboard then
		local self = wgt.object

		if Input.isPressed("add modifier") then
			local wx, wy = Camera.current:screenToWorld(mx, my)
			wgt.object:addAt(self.lastAddClass, wx, wy)

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
				local isRotate = modkeys.isPressed(self.rotateKey)
				local dragType = isRotate and "rotate selection" or "translate selection"
				startDrag(self, dragType)
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

function Tool.objectsUpdated(self)
	if not self.isDragging then
		updateHover(self)
	end
end

function Tool.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat, x, y, dx, dy, isTouch, presses)
	if action == wgt.ruu.MOUSE_MOVED then
		local self = wgt.object
		if self.isDragging then  return  end
		updateHover(self, x, y)
	elseif action == "delete" and change == 1 then
		local scene = scenes.active
		if scene then
			if scene.selection[1] then
				local self = wgt.object
				local enclosures = scene.selection:copyList()
				objectFn.removeDescendantsFromList(enclosures)
				scene.history:perform("deleteObjects", scene, enclosures)
				self:updatePropertiesPanel()
				updateHover(self)
			end
		end
	elseif action == "add" and change == 1 then
		local self = wgt.object
		local items = {}
		local fn = self.addAt
		local mx, my = love.mouse.getPosition()
		local wx, wy = Camera.current:screenToWorld(mx, my)
		for i,Class in ipairs(classList) do
			local name = classList:getName(Class)
			local item = { text = name, fn = fn, args = {self, Class, wx, wy} }
			table.insert(items, item)
		end
		local dropdown = Dropdown(mx, my, items)
		local guiRoot = self.tree:get("/Window")
		self.tree:add(dropdown, guiRoot)
	end
end

local function addAABBs(enclosures)
	local inf = math.huge
	local lt, top, rt, bot = inf, inf, -inf, -inf
	for i,enclosure in ipairs(enclosures) do
		local obj = enclosure[1]
		lt = math.min(lt, obj.AABB.lt)
		top = math.min(top, obj.AABB.top)
		rt = math.max(rt, obj.AABB.rt)
		bot = math.max(bot, obj.AABB.bot)
	end
	return lt, top, rt, bot
end

local function centeredRect(mode, cx, cy, w, h)
	love.graphics.rectangle(mode, cx-w/2, cy-w/2, w, h)
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
	elseif self.isRotateDragging then
		local sx1, sy1 = Camera.current:worldToScreen(self.dragStartX - 1, self.dragStartY)
		local sx2, sy2 = Camera.current:worldToScreen(self.lastDragX, self.lastDragY)
		local lx1, ly1 = self:toLocal(sx1, sy1)
		local lx2, ly2 = self:toLocal(sx2, sy2)
		local dx, dy = lx2 - lx1, ly2 - ly1
		local r = vec2.len(dx, dy)
		local angle1, angle2 = 0, math.atan2(dy, dx)
		local isSnapped = modkeys.isPressed(self.snapKey)
		local snapAngle = angle2
		if isSnapped then
			angle2 = math.round(angle2, math.rad(config.rotateSnapIncrement))
			snapAngle = angle2
		end
		local segments = math.abs(angle2)/0.1 + 1
		if angle2 < 0 then
			angle1, angle2 = angle2, angle1
		end
		local col = config.selectedHighlightColor
		love.graphics.setColor(col)
		love.graphics.arc("line", "open", lx1, ly1, r, angle1, angle2, segments)
		love.graphics.line(lx1, ly1, lx1 + r, ly1) -- Straight horizontal.
		local x2, y2 = lx2, ly2
		if isSnapped then
			x2, y2 = lx1 + math.cos(snapAngle)*r, ly1 + math.sin(snapAngle)*r
		end
		love.graphics.line(lx1, ly1, x2, y2) -- Angle.
		love.graphics.setColor(col[1], col[2], col[3], 0.02)
		love.graphics.arc("fill", lx1, ly1, r, angle1, angle2, segments)
	end

	if scenes.active and scenes.active.selection[1] then
		local lt, top, rt, bot = addAABBs(scenes.active.selection)
		lt, top = self:toLocal( Camera.current:worldToScreen(lt, top) )
		rt, bot = self:toLocal( Camera.current:worldToScreen(rt, bot) )

		local w, h = rt - lt, bot - top
		local cx, cy = lt + w/2, top + h/2

		love.graphics.setColor(1, 1, 1, 0.1)
		love.graphics.rectangle("line", lt, top, w, h)

		--[[
		local size = self.cornerHandleSize
		centeredRect("line", lt, top, size, size)
		centeredRect("line", rt, top, size, size)
		centeredRect("line", rt, bot, size, size)
		centeredRect("line", lt, bot, size, size)

		size = self.edgeHandleSize
		centeredRect("line", cx, top, size, size)
		centeredRect("line", cx, bot, size, size)
		centeredRect("line", rt, cy, size, size)
		centeredRect("line", lt, cy, size, size)

		local r = self.pivotRadius
		love.graphics.circle("line", cx, cy, r, 12)
		local r2 = r*2
		love.graphics.line(cx - r2, cy, cx + r2, cy)
		love.graphics.line(cx, cy - r2, cx, cy + r2)
		--]]
	end
end

return Tool
