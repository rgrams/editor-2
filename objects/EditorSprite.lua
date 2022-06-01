
local EditorObject = require "objects.EditorObject"
local EditorSprite = EditorObject:extend()
EditorSprite.className = "EditorSprite"

EditorSprite.displayName = "Sprite"

_G.objClassList:add(EditorSprite, EditorSprite.displayName)

local Image = require "objects.properties.Image"
local Color = require "objects.properties.Color"

EditorSprite.isBuiltinProperty = {
	pos = true,
	angle = true,
	scale = true,
	skew = true,
	image = true,
	color = true,
}

function EditorSprite.set(self)
	EditorSprite.super.set(self)
	self.color = { 1, 1, 1, 1 }
end

function EditorSprite.initProperties(self)
	EditorSprite.super.initProperties(self)
	self:addProperty(Image, "image")
	self:addProperty(Color, "color")
end

function EditorSprite.propertyWasSet(self, name, value, property)
	EditorSprite.super.propertyWasSet(self, name, value, property)
	if name == "image" then
		self:setImage(property.image)
	elseif name == "color" then
		self.color = property:getValue()
	end
end

function EditorSprite.setImage(self, image)
	self.image = image
	if image then
		local iw, ih = self.image:getDimensions()
		self.hitWidth, self.hitHeight = iw, ih
		self.ox, self.oy = -iw/2, -ih/2
	else
		self.hitWidth, self.hitHeight = 32, 32
	end
	if self.parent then  self:updateTransform()  end
	self:updateAABB()
end

function EditorSprite.draw(self)
	if self.image then
		love.graphics.setColor(self.color)
		love.graphics.draw(self.image, self.ox, self.oy)
	else
		love.graphics.setColor(self.color)
		local r = self.hitWidth*0.35
		love.graphics.line(-r, -r, r, r)
		love.graphics.line(r, -r, -r, r)
	end
	EditorSprite.super.draw(self)
end

return EditorSprite
