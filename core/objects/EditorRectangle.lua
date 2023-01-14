
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorRectangle = EditorObject:extend()
EditorRectangle.className = "EditorRectangle"
EditorRectangle.displayName = "Rectangle"

_G.objClassList:add(EditorRectangle, EditorRectangle.displayName)

EditorRectangle.drawFill = true

local style = require "core.ui.style"
local id = require "core.lib.id"
local PropData = require "core.commands.data.PropData"

local Float = require "core.objects.properties.Property"
local String = require "core.objects.properties.String"
local Vec2 = require "core.objects.properties.Vec2"

function EditorRectangle.set(self)
	EditorRectangle.super.set(self)
	local rand = math.random
	self.color = { rand()*0.8+0.4, rand()*0.8+0.4, rand()*0.8+0.4, 1 }
end

function EditorRectangle.initProperties(self)
	self:addProperty(PropData("id", id.new(), String, nil, true))
	self:addProperty(PropData("name", nil, String, nil, true))
	self:addProperty(PropData("pos", nil, Vec2, nil, true))
	self:addProperty(PropData("angle", nil, Float, nil, true))
	self:addProperty(PropData("size", { x = self.hitWidth, y = self.hitHeight }, Vec2, nil, true))
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
	if self.drawFill then
		local alpha = col[4]
		if self.isHovered then  alpha = alpha * 0.07
		else  alpha = alpha * 0.03  end
		love.graphics.setColor(col[1], col[2], col[3], alpha)
		love.graphics.rectangle("fill", -hw, -hh, hw*2, hh*2)
	end

	love.graphics.setColor(style.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(style.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	love.graphics.setColor(col)
	love.graphics.rectangle("line", -hw, -hh, hw*2, hh*2)

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

return EditorRectangle
