
local EditorObject = Object:extend()
EditorObject.className = "EditorObject"

local config = require "config"

EditorObject.displayName = "Object"
EditorObject.hitRadius = 16

local Position = require "objects.properties.Position"
local Angle = require "objects.properties.Angle"
local Scale = require "objects.properties.Scale"
local Skew = require "objects.properties.Skew"

function EditorObject.set(self, x, y, angle, ...)
	EditorObject.super.set(self, x, y, angle, ...)
	self.enclosure = { self } -- TODO: Placeholder. Should be in `addObject` command.
	self.isSelected = false
	self.isHovered = false
	self.properties = {
		Position(self),
		Angle(self),
		Scale(self),
		Skew(self),
	}
	self.AABB = {}
end

function EditorObject.init(self)
	self:updateTransform()
	self:updateAABB()
end

function EditorObject.updateAABB(self)
	local r = self.hitRadius
	local angle, sx, sy, kx, ky = matrix.parameters(self._to_world)
	local AABB = self.AABB

	if kx ~= 0 or ky ~= 0 then
		-- Need to do full transform of all 4 corners.
		local x1, y1 = self:toWorld(-r, -r)
		local x2, y2 = self:toWorld(r, -r)
		local x3, y3 = self:toWorld(r, r)
		local x4, y4 = self:toWorld(-r, r)
		local left = math.min(x1, x2, x3, x4)
		local top = math.min(y1, y2, y3, y4)
		local right = math.max(x1, x2, x3, x4)
		local bottom = math.max(y1, y2, y3, y4)
		AABB.w = right - left
		AABB.h = bottom - top
		AABB.lt, AABB.top, AABB.rt, AABB.bot = left, top, right, bottom
	elseif angle ~= 0 then
		-- Just need to rotate and scale.
		local hw, hh = r*sx, r*sy
		local x, y = self._to_world.x, self._to_world.y
		local x1, y1 = vec2.rotate(-hw, -hh, angle)
		local x2, y2 = vec2.rotate(hw, -hh, angle)
		local x3, y3 = vec2.rotate(hw, hh, angle)
		local x4, y4 = vec2.rotate(-hw, hh, angle)
		x1, y1 = x + x1, y + y1
		x2, y2 = x + x2, y + y2
		x3, y3 = x + x3, y + y3
		x4, y4 = x + x4, y + y4
		local left = math.min(x1, x2, x3, x4)
		local top = math.min(y1, y2, y3, y4)
		local right = math.max(x1, x2, x3, x4)
		local bottom = math.max(y1, y2, y3, y4)
		AABB.w = right - left
		AABB.h = bottom - top
		AABB.lt, AABB.top, AABB.rt, AABB.bot = left, top, right, bottom
	else
		-- Just need to scale.
		local hw, hh = r*sx, r*sy
		local x, y = self._to_world.x, self._to_world.y
		AABB.w, AABB.h = hw*2, hh*2
		AABB.lt, AABB.top, AABB.rt, AABB.bot = x - hw, y - hh, x + hw, y + hh
	end
end

function EditorObject.setProperty(self, name, ...)
	local props = self.properties
	for i,prop in ipairs(props) do
		if prop.name == name then
			prop:setValue(...)
			return true
		end
	end
	return false
end

function EditorObject.setPosition(self, pos)
	self.pos = pos
	if self.parent then  self:updateTransform()  end
	self:updateAABB()
end

function EditorObject.setAngle(self, angle)
	self.angle = angle
	if self.parent then  self:updateTransform()  end
	self:updateAABB()
end

function EditorObject.setScale(self, sx, sy)
	self.sx, self.sy = sx, sy
	if self.parent then  self:updateTransform()  end
	self:updateAABB()
end

function EditorObject.setSkew(self, kx, ky)
	self.kx, self.ky = kx, ky
	if self.parent then  self:updateTransform()  end
	self:updateAABB()
end

function EditorObject.getProperty(self, name)
	for i,prop in ipairs(self.properties) do
		if prop.name == name then
			return prop:getValue()
		end
	end
end

