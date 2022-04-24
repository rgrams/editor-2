
local Viewport = gui.Node:extend()
Viewport.className = "Viewport"

local config = require "config"
local scenes = require "scenes"
local BackgroundGrid = require "ui.BackgroundGrid"
local Tool = require "tools.Tool"
local objectFn = require "commands.functions.object-functions"

local maxLineWidth = 1

function Viewport.set(self, ruu)
	Viewport.super.set(self, 50, 600, "C", "C", "fill")
	self.isGreedy = true
	self.layer = "gui"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.scroll = Viewport.scroll
	self.widget.ruuInput = Viewport.ruuInput
	self.widget.drag = Viewport.drag
	self.children = {
		Tool(ruu)
	}
end

function Viewport.init(self)
	Viewport.super.init(self)
	self.tree:add(BackgroundGrid(self))
end

function Viewport.allocate(self, ...)
	Viewport.super.allocate(self, ...)
	-- TODO: Debug what's going on with Node allocations and make this non-hard-coded.
	Camera.current:setViewport(0, 0, self.w, self.h)
end

function Viewport.scroll(wgt, depth, dx, dy)
	Camera.current:zoomIn(config.zoomRate*dy, love.mouse.getPosition()) -- dy is actual, signed, mouse wheel dy.
end

function Viewport.drag(wgt, dx, dy, dragType)
	if dragType == "pan" then
		local wdx, wdy = Camera.current:screenToWorld(dx, dy, true)
		local pos = Camera.current.pos
		pos.x, pos.y = pos.x - wdx, pos.y - wdy
	end
end

function Viewport.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat, x, y, dx, dy, isTouch, presses)
	if action == "pan camera" then
		if change == 1 then
			wgt.ruu:startDrag(wgt, "pan")
		elseif change == -1 then
			wgt.ruu:stopDrag("pan")
		end
	elseif action == "scroll" then
		wgt:scroll(depth, dx, dy)
	elseif action == "cut" and change == 1 and scenes.active then
		local scene = scenes.active
		local selection = scene.selection
		if selection[1] then
			local enclosures = selection:copyList()
			objectFn.removeDescendantsFromList(enclosures)
			scene.history:perform("cut", scene, enclosures) -- Command sets clipboard (perform doesn't return).
			return true
		end
	elseif action == "copy" and change == 1 and scenes.active then
		local scene = scenes.active
		local selection = scene.selection
		if selection[1] then
			local enclosures = selection:copyList()
			objectFn.removeDescendantsFromList(enclosures)
			_G.scene_clipboard = objectFn.copy(scene, enclosures)
			return true
		end
	elseif action == "paste" and change == 1 and scenes.active then
		local scene = scenes.active
		local selection = scene.selection
		if _G.scene_clipboard then
			local parentEnclosures = selection:copyList() or false
			local firstParent = parentEnclosures and parentEnclosures[1] or false
			local argsList = objectFn.copyPasteDataFor(scene, firstParent, _G.scene_clipboard)
			-- Do NOT want to put the mutable clipboard table into the command history.
			scene.history:perform("paste", scene, parentEnclosures, argsList)
			return true
		end
	end
end

function Viewport.draw(self)
	if self.widget.isFocused then
		local depth = self.panelIndex or 0
		local lineWidth = maxLineWidth / (depth + 1)
		love.graphics.setLineWidth(lineWidth)
		love.graphics.setColor(1, 1, 1, 0.5)

		local w, h = self.w - lineWidth, self.h - lineWidth
		love.graphics.rectangle("line", -w/2, -h/2, w, h)

		love.graphics.setLineWidth(1)
	end

	if scenes.active then
		for i,enclosure in ipairs(scenes.active.selection) do
			local obj = enclosure[1]
			obj:drawSelectionHighlight(self)
		end
	end
end

return Viewport
