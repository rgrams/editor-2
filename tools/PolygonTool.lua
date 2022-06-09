
local PolygonTool = gui.Node:extend()
PolygonTool.className = "PolygonTool"

local scenes = require "scenes"
local config = require "config"
local modkeys = require "modkeys"

PolygonTool.snapKey = "ctrl"
PolygonTool.snapToAxisKey = "shift"

function PolygonTool.set(self, ruu)
	PolygonTool.super.set(self, 1, 1, "C", "C", "fill")
	self.layer = "viewport"
	self.ruu = ruu
end

function PolygonTool.init(self)
	PolygonTool.super.init(self)
	self.widget = self.ruu:Panel(self)
	self.widget.drag = self.drag
	self.widget.press = self.press
	self.widget.release = self.release
	self.widget.ruuInput = self.ruuInput
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
				local closestIdx = hitCheckVertices(verts, lx, ly, 10)
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

		local vi = self.hoverIdx
		local enclosure = self.hoverObj.enclosure
		local wx = self.dragStartX + totalWDX + self.dragOX
		local wy = self.dragStartY + totalWDY + self.dragOY
		wx, wy = math.round(wx, roundX), math.round(wy, roundY)
		local lx, ly = self.hoverObj:toLocal(wx, wy)
		if self.startedDragCommand then
			self.hoverObj:setVertPos(vi, lx, ly)
			scene.history:update(self, enclosure, vi, lx, ly)
		else
			self.startedDragCommand = true
			scene.history:perform("setVertexPos", self, enclosure, vi, lx, ly)
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
				return
			end
		end

		if self.hoverObj then
			if self.hoverIdx then -- Clicked on vertex.
				startDrag(self)
				local vx, vy = self.hoverObj:getVertPos(self.hoverIdx)
				local wvx, wvy = self.hoverObj:toWorld(vx, vy)
				self.dragOX, self.dragOY = wvx - self.dragStartX, wvy - self.dragStartY
			else -- Clicked on object but not vertex.
				local enclosure = self.hoverObj.enclosure
				scene.history:perform("setSelection", self, scene.selection, { enclosure })
			end
		else -- Clicked on nothing.
			scene.history:perform("clearSelection", self, scene.selection)
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
	end
end

function PolygonTool.draw(self)
	if scenes.active and scenes.active.selection[1] then
		local selection = scenes.active.selection
		local enclosure = selection[1]
		local obj = enclosure[1]
		local verts = obj.vertices
		if verts then
			love.graphics.setColor(0.2, 0.75, 1, 1)
			for i=2,#verts,2 do
				local isHovered = self.hoverIdx and self.hoverIdx == i/2
				local x, y = verts[i-1], verts[i]
				x, y = Camera.current:worldToScreen(obj:toWorld(x, y))
				x, y = x - self._to_world.x, y - self._to_world.y
				if isHovered then  love.graphics.setColor(0.5, 1, 1, 1)  end
				love.graphics.circle("fill", x, y, 5, 8)
				if isHovered then  love.graphics.setColor(0.2, 0.75, 1, 1)  end
			end
		end
	end
end

function PolygonTool.zoomUpdated(self)
end

return PolygonTool
