
local EditorGuiNode = require(GetRequireFolder(...) .. "EditorGuiNode")
local EditorGuiText = EditorGuiNode:extend()
EditorGuiText.className = "EditorGuiText"

EditorGuiText.displayName = "GUI Text"
EditorGuiText.hitHeight = 20

_G.objClassList:add(EditorGuiText, EditorGuiText.displayName)

local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local Font = require "objects.properties.Font"
local Float = require "objects.properties.Property"
local String = require "objects.properties.String"
local TextAlign = require "objects.properties.Enum_TextAlign"
local Cardinal = require "objects.properties.Enum_CardinalDir"
local ResizeMode = require "objects.properties.Enum_GuiResizeMode"

EditorGuiText.isBuiltinProperty = {
	pos = true,
	angle = true,
	size = true,
	skew = true,
	pivot = true,
	anchor = true,
	modeX = true,
	pad = true,
	text = true,
	font = true,
	align = true,
	isWrapping = true,
}

function EditorGuiText.set(self)
	EditorGuiText.super.set(self)
	self:size(nil, self.hitHeight, true)
	self.text = ""
	self.font = nil
	self.fontFilename = nil
	self.fontSize = 12
	self.blendMode = "alpha"
	self.color = { 1, 1, 1, 1 }
	self.isWrapping = false
	self.hAlign = TextAlign.DEFAULT_VALUE
end

function EditorGuiText.initProperties(self)
	self:addProperty(Vec2, "pos")
	self:addProperty(Float, "angle")
	self:addProperty(Vec2, "size", { x = self.hitWidth, y = self.hitHeight })
	self:addProperty(Vec2, "skew")
	self:addProperty(Cardinal, "pivot")
	self:addProperty(Cardinal, "anchor")
	self:addProperty(ResizeMode, "modeX")
	self:addProperty(Vec2, "pad")
	self:addProperty(String, "text")
	self:addProperty(Font, "font")
	self:addProperty(TextAlign, "align")
	self:addProperty(Bool, "isWrapping")
end

function EditorGuiText.updateScale(self, alloc)
	local isDirty = EditorGuiText.super.updateScale(self, alloc)
	if isDirty then
		-- TODO: Load new font like Font property does, with new.custom, etc.
		-- NOTE: Shouldn't be used currently since there's no way to set the allocation scale.
		-- local size = self.fontSize * self._givenRect.scale
		-- if self.fontFilename then
			-- self.font = new.font(self.fontFilename, size)
		-- else
			-- self.font = new.font(size)
		-- end
		return true
	end
end

function EditorGuiText.updateInnerSize(self)
	if self.font then
		gui.Text.updateInnerSize(self)
		self.hitWidth, self.hitHeight = self.w, self.h
		self:updateAABB()
	end
end

EditorGuiText.align = gui.Text.align
EditorGuiText.wrap = gui.Text.wrap

function EditorGuiText.draw(self)
	EditorGuiText.super.draw(self)
	if self.font and self.text ~= "" then
		gui.Text.draw(self)
	end
end

function EditorGuiText.setProperty(self, name, value)
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
		elseif name == "text" then
			self.text = value
			if self.parent then  self:allocate()  end
		elseif name == "font" then
			value = property:getValue()
			self.font = property.font
			self.fontFilename, self.fontSize = value[1], value[2]
			if self.parent then  self:allocate()  end
		elseif name == "align" then
			self:align(value)
		elseif name == "isWrapping" then
			self:wrap(value)
		elseif name == "isGreedy" and property:is(Bool) then
			self.isGreedy = value
		elseif name == "color" then
			self.color = property:getValue()
		end
		return true
	else
		return false
	end
end

return EditorGuiText
