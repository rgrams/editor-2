
local EmptyTheme = require(GetRequireFolder(...) .. "EmptyTheme")
local TabTheme = EmptyTheme:extend()

local font = { "assets/font/OpenSans-Semibold.ttf", 13 }

TabTheme.normalCheckVal = 0.55
TabTheme.hoverCheckVal = 0.65
TabTheme.normalUncheckVal = 0.3
TabTheme.hoverUncheckVal = 0.4
TabTheme.pressValue = 0.75

local ButtonTheme = require(GetRequireFolder(...) .. "ButtonTheme")
TabTheme.draw = ButtonTheme.draw

function TabTheme.init(self, themeData)
	TabTheme.super.init(self, themeData)

	local Theme = self.wgtTheme
	local val = self.isChecked and Theme.normalCheckVal or Theme.normalUncheckVal
	TabTheme.setValue(self.object.color, val)

	self.object.closeBtn.widget.isChecked = self.isChecked
	TabTheme.setValue(self.object.closeBtn, val)

	local textNode = self.object.text
	textNode.font = new.font(unpack(font))
	textNode.fontFilename, textNode.fontSize = font[1], font[2]
	textNode:setPos(0, 2)
end

function TabTheme.hover(self)
	local Theme = self.wgtTheme
	local val = self.isChecked and Theme.hoverCheckVal or Theme.hoverUncheckVal
	if self.isPressed then  val = Theme.pressValue  end
	TabTheme.setValue(self.object.color, val)
end

function TabTheme.unhover(self)
	local Theme = self.wgtTheme
	local val = self.isChecked and Theme.normalCheckVal or Theme.normalUncheckVal
	TabTheme.setValue(self.object.color, val)
end

function TabTheme.press(self, mx, my, isKeyboard)
	local Theme = self.wgtTheme
	TabTheme.setValue(self.object.color, Theme.pressValue)
end

function TabTheme.release(self, dontFire, mx, my, isKeyboard)
	local closeBtn = self.object.closeBtn.widget
	closeBtn.isChecked = self.isChecked
	closeBtn.wgtTheme.update(closeBtn)
	local Theme = self.wgtTheme
	local val
	if self.isHovered then
		val = self.isChecked and Theme.hoverCheckVal or Theme.hoverUncheckVal
	else
		val = self.isChecked and Theme.normalCheckVal or Theme.normalUncheckVal
	end
	TabTheme.setValue(self.object.color, val)
end

function TabTheme.setChecked(self, isChecked)
	local closeBtn = self.object.closeBtn.widget
	closeBtn.isChecked = self.isChecked
	closeBtn.wgtTheme.update(closeBtn)
	if not self.isPressed then
		local Theme = self.wgtTheme
		local val
		if self.isHovered then
			val = self.isChecked and Theme.hoverCheckVal or Theme.hoverUncheckVal
		else
			val = self.isChecked and Theme.normalCheckVal or Theme.normalUncheckVal
		end
		TabTheme.setValue(self.object.color, val)
	end
end

return TabTheme
