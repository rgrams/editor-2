
local EditorObject = require "objects.EditorObject"
local EditorSprite = EditorObject:extend()
EditorSprite.className = "EditorSprite"

local config = require "config"
local classList = require "objects.class-list"

EditorSprite.displayName = "Sprite"
EditorSprite.hitRadius = 16

classList.add(EditorSprite.displayName, EditorSprite)

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
	self.properties = {
		Position(self),
		Angle(self),
		Scale(self),
		Skew(self),
		Image(self),
	}
	self.AABB = {}
end

function EditorSprite.setImage(self, image)
	self.image = image
	if image then
		local iw, ih = self.image:getDimensions()
		self.ox, self.oy = -iw/2, -ih/2
	end
	if self.parent then  self:updateTransform()  end
	self:updateAABB()
end

function EditorSprite.draw(self)
	EditorSprite.super.draw(self)
	love.graphics.circle("line", 0, 0, self.hitRadius/2, 8)
	if self.image then
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.image, self.ox, self.oy)
	end
end

return EditorSprite
