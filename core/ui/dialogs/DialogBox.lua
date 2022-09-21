
-- Base Class for popup dialogs.
-- Basic panel with a title and an OK button. Makes its own Ruu instance.
-- Child classes are expected to override .addContent & .addButtons.

local DialogBox = gui.Column:extend()

local Ruu = require "core.ui.ruu.ruu"
local Button = require "core.ui.widgets.Button"
local PanelTheme = require "core.ui.widgets.themes.PanelTheme"

local spacing = 0
DialogBox.width = 400
DialogBox.height = 150
DialogBox.padW = 4
DialogBox.titleHeight = 25
DialogBox.btnBoxHeight = 35

local titleFontData = { "core/assets/font/OpenSans-Semibold.ttf", 16 }

function DialogBox.set(self, title, x, y)
	title = title or "Notification"
	x, y = x or 0, y or 0

	DialogBox.super.set(self, spacing, nil, -1, self.width, self.height)
	self:setPos(x, y)
	self:pad(self.padW, self.padW)
	self.layer = "gui"

	local titleBox = gui.Node(100, self.titleHeight, "C", "C", "fill", "none")
	local titleText = gui.Text(title, titleFontData, 100, "C", "C", "center", "fill")
	titleBox.children = { titleText }

	local contentBox = gui.Node(100, 10, "C", "C", "fill", "fill")
	contentBox.isGreedy = true

	local buttonBox = gui.Node(100, self.btnBoxHeight):mode("fill"):pad(0, 5)

	self.children = {
		titleBox,
		contentBox,
		buttonBox
	}

	self.ruu = Ruu()
	self.ruu:registerLayers({"viewport", "gui"}) -- Bottom to top.
	self.widget = self.ruu:Panel(self, PanelTheme)

	self:addContent(contentBox)
	self:addButtons(buttonBox)
end

function DialogBox.addContent(self, contentBox)
end

function DialogBox.addButtons(self, buttonBox)
	local okBtn = Button("OK", nil, "center")
	buttonBox.children = { okBtn }
	self.ruu:Button(okBtn, self.close):args(self)
	self.initialFocusWidget = okBtn.widget
end

function DialogBox.init(self)
	DialogBox.super.init(self)

	-- map buttons
	-- set initial focus (cancel button)
	self.ruu:setFocus(self.initialFocusWidget)

	Input.enable(self)
end

function DialogBox.final(self)
	Input.disable(self)
end

function DialogBox.close(self)
	self.tree:remove(self)
end

function DialogBox.cancel(self)
	self:close()
end

function DialogBox.input(self, action, value, change, ...)
	self.ruu:input(action, value, change, ...)
	if action == Ruu.CANCEL and change == 1 then
		self:cancel()
	end
	return true
end

function DialogBox.draw(self)
	local widget = self.widget
	if widget then
		widget.wgtTheme.draw(widget, self)
	end
end

return DialogBox
