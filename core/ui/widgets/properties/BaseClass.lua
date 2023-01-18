
local BaseClass = gui.Row:extend()
BaseClass.className = "BaseClass"

local style = require "core.ui.style"

BaseClass.font = style.buttonFont
BaseClass.labelColor = style.propertyTextColor
BaseClass.spacing = 2
BaseClass.width = 100
BaseClass.height = 26

function BaseClass.set(self, name, value, PropClass, propObj)
	BaseClass.super.set(self, self.spacing, false, -1, self.width, self.height)
	self:setMode("fill", "none")
	self.layer = "gui"
	self.propertyName = name
	self.propertyObj = propObj
	self.propertyClass = PropClass

	self.label = gui.Text(name, self.font, self.labelWidth or self.width, "W", "W", "left")
	self.label:setPos(2)
	self.label.color = self.labelColor
	self.label.isGreedy = true
	self.children = { self.label }

	self.value = value

	-- Inheriting classes will create widget objects and insert them into children table.
	-- self.field = InputField(self.value)
	-- table.insert(self.children, self.field)
end

function BaseClass.setSelection(self, selection)
	self.selection = selection
end

local objToStr = require "core.philtre.lib.object-to-string"

function BaseClass.ruuInput(wgt, depth, action, value, change)
	if action == "delete" and change == 1 then -- Deleting the property.
		local self = wgt.object
		if not self.selection then
			print("Error: PropertyWidget["..self.className.."].delete - No selection known.")
		else
			local scene = self.selection.scene
			local cmd = "removeSamePropertyFromMultiple"
			local enclosures = self.selection:copyList()
			scene.history:perform(cmd, self, enclosures, self.propertyName)
		end
	elseif action == "right click" and change == 1 then -- For debugging -- TODO: Put info in tooltip.
		local self = wgt.object
		local prop = self.propertyObj
		print("right click on property widget", prop, prop.id)
		print("   default value: ", objToStr(prop.defaultValue))
		print("   isAtDefault: ", prop:isAtDefault())
	end
end

function BaseClass.initRuu(self, ruu, navList)
	self.ruu = ruu
	self.widgetNavList = navList
	self.panel = self.ruu:Panel(self)
	self.panel.ruuInput = self.ruuInput
	self.widgets = {}
end

function BaseClass.registerWidget(self, wgt) -- Add to keyboard navigation lists.
	self.widgets[wgt] = true
	table.insert(self.widgetNavList, wgt)
	return wgt
end

--[[ Example for inheriting class:
function SubClass.initRuu(self, ruu, navList)
	SubClass.super.initRuu(self, ruu, navList)
	self.wgt = self.field:initRuu(self.ruu, self.onConfirm)
	self:registerWidget(self.wgt, self, self.wgt)
end
--]]

-- Destroy our Ruu widgets & remove them from parent's list for keyboard navigation.
function BaseClass.destroyRuu(self, navList)
	self.ruu:destroy(self.panel) -- Panel is not in navigation navList.
	local widgets = self.widgets
	for i=#navList,1,-1 do
		local wgt = navList[i]
		if widgets[wgt] then
			widgets[wgt] = nil
			self.ruu:destroy(wgt)
			table.remove(navList, i)
			if not next(widgets) then
				break
			end
		end
	end
end

function BaseClass.draw(self)
	if self.panel and self.panel.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local lineWidth = 1
		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)
	end
end

return BaseClass
