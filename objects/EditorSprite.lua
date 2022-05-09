
local EditorObject = require "objects.EditorObject"
local EditorSprite = EditorObject:extend()
EditorSprite.className = "EditorSprite"

EditorSprite.displayName = "Sprite"
EditorObject.hitWidth = 32
EditorObject.hitHeight = 32

_G.objClassList:add(EditorSprite, EditorSprite.displayName)

local Position = require "objects.properties.Position"
local Angle = require "objects.properties.Angle"
local Scale = require "objects.properties.Scale"
local Skew = require "objects.properties.Skew"
local Image = require "objects.properties.Image"

function EditorSprite.set(self, x, y, angle, ...)
	Object.set(self, x, y, angle, ...)
	self.enclosure = { self } -- TODO: Placeholder. Should be in `addObject` command.
	self.isSelected = false
	self.isHovered = false
	self.AABB = {}
	self.properties = {}
	self.propertyMap = {}
	self:addProperty(Position)
	self:addProperty(Angle)
	self:addProperty(Scale)
	self:addProperty(Skew)
	self:addProperty(Image)
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
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.image, self.ox, self.oy)
	else
		love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
		love.graphics.circle("line", 0, 0, self.hitWidth/4, 8)
	end
	EditorSprite.super.draw(self)
end

return EditorSprite
