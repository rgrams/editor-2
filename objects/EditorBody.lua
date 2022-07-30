
local EditorObject = require(GetRequireFolder(...) .. "EditorObject")
local EditorBody = EditorObject:extend()
EditorBody.className = "EditorBody"
EditorBody.displayName = "Body"

_G.objClassList:add(EditorBody, EditorBody.displayName)

local id = require "lib.id"
local PropData = require "commands.data.PropData"

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local String = require "objects.properties.String"
local BodyType = require "objects.properties.Enum_BodyType"

function EditorBody.initProperties(self)
	self:addProperty(PropData("id",  id.new(), String, nil, true))
	self:addProperty(PropData("name",     nil, String, nil, true))
	self:addProperty(PropData("pos",      nil, Vec2, nil, true))
	self:addProperty(PropData("angle",    nil, Float, nil, true))
	self:addProperty(PropData("bodyType", nil, BodyType, nil, true))
	self:addProperty(PropData("linDamp",  nil, Float, nil, true))
	self:addProperty(PropData("angDamp",  nil, Float, nil, true))
	self:addProperty(PropData("bullet",   nil, Bool, nil, true))
	self:addProperty(PropData("fixedRot", nil, Bool, nil, true))
	self:addProperty(PropData("gScale",   1,   Float, 1, true))
end

function EditorBody.draw(self)
	love.graphics.setLineStyle("smooth")
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, self.hitWidth*0.4, 12)
	love.graphics.setLineStyle("rough")

	EditorBody.super.draw(self)
end

return EditorBody
