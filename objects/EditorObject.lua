
local EditorObject = Object:extend()
EditorObject.className = "EditorObject"

local config = require "config"

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
	return lx >= -r and lx <= r and ly >= -r and ly <= r
end

function EditorObject.draw(self)
	love.graphics.setBlendMode("alpha")
	local r = self.hitRadius

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

local function drawSkewedRectangle() -- TODO
	--[[
	local dx, dy = math.cos(angle), math.sin(angle)
	local pdx, pdy = -dy, dx
	local wx, wy = hw*dx, hw*dy
	local hx, hy = hh*pdx, hh*pdy
	local x1, y1 = lx - wx - hx, ly - wy - hy
	local x2, y2 = lx + wx - hx, ly + wy - hy
	local x3, y3 = lx + wx + hx, ly + wy + hy
	local x4, y4 = lx - wx + hx, ly - wy + hy
	love.graphics.line(x1, y1, x2, y2, x3, y3, x4, y4, x1, y1)
	--]]
end

-- In node-space, not self-space.
function EditorObject.drawSelectionHighlight(self, node)
	love.graphics.setLineWidth(config.highlightLineWidth)

	local scrnX, scrnY = Camera.current:worldToScreen(self.pos.x, self.pos.y)
	local lx, ly = node:toLocal(scrnX, scrnY)
	local angle, sx, sy, kx, ky = matrix.parameters(self._to_world)

	love.graphics.setColor(config.selectedHighlightColor)
	local objLineWidth = 1
	local r = (self.hitRadius + objLineWidth/2) * Camera.current.zoom
	local pad = config.highlightPadding
	local hw, hh = r*sx + pad, r*sy + pad
	local x, y = lx - hw, ly - hh

	if angle ~= 0 then
		drawRotatedRectangle("line", x, y, hw*2, hh*2, angle)
	else
		love.graphics.rectangle("line", x, y, hw*2, hh*2)
	end

	love.graphics.setLineWidth(1)
end

return EditorObject
