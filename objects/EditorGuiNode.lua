
local EditorObject = require "objects.EditorObject"

local EditorGuiNode = gui.Node:extend()
EditorGuiNode:implements(EditorObject, "skip")

EditorGuiNode.className = "EditorGuiNode"

EditorGuiNode.displayName = "GUI Node"
EditorGuiNode.hitWidth = 100
EditorGuiNode.hitHeight = 100

_G.objClassList:add(EditorGuiNode, EditorGuiNode.displayName)

local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local Float = require "objects.properties.Property"
local Cardinal = require "objects.properties.Enum_CardinalDir"
local ResizeMode = require "objects.properties.Enum_GuiResizeMode"

EditorGuiNode.isBuiltinProperty = {
	pos = true,
	angle = true,
	size = true,
	skew = true,
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
	self:addProperty(Vec2, "pos")
	self:addProperty(Float, "angle")
	self:addProperty(Vec2, "size", { x = self.hitWidth, y = self.hitHeight })
	self:addProperty(Vec2, "skew")
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

function EditorGuiNode.toLocalPos(self, wx, wy)
	local lx, ly = self.parent:toLocal(wx, wy)
	lx, ly = lx - self.anchorPosX, ly - self.anchorPosY
	lx, ly = lx - self._givenRect.x, ly - self._givenRect.y
	local pivotX, pivotY = self.w * self.px/2, self.h * self.py/2
	lx, ly = lx + pivotX, ly + pivotY
	return lx, ly
end

function EditorGuiNode.setProperty(self, name, value)
	local property = self:getPropertyObj(name)
	if property then
		property:setValue(value)
		if name == "pos" then
			self:setPos(value.x, value.y, true)
			self:updateAABB()
		elseif name == "angle" then
			self:setAngle(math.rad(value))
			self:updateAABB()
		elseif name == "size" then
			local w, h = value.x, value.y

			-- Tell our children that we've always been this size.
			if w then  self._contentRect.designW = w - self.padX*2  end
			if h then  self._contentRect.designH = h - self.padY*2  end

			self:size(w, h, true)
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
		self:wasModified()
		return true
	else
		return false
	end
end

function EditorGuiNode.addProperty(self, Class, name, value)
	name, value = EditorObject.addProperty(self, Class, name, value)
	if name == "isGreedy" and Class == Bool then
		self.isGreedy = value
		self:wasModified()
	end
	return name, value
end

function EditorGuiNode.removeProperty(self, name)
	local wasRemoved = EditorObject.removeProperty(self, name)
	if name == "isGreedy" then
		self.isGreedy = nil
		self:wasModified()
	end
	return wasRemoved
end

return EditorGuiNode
