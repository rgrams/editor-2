
local EditorGuiNode = require(GetRequireFolder(...) .. "EditorGuiNode")
local EditorGuiSprite = EditorGuiNode:extend()
EditorGuiSprite.className = "EditorGuiSprite"
EditorGuiSprite.displayName = "GUI Sprite"

_G.objClassList:add(EditorGuiSprite, EditorGuiSprite.displayName)

local PropData = require "commands.data.PropData"
local Image = require "objects.properties.Image"
local Color = require "objects.properties.Color"

function EditorGuiSprite.set(self)
	EditorGuiSprite.super.set(self)
	self.color = { 1, 1, 1, 1 }
end

function EditorGuiSprite.initProperties(self)
	EditorGuiSprite.super.initProperties(self)
	self:addProperty(PropData("image", nil, Image, nil, true))
	self:addProperty(PropData("color", nil, Color, nil, true))
end

function EditorGuiSprite.updateInnerSize(self)
	EditorGuiSprite.super.updateInnerSize(self)
	if self.image then
		-- Will mess up .touchesPoint distance calculation if we use `sx` and `sy`.
		self.imgSX, self.imgSY = self.w / self.imgW, self.h / self.imgH
	end
end

function EditorGuiSprite.propertyWasSet(self, name, value, property)
	EditorGuiSprite.super.propertyWasSet(self, name, value, property)
	if name == "image" then
		self:setImage(property.image)
	elseif name == "color" then
		self.color = property:getValue()
	end
end

function EditorGuiSprite.setImage(self, image)
	self.image = image
	if image then
		local imgW, imgH = self.image:getDimensions()
		self.imgW, self.imgH = imgW, imgH
		self.imgOX, self.imgOY = imgW/2, imgH/2
		self:updateInnerSize()
	end
end

function EditorGuiSprite.draw(self)
	if self.image then
		love.graphics.setColor(self.color)
		love.graphics.draw(self.image, 0, 0, 0, self.imgSX, self.imgSY, self.imgOX, self.imgOY)
	else
		love.graphics.setColor(self.color)
		local hw, hh = self.hitWidth*0.35, self.hitHeight*0.35
		love.graphics.line(-hw, -hh, hw, hh)
		love.graphics.line(hw, -hh, -hw, hh)
	end
	EditorGuiSprite.super.draw(self)
end

return EditorGuiSprite
