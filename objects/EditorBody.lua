
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorBody = EditorObject:extend()
EditorBody.className = "EditorBody"
EditorBody.displayName = "Body"

_G.objClassList:add(EditorBody, EditorBody.displayName)

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local BodyType = require "objects.properties.Enum_BodyType"

EditorBody.isBuiltinProperty = {
	pos = true,
	angle = true,
	bodyType = true,
	linDamp = true,
	angDamp = true,
	bullet = true,
	fixedRot = true,
	gScale = true,
}

function EditorBody.initProperties(self)
	self:addProperty(Vec2, "pos")
	self:addProperty(Float, "angle")
	self:addProperty(BodyType, "bodyType")
	self:addProperty(Float, "linDamp")
	self:addProperty(Float, "angDamp")
	self:addProperty(Bool, "bullet")
	self:addProperty(Bool, "fixedRot")
	self:addProperty(Float, "gScale", 1)
end

function EditorBody.draw(self)
	love.graphics.setLineStyle("smooth")
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, self.hitWidth*0.4, 12)
	love.graphics.setLineStyle("rough")

	EditorBody.super.draw(self)
end

return EditorBody
