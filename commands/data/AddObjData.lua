
-- Read-only key-value data structure for add-object arguments.

-- NOTE: Can still modify elements -of properties-, such as the enclosures.

local function readOnly(t, proxy)
	proxy = proxy or {}
	local mt = {
		__index = t,
		__newindex = function(_t, k, v)
			error("Attempt to set key '"..tostring(k).."' to '"..tostring(v).."' on protected AddObjData table")
		end
	}
	return setmetatable(proxy, mt)
end

local function newAddObjData(scene, Class, enclosure, properties, isSelected, parentEnclosure, children)
	local t = {
		scene = scene or false,
		Class = Class or false,
		enclosure = enclosure or false,
		properties = properties or false,
		isSelected = isSelected or false,
		parentEnclosure = parentEnclosure or false,
		children = children or false,
	}
	local proxy = {
		unpack = function()
			return scene, Class, enclosure, properties, isSelected, parentEnclosure, children
		end
	}
	return readOnly(t, proxy)
end

return newAddObjData
