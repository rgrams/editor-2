
local Tool = gui.Node:extend()
Tool.className = "Tool"

local config = require "config"
local scenes = require "scenes"
local signals = require "signals"
local EditorObject = require "objects.EditorObject"
local Vec2Property = require "objects.properties.Vec2"
local objectFn = require "commands.functions.object-functions"
local objectCmd = require "commands.object-commands"
local selectCmd = require "commands.selection-commands"
local modkeys = require "modkeys"
local list = require "lib.list"
local Dropdown = require "ui.widgets.Dropdown"
local classList = _G.objClassList
local Handle = require "tools.ToolHandle"

Tool.boxSelectAddChord = "shift "
Tool.boxSelectToggleChord = "ctrl "
Tool.boxSelectSubtractChord = "alt "
Tool.cornerHandleSize = 12
Tool.edgeHandleSize = 9
Tool.pivotRadius = 6
Tool.rotateKey = "alt"
Tool.snapKey = "ctrl"
Tool.snapToAxisKey = "shift"
Tool.dragInWorldSpace = true

function Tool.set(self, ruu)
	Tool.super.set(self, 1, 1, "C", "C", "fill")
	self.layer = "viewport"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.ruuInput = self.ruuInput
	self.widget.press = self.press
	self.widget.release = self.release
	self.widget.drag = self.drag
	self.lastAddClass = EditorObject
	self.AABB = { lt = 0, top = 0, rt = 0, bot = 0 }

	signals.subscribe(self, self.onObjectsChanged,
		"objects added",
		"objects deleted",
		"selected objects modified",
		"selection changed",
		"active scene changed"
	)

	local cornerW = self.cornerHandleSize
	local edgeW = self.edgeHandleSize
	self.handles = {
		nw = Handle(cornerW, "nw"), ne = Handle(cornerW, "ne"),
		se = Handle(cornerW, "se"), sw = Handle(cornerW, "sw"),
		n = Handle(edgeW, "n"), e = Handle(edgeW, "e"),
		s = Handle(edgeW, "s"), w = Handle(edgeW, "w"),
		-- c = Handle(self.pivotRadius*2, "c", true)
	}
end

function Tool.init(self)
	Tool.super.init(self)
	self.propertyPanel = self.tree:get("/Window/UI/PropertyPanel")
end

local function startDrag(self, dragType)
	self.isDragging = true
	self.lastDragType = dragType
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

local function AABBsOverlap(lt1, top1, rt1, bot1, lt2, top2, rt2, bot2)
	return lt1 < rt2 and rt1 > lt2 and top1 < bot2 and bot1 > top2
end

local function getObjectsInBox(parent, lt, top, rt, bot, hitEnclosures)
	hitEnclosures = hitEnclosures or {}
	for i=1,parent.children.maxn do
		local child = parent.children[i]
		if child then
			local AABB = child.AABB
			local lt2, top2, rt2, bot2 = AABB.lt, AABB.top, AABB.rt, AABB.bot
			if AABBsOverlap(lt, top, rt, bot, lt2, top2, rt2, bot2) then
				table.insert(hitEnclosures, child.enclosure)
			end
			if child.children then
				getObjectsInBox(child, lt, top, rt, bot, hitEnclosures)
			end
		end
	end
	return hitEnclosures
end

local function getBoxSelectMode(self)
	local curModChord = modkeys.getString()
	local mode = "set"
	if     curModChord == self.boxSelectAddChord      then  mode = "add"
	elseif curModChord == self.boxSelectToggleChord   then  mode = "toggle"
	elseif curModChord == self.boxSelectSubtractChord then  mode = "subtract"
	end
	return mode
end

local function getEnclosuresForDrag(scene, inWorldSpace)
	if inWorldSpace then
		local enclosures = scene.selection:copyList()
		objectFn.removeDescendantsFromList(enclosures)
		return enclosures
	else
		return scene.selection
	end
end

local function getDragPropertyList(enclosures, property, inWorldSpace, out)
	out = out or {}
	for i,enclosure in ipairs(enclosures) do
		local item = { enclosure = enclosure }
		local obj = enclosure[1]

		if property == "pos" then
			if inWorldSpace then
				item.x, item.y = obj:getWorldPos()
			else
				item.x, item.y = obj:getLocalPos()
			end
			table.insert(out, item)
		elseif property == "angle" then
			item.angle = obj:getProperty("angle") or 0
			table.insert(out, item)
		elseif property == "scale" then
			local sizeProp = obj:getSizePropertyObj()
			if sizeProp then
				local size = sizeProp:getValue()
				if sizeProp.typeName == "vec2" then
					item.sx, item.sy = size.x, size.y
				elseif sizeProp.typeName == "float" then
					item.s = size
				end
				table.insert(out, item)
			end
		end
	end
	return out
