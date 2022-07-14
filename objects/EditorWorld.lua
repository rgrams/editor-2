
local EditorObject = require "objects.EditorObject"
local EditorWorld = EditorObject:extend()
EditorWorld.className = "EditorWorld"

EditorWorld.displayName = "World"

_G.objClassList:add(EditorWorld, EditorWorld.displayName)

EditorWorld.hitWidth = 54
EditorWorld.hitHeight = 54

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"
local String = require "objects.properties.String"
local Script = require "objects.properties.Script"

function EditorWorld.initProperties(self)
	-- Class, name, value, isDefault, isNonRemovable
	self:addProperty(String, "name", nil, nil, true)
	self:addProperty(Float, "gravityX", 0, true, true)
	self:addProperty(Float, "gravityY", 0, true, true)
	self:addProperty(Bool, "sleep", false, true, true)
	self:addProperty(Bool, "disableBegin", false, true, true)
	self:addProperty(Bool, "disableEnd", false, true, true)
	self:addProperty(Bool, "disablePre", false, true, true)
	self:addProperty(Bool, "disablePost", false, true, true)
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
