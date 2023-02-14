
-- For scene-loader. Constructors for all the default Philtre2D object types.
local M = {
	Object = Object,
	World = World,
	Body = Body,
	Sprite = Sprite,
	Camera = Camera,
	["GUI Node"] = gui.Node,
	["GUI Column"] = gui.Column,
	["GUI Row"] = gui.Row,
	["GUI Slice"] = gui.Slice,
	["GUI Sprite"] = gui.Sprite,
	["GUI Text"] = gui.Text,
}

local function copyColor(c)
	return { c[1], c[2], c[3], c[4] }
end

local function copyExtras(obj, d)
	if d.name and d.name ~= "" then  obj.name = d.name  end
	local extras = d.properties
	if extras then
		for k,v in pairs(extras) do
			obj[k] = v
		end
		if extras.script then
			local script = require(extras.script)
			obj.scripts = { script }
		end
	end
end

function Object.fromData(Class, data)
	local d = data
	local obj = Class(d.x, d.y, d.angle, d.sx, d.sy, d.kx, d.ky)
	copyExtras(obj, d)
	return obj
end

function World.fromData(Class, d)
	local obj = Class(d.gravityX, d.gravityY, d.sleep, d.disableBegin, d.disableEnd, d.disablePre, d.disablePost)
	copyExtras(obj, d)
	return obj
end

local shapeProps = {
	"sensor",
	"categories",
	"mask",
	"friction",
	"density",
	"restitution"
}

local function rotateVec(ax, ay, cos, sin)
	return cos * ax - sin * ay, sin * ax + cos * ay
end

function Body.fromData(Class, d)
	local props = {
		linDamp = d.linDamp,
		angDamp = d.angDamp,
		bullet = d.bullet,
		fixedRot = d.fixedRot,
		gScale = d.gScale,
	}
	local shapes = {}
	if d.children then
		for _,child in ipairs(d.children) do
			local shape
			if child.class == "Circle" then
				local params
				if child.x or child.y then
					params = { child.x, child.y, child.radius or 16 }
				else
					params = { child.radius or 16 }
				end
				shape = { "circle", params }
			elseif child.class == "Rectangle" then
				local params
				local w = child.size and child.size.x or 32
				local h = child.size and child.size.y or 32
				if child.x or child.y then
					params = { child.x, child.y, w, h, child.angle }
				else
					params = { w, h }
				end
				shape = { "rectangle", params }
			elseif child.class == "Polygon" then
				local verts = child.vertices
				if child.x or child.y or (child.angle ~= 0) then
					local cos, sin
					if child.angle and child.angle ~= 0 then
						cos, sin = math.cos(child.angle), math.sin(child.angle)
					end
					local ox, oy = child.x or 0, child.y or 0
					local origVerts = child.vertices
					verts = {}
					for iy=2,#origVerts,2 do
						local ix = iy - 1
						if cos then
							local x, y = rotateVec(origVerts[ix], origVerts[iy], cos, sin)
							verts[ix], verts[iy] = x + ox, y + oy
						else
							verts[ix], verts[iy] = origVerts[ix] + ox, origVerts[iy] + oy
						end
					end
				end
				if #verts <= 4 then
					shape = { "edge", verts }
				elseif not child.isLoop then
					shape = { "chain", { false, verts } }
				else
					shape = { "polygon", verts }
				end
			end
			if shape then
				if child.properties then
					for i,key in ipairs(shapeProps) do
						local val = child.properties[key]
						if val and key == "categories" then
							shape[key] = physics.categories(unpack(val))
						elseif val and key == "mask" then
							shape[key] = physics.mask(unpack(val))
						else
							shape[key] = val
						end
					end
				end
				table.insert(shapes, shape)
			end
		end
	end
	local obj = Class(d.bodyType or "dynamic", d.x, d.y, d.angle, shapes, props)
	copyExtras(obj, d)
	return obj
end

function Sprite.fromData(Class, d)
	local ox, oy = nil, nil
	local color
	if d.color then  color = copyColor(d.color)  end
	local obj = Class(d.image, d.x, d.y, d.angle, d.sx, d.sy, color, ox, oy, d.kx, d.ky)
	obj.blendMode = d.blendMode or "alpha"
	copyExtras(obj, d)
	return obj
end

function Camera.fromData(Class, d)
	local fixedAspectRatio
	if d.fixedAspect and d.viewArea then
		fixedAspectRatio = d.viewArea.x / d.viewArea.y
	end
	local obj = Class(d.x, d.y, d.angle, d.viewArea, d.scaleMode, fixedAspectRatio)
	copyExtras(obj, d)
	return obj
end