end

local function getPosDragArgList(caller, startOffsets, dx, dy, inWorldSpace, rx, ry)
	local argList = {}
	local shouldRound = rx and ry
	for i,start in ipairs(startOffsets) do
		local x = start.x + dx
		local y = start.y + dy
		if inWorldSpace then
			local obj = start.enclosure[1]
			x, y = obj:toLocalPos(x, y)
		end
		if shouldRound then
			x, y = math.round(x, rx), math.round(y, ry)
		end
		local args = { caller, start.enclosure, "pos", { x = x, y = y } }
		argList[i] = args
	end
	return argList
end

local function getRotDragArgList(caller, startOffsets, da, roundIncr)
	local argList = {}
	for i,start in ipairs(startOffsets) do
		local angle = start.angle + da
		if roundIncr then
			angle = math.round(angle, roundIncr)
		end
		local args = { caller, start.enclosure, "angle", angle }
		argList[i] = args
	end
	return argList
end

local function sumAABBs(enclosures)
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

local function updateHandleHover(self)
	for k,handle in pairs(self.handles) do
		handle.isHovered = handle == self.hoverHandle and true or false
	end
end

local function updateHandlePositions(self)
	local AABB = self.AABB
	local handles = self.handles
	-- Set to Tool-local coordinates for drawing.
	local lt, top = self:toLocal( Camera.current:worldToScreen(AABB.lt, AABB.top) )
	local rt, bot = self:toLocal( Camera.current:worldToScreen(AABB.rt, AABB.bot) )
	local cx, cy = lt + (rt-lt)/2, top + (bot-top)/2
	handles.nw:setPos(lt, top)
	handles.n:setPos(cx, top)
	handles.ne:setPos(rt, top)
	handles.e:setPos(rt, cy)
	handles.se:setPos(rt, bot)
	handles.s:setPos(cx, bot)
	handles.sw:setPos(lt, bot)
	handles.w:setPos(lt, cy)
	-- handles.c:setPos(cx, cy)
	updateHandleHover(self)
end

-- self.AABB is in world space.
local function updateAABB(self)
	local AABB = self.AABB
	if scenes.active and scenes.active.selection[1] then
		AABB.lt, AABB.top, AABB.rt, AABB.bot = sumAABBs(scenes.active.selection)
		updateHandlePositions(self)
	else
		AABB.lt, AABB.top, AABB.rt, AABB.bot = 0, 0, 0, 0
	end
end

