
local function add(selection, enclosure, index)
	selection:add(enclosure, index)
	return selection, enclosure
end

local function remove(selection, enclosure)
	local index = selection:remove(enclosure)
	return selection, enclosure, index
end

local function clear(selection)
	local oldList = selection:clear()
	return selection, oldList
end

local function setTo(selection, newList)
	local oldList = selection:setTo(newList)
	return selection, oldList
end

return {
	addToSelection = { add, remove },
	removeFromSelection = { remove, add },
	clearSelection = { clear, setTo },
	setSelection = { setTo, clear },
}
