
local EditorObject = require "objects.EditorObject"
local EditorPolygon = EditorObject:extend()
EditorPolygon.className = "EditorPolygon"
EditorPolygon.displayName = "Polygon"

local minHitWidth, minHitHeight = 16, 16
EditorPolygon.hitWidth = minHitWidth
EditorPolygon.hitHeight = minHitHeight
EditorPolygon.drawFill = true

_G.objClassList:add(EditorPolygon, EditorPolygon.displayName)

local config = require "config"
local PropData = require "commands.data.PropData"

local Bool = require "objects.properties.Bool"
local VertexArray = require "objects.properties.VertexArray"

function EditorPolygon.set(self)
	EditorPolygon.super.set(self)
	local rand = math.random
	self.color = { rand()*0.8+0.4, rand()*0.8+0.4, rand()*0.8+0.4, 1 }
end

function EditorPolygon.initProperties(self)
	EditorPolygon.super.initProperties(self)
	self:addProperty(PropData("isLoop", false, Bool, false, true))
	self:addProperty(PropData("vertices", nil, VertexArray, nil, true))
end

function EditorPolygon.propertyWasSet(self, name, value, property)
	EditorPolygon.super.propertyWasSet(self, name, value, property)
	if name == "vertices" then
		self:updateAABB()
	end
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
	self:setProperty(PropData("vertices", verts))
end

function EditorPolygon.insertVert(self, i, x, y)
	local ix = i*2 - 1
	local verts = self:getProperty("vertices")
	table.insert(verts, ix, y)
	table.insert(verts, ix, x)
	self:setProperty(PropData("vertices", verts))
end

function EditorPolygon.deleteVert(self, i)
	local ix = i*2 - 1
	local verts = self:getProperty("vertices")
	local oldX = table.remove(verts, ix)
	local oldY = table.remove(verts, ix)
	self:setProperty(PropData("vertices", verts))
	return oldX, oldY
end

local min, max = math.min, math.max

function EditorPolygon.updateAABB(self)
	if not self.path then  return  end -- Will update on init anyway.
	local verts = self:getProperty("vertices")
	if #verts < 4 then
		self.hitWidth, self.hitHeight = minHitWidth, minHitHeight
		self.hitOX, self.hitOY = 0, 0
		EditorPolygon.super.updateAABB(self)
		return
	end
	if self.parent then  self:updateTransform()  end
	local angle, sx, sy, kx, ky = matrix.parameters(self._to_world)
	local AABB = self.AABB
	local inf = math.huge
	local lt, rt, top, bot = inf, -inf, inf, -inf
	local llt, lrt, ltop, lbot = inf, -inf, inf, -inf -- Local-space bounds.

	if kx ~= 0 or ky ~= 0 then
		-- Need to do full transform of all verts.
		for iy=2,#verts,2 do
			local x, y = verts[iy-1], verts[iy]
			llt, lrt, ltop, lbot = min(llt, x), max(lrt, x), min(ltop, y), max(lbot, y)
			x, y = self:toWorld(x, y)
			lt, rt, top, bot = min(lt, x), max(rt, x), min(top, y), max(bot, y)
		end
	elseif angle ~= 0 then
		-- No skew, need to scale, rotate, and offset.
		local wx, wy = self._to_world.x, self._to_world.y
		for iy=2,#verts,2 do
			local x, y = verts[iy-1], verts[iy]
			llt, lrt, ltop, lbot = min(llt, x), max(lrt, x), min(ltop, y), max(lbot, y)
			x, y = vec2.rotate(x*sx, y*sy, angle)
			x, y = wx + x, wy + y
			lt, rt, top, bot = min(lt, x), max(rt, x), min(top, y), max(bot, y)
		end
	else
		-- No skew or rotation, just need to scale and offset.
		local wx, wy = self._to_world.x, self._to_world.y
		for iy=2,#verts,2 do
			local x, y = verts[iy-1], verts[iy]
			llt, lrt, ltop, lbot = min(llt, x), max(lrt, x), min(ltop, y), max(lbot, y)
			x, y = wx + x*sx, wy + y*sy
			lt, rt, top, bot = min(lt, x), max(rt, x), min(top, y), max(bot, y)
		end
	end
	AABB.w = rt - lt
	AABB.h = bot - top
	AABB.lt, AABB.top, AABB.rt, AABB.bot = lt, top, rt, bot

	self.hitWidth = math.max(lrt - llt, minHitWidth)
	self.hitHeight = math.max(lbot - ltop, minHitHeight)
	self.hitOX = (llt + lrt)/2
	self.hitOY = (ltop + lbot)/2

	if self.children then
		for i=1,self.children.maxn do
			local child = self.children[i]
			if child then
				child:updateAABB()
			end
		end
	end
end

function EditorPolygon.draw(self)
	love.graphics.setLineStyle("smooth")
	local lineWidth = 1
	local hw, hh = self.hitWidth/2 - lineWidth/2, self.hitHeight/2 - lineWidth/2
	local verts = self:getProperty("vertices")
	local isLoop = self:getProperty("isLoop")
	local vertCount = #verts/2

	local col = self.color
	local origAlpha = col[4]

	if self.drawFill and isLoop and vertCount >= 3 then
		local alpha = origAlpha * 0.03
		if self.isHovered then  alpha = origAlpha * 0.07  end
		love.graphics.setColor(col[1], col[2], col[3], alpha)
		love.graphics.polygon("fill", verts)
	end

	love.graphics.setColor(config.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(config.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	local alpha = origAlpha * 0.7
	if self.isHovered then  alpha = origAlpha * 1  end
	love.graphics.setColor(col[1], col[2], col[3], alpha)
	if isLoop and vertCount >= 3 then
		love.graphics.polygon("line", verts)
	elseif vertCount >= 2 then
		if self.isHovered then  love.graphics.setLineWidth(2.25)  end
		love.graphics.line(verts)
		love.graphics.setLineWidth(1)
	elseif vertCount == 1 then
		love.graphics.circle("fill", verts[1], verts[2], 1, 8)
	end

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

return EditorPolygon
