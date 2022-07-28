
local M = {}

function M.setProperty(caller, enclosure, name, value)
	local object = enclosure[1]
	local property = object:getPropertyObj(name)
	local oldValue
	if property then
		oldValue = property:copyValue()
		object:setProperty(name, value)
	end
	return caller, enclosure, name, oldValue, object.isSelected
end

function M.setSamePropertyOnMultiple(caller, enclosures, name, value)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.setProperty(caller, enclosure, name, value) }
		oneWasSelected = oneWasSelected or undoArgs[5]
		table.insert(undoArgList, undoArgs)
	end
	return caller, undoArgList, oneWasSelected
end

function M.setMultiPropertiesOnMultiple(caller, argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.setProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[5]
		table.insert(undoArgList, undoArgs)
	end
	return caller, undoArgList, oneWasSelected
end

function M.offsetVec2PropertyOnMultiple(caller, enclosures, name, dx, dy)
	dx, dy = dx or 0, dy or 0
	local undoArgList = {}
	local oneWasSelected = false
	for _,enclosure in ipairs(enclosures) do
		local object = enclosure[1]
		local oldValue = object:getProperty(name)
		local newValue = { x = oldValue.x + dx, y = oldValue.y + dy }
		object:setProperty(name, newValue)
		local undoArgs = { caller, enclosure, name, oldValue }
		oneWasSelected = oneWasSelected or object.isSelected
		table.insert(undoArgList, undoArgs)
	end
	return caller, undoArgList, oneWasSelected
end

function M.addProperty(caller, enclosure, Class, name, value)
	assert(name, "object-functions.addProperty - `name` can not be nil.")
	local obj = enclosure[1]
	if not Class or obj:getPropertyObj(name) then -- If adding `nil` property or object already has the property.
		return caller, enclosure, name, false
	end
	name = obj:addProperty(Class, name, value) -- `name` can be nil and the class default is used.
	return caller, enclosure, name, obj.isSelected
end

function M.removeProperty(caller, enclosure, name)
	local obj = enclosure[1]
	local property = obj:getPropertyObj(name)
	if not property then
		return caller, enclosure
	end
	local value = property:getValue()
	local Class = getmetatable(property)
	obj:removeProperty(name)
	return caller, enclosure, Class, name, value, obj.isSelected
end

function M.addSamePropertyToMultiple(caller, enclosures, Class, name, value)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.addProperty(caller, enclosure, Class, name, value) }
		oneWasSelected = oneWasSelected or undoArgs[4]
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList, oneWasSelected
end

function M.addPropertyToMultiple(caller, argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.addProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[4]
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList, oneWasSelected
end

function M.removeSamePropertyFromMultiple(caller, enclosures, name)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.removeProperty(caller, enclosure, name) }
		oneWasSelected = oneWasSelected or undoArgs[6]
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList, oneWasSelected
end

function M.removePropertyFromMultiple(caller, argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.removeProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[6]
		undoArgList[i] = undoArgs
	end
	return caller, undoArgList, oneWasSelected
end

return M
