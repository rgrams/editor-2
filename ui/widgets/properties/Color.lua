
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Color = BaseClass:extend()
Color.className = "Color"

local InputField = require "ui.widgets.InputField"

local sublabelFont = { "assets/font/OpenSans-Regular.ttf", 12 }
local fieldWidth = 32
Color.labelWidth = 50

local function Sublabel(text)
	local fnt = new.font(unpack(sublabelFont))
	local w = fnt:getWidth(text) - 1
	local label = gui.Text(text, sublabelFont, w, "C", "C", "right")
	label:setPos(0, -1)
	label.color = { 0.6, 0.6, 0.6, 1 }
	return label
end

function Color.set(self, name, value, PropClass)
	Color.super.set(self, name, nil, PropClass)

	self.r = value[1] or 1
	self.g = value[2] or 1
	self.b = value[3] or 1
	self.a = value[4] or 1

	table.insert(self.children, Sublabel("r"))
	table.insert(self.children, InputField(self.r, fieldWidth))
	table.insert(self.children, Sublabel("g"))
	table.insert(self.children, InputField(self.g, fieldWidth))
	table.insert(self.children, Sublabel("b"))
	table.insert(self.children, InputField(self.b, fieldWidth))
	table.insert(self.children, Sublabel("a"))
	table.insert(self.children, InputField(self.a, fieldWidth))

	self.fieldR = self.children[3]
	self.fieldG = self.children[5]
	self.fieldB = self.children[7]
	self.fieldA = self.children[9]
end

function Color.updateValue(self, value)
	self.widgetR:setText(value[1])
	self.widgetG:setText(value[2])
	self.widgetB:setText(value[3])
	self.widgetA:setText(value[4])
end

function Color.onConfirm(self, wgt, key)
	local value = tonumber(wgt.text)
	if not value then
		return true -- Reject input.
	end
	if not self.selection then
		print("Error: PropertyWidget[Color].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local setVal = {}
		setVal[key] = value
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, self.propertyName, setVal)
	end
end

function Color.initRuu(self, ruu, navList)
	Color.super.initRuu(self, ruu, navList)

	self.widgetR = self.ruu:InputField(self.fieldR, self.onConfirm, self.r)
	self.widgetG = self.ruu:InputField(self.fieldG, self.onConfirm, self.g)
	self.widgetB = self.ruu:InputField(self.fieldB, self.onConfirm, self.b)
	self.widgetA = self.ruu:InputField(self.fieldA, self.onConfirm, self.a)
	self.widgetR:args(self, self.widgetR, 1)
	self.widgetG:args(self, self.widgetG, 2)
	self.widgetB:args(self, self.widgetB, 3)
	self.widgetA:args(self, self.widgetA, 4)
	self:addWidget(self.widgetR)
	self:addWidget(self.widgetG)
	self:addWidget(self.widgetB)
	self:addWidget(self.widgetA)
end

return Color
