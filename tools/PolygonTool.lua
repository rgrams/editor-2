
local PolygonTool = gui.Node:extend()
PolygonTool.className = "PolygonTool"

local scenes = require "scenes"
local config = require "config"
local modkeys = require "modkeys"
local signals = require "signals"
local polygonCmd = require "commands.polygon-commands"
local list = require "lib.list"
local pointHitsLine = require "lib.pointHitsLine"

PolygonTool.snapKey = "ctrl"
PolygonTool.snapToAxisKey = "shift"
PolygonTool.normalVertColor = { 0.5, 0.5, 0.5, 1 }
PolygonTool.boxSelectAddChord = "shift "
PolygonTool.boxSelectToggleChord = "ctrl "
PolygonTool.boxSelectSubtractChord = "alt "

local vertNormalAlpha = 0.4
local vertHoverAlpha = 1.0
local vertNormalRadius = 6
local vertHoverRadius = 8
local vertHitRadius = 10
local segmentHitRadius = 8
local segmentIntersectionRadius = 6
local segmentIntersectColor = PolygonTool.normalVertColor

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
	self.isBoxSelecting = false
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

local function hitCheckVertices(verts, x, y, r, minDist)
	minDist = minDist or math.huge
	local closestIdx
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

local function hitCheckSegments(verts, x, y, r, isLoop, minDist)
	minDist = minDist or math.huge
	local closestIdx, hitX, hitY
	local len = #verts
	for i=2,len,2 do
		local x1, y1, x2, y2
		if i == len then
			if not isLoop then  break
			else  x2, y2 = verts[1], verts[2]  end
		else
			x2, y2 = verts[i+1], verts[i+2]
		end
		x1, y1 = verts[i-1], verts[i]
		local dist, _hitX, _hitY = pointHitsLine(x, y, x1, y1, x2, y2, r)
		if dist and dist < minDist then
			minDist = dist
			closestIdx, hitX, hitY = i/2, _hitX, _hitY
		end
	end
	return closestIdx, minDist, hitX, hitY
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
		self.hoverSegIdx = nil
		local enc1 = scenes.active.selection[1]
		if enc1 then
			local obj = enc1[1]
			local verts = obj:getProperty("vertices")
			if verts then
				local lx, ly = obj:toLocal(wx, wy)
				local hitR = vertHitRadius / Camera.current.zoom
				local closestIdx = hitCheckVertices(verts, lx, ly, hitR)
				if closestIdx then
					self.hoverIdx = closestIdx
					self.hoverObj = obj
				else
					local r = segmentHitRadius / Camera.current.zoom
					local isLoop = obj:getProperty("isLoop")
					local segIdx, dist, hitX, hitY = hitCheckSegments(verts, lx, ly, r, isLoop)
					if segIdx then
						self.hoverSegIdx = segIdx
						self.intersectX, self.intersectY = hitX, hitY
					end
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

local function getBoxSelectMode(self)
	local curModChord = modkeys.getString()
	local mode = "set"
	if     curModChord == self.boxSelectAddChord      then  mode = "add"
	elseif curModChord == self.boxSelectToggleChord   then  mode = "toggle"
	elseif curModChord == self.boxSelectSubtractChord then  mode = "subtract"
	end
	return mode
end

local function getVertsInBox(verts, lt, top, rt, bot)
	local hitIndices = {}
	local vertCount = #verts/2
	for i=1,vertCount do
		local iy = i*2
		local x, y = verts[iy-1], verts[iy]
		if x >= lt and x <= rt and y >= top and y <= bot then
			table.insert(hitIndices, i)
		end
	end
	return hitIndices
end

local function clearVertSelection(selection)
	for k,v in pairs(selection) do
		selection[k] = nil
	end
end

