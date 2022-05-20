
local function add(caller, selection, enclosure, index)
	selection:add(enclosure, index)
	return caller, selection, enclosure
end

local function remove(caller, selection, enclosure)
	local index = selection:remove(enclosure)
	return caller, selection, enclosure, index
end

local function clear(caller, selection)
	local oldList = selection:clear()
	return caller, selection, oldList
end

local function setTo(caller, selection, newList)
	local oldList = selection:setTo(newList)
	return caller, selection, oldList
end

return {
	addToSelection = { add, remove },
	removeFromSelection = { remove, add },
	clearSelection = { clear, setTo },
	setSelection = { setTo, setTo },
}
