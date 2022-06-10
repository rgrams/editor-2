
local EditorObject = require "objects.EditorObject"
local EditorPolygon = EditorObject:extend()
EditorPolygon.className = "EditorPolygon"

local config = require "config"

EditorPolygon.displayName = "Polygon"
EditorPolygon.hitWidth = 32
EditorPolygon.hitHeight = 32

_G.objClassList:add(EditorPolygon, EditorPolygon.displayName)

local Bool = require "objects.properties.Bool"
local VertexArray = require "objects.properties.VertexArray"

EditorPolygon.isBuiltinProperty = {
	name = true,
	pos = true,
	angle = true,
	scale = true,
	skew = true,
	isLoop = true,
	vertices = true,
}

function EditorPolygon.initProperties(self)
	EditorPolygon.super.initProperties(self)
	self:addProperty(Bool, "isLoop", true, true)
	self:addProperty(VertexArray, "vertices")
end

function EditorPolygon.getVertPos(self, i)
	local ix = i*2 - 1
	local verts = self:getProperty("vertices")
	return verts[ix], verts[ix+1]
end

function EditorPolygon.setVertPos(self, i, x, y)
	local ix = i*2 - 1
	local verts = self:getProperty("vertices")
	verts[ix], verts[ix+1] = x, y
end

function EditorPolygon.insertVert(self, i, x, y)
	local ix = i*2 - 1
	local verts = self:getProperty("vertices")
	table.insert(verts, ix, y)
	table.insert(verts, ix, x)
end

function EditorPolygon.deleteVert(self, i)
	local ix = i*2 - 1
	local verts = self:getProperty("vertices")
	local oldX = table.remove(verts, ix)
	local oldY = table.remove(verts, ix)
	return oldX, oldY
end

function EditorPolygon.draw(self)
	local lineWidth = 1
	local hw, hh = self.hitWidth/2 - lineWidth/2, self.hitHeight/2 - lineWidth/2
	local verts = self:getProperty("vertices")

	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.03)
		love.graphics.polygon("fill", verts)
	end

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	love.graphics.polygon("line", verts)

	self:drawParentChildLines()
end

return EditorPolygon
