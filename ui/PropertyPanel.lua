
local PropertyPanel = gui.Column:extend()
PropertyPanel.className = "PropertyPanel"

local scenes = require "scenes"
local AddPropertyDialog = require "ui.AddPropertyDialog"

local headerFont = { "assets/font/OpenSans-Semibold.ttf", 17 }
local propWidget = {
	float = require "ui.widgets.properties.Float",
	vec2 = require "ui.widgets.properties.Vec2",
	file = require "ui.widgets.properties.File",
	image = require "ui.widgets.properties.File",
	bool = require "ui.widgets.properties.Bool",
	enum = require "ui.widgets.properties.Enum",
}
local propClass = _G.propClassList

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
	self.widget.ruuInput = self.ruuInput
	self.wgtMap = {}
end

function PropertyPanel.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat)
	if action == "add property" and change == 1 then
		if scenes.active and scenes.active.selection[1] then
			local self = wgt.object
			local guiRoot = self.tree:get("/Window")
			local dialog = AddPropertyDialog(self.addProperty, { self })
			self.tree:add(dialog, guiRoot)
			return true
		end
	end
end

function PropertyPanel.addProperty(self, propType, propName)
	local selection = scenes.active.selection
	local enclosures = selection:copyList()
	local Class = propClass:get(propType)
	scenes.active.history:perform("addSamePropertyToMultiple", enclosures, Class, propName)
	self:updateProperties(selection)
end

local function addPropertyWidget(self, selection, PropClass, name, value)
	local Class = propWidget[PropClass.widgetName]
	local object = Class(name, value, PropClass)
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
	-- Need properties and value.
	local commonProperties = {
		votes = {}, -- Lookup table by name.
		classes = {}
		-- { Class = , value = value }
	}

	-- Copy property list from the first object.
	local firstObj = selection[1][1]
	for i,property in ipairs(firstObj.properties) do
		local Class, name = getmetatable(property), property.name
		local value = property:getValue()
		table.insert(commonProperties, { Class = Class, name = name, value = value })
		commonProperties.votes[name] = 1
		commonProperties.classes[name] = Class
	end

	-- Loop through all other objects to check which properties are shared.
	for objI=2,#selection do
		local obj = selection[objI][1]
		-- Loop once and "vote" for properties that this object has.
		for i,property in ipairs(obj.properties) do
			local name = property.name
			local votes = commonProperties.votes[name]
			if votes and commonProperties.classes[name] == getmetatable(property) then
				commonProperties.votes[name] = votes + 1
			end
		end
	end

	-- If not all objects "voted" for a property, remove it from the list.
	local requiredVotes = #selection
	for i=#commonProperties,1,-1 do
		local name = commonProperties[i].name
		if commonProperties.votes[name] < requiredVotes then
			table.remove(commonProperties, i)
		end
	end

	for i,propData in ipairs(commonProperties) do
		addPropertyWidget(self, selection, propData.Class, propData.name, propData.value)
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
