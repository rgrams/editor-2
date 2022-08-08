
local EditorGuiNode = require(GetRequireFolder(...) .. "EditorGuiNode")
local EditorGuiText = EditorGuiNode:extend()
EditorGuiText.className = "EditorGuiText"
EditorGuiText.displayName = "GUI Text"

EditorGuiText.hitHeight = 20

_G.objClassList:add(EditorGuiText, EditorGuiText.displayName)

local id = require "lib.id"
local PropData = require "commands.data.PropData"

local Bool = require "objects.properties.Bool"
local Vec2 = require "objects.properties.Vec2"
local Color = require "objects.properties.Color"
local Font = require "objects.properties.Font"
local Float = require "objects.properties.Property"
local String = require "objects.properties.String"
local TextAlign = require "objects.properties.Enum_TextAlign"
local Cardinal = require "objects.properties.Enum_CardinalDir"
local ResizeMode = require "objects.properties.Enum_GuiResizeMode"

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
	self.hAlign = TextAlign.defaultValue
end

function EditorGuiText.initProperties(self)
	local size = { x = self.hitWidth, y = self.hitHeight }
	self:addProperty(PropData("id",    id.new(),  String, nil, true))
	self:addProperty(PropData("name",       nil,  String, nil, true))
	self:addProperty(PropData("pos",        nil,  Vec2, nil, true))
	self:addProperty(PropData("angle",      nil,  Float, nil, true))
	self:addProperty(PropData("size",       size, Vec2, size, true))
	self:addProperty(PropData("skew",       nil,  Vec2, nil, true))
	self:addProperty(PropData("pivot",      nil,  Cardinal, nil, true))
	self:addProperty(PropData("anchor",     nil,  Cardinal, nil, true))
	self:addProperty(PropData("modeX",      nil,  ResizeMode, nil, true))
	self:addProperty(PropData("pad",        nil,  Vec2, nil, true))
	self:addProperty(PropData("text",       nil,  String, nil, true))
	self:addProperty(PropData("font",       nil,  Font, nil, true))
	self:addProperty(PropData("align",      nil,  TextAlign, nil, true))
	self:addProperty(PropData("isWrapping", nil,  Bool, nil, true))
	self:addProperty(PropData("color", nil, Color, nil, true))
end

function EditorGuiText.updateScale(self, alloc)
	local isDirty = EditorGuiText.super.updateScale(self, alloc)
	if isDirty then
		-- TODO: Load new font like Font property does, with new.custom, etc.
		-- NOTE: Won't be used currently since there's no way to set the allocation scale.
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

function EditorGuiText.propertyWasSet(self, name, value, property)
	EditorGuiText.super.propertyWasSet(self, name, value, property)
	if name == "text" then
		self.text = value
		if self.parent then  self:allocate()
		else  self:updateInnerSize()  end
	elseif name == "font" then
		value = property:getValue()
		self.font = property.font
		self.fontFilename, self.fontSize = value[1], value[2]
		if self.parent then  self:allocate()
		else  self:updateInnerSize()  end
	elseif name == "align" then
		self:align(value)
	elseif name == "isWrapping" then
		self:wrap(value)
	elseif name == "color" then
		self.color = property:getValue()
	end
end

return EditorGuiText
