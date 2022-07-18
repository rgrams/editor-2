
local AddPropDialog = gui.Column:extend()

local Ruu = require "ui.ruu.ruu"
local Button = require "ui.widgets.Button"
local InputField = require "ui.widgets.InputField"
local Dropdown = require "ui.widgets.Dropdown"
local PanelTheme = require "ui.widgets.themes.PanelTheme"
local InputFieldTheme = require "ui.widgets.themes.InputFieldTheme"

local headerFont = { "assets/font/OpenSans-Semibold.ttf", 17 }
local spacing = 2

function AddPropDialog.set(self, callback, callbackArgs)
	AddPropDialog.super.set(self, spacing, false, nil, 400, 125)
	self.callback = callback
	self.callbackArgs = callbackArgs
	self:pad(4, 4)
	self.children = {
		gui.Text("Add Property", headerFont, 250, "C", "C", "center", "fill"),
		gui.Node(10, 10),
		gui.Row(4, nil, nil, 100, 25):pad(4, 0):mode("fill"),
		gui.Node(10, 20),
		gui.Node(100, 25):mode("fill")
	}
	local inputRow = self.children[3]
	local btnRow = self.children[5]
	self.inputFld = InputField("propertyName", 325)
	self.typeBtn = Button("float", 50, "center")
	inputRow.children = {
		self.inputFld,
		self.typeBtn,
	}
	self.cancelBtn = Button("Cancel", nil, "center"):pivot("E"):anchor("C"):setPos(-4, 0)
	self.OKBtn = Button("OK", nil, "center"):pivot("W"):anchor("C"):setPos(4, 0)
	btnRow.children = {
		self.cancelBtn,
		self.OKBtn,
	}
	self.layer = "gui"
	self.ruu = Ruu()
	self.ruu:registerLayers({"gui"})
	self.widget = self.ruu:Panel(self, PanelTheme)

	local inputWgt = self.ruu:InputField(self.inputFld, self.inputConfirmed, "propertyName", InputFieldTheme)
	inputWgt:args(self, inputWgt)
	local typeWgt = self.ruu:Button(self.typeBtn, self.typeBtnPressed)
	typeWgt:args(self, typeWgt)

	local cancelWgt = self.ruu:Button(self.cancelBtn, self.cancelBtnPressed):args(self)
	local OKWgt = self.ruu:Button(self.OKBtn, self.OKBtnPressed):args(self)

	self.wgtMap = { inputWgt, typeWgt, cancelWgt, OKWgt }
	self.ruu:mapNextPrev(self.wgtMap)

	self.typeDropdownItems = { -- item = { text=, fn=, args= }
		{ text = "float", fn = self.setType, args = {self, "float" } },
		{ text = "bool", fn = self.setType, args = {self, "bool" } },
		{ text = "vec2", fn = self.setType, args = {self, "vec2" } },
		{ text = "color", fn = self.setType, args = {self, "color" } },
		{ text = "string", fn = self.setType, args = {self, "string" } },
		{ text = "file", fn = self.setType, args = {self, "file" } },
		{ text = "script", fn = self.setType, args = {self, "script" } },
		{ text = "font", fn = self.setType, args = {self, "font" } },
		{ text = "object", fn = self.setType, args = {self, "object" } },
	}
end

function AddPropDialog.init(self)
	AddPropDialog.super.init(self)
	self.ruu:setFocus(self.inputFld.widget)
	local mx, my = love.mouse.getPosition()
	self.ruu:mouseMoved(mx, my, 0, 0) -- TODO: For some reason this doesn't work?
	Input.enable(self)
end

function AddPropDialog.final(self)
	Input.disable(self)
end

function AddPropDialog.close(self)
	self.tree:remove(self)
end

function AddPropDialog.confirm(self)
	local propType = self.typeBtn.text.text
	local propName = self.inputFld.widget.text
	self:close()
	if self.callback then
		local args = self.callbackArgs or {}
		table.insert(args, propType)
		table.insert(args, propName)
		self.callback(unpack(args))
	end
end

function AddPropDialog.input(self, action, value, change, ...)
	if action == Ruu.CANCEL and change == 1 then
		self:close()
	end
	self.ruu:input(action, value, change, ...)
	return true
end

function AddPropDialog.inputConfirmed(self, wgt)
	if wgt.isFocused then
		self:confirm()
	end
end

function AddPropDialog.typeBtnPressed(self, wgt)
	local btn = wgt.object
	local x, y = btn:toWorld(-btn.w/2, -btn.h/2)
	local dropdown = Dropdown(x, y, self.typeDropdownItems)
	local guiRoot = self.tree:get("/Window")
	self.tree:add(dropdown, guiRoot)
end

function AddPropDialog.setType(self, typeName)
	self.typeBtn.text.text = typeName
end

function AddPropDialog.cancelBtnPressed(self)
	self:close()
end

function AddPropDialog.OKBtnPressed(self)
	self:confirm()
end

function AddPropDialog.draw(self)
	local widget = self.widget
	if widget then
		widget.wgtTheme.draw(widget, self)
	end
end

return AddPropDialog
