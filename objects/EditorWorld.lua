
local EditorObject = require "objects.EditorObject"
local EditorWorld = EditorObject:extend()
EditorWorld.className = "EditorWorld"
EditorWorld.displayName = "World"

EditorWorld.hitWidth = 54
EditorWorld.hitHeight = 54

_G.objClassList:add(EditorWorld, EditorWorld.displayName)

local id = require "lib.id"
local PropData = require "commands.data.PropData"

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local String = require "objects.properties.String"
local Script = require "objects.properties.Script"

function EditorWorld.initProperties(self)
	self:addProperty(PropData("id", id.new(), String, nil, true))
	self:addProperty(PropData("name", nil, String, nil, true))
	self:addProperty(PropData("gravityX", 0, Float, 0, true))
	self:addProperty(PropData("gravityY", 0, Float, 0, true))
	self:addProperty(PropData("sleep", false, Bool, false, true))
	self:addProperty(PropData("disableBegin", false, Bool, false, true))
	self:addProperty(PropData("disableEnd", false, Bool, false, true))
	self:addProperty(PropData("disablePre", false, Bool, false, true))
	self:addProperty(PropData("disablePost", false, Bool, false, true))
end

function EditorWorld.propertyWasSet(self, name, value, property)
	if getmetatable(property) == Script then
		if property.oldScript then
			self:removeScript(name, property.oldPath, property.oldScript)
		end
		self:addScript(name, value, property.script)
	end
end

function EditorWorld.draw(self)
	love.graphics.setLineStyle("smooth")
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, self.hitWidth*math.sqrt(2)/2, 32)
	love.graphics.setLineStyle("rough")

	EditorWorld.super.draw(self)
end

return EditorWorld
