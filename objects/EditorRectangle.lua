
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorRectangle = EditorObject:extend()
EditorRectangle.className = "EditorRectangle"
EditorRectangle.displayName = "Rectangle"

local config = require "config"

_G.objClassList:add(EditorRectangle, EditorRectangle.displayName)

local Float = require "objects.properties.Property"
local Vec2 = require "objects.properties.Vec2"

EditorRectangle.isBuiltinProperty = {
	pos = true,
	angle = true,
	size = true,
}

function EditorRectangle.set(self)
	EditorRectangle.super.set(self)
	local rand = math.random
	self.color = { rand()*0.8+0.4, rand()*0.8+0.4, rand()*0.8+0.4, 1 }
end

function EditorRectangle.initProperties(self)
	self:addProperty(Vec2, "pos")
	self:addProperty(Float, "angle")
	self:addProperty(Vec2, "size", { x = self.hitWidth, y = self.hitHeight }, true)
end

function EditorRectangle.propertyWasSet(self, name, value, property)
	EditorRectangle.super.propertyWasSet(self, name, value, property)
	if name == "size" then
		value = property:getValue()
		self.hitWidth, self.hitHeight = value.x, value.y
		self:updateAABB()
	end
end

function EditorRectangle.getSizePropertyObj(self)
	return self:getPropertyObj("size")
end

function EditorRectangle.draw(self)
	love.graphics.setBlendMode("alpha")
	love.graphics.setLineStyle("smooth")
	local lineWidth = 1
	local hw, hh = self.hitWidth/2 - lineWidth/2, self.hitHeight/2 - lineWidth/2

	local col = self.color
	local alpha = 0.03
	if self.isHovered then
		alpha = 0.07
	end
	love.graphics.setColor(col[1], col[2], col[3], alpha)
	love.graphics.rectangle("fill", -hw, -hh, hw*2, hh*2)

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	love.graphics.setColor(col)
	love.graphics.rectangle("line", -hw, -hh, hw*2, hh*2)

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

return EditorRectangle
