
local Vec2 = gui.Row:extend()
Vec2.className = "Vec2"

local InputField = require "ui.widgets.InputField"

local font = { "assets/font/OpenSans-Semibold.ttf", 15 }
local sublabelFont = { "assets/font/OpenSans-Regular.ttf", 12 }
local spacing = 2
local width = 100
local height = 26

local function Sublabel(text)
	local fnt = new.font(unpack(sublabelFont))
	local w = fnt:getWidth(text) + 4
	local label = gui.Text(text, sublabelFont, w, "C", "C", "right")
	label:setPos(0, -1)
	label.color = { 0.6, 0.6, 0.6, 1 }
	return label
end

function Vec2.set(self, name, value)
	Vec2.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.propertyName = name
	self.xValue = value.x or 0
	self.yValue = value.y or 0
	self.children = {
		gui.Text(name, font, width, "W", "W", "left"):setPos(2),
		Sublabel("x"),
		InputField(self.xValue, 50),
		Sublabel("y"),
		InputField(self.yValue, 50),
	}
	local text = self.children[1]
	text.isGreedy = true
	text.color = { 0.65, 0.65, 0.65, 1 }
	self.fieldX = self.children[3]
	self.fieldY = self.children[5]
end

function Vec2.setSelection(self, selection)
	self.selection = selection
end

function Vec2.onConfirm(self, wgt, axis)
	if wgt.text == wgt.oldText then
		return
	end
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
		local x, y = false, false -- Can't have nil values in command args.
		if axis == "x" then  x = value
		else  y = value  end
		scene.history:perform(cmd, enclosures, self.propertyName, { x = x, y = y })
	end
end

function Vec2.initRuu(self, ruu, map)
	self.ruu = ruu
	self.widgetX = self.ruu:InputField(self.fieldX, self.onConfirm, self.xValue)
	self.widgetY = self.ruu:InputField(self.fieldY, self.onConfirm, self.yValue)
	self.widgetX:args(self, self.widgetX, "x")
	self.widgetY:args(self, self.widgetY, "y")
	table.insert(map, self.widgetX)
	table.insert(map, self.widgetY)
end

function Vec2.destroyRuu(self, map)
	self.ruu:destroy(self.widgetX)
	self.ruu:destroy(self.widgetY)
	for i=#map,1,-1 do
		local wgt = map[i]
		if wgt == self.widgetX or wgt == self.widgetY then
			table.remove(map, i)
		end
	end
end

return Vec2
