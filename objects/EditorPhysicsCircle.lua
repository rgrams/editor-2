
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorPhysicsCircle = EditorObject:extend()
EditorPhysicsCircle.className = "EditorPhysicsCircle"
EditorPhysicsCircle.displayName = "Physics Circle"

local config = require "config"

_G.objClassList:add(EditorPhysicsCircle, EditorPhysicsCircle.displayName)

EditorPhysicsCircle.radius = 16
EditorPhysicsCircle.hitWidth = EditorPhysicsCircle.radius*2
EditorPhysicsCircle.hitHeight = EditorPhysicsCircle.radius*2
EditorPhysicsCircle.segments = 24

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"

EditorPhysicsCircle.isBuiltinProperty = {
	pos = true,
	radius = true,
	sensor = true,
	friction = true,
	density = true,
	restitution = true,
}

function EditorPhysicsCircle.set(self)
	EditorPhysicsCircle.super.set(self)
	local rand = math.random
	self.color = { rand()*0.8+0.4, rand()*0.8+0.4, rand()*0.8+0.4, 1 }
end

function EditorPhysicsCircle.initProperties(self)
	self:addProperty(Vec2, "pos")
	self:addProperty(Float, "radius", self.radius)
	self:addProperty(Bool, "sensor", false)
	self:addProperty(Float, "friction", 0.2)
	self:addProperty(Float, "density", 1)
	self:addProperty(Float, "restitution")
end

function EditorPhysicsCircle.propertyWasSet(self, name, value, property)
	EditorPhysicsCircle.super.propertyWasSet(self, name, value, property)
	if name == "radius" then
		self.radius = value
		self.hitWidth, self.hitHeight = value*2, value*2
		self:updateAABB()
	end
end

function EditorPhysicsCircle.getSizePropertyObj(self)
	return self:getPropertyObj("radius")
end

function EditorPhysicsCircle.draw(self)
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

	EditorPhysicsCircle.super.drawParentChildLines(self)

	love.graphics.setLineStyle("rough")
end

return EditorPhysicsCircle
