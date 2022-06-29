
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorBody = EditorObject:extend()
EditorBody.className = "EditorBody"
EditorBody.displayName = "Body"

_G.objClassList:add(EditorBody, EditorBody.displayName)

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local String = require "objects.properties.String"
local BodyType = require "objects.properties.Enum_BodyType"

function EditorBody.initProperties(self)
	self:addProperty(String,   "name",     nil, nil, true)
	self:addProperty(Vec2,     "pos",      nil, nil, true)
	self:addProperty(Float,    "angle",    nil, nil, true)
	self:addProperty(BodyType, "bodyType", nil, nil, true)
	self:addProperty(Float,    "linDamp",  nil, nil, true)
	self:addProperty(Float,    "angDamp",  nil, nil, true)
	self:addProperty(Bool,     "bullet",   nil, nil, true)
	self:addProperty(Bool,     "fixedRot", nil, nil, true)
	self:addProperty(Float,    "gScale",   1,  true, true)
end

function EditorBody.draw(self)
	love.graphics.setLineStyle("smooth")
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, self.hitWidth*0.4, 12)
	love.graphics.setLineStyle("rough")

	EditorBody.super.draw(self)
end

return EditorBody
