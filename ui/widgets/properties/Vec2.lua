
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

function Vec2.set(self, name, value, PropClass)
	Vec2.super.set(self, spacing, false, -1, width, height)
	self:mode("fill", "none")
	self.layer = "gui"
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

function Vec2.ruuInput(wgt, depth, action, value, change)
	if action == "delete" and change == 1 then
		local self = wgt.object
		if not self.selection then
			print("Error: PropertyWidget[Vec2].delete - No selection known.")
		else
			local scene = self.selection.scene
			local cmd = "removeSamePropertyFromMultiple"
			local enclosures = self.selection:copyList()
			scene.history:perform(cmd, enclosures, self.propertyName)
			local propertyPanel = self.tree:get("/Window/UI/PropertyPanel")
			propertyPanel:updateProperties(self.selection)
		end
	end
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
		scene.history:perform(cmd, enclosures, self.propertyName, { x = x, y = y })
	end
end

function Vec2.initRuu(self, ruu, map)
	self.ruu = ruu
	self.panel = self.ruu:Panel(self)
	self.panel.ruuInput = self.ruuInput
	self.widgetX = self.ruu:InputField(self.fieldX, self.onConfirm, self.xValue)
	self.widgetY = self.ruu:InputField(self.fieldY, self.onConfirm, self.yValue)
	self.widgetX:args(self, self.widgetX, "x")
	self.widgetY:args(self, self.widgetY, "y")
	table.insert(map, self.widgetX)
	table.insert(map, self.widgetY)
	self.widgets = {
		[self.widgetX] = true,
		[self.widgetY] = true
	}
end

function Vec2.destroyRuu(self, map)
	self.ruu:destroy(self.panel) -- Panel is not in navigation map.
	for i=#map,1,-1 do
		local wgt = map[i]
		if self.widgets[wgt] then
			self.widgets[wgt] = nil
			self.ruu:destroy(wgt)
			table.remove(map, i)
			if not next(self.widgets) then
				break
			end
		end
	end
end

function Vec2.draw(self)
	if self.panel and self.panel.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return Vec2