function PolygonTool.drag(wgt, dx, dy, dragType)
	local self, scene = wgt.object, scenes.active

	local msx, msy = self.ruu.mx, self.ruu.my
	local mwx, mwy = Camera.current:screenToWorld(msx, msy)
	self.lastDragX, self.lastDragY = mwx, mwy

	if dragType == "translate vertex" then
		if not self.hoverObj then  return  end

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

	elseif dragType == "box select" then
		self.isBoxSelecting = true

		local enclosure = scene.selection[1]
		if not enclosure or not enclosure[1]:hasProperty("vertices") then
			return
		end

		local obj = enclosure[1]
		local verts = obj:getProperty("vertices")
		local lt, top = math.min(mwx, self.dragStartX), math.min(mwy, self.dragStartY)
		local rt, bot = math.max(mwx, self.dragStartX), math.max(mwy, self.dragStartY)
		lt, top = obj:toLocal(lt, top)
		rt, bot = obj:toLocal(rt, bot)
		local hitIndices = getVertsInBox(verts, lt, top, rt, bot)
		local mode = getBoxSelectMode(self)
		local origSelection = self.originalSelection
		local newSelection
		if mode == "set" then
			newSelection = hitIndices
		elseif mode == "add" then
			newSelection = list.getUnion(origSelection, hitIndices)
		elseif mode == "toggle" then
			newSelection = list.getDifference(origSelection, hitIndices)
		elseif mode == "subtract" then
			newSelection = list.getSubtraction(origSelection, hitIndices)
		end

		clearVertSelection(scene.isVertSelected)
		for i,idx in ipairs(newSelection) do
			scene.isVertSelected[idx] = true
		end
	end
end

local function startDrag(self, dragType)
	self.isDragging = true
	self.ruu:startDrag(self.widget, dragType)

	local wmx, wmy = Camera.current:screenToWorld(self.ruu.mx, self.ruu.my)
	self.lastDragX, self.lastDragY = wmx, wmy
	self.dragStartX, self.dragStartY = wmx, wmy
end

local function getSelectedVertList(isSelected)
	local indices = {}
	for idx,_ in pairs(isSelected) do
		table.insert(indices, idx)
	end
	return indices
end

function PolygonTool.press(wgt, depth, mx, my, isKeyboard)
	local self, scene = wgt.object, scenes.active
	if scene then
		local enclosure = scene.selection[1]
		if enclosure and enclosure[1]:hasProperty("vertices") then
			if Input.isPressed("add modifier") then
				if self.hoverSegIdx then
					local lx, ly = self.intersectX, self.intersectY
					local vi = self.hoverSegIdx + 1
					scene.history:perform("insertVertex", self, enclosure, vi, lx, ly)
				else
					local wx, wy = Camera.current:screenToWorld(mx, my)
					local obj = enclosure[1]
					local lx, ly = obj:toLocal(wx, wy)
					scene.history:perform("addVertex", self, enclosure, lx, ly)
				end
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
					startDrag(self, "translate vertex")
					local vx, vy = self.hoverObj:getVertPos(self.hoverIdx)
					local wvx, wvy = self.hoverObj:toWorld(vx, vy)
					self.dragOX, self.dragOY = wvx - self.dragStartX, wvy - self.dragStartY
				end
			else -- Clicked on object but not vertex.
				clearVertSelection(scene.isVertSelected)
				local enclosure = self.hoverObj.enclosure
				scene.history:perform("setSelection", self, scene.selection, { enclosure })
			end
		else -- Clicked on nothing.
			if modkeys.getString() == "" and next(scene.isVertSelected) then
				clearVertSelection(scene.isVertSelected)
			end
			startDrag(self, "box select")
			self.originalSelection = getSelectedVertList(scene.isVertSelected)
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
			if enclosure and enclosure[1]:hasProperty("vertices") then
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

-- Convert an obj-local vertex position to a Tool/Viewport-local position for drawing.
local function vertPosToViewPos(self, obj, x, y)
	x, y = Camera.current:worldToScreen(obj:toWorld(x, y))
	return x - self._to_world.x, y - self._to_world.y
end

function PolygonTool.draw(self)
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

	if scenes.active and scenes.active.selection[1] then
		local selection = scenes.active.selection
		local enclosure = selection[1]
		local obj = enclosure[1]
		local verts = obj:getProperty("vertices")
		if verts then
			love.graphics.setLineStyle("smooth")
			local isVertSelected = scenes.active.isVertSelected
			local normalColor = self.normalVertColor
			local selectColor = config.selectedHighlightColor
			local hoverSegIdx = self.hoverSegIdx

			for i=2,#verts,2 do
				local vertIdx = i/2
				local isHovered = self.hoverIdx and self.hoverIdx == vertIdx
				local alpha = isHovered and vertHoverAlpha or vertNormalAlpha
				local r = isHovered and vertHoverRadius or vertNormalRadius
				local x, y = vertPosToViewPos(self, obj, verts[i-1], verts[i])

				if hoverSegIdx and hoverSegIdx == vertIdx then
					local hitX, hitY = self.intersectX, self.intersectY
					hitX, hitY = vertPosToViewPos(self, obj, hitX, hitY)
					love.graphics.setColor(segmentIntersectColor)
					love.graphics.circle("line", hitX, hitY, segmentIntersectionRadius, 16)
				end

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
