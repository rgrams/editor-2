
local EditorGuiColumn = require "objects.EditorGuiColumn"
local EditorGuiRow = EditorGuiColumn:extend()

EditorGuiRow.className = "EditorGuiRow"
EditorGuiRow.displayName = "GUI Row"

_G.objClassList:add(EditorGuiRow, EditorGuiRow.displayName)

EditorGuiRow.allocateHomogeneous = gui.Row.allocateHomogeneous
EditorGuiRow.allocateHeterogeneous = gui.Row.allocateHeterogeneous

function EditorGuiRow.allocateChildren(self, forceUpdate)
	gui.Row.allocateChildren(self, forceUpdate)
	self.hitWidth, self.hitHeight = self.w, self.h
	self:updateAABB()
end

function EditorGuiRow.allocateChild(self, child, forceUpdate)
	gui.Row.allocateChild(self, child, forceUpdate)
end

return EditorGuiRow
