
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
		scene = scene,
		Class = Class,
		enclosure = enclosure,
		properties = properties,
		isSelected = isSelected,
		parentEnclosure = parentEnclosure,
		children = children,
	}
	local proxy = {
		unpack = function()
			return scene, Class, enclosure, properties, isSelected, parentEnclosure, children
		end
	}
	return readOnly(t, proxy)
end

return newAddObjData
