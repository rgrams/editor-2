
local PropertyPanel = gui.Column:extend()
PropertyPanel.className = "PropertyPanel"

local headerFont = { "assets/font/OpenSans-Semibold.ttf", 17 }
local propWidget = {
	float = require "ui.widgets.properties.Float",
	vec2 = require "ui.widgets.properties.Vec2",
}

function PropertyPanel.set(self, ruu)
	PropertyPanel.super.set(self, 5, false, nil, 250, 600, "E", "E", "fill")
	self:pad(4, 4)
	self.children = {
		gui.Text("Properties", headerFont, 250, "C", "C", "center", "fill"),
	}
	self.layer = "gui"
	self.ruu = ruu
	self.widget = self.ruu:Panel(self)
end

local function hasProperty(obj, Property)
	local list = obj.properties
	for i=1,#list do
		if list[i]:is(Property) then
			return i
		end
	end
end

function PropertyPanel.updateProperties(self, enclosures)
	print("PropertyPanel.updateProperties")
	for i=self.children.maxn,2,-1 do
		local child = self.children[i]
		if child then
			self.tree:remove(child)
			-- self.ruu:destroy(child.widget)
		end
	end
	if not enclosures or not enclosures[1] then
		return
	end
	local propList = {}
	local firstObj = enclosures[1][1]
	local valueList = {}
	for i,property in ipairs(firstObj.properties) do
		table.insert(propList, getmetatable(property))
		table.insert(valueList, { property:getValue() })
	end
	for _,enclosure in ipairs(enclosures) do
		local obj = enclosure[1]
		for i=#propList,1,-1 do
			local Property = propList[i]
			if not hasProperty(obj, Property) then
				table.remove(propList, i)
				table.remove(valueList, i)
			end
		end
	end
	for i,v in ipairs(propList) do
		local widgetClass = propWidget[v.type]
		local thing = widgetClass(v.name, unpack(valueList[i]))
		self.tree:add(thing, self)
	end
end

local maxLineWidth = 1

function PropertyPanel.draw(self)
	love.graphics.setColor(0.2, 0.2, 0.2, 1)
	local w, h = self.w, self.h
	love.graphics.rectangle("fill", -w/2, -h/2, w, h)

	if self.widget.isFocused then
		local depth = self.panelIndex or 0
		local lineWidth = maxLineWidth / (depth + 1)
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setColor(1, 1, 1, 0.5)

		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)

		love.graphics.setLineWidth(1)
	end
end

return PropertyPanel
