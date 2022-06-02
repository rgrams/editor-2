
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorCircle = EditorObject:extend()
EditorCircle.className = "EditorCircle"
EditorCircle.displayName = "Circle"

local config = require "config"

_G.objClassList:add(EditorCircle, EditorCircle.displayName)

EditorCircle.radius = 16
EditorCircle.hitWidth = EditorCircle.radius*2
EditorCircle.hitHeight = EditorCircle.radius*2
EditorCircle.segments = 24
EditorCircle.lineWidth = 1
EditorCircle.isFilled = true

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local Color = require "objects.properties.Color"

EditorCircle.isBuiltinProperty = {
	pos = true,
	angle = true,
	radius = true,
	segments = true,
	lineWidth = true,
	filled = true,
	color = true,
}

function EditorCircle.set(self)
	EditorCircle.super.set(self)
	self.color = { 1, 1, 1, 1 }
end

function EditorCircle.initProperties(self)
	self:addProperty(Vec2, "pos")
	self:addProperty(Float, "angle")
	self:addProperty(Float, "radius", self.radius, true)
	self:addProperty(Float, "segments", self.segments, true)
	self:addProperty(Float, "lineWidth", 1, true)
	self:addProperty(Bool, "filled", self.isFilled, true)
	self:addProperty(Color, "color")
end

function EditorCircle.propertyWasSet(self, name, value, property)
	EditorCircle.super.propertyWasSet(self, name, value, property)
	if name == "radius" then
		self.radius = value
		self.hitWidth, self.hitHeight = value*2, value*2
		self:updateAABB()
	elseif name == "segments" then
		self.segments = value
	elseif name == "lineWidth" then
		self.lineWidth = value
	elseif name == "filled" then
		self.isFilled = value
	elseif name == "color" then
		self.color = property:getValue()
	end
end

function EditorCircle.getSizePropertyObj(self)
	return self:getPropertyObj("radius")
end

function EditorCircle.draw(self)
	love.graphics.setLineStyle("smooth")

	local r = self.radius

	love.graphics.push()
	love.graphics.rotate(-math.pi/2) -- Orient low-poly circles pointing up.

	love.graphics.setLineWidth(self.lineWidth)
	love.graphics.setColor(self.color)
	do
		local r = r
		if not self.isFilled then  r = r - self.lineWidth/2  end -- Lines are -inside- radius.
		love.graphics.circle(self.isFilled and "fill" or "line", 0, 0, r, self.segments)
	end
	love.graphics.setLineWidth(1)

	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.03)
		love.graphics.circle("fill", 0, 0, r, self.segments)
	end
	love.graphics.pop()

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, r, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -r)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	EditorCircle.super.drawParentChildLines(self)

	love.graphics.setLineStyle("rough")
end

return EditorCircle
