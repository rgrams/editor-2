
local theme = {}

local function setValue(obj, val)
	local c = obj.color
	c[1], c[2], c[3] = val, val, val
end

local font = { "assets/font/OpenSans-Regular.ttf", 13 }
local textValue = 1.0
local normalValue = 0.2
local hoverValue = 0.35
local pressValue = 0.4

function theme.init(self, themeData)
	self.object = themeData
	setValue(self.object, normalValue)
	setValue(self.object.text, textValue)
	local textNode = self.object.text
	textNode.font = new.font(unpack(font))
	textNode.fontFilename, textNode.fontSize = font[1], font[2]
	textNode:setPos(16)
end

function theme.hover(self)
	setValue(self.object, hoverValue)
end

function theme.unhover(self)
	setValue(self.object, normalValue)
end

function theme.focus(self) end

function theme.unfocus(self) end

function theme.drawFocus(wgt, obj)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(1, 1, 1, 0.05)
	local hw, hh = obj.w/2, obj.h/2
	-- For some reason, using lines keeps giving me 2px wide lines, so I'm doing this:
	love.graphics.rectangle("fill", -hw, -hh, hw*2, 1)
	love.graphics.rectangle("fill", -hw, hh-1, hw*2, 1)
	love.graphics.rectangle("fill", -hw, -hh, 1, hh*2)
	love.graphics.rectangle("fill", hw-1, -hh, 1, hh*2)
end

function theme.press(self, mx, my, isKeyboard)
	setValue(self.object, pressValue)
end

function theme.release(self, dontFire, mx, my, isKeyboard)
	setValue(self.object, self.isHovered and hoverValue or normalValue)
end

return theme
