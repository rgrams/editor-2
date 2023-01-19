
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Vec2 = BaseClass:extend()
Vec2.className = "Vec2"

local PropData = require "core.commands.data.PropData"
local InputField = require "core.ui.widgets.InputField"
local style = require "core.ui.style"

local sublabelFont = style.propertySubLabelFont

local function Sublabel(text)
	local fnt = new.font(unpack(sublabelFont))
	local w = fnt:getWidth(text) + 4
	local label = gui.Text(text, sublabelFont, w, "C", "C", "right")
	label:setPos(0, -1)
	label.color = style.propertyTextColor
	return label
end

function Vec2.set(self, name, value, PropClass, propObj)
	Vec2.super.set(self, name, nil, PropClass, propObj)

	self.xValue = value.x or 0
	self.yValue = value.y or 0

	table.insert(self.children, Sublabel("x"))
	table.insert(self.children, InputField(self.xValue, 50))
	table.insert(self.children, Sublabel("y"))
	table.insert(self.children, InputField(self.yValue, 50))

	self.fieldX = self.children[3]
	self.fieldY = self.children[5]
end

function Vec2.updateValue(self, value)
	self.widgetX:setText(value.x)
	self.widgetY:setText(value.y)
end

function Vec2.onConfirm(self, wgt, axis)
	local value = tonumber(wgt.text)
	if not value then
		return true -- Reject input.
	end
	if not self.selection then
		print("Error: PropertyWidget[Vec2].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local x, y
		if axis == "x" then  x = value
		else  y = value  end
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, { x = x, y = y }))
	end
end

function Vec2.initRuu(self, ruu, ...)
	Vec2.super.initRuu(self, ruu, ...)

	self.widgetX = self.fieldX:initRuu(self.ruu, self.onConfirm)
	self.widgetY = self.fieldY:initRuu(self.ruu, self.onConfirm)
	self.widgetX:args(self, self.widgetX, "x")
	self.widgetY:args(self, self.widgetY, "y")
	self:registerWidget(self.widgetX)
	self:registerWidget(self.widgetY)
end

return Vec2
