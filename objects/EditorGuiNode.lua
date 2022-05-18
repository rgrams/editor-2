
local EditorObject = require "objects.EditorObject"

local EditorGuiNode = gui.Node:extend()
EditorGuiNode:implements(EditorObject, "skip")

EditorGuiNode.className = "EditorGuiNode"

EditorGuiNode.displayName = "GUINode"
EditorGuiNode.hitWidth = 100
EditorGuiNode.hitHeight = 100

_G.objClassList:add(EditorGuiNode, EditorGuiNode.displayName)

local Vec2 = require "objects.properties.Vec2"
local Cardinal = require "objects.properties.Enum_CardinalDir"
local ResizeMode = require "objects.properties.Enum_GuiResizeMode"

EditorGuiNode.isBuiltinProperty = {
	size = true,
	pivot = true,
	anchor = true,
	modeX = true,
	modeY = true,
	pad = true,
}

function EditorGuiNode.set(self)
	EditorGuiNode.super.set(self)
	self.isSelected = false
	self.isHovered = false
	self.AABB = {}
	self.properties = {}
	self.propertyMap = {}
	self:initProperties()
end

function EditorGuiNode.init(self)
	EditorGuiNode.super.init(self)
	EditorObject.init(self)
end

function EditorGuiNode.initProperties(self)
	self:addProperty(Vec2, "size", { x = self.hitWidth, y = self.hitHeight })
	self:addProperty(Cardinal, "pivot")
	self:addProperty(Cardinal, "anchor")
	self:addProperty(ResizeMode, "modeX")
	self:addProperty(ResizeMode, "modeY")
	self:addProperty(Vec2, "pad")
end

function EditorGuiNode.allocate(self, ...)
	EditorGuiNode.super.allocate(self, ...)
	self.hitWidth, self.hitHeight = self.w, self.h
	self:updateAABB()
end

function EditorGuiNode.setProperty(self, name, value)
	local property = self:getPropertyObj(name)
	if property then
		property:setValue(value)
		if name == "size" then
			self:size(value.x, value.y, true)
			self.hitWidth, self.hitHeight = self.w, self.h
			self:updateAABB()
		elseif name == "pivot" then
			self:pivot(value) -- Cardinal
			self:updateAABB()
		elseif name == "anchor" then
			self:anchor(value) -- Cardinal
			self:updateAABB()
		elseif name == "modeX" then
			self:mode(value, nil)
			self.hitWidth, self.hitHeight = self.w, self.h
			self:updateAABB()
		elseif name == "modeY" then
			self:mode(nil, value)
			self.hitWidth, self.hitHeight = self.w, self.h
			self:updateAABB()
		elseif name == "pad" then
			self:pad(value.x, value.y)
			self:updateAABB()
		end
		return true
	else
		return false
	end
end

return EditorGuiNode
