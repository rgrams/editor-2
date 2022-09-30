
local EmptyTheme = require(GetRequireFolder(...) .. "EmptyTheme")
local TabTheme = EmptyTheme:extend()

local font = { "core/assets/font/OpenSans-Semibold.ttf", 13 }

TabTheme.normalCheckVal = 0.47
TabTheme.hoverCheckVal = 0.5
TabTheme.normalUncheckVal = 0.26
TabTheme.hoverUncheckVal = 0.28
TabTheme.pressValue = 0.5

TabTheme.textCheckNormalVal = 1.0
TabTheme.textCheckHoverVal = 1.0
TabTheme.textUncheckNormalVal = 0.65
TabTheme.textUncheckHoverVal = 0.85

TabTheme.bevelLighten = 0.15
TabTheme.bevelHoverLighten = 0.25
TabTheme.bevelDarken = 0.15
TabTheme.bevelDepth = 2

local ButtonTheme = require(GetRequireFolder(...) .. "ButtonTheme")
TabTheme.draw = ButtonTheme.draw

function TabTheme.init(self, themeData)
	TabTheme.super.init(self, themeData)

	local textNode = self.object.text
	textNode.font = new.font(unpack(font))
	textNode.fontFilename, textNode.fontSize = font[1], font[2]
	textNode:setPos(0, 1)

	self.theme.updateColors(self)

	local closeBtn = self.object.closeBtn.widget
	closeBtn.isChecked = self.isChecked
	closeBtn.theme.updateColors(closeBtn)
end

function TabTheme.updateColors(self)
	local Theme = self.theme
	local val, textVal
	if self.isHovered then
		val = self.isChecked and Theme.hoverCheckVal or Theme.hoverUncheckVal
		textVal = self.isChecked and Theme.textCheckHoverVal or Theme.textUncheckHoverVal
	else
		val = self.isChecked and Theme.normalCheckVal or Theme.normalUncheckVal
		textVal = self.isChecked and Theme.textCheckNormalVal or Theme.textUncheckNormalVal
	end
	if self.isPressed then  val = Theme.pressValue  end
	TabTheme.setValue(self.object.color, val)
	TabTheme.setValue(self.object.text.color, textVal)
end

function TabTheme.hover(self)
	self.theme.updateColors(self)
end

function TabTheme.unhover(self)
	self.theme.updateColors(self)
end

function TabTheme.press(self, mx, my, isKeyboard)
	local Theme = self.theme
	TabTheme.setValue(self.object.color, Theme.pressValue)
end

function TabTheme.release(self, dontFire, mx, my, isKeyboard)
	local closeBtn = self.object.closeBtn.widget
	closeBtn.isChecked = self.isChecked
	closeBtn.theme.updateColors(closeBtn)
	self.theme.updateColors(self)
end

function TabTheme.setChecked(self, isChecked)
	local closeBtn = self.object.closeBtn.widget
	closeBtn.isChecked = self.isChecked
	closeBtn.theme.updateColors(closeBtn)
	self.theme.updateColors(self)
end

return TabTheme
