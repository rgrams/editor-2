
local PolygonTool = gui.Node:extend()
PolygonTool.className = "PolygonTool"

local scenes = require "scenes"
local config = require "config"
local modkeys = require "modkeys"
local signals = require "signals"
local polygonCmd = require "commands.polygon-commands"

PolygonTool.snapKey = "ctrl"
PolygonTool.snapToAxisKey = "shift"
PolygonTool.normalVertColor = { 0.5, 0.5, 0.5, 1 }

local vertNormalAlpha = 0.4
local vertHoverAlpha = 1.0
local vertNormalRadius = 6
local vertHoverRadius = 8
local vertHitRadius = 10

function PolygonTool.set(self, ruu)
	PolygonTool.super.set(self, 1, 1, "C", "C", "fill")
	self.layer = "viewport"
	self.ruu = ruu
	signals.subscribe(self, self.onSceneAdded, "scene added")
end

function PolygonTool.init(self)
	PolygonTool.super.init(self)
	self.widget = self.ruu:Panel(self)
	self.widget.drag = self.drag
	self.widget.press = self.press
	self.widget.release = self.release
	self.widget.ruuInput = self.ruuInput
end

function PolygonTool.onSceneAdded(self, sender, signal, scene)
	scene.isVertSelected = scene.isVertSelected or {}
end

local function stopDrag(self)
	self.isDragging = false
	self.startedDragCommand = false
	self.ruu:stopDraggingWidget(self.widget)
end

function PolygonTool.final(self)
	if self.isDragging then
		stopDrag(self)
	end
	self.ruu:destroy(self.widget)
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

local function hitCheckVertices(verts, x, y, r, minDist, closestIdx)
	minDist = minDist or math.huge
	for i=2,#verts,2 do
		local vx, vy = verts[i-1], verts[i]
		local dist = vec2.len(vx - x, vy - y)
		if dist <= r and dist < minDist then
			minDist = dist
			closestIdx = i/2
		end
	end
	return closestIdx, minDist
end

local function updateHover(self, mx, my)
	if self.hoverObj then
		self.hoverObj.isHovered = false
		self.hoverObj = nil
	end
	if scenes.active then
		if not (mx and my) then
			mx, my = love.mouse.getPosition()
		end
		local wx, wy = Camera.current:screenToWorld(mx, my)
		local hoverObj, minDist = hitCheckChildren(scenes.active.children, wx, wy)
		self.hoverObj = hoverObj

		self.hoverIdx = nil
		local enc1 = scenes.active.selection[1]
		if enc1 then
			local obj = enc1[1]
			local verts = obj.vertices
			if verts then
				local lx, ly = obj:toLocal(wx, wy)
				local hitR = vertHitRadius / Camera.current.zoom
				local closestIdx = hitCheckVertices(verts, lx, ly, hitR)
				if closestIdx then
					self.hoverIdx = closestIdx
					self.hoverObj = obj
				end
			end
		end

		if hoverObj then
			hoverObj.isHovered = true
		end
	end
end

local function getDragStartOffsets(self, mwx, mwy, obj, selectedVertMap)
	local startX, startY = self.dragStartX, self.dragStartY
	local offsets = {}
	for idx,_ in pairs(selectedVertMap) do
		local lx, ly = obj:getVertPos(idx)
		local wx, wy = obj:toWorld(lx, ly)
		local val = { i = idx, x = wx - startX, y = wy - startY }
		table.insert(offsets, val)
	end
	return offsets
end

local function getPosDragArgList(self, enclosure, startOffsets, totalDX, totalDY, roundX, roundY)
	local argList = {}
	local startX, startY = self.dragStartX, self.dragStartY
	for i,offset in ipairs(startOffsets) do
		local wx, wy = startX + offset.x + totalDX, startY + offset.y + totalDY
		wx, wy = math.round(wx, roundX), math.round(wy, roundY)
		local lx, ly = self.hoverObj:toLocal(wx, wy)
		table.insert(argList, { self, enclosure, offset.i, lx, ly })
	end
	return argList
end

function PolygonTool.drag(wgt, dx, dy, dragType)
	local self, scene = wgt.object, scenes.active

	local msx, msy = self.ruu.mx, self.ruu.my
	local mwx, mwy = Camera.current:screenToWorld(msx, msy)
	self.lastDragX, self.lastDragY = mwx, mwy

	if dragType == "translate vertex" then
		local totalWDX, totalWDY = mwx - self.dragStartX, mwy - self.dragStartY

		local snapIncr = config.roundAllPropsTo
		if modkeys.isPressed(self.snapKey) then
			snapIncr = config.translateSnapIncrement
		end
		local roundX, roundY = snapIncr, snapIncr
		if modkeys.isPressed(self.snapToAxisKey) then
			if math.abs(totalWDX) > math.abs(totalWDY) then
				totalWDY = 0
				roundY = config.roundAllPropsTo
			else
				totalWDX = 0
				roundX = config.roundAllPropsTo
			end
		end

		local enclosure = self.hoverObj.enclosure

		if not self.startedDragCommand then
			self.startedDragCommand = true
			local _x, _y = self.dragStartX, self.dragStartY
			local obj = self.hoverObj
			self.dragStartOffsets = getDragStartOffsets(self, _x, _y, obj, scene.isVertSelected)
			local argList = getPosDragArgList(self, enclosure, self.dragStartOffsets, totalWDX, totalWDY, roundX, roundY)
			scene.history:perform("setMultiVertexPos", self, argList)
		else
			local argList = getPosDragArgList(self, enclosure, self.dragStartOffsets, totalWDX, totalWDY, roundX, roundY)
			local doCmd = polygonCmd.setMultiVertexPos[1]
			doCmd(self, argList)
			scene.history:update(self, argList)
		end
	end
