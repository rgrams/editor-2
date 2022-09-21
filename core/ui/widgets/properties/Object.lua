
local BaseClass = require(GetRequireFolder(...) .. "BaseClass")
local Object = BaseClass:extend()
Object.className = "Object"

local PropData = require "core.commands.data.PropData"
local Button = require "core.ui.widgets.Button"
local ObjectSelectorTool = require "core.tools.ObjectSelectorTool"

Object.labelWidth = Object.width/4
local selectBtnWidth = 45
local labelFont = { "core/assets/font/OpenSans-Regular.ttf", 14 }

function Object.set(self, name, value, PropClass, propObj)
	Object.super.set(self, name, value, PropClass, propObj)

	self.valueLabel = gui.Text(self.value, labelFont, 30, "C", "C", "center")
	table.insert(self.children, self.valueLabel)

	table.insert(self.children, gui.Node(15, 10))

	self.button = Button("select", selectBtnWidth, "center")
	table.insert(self.children, self.button)
end

function Object.updateValue(self, value)
	self.valueLabel.text = value
end

function Object.objectSelected(self, obj)
	local value = obj:getProperty("id")
	self.valueLabel.text = value

	if not self.selection then
		print("Error: PropertyWidget[Object].objectSelected - No selection known.")
	else
		local scene = self.selection.scene
		local cmd = "setSamePropertyOnMultiple"
		local enclosures = self.selection:copyList()
		local caller = self.tree:get("/Window/UI/PropertyPanel")
		scene.history:perform(cmd, caller, enclosures, PropData(self.propertyName, value))
	end
end

function Object.buttonPressed(self)
	-- Activate object selector tool.
	local cb = function(obj)  self:objectSelected(obj)  end
	local tool = ObjectSelectorTool(cb, self.ruu)
	local viewport = self.tree:get("/Window/UI/MainRow/VPColumn/Viewport")
	self.tree:add(tool, viewport)
end

function Object.initRuu(self, ruu, navList)
	Object.super.initRuu(self, ruu, navList)

	self.buttonWgt = self.ruu:Button(self.button, self.buttonPressed)
	self.buttonWgt:args(self)
	self:addWidget(self.buttonWgt)
end

return Object
