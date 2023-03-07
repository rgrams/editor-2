
local EditorObject = Object:extend()
EditorObject.className = "EditorObject"
EditorObject.displayName = "Object"

EditorObject.hitWidth = 32
EditorObject.hitHeight = 32

_G.objClassList:add(EditorObject, EditorObject.displayName)

local config = require "core.config"
local style = require "core.ui.style"
local id = require "core.lib.id"
local PropData = require "core.commands.data.PropData"

local Float = require "core.objects.properties.Property"
local Vec2 = require "core.objects.properties.Vec2"
local String = require "core.objects.properties.String"
local Script = require "core.objects.properties.Script"

function EditorObject.set(self)
	EditorObject.super.set(self)
	self.layer = "default"
	self.isSelected = false
	self.isHovered = false
	self.AABB = {}
	self.properties = {}
	self.propertyMap = {}
	self:initProperties()
end

function EditorObject.initProperties(self)
	local scale = { x = 1, y = 1 }
	self:addProperty(PropData("id", id.new(), String, nil, true))
	self:addProperty(PropData("name", nil, String, nil, true))
	self:addProperty(PropData("pos", nil, Vec2, nil, true))
	self:addProperty(PropData("angle", nil, Float, nil, true))
	self:addProperty(PropData("scale", scale, Vec2, scale, true))
	self:addProperty(PropData("skew", nil, Vec2, nil, true))
end

function EditorObject.init(self)
	self:updateAABB()
	self:wasModified()
end

