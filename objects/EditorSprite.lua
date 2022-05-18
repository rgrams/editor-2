
local EditorObject = require "objects.EditorObject"
local EditorSprite = EditorObject:extend()
EditorSprite.className = "EditorSprite"

EditorSprite.displayName = "Sprite"

_G.objClassList:add(EditorSprite, EditorSprite.displayName)

local Image = require "objects.properties.Image"

EditorSprite.isBuiltinProperty = {
	pos = true,
	angle = true,
	scale = true,
	skew = true,
	image = true,
}

function EditorSprite.set(self)
	EditorSprite.super.set(self)
	self:addProperty(Image, "image")
end

function EditorSprite.setProperty(self, name, value)
	local property = self:getPropertyObj(name)
	if property then
		property:setValue(value)
		if name == "pos" then
			self:setPosition(value.x, value.y)
		elseif name == "angle" then
			self:setAngle(math.rad(value))
		elseif name == "scale" then
			self:setScale(value.x, value.y)
		elseif name == "skew" then
			self:setSkew(value.x, value.y)
		elseif name == "image" then
			self:setImage(property.image)
		end
		return true
	else
		return false
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
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.image, self.ox, self.oy)
	else
		love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
		love.graphics.circle("line", 0, 0, self.hitWidth/4, 8)
	end
	EditorSprite.super.draw(self)
end

return EditorSprite
