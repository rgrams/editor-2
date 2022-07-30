
-- Class representing the data used to set and add properties.

local function readOnly(t, proxy)
	proxy = proxy or {}
	local mt = {
		__index = t,
		__newindex = function(_t, k, v)
			error("Attempt to set key '"..tostring(k).."' to '"..tostring(v).."' on protected PropData table")
		end,
		__tostring = function(pd)
			return ("PropData{%s, %s, %s}"):format(tostring(pd[1]), tostring(pd[2]), tostring(pd[3]))
		end,
	}
	return setmetatable(proxy, mt)
end

local PropData = {}

function PropData.new(name, value, Class, defaultVal, isClassBuiltin, isNonRemovable, newName)
	local t
	if type(name) == "table" then -- Can pass in a dictionary instead of all separate arguments.
		t = name
		name = t.name  value = t.value  Class = t.Class
		defaultVal = t.defaultVal  isClassBuiltin = t.isClassBuiltin
		isNonRemovable = t.isNonRemovable  newName = t.newName
	else
		t = {
			name = name,
			value = value,
			Class = Class,
			defaultVal = defaultVal,
			isClassBuiltin = isClassBuiltin,
			isNonRemovable = isNonRemovable,
			newName = newName,
		}
	end
	local proxy = {
		unpack = function()
			return name, value, Class, defaultVal, isClassBuiltin, isNonRemovable, newName
		end
	}
	return readOnly(t, proxy)
end

function PropData.fromProp(p, overrideValue)
	local name = p.name
	local value = overrideValue
	if value == nil then  value = p:copyValue()  end
	local Class = getmetatable(p)
	local defaultValue = p.defaultValue ~= Class.defaultValue and p.defaultValue
	return PropData.new(name, value, Class, defaultValue, p.isClassBuiltin, p.isNonRemovable)
end

function PropData.fromPropIfModified(p)
	if p.isNonRemovable then
		if not p:isAtDefault() then
			return PropData.fromProp(p)
		end
	else
		return PropData.fromProp(p)
	end
end

local mt = {
	__call = function(m, ...)
		return PropData.new(...)
	end
}

return setmetatable(PropData, mt)