-- Called from object-functions after fully removed from the tree (no longer in parent's child list).
function EditorObject.wasRemoved(self, fromParent)
	self:wasModified(fromParent)
end

local function setPropValues(prop, pdata)
	if pdata.value ~= nil then  prop:setValue(pdata.value)  end
	if pdata.defaultVal ~= nil then  prop.defaultValue = prop:copyValue(pdata.defaultVal)  end
	if pdata.isClassBuiltin ~= nil then  prop.isClassBuiltin = pdata.isClassBuiltin  end
	if pdata.isNonRemovable ~= nil then  prop.isNonRemovable = pdata.isNonRemovable  end
end

function EditorObject.addProperty(self, pdata)
	assert(pdata.Class, "EditorObject.addProperty - No class given for property: '"..tostring(pdata.name).."'.")
	local name = pdata.name or pdata.Class.name
	if self.propertyMap[name] then  return  end -- Abort if property already exists.

	local prop = pdata.Class(self, name)
	self.propertyMap[name] = prop
	table.insert(self.properties, prop)

	setPropValues(prop, pdata)

	self:call("propertyWasAdded", name, prop.value, prop, pdata.Class)
	self:wasModified()
	return name, prop.value
end

function EditorObject.removeProperty(self, name)
	local property = self:getPropertyObj(name)
	if property and not property.isNonRemovable then
		self.propertyMap[name] = nil
		for i,prop in ipairs(self.properties) do
			if prop == property then
				table.remove(self.properties, i)
				self:call("propertyWasRemoved", name, property)
				self:wasModified()
				return true
			end
		end
	end
end

function EditorObject.wasModified(self, parent)
	parent = parent or self.parent
	if parent and parent.childrenModified then
		parent:childrenModified()
	end
end

function EditorObject.setProperty(self, pdata)
	local prop = self:getPropertyObj(pdata.name)
	if prop then
		if pdata.Class ~= nil then
			assert(pdata.Class == getmetatable(prop), "EditorObject.setProperty - tried to alter property class of prop '"..pdata.name.."'.")
		end

		setPropValues(prop, pdata)

		if pdata.newName then
			local oldName, newName = pdata.name, pdata.newName
			self.propertyMap[oldName] = nil
			self:call("propertyWasRemoved", oldName, prop)
			prop.name = newName
			self.propertyMap[newName] = prop
			self:call("propertyWasAdded", newName, prop.value, prop, getmetatable(prop))
		end
		if pdata.value ~= nil then
			self:call("propertyWasSet", pdata.name, prop.value, prop)
		end
		if pdata.value or pdata.newName then
			self:wasModified()
		end
		return true
	else
		return false
	end
end

function EditorObject.propertyWasSet(self, name, value, property)
	if name == "pos" then
		self:setPosition(value.x, value.y)
	elseif name == "angle" then
		self:setAngle(math.rad(value))
	elseif name == "scale" then
		self:setScale(value.x, value.y)
	elseif name == "skew" then
		self:setSkew(value.x, value.y)
	elseif getmetatable(property) == Script then
		if property.oldScript then
			self:removeScript(name, property.oldPath, property.oldScript)
		end
		self:addScript(name, value, property.script)
	end
end

function EditorObject.addScript(self, name, filepath, script)
	if not script then  return  end
	self.scripts = self.scripts or {}
	table.insert(self.scripts, script)
	if script.editor_script_added then
		script.editor_script_added(self, name, filepath)
	end
end

function EditorObject.removeScript(self, name, filepath, script)
	if not script then  return  end
	if script.editor_script_removed then
		script.editor_script_removed(self, name, filepath)
	end
	local scripts = self.scripts
	if scripts then
		for i=#scripts,1,-1 do
			if scripts[i] == script then
				table.remove(scripts, i)
				break
			end
		end
	end
end

function EditorObject.propertyWasAdded(self, name, value, property, Class)
	if Class == Script then
		self:addScript(name, value, property.script)
	end
end

function EditorObject.propertyWasRemoved(self, name, property)
	if getmetatable(property) == Script then
		self:removeScript(name, property.value, property.script)
	end
end

function EditorObject.getPropertyObj(self, name)
	return self.propertyMap[name]
end

function EditorObject.hasProperty(self, name)
	return not not self.propertyMap[name]
end

function EditorObject.getProperty(self, name)
	local property = self:getPropertyObj(name)
	if property then
		return property:getValue()
	end
end

function EditorObject.getModifiedProperties(self)
	local propDatas = { isChildSceneObj = self.isChildSceneObj }
	for i,property in ipairs(self.properties) do
		local propData
		if self.isChildSceneObj then
			local Class = getmetatable(property)
			if not (Class.defaultValue == property.defaultValue and property:isAtDefault()) then
				propData = PropData.fromProp(property)
			end
		else
			if not (property.isClassBuiltin and property:isAtDefault()) then
				propData = PropData.fromProp(property)
			end
		end
		if propData then
			propDatas = propDatas or {}
			table.insert(propDatas, propData)
		end
	end
	return propDatas
end

function EditorObject.applyModifiedProperties(self, propDatas)
	if propDatas.isChildSceneObj ~= nil then
		self.isChildSceneObj = propDatas.isChildSceneObj
	end
	for i,propData in ipairs(propDatas) do
		if not self:hasProperty(propData.name) then
			self:addProperty(propData)
		else
			self:setProperty(propData)
		end
	end
end

function EditorObject.getLocalPos(self)
	return self.pos.x, self.pos.y
end

function EditorObject.getWorldPos(self)
	return self._toWorld.x, self._toWorld.y
end

function EditorObject.toLocalPos(self, wx, wy)
	return self.parent:toLocal(wx, wy)
end

function EditorObject.getSizePropertyObj(self)
	return self:getPropertyObj("scale")
end

function EditorObject.setPosition(self, x, y)
	if x then  self.pos.x = x  end
	if y then  self.pos.y = y  end
	self:updateAABB()
end

function EditorObject.setAngle(self, angle)
	self.angle = angle
	self:updateAABB()
end

function EditorObject.setScale(self, x, y)
	if x then  self.sx = x  end
	if y then  self.sy = y  end
	self:updateAABB()
end

function EditorObject.setSkew(self, x, y)
	if x then  self.kx = x  end
	if y then  self.ky = y  end
	self:updateAABB()
end

function EditorObject.touchesPoint(self, wx, wy)
	local lx, ly = self:toLocal(wx, wy)
	lx, ly = lx - (self.hitOX or 0), ly - (self.hitOY or 0)
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	if lx >= -hw and lx <= hw and ly >= -hh and ly <= hh then
		-- Funky calculation so smaller objects are more "sensitive" for when obj positions are identical.
		local sx, sy = self.sx, self.sy
		return vec2.len2(lx*hw*sx*sx, ly*hh*sy*sy)
	end
end

local tempTransform = love.math.newTransform()

function EditorObject.drawParentChildLines(self, children)
	children = children or self.children
	if children then
		-- Reset our world transform, back to just camera transform.
		love.graphics.pop()

		local arrowLen = config.parentLineArrowLength
		local arrowAngle = config.parentLineArrowAngle
		local px, py = self._toWorld.x, self._toWorld.y

		for i=1,children.maxn or #children do
			local child = children[i]
			if child then
				love.graphics.setColor(config.parentLineColor)
				local frac = config.parentLineLenFrac
				local chx, chy = child._toWorld.x, child._toWorld.y
				local dx, dy = (chx - px)*frac, (chy - py)*frac
				chx, chy = px + dx, py + dy
				love.graphics.line(px, py, chx, chy)
				local vx, vy = vec2.normalize(dx, dy)
				vx, vy = -vx*arrowLen, -vy*arrowLen
				local x2, y2 = vec2.rotate(vx, vy, arrowAngle)
				local x3, y3 = vec2.rotate(vx, vy, -arrowAngle)
				love.graphics.line(x2+chx, y2+chy, chx, chy, x3+chx, y3+chy)
			end
		end

		-- Re-apply our world transform.
		local t = matrix.toTransform(self._toWorld, tempTransform)
		love.graphics.push()
		love.graphics.applyTransform(t)
	end
end

function EditorObject.draw(self)
	love.graphics.setBlendMode("alpha")
	love.graphics.setLineStyle("smooth")
	local lineWidth = 1
	local hw, hh = self.hitWidth/2 - lineWidth/2, self.hitHeight/2 - lineWidth/2

	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.03)
		love.graphics.rectangle("fill", -hw, -hh, hw*2, hh*2)
	end

	love.graphics.setColor(style.xAxisColor)
	love.graphics.line(0, 0, hw, 0)
	love.graphics.setColor(style.yAxisColor)
	love.graphics.line(0, 0, 0, -hh)
	love.graphics.setColor(0.7, 0.7, 0.7, 0.4)
	love.graphics.rectangle("line", -hw, -hh, hw*2, hh*2)
	love.graphics.circle("line", 0, 0, 0.5, 4)

	self:drawParentChildLines()

	love.graphics.setLineStyle("rough")
