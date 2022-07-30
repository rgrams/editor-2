
local M = {}

local PropData = require "commands.data.PropData"

function M.setProperty(enclosure, pdata)
	local object = enclosure[1]
	local property = object:getPropertyObj(pdata.name)
	if property then
		local oldPdata = PropData.fromProp(property)
		object:setProperty(pdata)
		return enclosure, oldPdata, object.isSelected
	end
	return enclosure
end

function M.setSamePropertyOnMultiple(enclosures, pdata)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.setProperty(enclosure, pdata) }
		oneWasSelected = oneWasSelected or undoArgs[3]
		table.insert(undoArgList, undoArgs)
	end
	return undoArgList, oneWasSelected
end

function M.setMultiPropertiesOnMultiple(argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.setProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[3]
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
		local oldX, oldY = oldValue.x, oldValue.y
		local oldPdata = PropData(name, { x = oldX, y = oldY })
		local newPdata = PropData(name, { x = oldX + dx, y = oldY + dy })
		object:setProperty(newPdata)
		local undoSetPropertyArgs = { enclosure, oldPdata }
		oneWasSelected = oneWasSelected or object.isSelected
		table.insert(undoArgList, undoSetPropertyArgs)
	end
	return undoArgList, oneWasSelected
end

function M.addProperty(enclosure, pdata)
	local name = pdata.name
	assert(name, "object-functions.addProperty - `propData.name` can not be nil.")
	local obj = enclosure[1]
	if not pdata.Class or obj:getPropertyObj(name) then -- If adding `nil` property or object already has the property.
		return enclosure, name, false
	end
	name = obj:addProperty(pdata)
	return enclosure, name, obj.isSelected
end

function M.removeProperty(enclosure, name)
	local obj = enclosure[1]
	local property = obj:getPropertyObj(name)
	if not property then
		return enclosure
	end
	local pdata = PropData.fromProp(property)
	obj:removeProperty(name)
	return enclosure, pdata, obj.isSelected
end

function M.addSamePropertyToMultiple(enclosures, pdata)
	local undoArgList = {}
	local oneWasSelected = false
	for i,enclosure in ipairs(enclosures) do
		local undoArgs = { M.addProperty(enclosure, pdata) }
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
		oneWasSelected = oneWasSelected or undoArgs[3]
		undoArgList[i] = undoArgs
	end
	return undoArgList, oneWasSelected
end

function M.removePropertyFromMultiple(argList)
	local undoArgList = {}
	local oneWasSelected = false
	for i,args in ipairs(argList) do
		local undoArgs = { M.removeProperty(unpack(args)) }
		oneWasSelected = oneWasSelected or undoArgs[3]
		undoArgList[i] = undoArgs
	end
	return undoArgList, oneWasSelected
end

return M
