
local PropertyPanel = gui.Column:extend()
PropertyPanel.className = "PropertyPanel"

local headerFont = { "assets/font/OpenSans-Semibold.ttf", 17 }
local propWidget = {
	float = require "ui.widgets.properties.Float",
	vec2 = require "ui.widgets.properties.Vec2",
}

local spacing = 2

function PropertyPanel.set(self, ruu)
	PropertyPanel.super.set(self, spacing, false, nil, 250, 600, "E", "E", "fill")
	self:pad(4, 4)
	self.children = {
		gui.Text("Properties", headerFont, 250, "C", "C", "center", "fill"),
	}
	self.layer = "gui"
	self.ruu = ruu
	self.widget = self.ruu:Panel(self)
	self.wgtMap = {}
end

local function addPropertyWidget(self, selection, PropertyClass, ...)
	local Class = propWidget[PropertyClass.type]
	local object = Class(PropertyClass.name, ...)
	object.PropertyClass = PropertyClass
	self.tree:add(object, self)
	object:setSelection(selection)
	object:initRuu(self.ruu, self.wgtMap)
end

local function removePropertyWidget(self, object)
	object:destroyRuu(self.wgtMap)
	self.tree:remove(object)
end

function PropertyPanel.updateProperties(self, selection)
	for i=self.children.maxn,2,-1 do
		local child = self.children[i]
		if child then
			removePropertyWidget(self, child)
		end
	end

	if not selection or not selection[1] then
		return
	end

	-- Get list of properties that all objects have in common.
	-- Need properties and values.
	local commonProperties = {
		includes = {} -- Lookup table by class.
		-- { Class = , values = { ... } }
	}

	-- Copy property list from the first object.
	local firstObj = selection[1][1]
	for i,property in ipairs(firstObj.properties) do
		local PropertyClass = getmetatable(property)
		local values = { property:getValue() }
		table.insert(commonProperties, { Class = PropertyClass, values = values })
		commonProperties.includes[PropertyClass] = 1
	end

	-- Loop through all other objects to check which properties are shared.
	for objI=2,#selection do
		local obj = selection[objI][1]
		-- Loop once and "vote" for properties that this object has.
		for i,property in ipairs(obj.properties) do
			local PropertyClass = getmetatable(property)
			local votes = commonProperties.includes[PropertyClass]
			if votes then
				commonProperties.includes[PropertyClass] = votes + 1
			end
		end
	end

	-- If not all objects "voted" for a property, remove it from the list.
	local requiredVotes = #selection
	for i=#commonProperties,1,-1 do
		local Class = commonProperties[i].Class
		if commonProperties.includes[Class] < requiredVotes then
			table.remove(commonProperties, i)
			commonProperties.includes[Class] = nil
		end
	end

	for i,propData in ipairs(commonProperties) do
		addPropertyWidget(self, selection, propData.Class, unpack(propData.values))
	end
	self.ruu:mapNextPrev(self.wgtMap)
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