function EditorObject.getModifiedProperties(self)
	local properties
	for i,prop in ipairs(self.properties) do
		local values = { prop:getDiff() }
		if values[1] then
			properties = properties or {}
			properties[prop.name] = values
		end
	end
	return properties
end

function EditorObject.touchesPoint(self, wx, wy)
	local lx, ly = self:toLocal(wx, wy)
	local r = self.hitRadius
	if lx >= -r and lx <= r and ly >= -r and ly <= r then
		return vec2.len2(lx, ly)
	end
end

function EditorObject.draw(self)
	love.graphics.setBlendMode("alpha")
	local lineWidth = 1
	local r = self.hitRadius - lineWidth/2

	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.03)
		love.graphics.rectangle("fill", -r, -r, r*2, r*2)
	end

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, r, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -r)
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.rectangle("line", -r, -r, r*2, r*2)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	local children = self.children
	if children then
		for i=1,children.maxn or #children do
			local child = children[i]
			if child then
				love.graphics.setColor(config.parentLineColor)
				local frac = config.parentLineLenFrac
				local x, y = child.pos.x*frac, child.pos.y*frac
				love.graphics.line(0, 0, x, y)
				local vx, vy = vec2.normalize(x, y)
				local arrowLen = config.parentLineArrowLength
				local arrowAngle = config.parentLineArrowAngle
				vx, vy = -vx*arrowLen, -vy*arrowLen
				local x2, y2 = vec2.rotate(vx, vy, arrowAngle)
				local x3, y3 = vec2.rotate(vx, vy, -arrowAngle)
				love.graphics.line(x2+x, y2+y, x, y, x3+x, y3+y)
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

local function drawSkewedRectangle(self, mode, pad, sx, sy, cam)
	-- Get the skewed screen vectors for up and right in object-space.
	-- Then normalize and scale them by `pad` in screen space.
	-- (Screen-space is the same as world-space here except for translation - no rotation on camera.)
	local wx, wy = self._to_world.x, self._to_world.y
	local upX, upY = self:toWorld(0, 1)
	upX, upY = vec2.normalize(upX - wx, upY - wy)
	local rtX, rtY = self:toWorld(1, 0)
	rtX, rtY = vec2.normalize(rtX - wx, rtY - wy)
	upX, upY, rtX, rtY = upX*pad, upY*pad, rtX*pad, rtY*pad

	local r = self.hitRadius
	local x1, y1 = cam:worldToScreen( self:toWorld(-r, -r) )
	local x2, y2 = cam:worldToScreen( self:toWorld(r, -r) )
	local x3, y3 = cam:worldToScreen( self:toWorld(r, r) )
	local x4, y4 = cam:worldToScreen( self:toWorld(-r, r) )
	x1, y1 = x1 - rtX - upX, y1 - rtY - upY
	x2, y2 = x2 + rtX - upX, y2 + rtY - upY
	x3, y3 = x3 + rtX + upX, y3 + rtY + upY
	x4, y4 = x4 - rtX + upX, y4 - rtY + upY
	love.graphics.line(x1, y1, x2, y2, x3, y3, x4, y4, x1, y1)
end

-- In node-space, not self-space.
function EditorObject.drawSelectionHighlight(self, node)

	love.graphics.push()
	love.graphics.translate(-node._to_world.x, -node._to_world.y)

	love.graphics.setColor(config.selectedHighlightColor)
	love.graphics.setLineWidth(config.highlightLineWidth)

	local angle, sx, sy, kx, ky = matrix.parameters(self._to_world)

	local pad = config.highlightPadding

	if kx ~= 0 or ky ~= 0 then
		drawSkewedRectangle(self, "line", pad, sx, sy, Camera.current)
	else
		local r = self.hitRadius * Camera.current.zoom
		local objX, objY = self:toWorld(0, 0)
		local scrnX, scrnY = Camera.current:worldToScreen(objX, objY)
		local lx, ly = scrnX, scrnY

		local hw, hh = r*sx + pad, r*sy + pad
		local x, y = lx - hw, ly - hh

		if angle ~= 0 then
			drawRotatedRectangle("line", x, y, hw*2, hh*2, angle)
		else
			love.graphics.rectangle("line", x, y, hw*2, hh*2)
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.pop()
end

return EditorObject