function Tool.drag(wgt, dx, dy, dragType)
	local self = wgt.object
	local scene = scenes.active

	local x, y = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	self.lastDragX, self.lastDragY = x, y

	if dragType == "translate selection" then
		local totalDX, totalDY = x - self.dragStartX, y - self.dragStartY
		local inWorldSpace = self.dragInWorldSpace
		local snapIncr = config.roundAllPropsTo
		if modkeys.isPressed(self.snapKey) then
			snapIncr = config.translateSnapIncrement
		end
		local roundX, roundY = snapIncr, snapIncr
		if modkeys.isPressed(self.snapToAxisKey) then
			if math.abs(totalDX) > math.abs(totalDY) then
				totalDY = 0
				roundY = config.roundAllPropsTo
			else
				totalDX = 0
				roundX = config.roundAllPropsTo
			end
		end

		if not self.startedDragCommand then
			self.startedDragCommand = true
			local enclosures = getEnclosuresForDrag(scenes.active, inWorldSpace)
			self.dragStartOffsets = getDragPropertyList(enclosures, "pos", inWorldSpace)
			local argList = getPosDragArgList(self, self.dragStartOffsets, totalDX, totalDY, inWorldSpace, roundX, roundY)
			scene.history:perform("setMultiPropertiesOnMultiple", self, argList)
		else
			-- TODO: Make sure the last command in the history is still ours.
			local argList = getPosDragArgList(self, self.dragStartOffsets, totalDX, totalDY, inWorldSpace, roundX, roundY)
			local doCmd = objectCmd.setMultiPropertiesOnMultiple[1]
			doCmd(self, argList)
			scene.history:update(self, argList)
		end
		updateAABB(self)

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
			local enclosures = getEnclosuresForDrag(scenes.active)
			self.dragStartOffsets = getDragPropertyList(enclosures, "angle")
			local argList = getRotDragArgList(self, self.dragStartOffsets, angle, roundIncr)
			scene.history:perform("setMultiPropertiesOnMultiple", self, argList)
		else
			-- TODO: Make sure the last command in the history is still ours.
			local argList = getRotDragArgList(self, self.dragStartOffsets, angle, roundIncr)
			local doCmd = objectCmd.setMultiPropertiesOnMultiple[1]
			doCmd(self, argList)
			scene.history:update(self, argList)
		end
		updateAABB(self)

	elseif dragType == "box select" then
		self.isBoxSelecting = true
		local lt, top = math.min(x, self.dragStartX), math.min(y, self.dragStartY)
		local rt, bot = math.max(x, self.dragStartX), math.max(y, self.dragStartY)
		local hitEnclosures = getObjectsInBox(scene, lt, top, rt, bot)
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
			scene.history:perform("setSelection", self, scene.selection, newSelection)
		else
			local doCmd = selectCmd.setSelection[1]
			doCmd(self, scene.selection, newSelection)
			scene.history:update(self, scene.selection, newSelection)
		end
		updateAABB(self)

	elseif dragType == "handle transform" then
		local handle = self.hoverHandle
		local inWorldSpace = true
		local totalDX, totalDY = x - self.dragStartX, y - self.dragStartY

		handle.x, handle.y = handle.x + dx, handle.y + dy

		if not self.startedDragCommand then
			-- Store original AABB.
			local AABB = self.AABB
			local lt, top, rt, bot = AABB.lt, AABB.top, AABB.rt, AABB.bot
			local w, h = rt - lt, bot - top
			self.originalDragAABB = { lt = lt, top = top, rt = rt, bot = bot, w = w, h = h }

			-- Store original object positions & scales
			local enclosures = getEnclosuresForDrag(scenes.active, inWorldSpace)
			self.dragPosStartOffsets = getDragPropertyList(enclosures, "pos", inWorldSpace)
			self.dragScaleStartOffsets = getDragPropertyList(enclosures, "scale", inWorldSpace)
		end

		-- AABB is in world space.
		local AABB = self.originalDragAABB
		local lt, top, rt, bot = AABB.lt, AABB.top, AABB.rt, AABB.bot
		local w, h = rt - lt, bot - top

		-- Figure out transform origin and new AABB.
		local isSnapped = modkeys.isPressed(self.snapKey)
		local snapIncr = isSnapped and config.translateSnapIncrement or config.roundAllPropsTo

		local dir = handle.dir
		local ox, oy

		if dir.x == -1 then
			lt = lt + totalDX
			lt = math.round(lt, snapIncr)
			self.AABB.lt = lt -- Directly modify current AABB instead of re-summing it.
			ox = rt
		elseif dir.x == 0 then
			ox = lt + w/2
		elseif dir.x == 1 then
			rt = rt + totalDX
			rt = math.round(rt, snapIncr)
			self.AABB.rt = rt
			ox = lt
		end
		if dir.y == -1 then
			top = top + totalDY
			top = math.round(top, snapIncr)
			self.AABB.top = top
			oy = bot
		elseif dir.y == 0 then
			oy = top + h/2
		elseif dir.y == 1 then
			bot = bot + totalDY
			bot = math.round(bot, snapIncr)
			self.AABB.bot = bot
			oy = top
		end

		local newW, newH = rt - lt, bot - top
		local sx, sy = newW / w, newH / h

		local argsList = {}
		for i,start in ipairs(self.dragPosStartOffsets) do
			local x = ox + (start.x - ox)*sx
			local y = oy + (start.y - oy)*sy
			if inWorldSpace then
				local obj = start.enclosure[1]
				x, y = obj:toLocalPos(x, y)
			end
			local args = { self, start.enclosure, "pos", { x = x, y = y } }
			table.insert(argsList, args)
		end
		for i,start in ipairs(self.dragScaleStartOffsets) do
			local obj = start.enclosure[1]
			local sizeProp = obj:getSizePropertyObj()
			local value
			if sizeProp.typeName == "vec2" then
				value = { x = start.sx*sx, y = start.sy*sy }
			elseif sizeProp.typeName == "float" then
				value = start.s * math.min(sx, sy)
			end
			local propName = sizeProp.name
			local args = { self, start.enclosure, propName, value }
			table.insert(argsList, args)
		end

		if not self.startedDragCommand then
			self.startedDragCommand = true
			-- Perform set property command.
			scene.history:perform("setMultiPropertiesOnMultiple", self, argsList)
		else
			-- Update set property command args.
			-- TODO: Make sure the last command in the history is still ours.
			local doCmd = objectCmd.setMultiPropertiesOnMultiple[1]
			doCmd(self, argsList)
			scene.history:update(self, argsList)
		end
		updateHandlePositions(self)
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

local function hitCheckHandles(self, mx, my, minDist)
	local lx, ly = self:toLocal(mx, my)
	local closestHandle
	for k,handle in pairs(self.handles) do
		local dist = handle:touchesPoint(lx, ly)
		if dist and dist < minDist then
			minDist = dist
			closestHandle = handle
		end
	end
	return closestHandle, minDist