function gui.Node.fromData(Class, d)
	local modeX, modeY = d.modeX or "none", d.modeY or "none"
	local padX, padY
	if d.pad then  padX, padY = d.pad.x or 0, d.pad.y or 0  end
	local w, h = d.size and d.size.x, d.size and d.size.y
	local obj = Class(w, h, d.pivot, d.anchor, modeX, modeY, padX, padY)
	if d.x ~= 0 or d.y ~= 0 then  obj:setPos(d.x, d.y)  end
	if (d.angle or 0) ~= 0 then  obj:setAngle(d.angle)  end
	obj.kx, obj.ky = d.kx or 0, d.ky or 0
	copyExtras(obj, d)
	return obj
end

function gui.Column.fromData(Class, d)
	local modeX, modeY = d.modeX or "none", d.modeY or "none"
	local padX, padY
	if d.pad then  padX, padY = d.pad.x or 0, d.pad.y or 0  end
	local w, h = d.size and d.size.x, d.size and d.size.y
	-- spacing, homogeneous, dir, w, h, pivot, anchor, modeX, modeY, padX, padY
	local obj = Class(d.spacing, d.homogeneous, d.dir, w, h, d.pivot, d.anchor, modeX, modeY, padX, padY)
	if d.x ~= 0 or d.y ~= 0 then  obj:setPos(d.x, d.y)  end
	if (d.angle or 0) ~= 0 then  obj:setAngle(d.angle)  end
	obj.kx, obj.ky = d.kx or 0, d.ky or 0
	copyExtras(obj, d)
	return obj
end

gui.Row.fromData = gui.Column.fromData

function gui.Slice.fromData(Class, d)
	local modeX, modeY = d.modeX or "none", d.modeY or "none"
	local padX, padY
	if d.pad then  padX, padY = d.pad.x or 0, d.pad.y or 0  end
	local m = d.margins
	local margins = { m[1], m[3], m[2], m[4] } -- from {lt, top, rt, bot} to: {lt, rt, top, bot}
	local w, h = d.size and d.size.x, d.size and d.size.y
	-- image, quad, margins, w, h, pivot, anchor, modeX, modeY, padX, padY
	-- NOTE: no quad.
	--                 image, quad, margins, w, h, pivot, anchor, modeX, modeY, padX, padY
	local obj = Class(d.image, nil, margins, w, h, d.pivot, d.anchor, modeX, modeY, padX, padY)
	if d.x ~= 0 or d.y ~= 0 then  obj:setPos(d.x, d.y)  end
	if (d.angle or 0) ~= 0 then  obj:setAngle(d.angle)  end
	obj.kx, obj.ky = d.kx or 0, d.ky or 0
	if d.color then  obj.color = copyColor(d.color)  end
	copyExtras(obj, d)
	return obj
end

function gui.Sprite.fromData(Class, d)
	local modeX, modeY = d.modeX or "none", d.modeY or "none"
	local padX, padY
	if d.pad then  padX, padY = d.pad.x or 0, d.pad.y or 0  end
	local image = new.image(d.image)
	local iw, ih = image:getDimensions()
	local w, h = d.size and d.size.x or 100, d.size and d.size.y or 100
	local sx, sy = w/iw, h/ih
	-- image, sx, sy, color, pivot, anchor, modeX, modeY
	local color
	if d.color then  color = copyColor(d.color)  end
	local obj = Class(image, sx, sy, color, d.pivot, d.anchor, modeX, modeY, padX, padY)
	if d.x ~= 0 or d.y ~= 0 then  obj:setPos(d.x, d.y)  end
	if (d.angle or 0) ~= 0 then  obj:setAngle(d.angle)  end
	obj.kx, obj.ky = d.kx or 0, d.ky or 0
	copyExtras(obj, d)
	return obj
end

function gui.Text.fromData(Class, d)
	local padX, padY
	if d.pad then  padX, padY = d.pad.x or 0, d.pad.y or 0  end
	local w = d.size and d.size.x
	-- text, font, w, pivot, anchor, hAlign, modeX, isWrapping
	local obj = Class(d.text or "", d.font, w, d.pivot, d.anchor, d.align, d.modeX, d.isWrapping)
	if padX ~= 0 or padY ~= 0 then  obj:setPad(padX, padY)  end
	if d.x ~= 0 or d.y ~= 0 then  obj:setPos(d.x, d.y)  end
	if (d.angle or 0) ~= 0 then  obj:setAngle(d.angle)  end
	obj.kx, obj.ky = d.kx or 0, d.ky or 0
	if d.color then  obj.color = copyColor(d.color)  end
	copyExtras(obj, d)
	return obj
end

return M
