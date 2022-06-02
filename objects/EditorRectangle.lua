
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorRectangle = EditorObject:extend()
EditorRectangle.className = "EditorRectangle"
EditorRectangle.displayName = "Rectangle"

local config = require "config"

EditorRectangle.lineWidth = 1
EditorRectangle.isFilled = true

EditorRectangle.rx = 0
EditorRectangle.ry = 0
EditorRectangle.roundSegments = 2

_G.objClassList:add(EditorRectangle, EditorRectangle.displayName)

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local Color = require "objects.properties.Color"

EditorRectangle.isBuiltinProperty = {
	pos = true,
	angle = true,
	size = true,
	lineWidth = true,
	filled = true,
	color = true,
	roundX = true,
	roundY = true,
	roundSegments = true,
}

function EditorRectangle.set(self)
	EditorRectangle.super.set(self)
	self.color = { 1, 1, 1, 1 }
end

function EditorRectangle.initProperties(self)
	self:addProperty(Vec2, "pos")
	self:addProperty(Float, "angle")
	self:addProperty(Vec2, "size", { x = self.hitWidth, y = self.hitHeight })
	self:addProperty(Float, "lineWidth", 1)
	self:addProperty(Bool, "filled", self.isFilled)
	self:addProperty(Color, "color")
	self:addProperty(Float, "roundX", 0)
	self:addProperty(Float, "roundY", 0)
	self:addProperty(Float, "roundSegments", 2)
end

function EditorRectangle.propertyWasSet(self, name, value, property)
	EditorRectangle.super.propertyWasSet(self, name, value, property)
	if name == "size" then
		local size = property:getValue()
		self.hitWidth, self.hitHeight = size.x, size.y
		self:updateAABB()
	elseif name == "lineWidth" then
		self.lineWidth = value
	elseif name == "filled" then
		self.isFilled = value
	elseif name == "color" then
		self.color = property:getValue()
	elseif name == "roundX" then
		self.rx = value
	elseif name == "roundY" then
		self.ry = value
	elseif name == "roundSegments" then
		self.rSegments = value
	end
end

function EditorRectangle.getSizePropertyObj(self)
	return self:getPropertyObj("size")
end

function EditorRectangle.draw(self)
	love.graphics.setBlendMode("alpha")
	love.graphics.setLineStyle("smooth")
	local hw, hh = self.hitWidth/2, self.hitHeight/2

	love.graphics.setLineWidth(self.lineWidth)
	love.graphics.setColor(self.color)
	local rx, ry, seg = self.rx, self.ry, self.rSegments
	do
		local hw, hh = hw, hh
		if not self.isFilled then
			hw, hh = hw - self.lineWidth/2, hh - self.lineWidth/2 -- Lines are -inside- bounds.
		end
		love.graphics.rectangle(self.isFilled and "fill" or "line", -hw, -hh, hw*2, hh*2, rx, ry, seg)
	end
	love.graphics.setLineWidth(1)

	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.03)
		love.graphics.rectangle("fill", -hw, -hh, hw*2, hh*2, rx, ry, seg)
	end

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

return EditorRectangle