end

local function startDrag(self)
	self.isDragging = true
	self.ruu:startDrag(self.widget, "translate vertex")

	local wmx, wmy = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	self.lastDragX, self.lastDragY = wmx, wmy
	self.dragStartX, self.dragStartY = wmx, wmy
end

local function clearVertSelection(selection)
	for k,v in pairs(selection) do
		selection[k] = nil
	end
end

function PolygonTool.press(wgt, depth, mx, my, isKeyboard)
	local self, scene = wgt.object, scenes.active
	if scene then
		local enclosure = scene.selection[1]
		if enclosure and enclosure[1].vertices then
			if Input.isPressed("add modifier") then
				local wx, wy = Camera.current:screenToWorld(mx, my)
				local obj = enclosure[1]
				local lx, ly = obj:toLocal(wx, wy)
				scene.history:perform("addVertex", self, enclosure, lx, ly)
				updateHover(self, mx, my)
			end
		end

		if self.hoverObj then
			if self.hoverIdx then -- Clicked on vertex.
				local shouldToggle = modkeys.isPressed("shift")
				local isSelected = scene.isVertSelected[self.hoverIdx]
				if not isSelected then
					if shouldToggle then                 -- Add to selection.
						scene.isVertSelected[self.hoverIdx] = true
					else                                 -- Set selection.
						clearVertSelection(scene.isVertSelected)
						scene.isVertSelected[self.hoverIdx] = true
					end
				elseif isSelected and shouldToggle then -- Remove from selection.
					scene.isVertSelected[self.hoverIdx] = nil
				end

				if next(scene.isVertSelected) then
					startDrag(self)
					local vx, vy = self.hoverObj:getVertPos(self.hoverIdx)
					local wvx, wvy = self.hoverObj:toWorld(vx, vy)
					self.dragOX, self.dragOY = wvx - self.dragStartX, wvy - self.dragStartY
				end
			else -- Clicked on object but not vertex.
				local enclosure = self.hoverObj.enclosure
				scene.history:perform("setSelection", self, scene.selection, { enclosure })
			end
		else -- Clicked on nothing.
			if next(scene.isVertSelected) then
				clearVertSelection(scene.isVertSelected)
			else
				scene.history:perform("clearSelection", self, scene.selection)
			end
		end
	end
end

function PolygonTool.release(wgt, depth, dontFire, mx, my, isKeyboard)
	if wgt.object.isDragging then
		stopDrag(wgt.object)
	end
end

function PolygonTool.onObjectsChanged(self, sender, signal)
end

function PolygonTool.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat, x, y, dx, dy, isTouch, presses)
	if action == wgt.ruu.MOUSE_MOVED then
		local self = wgt.object
		if not self.isDragging then
			updateHover(self, x, y)
		end
	elseif action == "delete" and change == 1 then
		local scene = scenes.active
		if scene and next(scene.isVertSelected) then
			local enclosure = scene.selection[1]
			if enclosure and enclosure[1].vertices then
				local indicesToDelete = {}
				for idx,_ in pairs(scene.isVertSelected) do
					table.insert(indicesToDelete, idx)
					scene.isVertSelected[idx] = nil
				end
				local self = wgt.object
				scene.history:perform("deleteMultiVertex", self, enclosure, indicesToDelete)
			end
		end
	end
end

function PolygonTool.draw(self)
	if scenes.active and scenes.active.selection[1] then
		local selection = scenes.active.selection
		local enclosure = selection[1]
		local obj = enclosure[1]
		local verts = obj.vertices
		if verts then
			love.graphics.setLineStyle("smooth")
			local isVertSelected = scenes.active.isVertSelected
			local normalColor = self.normalVertColor
			local selectColor = config.selectedHighlightColor
			for i=2,#verts,2 do
				local isHovered = self.hoverIdx and self.hoverIdx == i/2
				local alpha = isHovered and vertHoverAlpha or vertNormalAlpha
				local r = isHovered and vertHoverRadius or vertNormalRadius
				local x, y = verts[i-1], verts[i]
				x, y = Camera.current:worldToScreen(obj:toWorld(x, y))
				x, y = x - self._to_world.x, y - self._to_world.y
				local color = isVertSelected[i/2] and selectColor or normalColor
				love.graphics.setColor(color[1], color[2], color[3], alpha)
				love.graphics.circle("fill", x, y, r, 16)
				love.graphics.setColor(color)
				love.graphics.circle("line", x, y, r, 16)
			end
			love.graphics.setLineStyle("rough")
		end
	end
end

function PolygonTool.zoomUpdated(self)
end

return PolygonTool
