
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Vec4 = BaseClass:extend()
Vec4.className = "Vec4"

local PropData = require "core.commands.data.PropData"
local InputField = require "core.ui.widgets.InputField"

local sublabelFont = { "core/assets/font/OpenSans-Regular.ttf", 12 }
local fieldWidth = 32
local defaultLabels = { "x", "y", "z", "w" }
Vec4.labelWidth = 50

local function Sublabel(text)
	local fnt = new.font(unpack(sublabelFont))
	local w = fnt:getWidth(text) - 1
	local label = gui.Text(text, sublabelFont, w, "C", "C", "right")
	label:setPos(0, -1)
	label.color = { 0.6, 0.6, 0.6, 1 }
	return label
end

function Vec4.set(self, name, value, PropClass, propObj)
	Vec4.super.set(self, name, nil, PropClass, propObj)

	self.X = value[1] or 1
	self.Y = value[2] or 1
	self.Z = value[3] or 1
	self.W = value[4] or 1

	local labels = propObj.wgtFieldLabels or defaultLabels

	table.insert(self.children, Sublabel(labels[1]))
	table.insert(self.children, InputField(self.X, fieldWidth))
	table.insert(self.children, Sublabel(labels[2]))
	table.insert(self.children, InputField(self.Y, fieldWidth))
	table.insert(self.children, Sublabel(labels[3]))
	table.insert(self.children, InputField(self.Z, fieldWidth))
	table.insert(self.children, Sublabel(labels[4]))
	table.insert(self.children, InputField(self.W, fieldWidth))

	self.fieldX = self.children[3]
	self.fieldY = self.children[5]
	self.fieldZ = self.children[7]
	self.fieldW = self.children[9]
end

function Vec4.updateValue(self, value)
	self.widgetX:setText(value[1])
	self.widgetY:setText(value[2])
	self.widgetZ:setText(value[3])
	self.widgetW:setText(value[4])
end

function Vec4.onConfirm(self, wgt, key)
	local value = tonumber(wgt.text)
	if not value then
		return true -- Reject input.
	end
	if not self.selection then
		print("Error: PropertyWidget[Vec4].onConfirm - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local setVal = {}
		setVal[key] = value
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, setVal))
	end
end

function Vec4.initRuu(self, ruu, navList)
	Vec4.super.initRuu(self, ruu, navList)

	self.widgetX = self.fieldX:initRuu(self.ruu, self.onConfirm)
	self.widgetY = self.fieldY:initRuu(self.ruu, self.onConfirm)
	self.widgetZ = self.fieldZ:initRuu(self.ruu, self.onConfirm)
	self.widgetW = self.fieldW:initRuu(self.ruu, self.onConfirm)
	self.widgetX:args(self, self.widgetX, 1)
	self.widgetY:args(self, self.widgetY, 2)
	self.widgetZ:args(self, self.widgetZ, 3)
	self.widgetW:args(self, self.widgetW, 4)
	self:addWidget(self.widgetX)
	self:addWidget(self.widgetY)
	self:addWidget(self.widgetZ)
	self:addWidget(self.widgetW)
end

return Vec4
