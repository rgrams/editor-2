
local M = {}

function M.setProperty(enclosure, name, value)
	local object = enclosure[1]
	local property = object:getPropertyObj(name)
	local oldValue
	if property then
		oldValue = property:copyValue()
		object:setProperty(name, value)
	end
	return enclosure, name, oldValue, object.isSelected
end

function M.setSamePropertyOnMultiple(enclosures, name, value)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.setProperty(enclosure, name, value) }
		oneWasSelected = oneWasSelected or undoArgs[4]
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList, oneWasSelected
end

function M.setMultiPropertiesOnMultiple(argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.setProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[4]
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList, oneWasSelected
end

function M.offsetVec2PropertyOnMultiple(enclosures, name, dx, dy)
	dx, dy = dx or 0, dy or 0
	local undoArgList = {}
	local oneWasSelected = false
	for _,enclosure in ipairs(enclosures) do
		local object = enclosure[1]
		local oldValue = object:getProperty(name)
		local newValue = { x = oldValue.x + dx, y = oldValue.y + dy }
		object:setProperty(name, newValue)
		local undoArgs = { enclosure, name, oldValue }
		oneWasSelected = oneWasSelected or object.isSelected
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList, oneWasSelected
end

function M.addProperty(enclosure, Class, name, value)
	assert(name, "object-functions.addProperty - `name` can not be nil.")
	local obj = enclosure[1]
	if not Class or obj:getPropertyObj(name) then -- If adding `nil` property or object already has the property.
		return enclosure, name, false
	end
	name = obj:addProperty(Class, name, value) -- `name` can be nil and the class default is used.
	return enclosure, name, obj.isSelected
end

function M.removeProperty(enclosure, name)
	local obj = enclosure[1]
	local property = obj:getPropertyObj(name)
	if not property then
		return enclosure
	end
	local value = property:getValue()
	local Class = getmetatable(property)
	obj:removeProperty(name)
	return enclosure, Class, name, value, obj.isSelected
end

function M.addSamePropertyToMultiple(enclosures, Class, name, value)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.addProperty(enclosure, Class, name, value) }
		oneWasSelected = oneWasSelected or undoArgs[3]
		undoArgList[i] = undoArgs
	end
	return undoArgList, oneWasSelected
end

function M.addPropertyToMultiple(argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.addProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[3]
		undoArgList[i] = undoArgs
	end
	return undoArgList, oneWasSelected
end

function M.removeSamePropertyFromMultiple(enclosures, name)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.removeProperty(enclosure, name) }
		oneWasSelected = oneWasSelected or undoArgs[5]
		undoArgList[i] = undoArgs
	end
	return undoArgList, oneWasSelected
end

function M.removePropertyFromMultiple(argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.removeProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[5]
		undoArgList[i] = undoArgs
	end
	return undoArgList, oneWasSelected
end

return M
