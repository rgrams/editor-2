
local Viewport = gui.Node:extend()
Viewport.className = "Viewport"

local config = require "core.config"
local scenes = require "core.scenes"
local signals = require "core.signals"
local BackgroundGrid = require "core.ui.BackgroundGrid"
local MultiTool = require "core.tools.Tool"
local PolygonTool = require "core.tools.PolygonTool"

function Viewport.set(self)
	Viewport.super.set(self, 50, 50, "C", "C", "fill")
	self.isGreedy = true
	self.layer = "viewport"

	-- Subscribe before tool so camera updates before tool AABB.
	signals.subscribe(self, self.onActiveSceneChanged, "active scene changed")

	self.tools = {
		default = MultiTool(),
		polygon = PolygonTool(),
	}

	self.curToolName = "default"
	self.tool = self.tools[self.curToolName] -- Used in wgt.scroll
	self.children = {
		self.tool
	}
end

function Viewport.fromData(Class, data)
	return Class()
end

function Viewport.initRuu(self, ruu)
	self.ruu = ruu
	self.widget = ruu:Panel(self)
	self.widget.drag = Viewport.drag
	self.widget.scroll = Viewport.scroll
	self.widget.ruuInput = Viewport.ruuInput
	self.tool:initRuu(self.ruu)
	self.ruu:setFocus(self.tool.widget)
end

function Viewport.init(self)
	Viewport.super.init(self)
	self.inputMap = _G.editor._registerInputContext(self)
	-- Add Background Grid to scene-tree root so our Node transform doesn't make things difficult.
	self.tree:add( BackgroundGrid(self) )
end

function Viewport.allocate(self, x, y, w, h, designW, designH, scale)
	Viewport.super.allocate(self, x, y, w, h, designW, designH, scale)
	local left, top = self._toWorld.x - self.w/2, self._toWorld.y - self.h/2
	Camera.current:setViewport(left, top, self.w, self.h)
end

function Viewport.setTool(self, toolName)
	assert(self.tools[toolName], "Viewport.setTool - No tool by the name: '"..tostring(toolName).."'.")
	if toolName == self.curToolName then  return  end
	local curTool = self.tools[self.curToolName]
	self.tree:remove(curTool)
	self.curToolName = toolName
	self.tool = self.tools[toolName]
	self.tree:add(self.tool, self)
	self.tool:initRuu(self.ruu)
	self.ruu:setFocus(self.tool.widget)
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
	signals.send("zoom changed", wgt.object)
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

function Viewport.ruuInput(wgt, depth, action, value, change, rawChange, isRepeat, ...)
	if action == "pan camera" then
		if change == 1 then
			wgt.ruu:startDrag(wgt, "pan")
		elseif change == -1 then
			wgt.ruu:stopDrag("pan")
		end
		return true
	elseif action == "default tool" and change == 1 then
		wgt.object:setTool("default")
		return true
	elseif action == "polygon tool" and change == 1 then
		wgt.object:setTool("polygon")
		return true
	end

	local inputMap = wgt.object.inputMap
	editor.handleInputsForMap(inputMap, action, value, change, rawChange, isRepeat, ...)
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
