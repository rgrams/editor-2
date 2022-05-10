
local EditorObject = Object:extend()
EditorObject.className = "EditorObject"

local config = require "config"

EditorObject.displayName = "Object"
EditorObject.hitWidth = 32
EditorObject.hitHeight = 32

_G.objClassList:add(EditorObject, EditorObject.displayName)

local Position = require "objects.properties.Position"
local Angle = require "objects.properties.Angle"
local Scale = require "objects.properties.Scale"
local Skew = require "objects.properties.Skew"

function EditorObject.set(self, x, y, angle, ...)
	EditorObject.super.set(self, x, y, angle, ...)
	self.enclosure = { self } -- TODO: Placeholder. Should be in `addObject` command.
	self.isSelected = false
	self.isHovered = false
	self.AABB = {}
	self.properties = {}
	self.propertyMap = {}
	self:addProperty(Position)
	self:addProperty(Angle)
	self:addProperty(Scale)
	self:addProperty(Skew)
end

function EditorObject.init(self)
	self:updateAABB()
end

function EditorObject.addProperty(self, Class, name, value)
	assert(Class, "EditorObject.addProperty - No class given for property: '"..tostring(name).."', value: '"..tostring(value).."'.")
	local property = Class(self, name)
	name = property.name
	if value ~= nil then
		property:setValue(value)
	end
	self.propertyMap[name] = property
	table.insert(self.properties, property)
	return name
end

function EditorObject.removeProperty(self, name)
	if self:getPropertyObj(name) then
		self.propertyMap[name] = nil
		for i,property in ipairs(self.properties) do
			if property.name == name then
				table.remove(self.properties, i)
				return true
			end
		end
	end
end

function EditorObject.setProperty(self, name, value)
	local property = self:getPropertyObj(name)
	if property then
		property:setValue(value)
		return true
	else
		return false
	end
end

function EditorObject.getPropertyObj(self, name)
	return self.propertyMap[name]
end

function EditorObject.hasProperty(self, name)
	return not not self.propertyMap[name]
end

function EditorObject.getProperty(self, name)
	local property = self:getPropertyObj(name)
	if property then
		return property:getValue()
	end
end

function EditorObject.getModifiedProperties(self)
	local properties
	for i,property in ipairs(self.properties) do
		local value = property:getDiff()
		if value then
			properties = properties or {}
			local Class = getmetatable(property)
			properties[property.name] = { value, Class }
		end
	end
	return properties
end

function EditorObject.setPosition(self, pos)
	self.pos = pos
	self:updateAABB()
end

function EditorObject.setAngle(self, angle)
	self.angle = angle
	self:updateAABB()
end

function EditorObject.setScale(self, sx, sy)
	self.sx, self.sy = sx, sy
	self:updateAABB()
end

function EditorObject.setSkew(self, kx, ky)
	self.kx, self.ky = kx, ky
	self:updateAABB()
end

function EditorObject.touchesPoint(self, wx, wy)
	local lx, ly = self:toLocal(wx, wy)
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	if lx >= -hw and lx <= hw and ly >= -hh and ly <= hh then
		return vec2.len2(lx, ly)
	end
end

function EditorObject.draw(self)
	love.graphics.setBlendMode("alpha")
	local lineWidth = 1
	local hw, hh = self.hitWidth/2 - lineWidth/2, self.hitHeight/2 - lineWidth/2

	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.03)
		love.graphics.rectangle("fill", -hw, -hh, hw*2, hh*2)
	end

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.rectangle("line", -hw, -hh, hw*2, hh*2)
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

function EditorObject.updateAABB(self)
	if self.parent then  self:updateTransform()  end
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	local angle, sx, sy, kx, ky = matrix.parameters(self._to_world)
	local AABB = self.AABB

	if kx ~= 0 or ky ~= 0 then
		-- Need to do full transform of all 4 corners.
		local x1, y1 = self:toWorld(-hw, -hh)
		local x2, y2 = self:toWorld(hw, -hh)
		local x3, y3 = self:toWorld(hw, hh)
		local x4, y4 = self:toWorld(-hw, hh)
		local left = math.min(x1, x2, x3, x4)
		local top = math.min(y1, y2, y3, y4)
		local right = math.max(x1, x2, x3, x4)
		local bottom = math.max(y1, y2, y3, y4)
		AABB.w = right - left
		AABB.h = bottom - top
		AABB.lt, AABB.top, AABB.rt, AABB.bot = left, top, right, bottom
	elseif angle ~= 0 then
		-- Just need to rotate and scale.
		local _hw, _hh = hw*sx, hh*sy
		local x, y = self._to_world.x, self._to_world.y
		local x1, y1 = vec2.rotate(-_hw, -_hh, angle)
		local x2, y2 = vec2.rotate(_hw, -_hh, angle)
		local x3, y3 = vec2.rotate(_hw, _hh, angle)
		local x4, y4 = vec2.rotate(-_hw, _hh, angle)
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
		local _hw, _hh = hw*sx, hh*sy
		local x, y = self._to_world.x, self._to_world.y
		AABB.w, AABB.h = _hw*2, _hh*2
		AABB.lt, AABB.top, AABB.rt, AABB.bot = x - _hw, y - _hh, x + _hw, y + _hh
	end

	if self.children then
		for i=1,self.children.maxn do
			local child = self.children[i]
			if child then
				child:updateAABB()
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

	local hw, hh = self.hitWidth/2, self.hitHeight/2
	local x1, y1 = cam:worldToScreen( self:toWorld(-hw, -hh) )
	local x2, y2 = cam:worldToScreen( self:toWorld(hw, -hh) )
	local x3, y3 = cam:worldToScreen( self:toWorld(hw, hh) )
	local x4, y4 = cam:worldToScreen( self:toWorld(-hw, hh) )
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
		local zoom = Camera.current.zoom
		local hw, hh = self.hitWidth/2 * zoom, self.hitHeight/2 * zoom
		local objX, objY = self:toWorld(0, 0)
		local scrnX, scrnY = Camera.current:worldToScreen(objX, objY)
		local lx, ly = scrnX, scrnY

		hw, hh = hw*sx + pad, hh*sy + pad
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