end

function EditorObject.updateAABB(self)
	if not self.path then  return  end -- Will update on init anyway.
	if self.parent then  self:updateTransform()  end
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	local angle, sx, sy, kx, ky = matrix.parameters(self._toWorld)
	local AABB = self.AABB

	if kx ~= 0 or ky ~= 0 then
		-- Need to do full transform of all 4 corners.
		local x1, y1 = self:toWorld(-hw, -hh)
		local x2, y2 = self:toWorld(hw, -hh)
		local x3, y3 = self:toWorld(hw, hh)
		local x4, y4 = self:toWorld(-hw, hh)
		local left = math.min(x1, x2, x3, x4)
		local top = math.min(y1, y2, y3, y4)
		local right = math.max(x1, x2, x3, x4)
		local bottom = math.max(y1, y2, y3, y4)
		AABB.w = right - left
		AABB.h = bottom - top
		AABB.lt, AABB.top, AABB.rt, AABB.bot = left, top, right, bottom
	elseif angle ~= 0 then
		-- Just need to rotate and scale.
		local _hw, _hh = hw*sx, hh*sy
		local x, y = self._toWorld.x, self._toWorld.y
		local x1, y1 = vec2.rotate(-_hw, -_hh, angle)
		local x2, y2 = vec2.rotate(_hw, -_hh, angle)
		local x3, y3 = vec2.rotate(_hw, _hh, angle)
		local x4, y4 = vec2.rotate(-_hw, _hh, angle)
		x1, y1 = x + x1, y + y1
		x2, y2 = x + x2, y + y2
		x3, y3 = x + x3, y + y3
		x4, y4 = x + x4, y + y4
		local left = math.min(x1, x2, x3, x4)
		local top = math.min(y1, y2, y3, y4)
		local right = math.max(x1, x2, x3, x4)
		local bottom = math.max(y1, y2, y3, y4)
		AABB.w = right - left
		AABB.h = bottom - top
		AABB.lt, AABB.top, AABB.rt, AABB.bot = left, top, right, bottom
	else
		-- Just need to scale.
		local _hw, _hh = hw*sx, hh*sy
		local x, y = self._toWorld.x, self._toWorld.y
		AABB.w, AABB.h = _hw*2, _hh*2
		AABB.lt, AABB.top, AABB.rt, AABB.bot = x - _hw, y - _hh, x + _hw, y + _hh
	end

	if self.children then
		for i=1,self.children.maxn do
			local child = self.children[i]
			if child then
				child:updateAABB()
			end
		end
	end
