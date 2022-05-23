
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
	self:addProperty(Bool, "homogeneous", false)
	self:addProperty(Float, "dir", -1)
end

function EditorGuiColumn.allocateChildren(self, forceUpdate)
	gui.Column.allocateChildren(self, forceUpdate)
	self.hitWidth, self.hitHeight = self.w, self.h
	self:updateAABB()
end

function EditorGuiColumn.allocateChild(self, child, forceUpdate)
	gui.Column.allocateChild(self, child, forceUpdate)
end

function EditorGuiColumn.setProperty(self, name, value)
	local property = self:getPropertyObj(name)
	if property then
		property:setValue(value)
		if name == "spacing" then
			self.spacing = value
			self:allocateChildren()
		elseif name == "homogeneous" then
			self.homogeneous = value
			self:allocateChildren()
		elseif name == "dir" then
			self.dir = value
			self:allocateChildren()
		elseif name == "pos" then
			self:setPos(value.x, value.y, true)
			self:updateAABB()
		elseif name == "angle" then
			self:setAngle(math.rad(value))
			self:updateAABB()
		elseif name == "size" then
			self:size(value.x, value.y, true)
			self.hitWidth, self.hitHeight = self.w, self.h
			self:updateAABB()
		elseif name == "skew" then
			self:setSkew(value.x, value.y)
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
		elseif name == "isGreedy" and property:is(Bool) then
			self.isGreedy = value
		end
		return true
	else
		return false
	end
end

return EditorGuiColumn
