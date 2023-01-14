
local Button = require "core.ui.widgets.Button"
local Tab = Button:extend()
Tab.className = "Tab"

local TabCloseBtn = require(GetRequireFolder(...) .. "TabCloseBtn")
local setValue = require "core.lib.setValue"
Tab.theme = require "core.ui.object-as-theme"

Tab.font = { "core/assets/font/OpenSans-Semibold.ttf", 13 }
Tab.width = 100
Tab.height = 24
Tab.closeBtnWidth = 20

Tab.normalCheckVal = 0.47
Tab.hoverCheckVal = 0.5
Tab.normalUncheckVal = 0.26
Tab.hoverUncheckVal = 0.28
Tab.pressValue = 0.5

Tab.textCheckNormalVal = 1.0
Tab.textCheckHoverVal = 1.0
Tab.textUncheckNormalVal = 0.65
Tab.textUncheckHoverVal = 0.85

function Tab.set(self, text)
	Tab.super.set(self, text, self.width, "left")
	self.text:setPivot("W"):setAnchor("W"):setPos(0, 1)
	self:setPad(3)
	local w = self.closeBtnWidth
	self.closeBtn = TabCloseBtn("x", w, "center"):setPivot("E"):setAnchor("E"):setSize(w, w, true):setPos(1)
	table.insert(self.children, self.closeBtn)
end

function Tab.initRuu(self, ruu, fn, ...)
	self.ruu = ruu
	local widget = ruu:RadioButton(self, fn, false, self.theme):args(...)
	widget.object = self
	self.widget = widget
	self:updateColors()
	Tab.updateColors(self.closeBtn)
	return widget
end

function Tab.updateColors(self)
	local wgt = self.widget
	local val, textVal
	if wgt.isHovered then
		val = wgt.isChecked and Tab.hoverCheckVal or Tab.hoverUncheckVal
		textVal = wgt.isChecked and Tab.textCheckHoverVal or Tab.textUncheckHoverVal
	else
		val = wgt.isChecked and Tab.normalCheckVal or Tab.normalUncheckVal
		textVal = wgt.isChecked and Tab.textCheckNormalVal or Tab.textUncheckNormalVal
	end
	if wgt.isPressed then  val = Tab.pressValue  end
	setValue(self.color, val)
	setValue(self.text.color, textVal)
end
TabCloseBtn.updateColors = Tab.updateColors

function Tab.hover(self, wgt)
	self:updateColors()
end

function Tab.unhover(self, wgt)
	self:updateColors()
end

function Tab.press(self, wgt, mx, my, isKeyboard)
	setValue(self.color, self.pressValue)
end

function Tab.release(self, wgt, dontFire, mx, my, isKeyboard)
	local closeBtn = self.closeBtn
	if not dontFire then
		closeBtn.widget.isChecked = true
	end
	Tab.updateColors(closeBtn)
	self:updateColors()
end

function Tab.setChecked(self, wgt, isChecked)
	local closeBtn = self.closeBtn
	closeBtn.widget.isChecked = isChecked
	Tab.updateColors(closeBtn)
	self:updateColors()
end

return Tab