end

local function updateHover(self, mx, my)
	updateAABB(self)
	if self.hoverObj then
		self.hoverObj.isHovered = false
	end
	self.hoverObj = nil
	self.hoverHandle = nil
	if scenes.active then
		if not (mx and my) then
			mx, my = love.mouse.getPosition()
		end
		local wx, wy = Camera.current:screenToWorld(mx, my)
		local hoverObj, minDist = hitCheckChildren(scenes.active.children, wx, wy)
		self.hoverObj = hoverObj

		if scenes.active.selection[1] then
			local hoverHandle = hitCheckHandles(self, mx, my, minDist)
			if hoverHandle then
				self.hoverObj = nil
				self.hoverHandle = hoverHandle
			end
			updateHandleHover(self)
		end

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
				self, scene, Class, {}, properties, isSelected, parentEnclosure
			}
			argsList[i] = args
		end
		scene.history:perform("addObjects", self, scene, argsList)
	else
		local properties = { pos = { { x = wx, y = wy }, Vec2Property } }
		scene.history:perform("addObject", self, scene, Class, {}, properties, isSelected, false)
	end
	updateHover(self)
end

function Tool.press(wgt, depth, mx, my, isKeyboard)
	if depth ~= 1 then  return  end
	if scenes.active and not isKeyboard then
		local self = wgt.object

		if scenes.active.selection[1] and Input.isPressed("force drag modifier") then
			local isRotate = modkeys.isPressed(self.rotateKey)
			local dragType = isRotate and "rotate selection" or "translate selection"
			startDrag(self, dragType)

		elseif Input.isPressed("add modifier") then
			local wx, wy = Camera.current:screenToWorld(mx, my)
			wgt.object:addAt(self.lastAddClass, wx, wy)

		elseif self.hoverObj then
			local shouldToggle = modkeys.isPressed("shift")
			local isSelected = self.hoverObj.isSelected
			local selection = scenes.active.selection
			local history = scenes.active.history

			if not isSelected then
				if shouldToggle then
					history:perform("addToSelection", self, selection, self.hoverObj.enclosure)
				else
					history:perform("setSelection", self, selection, { self.hoverObj.enclosure })
				end
			elseif isSelected and shouldToggle then
				history:perform("removeFromSelection", self, selection, self.hoverObj.enclosure)
			end
			if self.hoverObj.isSelected then
				local isRotate = modkeys.isPressed(self.rotateKey)
				local dragType = isRotate and "rotate selection" or "translate selection"
				startDrag(self, dragType)
			end
			updateAABB(self)

		elseif self.hoverHandle then
			startDrag(self, "handle transform")

		else -- Clicked on nothing.
			local selection = scenes.active.selection
			if selection[1] and modkeys.getString() == "" then
				scenes.active.history:perform("clearSelection", self, selection)
			end
			startDrag(self, "box select")
			self.originalSelection = selection:copyList() or {}
			updateAABB(self)
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

function Tool.onObjectsChanged(self, sender, signal)
	if sender == self then  return  end
	if not self.isDragging then
		updateHover(self)
	else
		updateAABB(self)
	end
end

function Tool.zoomUpdated(self)
	if not self.isDragging then
		updateAABB(self)
	else
		updateHandlePositions(self)
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
				scene.history:perform("deleteObjects", self, scene, enclosures)
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
	elseif action == "snap" then
		if wgt.object.isDragging and (change == 1 or change == -1) then
			wgt:drag(0, 0, wgt.object.lastDragType)
		end
	elseif action == "zero position" and change == 1 then
		local self, scene = wgt.object, scenes.active
		if scene.selection[1] then
			local enclosures = scene.selection:copyList()
			local pos = { x = 0, y = 0 }
			scene.history:perform("setSamePropertyOnMultiple", self, enclosures, "pos", pos)
			updateHover(self)
		end
	elseif action == "zero rotation" and change == 1 then
		local self, scene = wgt.object, scenes.active
		if scene.selection[1] then
			local enclosures = scene.selection:copyList()
			scene.history:perform("setSamePropertyOnMultiple", self, enclosures, "angle", 0)
			updateHover(self)
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
		local AABB = self.AABB
		local lt, top, rt, bot = AABB.lt, AABB.top, AABB.rt, AABB.bot
		lt, top = self:toLocal( Camera.current:worldToScreen(lt, top) )
		rt, bot = self:toLocal( Camera.current:worldToScreen(rt, bot) )

		local w, h = rt - lt, bot - top

		love.graphics.setColor(1, 1, 1, 0.1)
		love.graphics.rectangle("line", lt, top, w, h)

		for k,handle in pairs(self.handles) do
			handle:draw()
		end
	end
end

return Tool