end

-- Rotates around center, not top left corner.
local function drawRotatedRectangle(mode, x, y, width, height, angle)
	love.graphics.push()
	love.graphics.translate(x + width/2, y + height/2)
	love.graphics.rotate(angle)
	love.graphics.rectangle(mode, -width/2, -height/2, width, height) -- origin in the top left corner
	love.graphics.pop()
end

local function drawSkewedRectangle(self, mode, pad, sx, sy, cam)
	-- Get the skewed screen vectors for up and right in object-space.
	-- Then normalize and scale them by `pad` in screen space.
	-- (Screen-space is the same as world-space here except for translation - no rotation on camera.)
	local wx, wy = self._toWorld.x, self._toWorld.y
	local upX, upY = self:toWorld(0, 1)
	upX, upY = vec2.normalize(upX - wx, upY - wy)
	local rtX, rtY = self:toWorld(1, 0)
	rtX, rtY = vec2.normalize(rtX - wx, rtY - wy)
	upX, upY, rtX, rtY = upX*pad, upY*pad, rtX*pad, rtY*pad

	local ox, oy = self.hitOX or 0, self.hitOY or 0
	local hw, hh = self.hitWidth/2, self.hitHeight/2
	local x1, y1 = cam:worldToScreen( self:toWorld(ox-hw, oy-hh) )
	local x2, y2 = cam:worldToScreen( self:toWorld(ox+hw, oy-hh) )
	local x3, y3 = cam:worldToScreen( self:toWorld(ox+hw, oy+hh) )
	local x4, y4 = cam:worldToScreen( self:toWorld(ox-hw, oy+hh) )
	x1, y1 = x1 - rtX - upX, y1 - rtY - upY
	x2, y2 = x2 + rtX - upX, y2 + rtY - upY
	x3, y3 = x3 + rtX + upX, y3 + rtY + upY
	x4, y4 = x4 - rtX + upX, y4 - rtY + upY
	love.graphics.line(x1, y1, x2, y2, x3, y3, x4, y4, x1, y1)
end

-- In node-space, not self-space.
function EditorObject.drawSelectionHighlight(self, node)

	love.graphics.push()
	love.graphics.translate(-node._toWorld.x, -node._toWorld.y)

	love.graphics.setColor(config.selectedHighlightColor)
	love.graphics.setLineWidth(config.highlightLineWidth)

	local angle, sx, sy, kx, ky = matrix.parameters(self._toWorld)

	local pad = config.highlightPadding

	if kx ~= 0 or ky ~= 0 then
		drawSkewedRectangle(self, "line", pad, sx, sy, Camera.current)
	else
		local zoom = Camera.current.zoom
		local hw, hh = self.hitWidth/2 * zoom, self.hitHeight/2 * zoom
		local objX, objY = self:toWorld(self.hitOX or 0, self.hitOY or 0)
		local scrnX, scrnY = Camera.current:worldToScreen(objX, objY)
		local lx, ly = scrnX, scrnY

		hw, hh = hw*sx + pad, hh*sy + pad
		local x, y = lx - hw, ly - hh

		if angle ~= 0 then
			drawRotatedRectangle("line", x, y, hw*2, hh*2, angle)
		else
			love.graphics.rectangle("line", x, y, hw*2, hh*2)
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.pop()
end

return EditorObject
