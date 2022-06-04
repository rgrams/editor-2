
local Viewport = gui.Node:extend()
Viewport.className = "Viewport"

local config = require "config"
local scenes = require "scenes"
local signals = require "signals"
local BackgroundGrid = require "ui.BackgroundGrid"
local Tool = require "tools.Tool"
local objectFn = require "commands.functions.object-functions"

function Viewport.set(self, ruu)
	Viewport.super.set(self, 50, 50, "C", "C", "fill")
	self.isGreedy = true
	self.layer = "viewport"
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.scroll = Viewport.scroll
	self.widget.ruuInput = Viewport.ruuInput
	self.widget.drag = Viewport.drag

	-- Subscribe before tool so camera updates before tool AABB.
	signals.subscribe(self, self.onActiveSceneChanged, "active scene changed")

	self.children = {
		Tool(ruu),
	}
	self.tool = self.children[1]
end

function Viewport.init(self)
	Viewport.super.init(self)
	-- Add Background Grid to scene-tree root so our Node transform doesn't make things difficult.
	self.tree:add( BackgroundGrid(self) )
	self.ruu:setFocus(self.children[1].widget)
end

function Viewport.allocate(self, ...)
	Viewport.super.allocate(self, ...)
	local left, top = self._to_world.x - self.w/2, self._to_world.y - self.h/2
	Camera.current:setViewport(left, top, self.w, self.h)
end

function Viewport.onActiveSceneChanged(self, sender, signal, scene)
	Camera.current.zoom = scene.camZoom
	local pos = Camera.current.pos
	pos.x, pos.y = scene.camX, scene.camY
end

function Viewport.scroll(wgt, depth, dx, dy)
	Camera.current:zoomIn(config.zoomRate*dy, love.mouse.getPosition()) -- dy is actual, signed, mouse wheel dy.
	if scenes.active then
		scenes.active.camZoom = Camera.current.zoom
	end
	wgt.object.tool:zoomUpdated()
end

function Viewport.drag(wgt, dx, dy, dragType)
	if dragType == "pan" then
		local wdx, wdy = Camera.current:screenToWorld(dx, dy, true)
		local pos = Camera.current.pos
		pos.x, pos.y = pos.x - wdx, pos.y - wdy
		if scenes.active then
			scenes.active.camX, scenes.active.camY = pos.x, pos.y
		end
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
			-- Don't want redo to set the clipboard, so just copy and then perform delete.
			_G.scene_clipboard = objectFn.copy(scene, enclosures)
			scene.history:perform("deleteObjects", wgt.object, scene, enclosures)
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
			local argsList = objectFn.copyPasteDataFor(wgt.object, scene, firstParent, _G.scene_clipboard)
			-- Do NOT want to put the mutable clipboard table into the command history.
			scene.history:perform("paste", wgt.object, scene, parentEnclosures, argsList)
			return true
		end
	end
end

function Viewport.draw(self)
	if self.widget.isFocused then
		love.graphics.setColor(1, 1, 1, 0.5)
		local w, h = self.w, self.h
		love.graphics.rectangle("line", -w/2+1, -h/2+1, w-1, h-1)

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
