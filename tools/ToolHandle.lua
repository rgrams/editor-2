
local Class = require "philtre.modules.base-class"
local Handle = Class:extend()

local CARDINALS = {
	n = {x=0, y=-1}, ne = {x=1, y=-1}, e = {x=1, y=0}, se = {x=1, y=1},
	s = {x=0, y=1}, sw = {x=-1, y=1}, w = {x=-1, y=0}, nw = {x=-1, y=-1},
	c = {x=0, y=0}
}

function Handle.set(self, size, cardinalDir, isPivot)
	self.x, self.y = 0, 0
	self.w, self.h = size, size
	self.cardinalDir = cardinalDir
	self.dir = CARDINALS[cardinalDir]
	self.isPivot = isPivot
	self.isHovered = false
end

function Handle.setPos(self, x, y)
	self.x, self.y = x, y
end

function Handle.touchesPoint(self, x, y)
	x, y = x - self.x, y - self.y
	local hw, hh = self.w/2, self.h/2
	if x >= -hw and x <= hw and y >= -hh and y <= hh then
		-- Funky calculation so smaller objects are more "sensitive" for when obj positions are identical.
		local z = Camera.current.zoom
		return vec2.len2(x*hw*z, y*hh*z)
	end
end

function Handle.draw(self)
	local x, y = self.x, self.y

	local alpha = self.isHovered and 0.5 or 0.1
	love.graphics.setColor(1, 1, 1, alpha)

	if self.isPivot then
		local r = self.w/2
		love.graphics.circle("line", x, y, r, 12)
		local r2 = self.w
		love.graphics.line(x - r2, y, x + r2, y)
		love.graphics.line(x, y - r2, x, y + r2)
	else
		love.graphics.rectangle("line", x - self.w/2, y - self.w/2, self.w, self.h)
	end
end

return Handle
