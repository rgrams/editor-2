
local EditorGuiNode = require "objects.EditorGuiNode"
local EditorGuiColumn = EditorGuiNode:extend()

EditorGuiColumn:implements(gui.Column, "skip")

EditorGuiColumn.className = "EditorGuiColumn"
EditorGuiColumn.displayName = "GUI Column"

_G.objClassList:add(EditorGuiColumn, EditorGuiColumn.displayName)

local Float = require "objects.properties.Property"
local Bool = require "objects.properties.Bool"

EditorGuiColumn.isBuiltinProperty = {
	pos = true,
	angle = true,
	size = true,
	skew = true,
	pivot = true,
	anchor = true,
	modeX = true,
	modeY = true,
	pad = true,
	spacing = true,
	homogeneous = true,
	dir = true,
}

function EditorGuiColumn.set(self)
	EditorGuiColumn.super.set(self)
	self.spacing = 0
	self.homogeneous = false
	self.dir = -1
end

function EditorGuiColumn.initProperties(self)
	EditorGuiColumn.super.initProperties(self)
	self:addProperty(Float, "spacing")
	self:addProperty(Bool, "homogeneous", false, true)
	self:addProperty(Float, "dir", -1, true)
end

function EditorGuiColumn.allocateChildren(self, forceUpdate)
	gui.Column.allocateChildren(self, forceUpdate)
	self.hitWidth, self.hitHeight = self.w, self.h
	self:updateAABB()
end

function EditorGuiColumn.allocateChild(self, child, forceUpdate)
	gui.Column.allocateChild(self, child, forceUpdate)
end

function EditorGuiColumn.childrenModified(self)
	self:allocateChildren()
end

function EditorGuiColumn.propertyWasSet(self, name, value, property)
	EditorGuiColumn.super.propertyWasSet(self, name, value, property)
	if name == "spacing" then
		self.spacing = value
		self:allocateChildren()
	elseif name == "homogeneous" then
		self.homogeneous = value
		self:allocateChildren()
	elseif name == "dir" then
		self.dir = value
		self:allocateChildren()
	end
end

return EditorGuiColumn
