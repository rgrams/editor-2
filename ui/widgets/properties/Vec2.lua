
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Vec2 = BaseClass:extend()
Vec2.className = "Vec2"

local InputField = require "ui.widgets.InputField"

local sublabelFont = { "assets/font/OpenSans-Regular.ttf", 12 }

local function Sublabel(text)
	local fnt = new.font(unpack(sublabelFont))
	local w = fnt:getWidth(text) + 4
	local label = gui.Text(text, sublabelFont, w, "C", "C", "right")
	label:setPos(0, -1)
	label.color = { 0.6, 0.6, 0.6, 1 }
	return label
end

function Vec2.set(self, name, value, PropClass)
	Vec2.super.set(self, name, nil, PropClass)

	self.xValue = value.x or 0
	self.yValue = value.y or 0

	table.insert(self.children, Sublabel("x"))
	table.insert(self.children, InputField(self.xValue, 50))
	table.insert(self.children, Sublabel("y"))
	table.insert(self.children, InputField(self.yValue, 50))

	self.fieldX = self.children[3]
	self.fieldY = self.children[5]
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
		scene.history:perform(cmd, caller, enclosures, self.propertyName, { x = x, y = y })
	end
end

function Vec2.initRuu(self, ruu, navList)
	Vec2.super.initRuu(self, ruu, navList)

	self.widgetX = self.ruu:InputField(self.fieldX, self.onConfirm, self.xValue)
	self.widgetY = self.ruu:InputField(self.fieldY, self.onConfirm, self.yValue)
	self.widgetX:args(self, self.widgetX, "x")
	self.widgetY:args(self, self.widgetY, "y")
	self:addWidget(self.widgetX)
	self:addWidget(self.widgetY)
end

return Vec2
