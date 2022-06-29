
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

local Float = require "objects.properties.Property"
local Vec2 = require "objects.properties.Vec2"

function EditorCircle.set(self)
	EditorCircle.super.set(self)
	local rand = math.random
	self.color = { rand()*0.8+0.4, rand()*0.8+0.4, rand()*0.8+0.4, 1 }
end

function EditorCircle.initProperties(self)
	self:addProperty(Vec2, "pos", nil, nil, true)
	self:addProperty(Float, "radius", self.radius, true, true)
end

function EditorCircle.propertyWasSet(self, name, value, property)
	EditorCircle.super.propertyWasSet(self, name, value, property)
	if name == "radius" then
		self.radius = value
		self.hitWidth, self.hitHeight = value*2, value*2
		self:updateAABB()
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

	local col = self.color
	local alpha = 0.03
	if self.isHovered then
		alpha = 0.07
	end
	love.graphics.setColor(col[1], col[2], col[3], alpha)
	love.graphics.circle("fill", 0, 0, r, self.segments)

	love.graphics.setColor(col)
	love.graphics.circle("line", 0, 0, r, self.segments)
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
