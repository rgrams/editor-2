
local Button = require "core.ui.widgets.Button"
local Tab = Button:extend()
Tab.className = "Tab"

local style = require "core.ui.style"
local TabCloseBtn = require(GetRequireFolder(...) .. "TabCloseBtn")
Tab.theme = require "core.ui.object-as-theme"

Tab.font = style.tabFont
Tab.width = 100
Tab.height = 24
Tab.closeBtnWidth = 20

Tab.normalCheckColor = style.tabNormalCheckColor
Tab.hoverCheckColor = style.tabHoverCheckColor
Tab.normalUncheckColor = style.tabNormalUncheckColor
Tab.hoverUncheckColor = style.tabHoverUncheckColor
Tab.pressColor = style.tabPressColor

Tab.textCheckNormalColor = style.tabTextNormalCheckColor
Tab.textCheckHoverColor = style.tabTextHoverCheckColor
Tab.textUncheckNormalColor = style.tabTextNormalUncheckColor
Tab.textUncheckHoverColor = style.tabTextHoverUncheckColor

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
	local col, textCol
	if wgt.isHovered then
		col = wgt.isChecked and self.hoverCheckColor or self.hoverUncheckColor
		textCol = wgt.isChecked and self.textCheckHoverColor or self.textUncheckHoverColor
	else
		col = wgt.isChecked and self.normalCheckColor or self.normalUncheckColor
		textCol = wgt.isChecked and self.textCheckNormalColor or self.textUncheckNormalColor
	end
	if wgt.isPressed then  col = self.pressColor  end
	self.color = col
	self.text.color = textCol
end
TabCloseBtn.updateColors = Tab.updateColors

function Tab.hover(self, wgt)
	self:updateColors()
end

function Tab.unhover(self, wgt)
	self:updateColors()
end

function Tab.press(self, wgt, mx, my, isKeyboard)
	self.color = self.pressColor
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
