
local DialogBox = require "core.ui.dialogs.DialogBox"
local MessageBox = DialogBox:extend()

local textPad = 7
local msgFontData = { "core/assets/font/OpenSans-Regular.ttf", 14 }
local msgFont = new.font(unpack(msgFontData))
local msgFontHeight = msgFont:getHeight()

function MessageBox.set(self, msg, title, x, y)
	-- Calculate box height to fit message text.
	local textWidth = self.width - self.padW*2
	local _, lines = msgFont:getWrap(msg, textWidth)
	local lineCt = #lines
	local height = self.padW*2 + self.titleHeight + textPad*2 + lineCt*msgFontHeight + self.btnBoxHeight
	local minHeight = self.height
	height = math.max(minHeight, height)
	self.height = height

	self.msg = msg

	MessageBox.super.set(self, title, x, y)
end

function MessageBox.addContent(self, contentBox)
	contentBox:setPad(0, textPad)
	local msgText = gui.Text(self.msg, msgFontData, self.width, "C", "C", "center", "fill", "none", true)
	contentBox.children = { msgText }
end

return MessageBox
