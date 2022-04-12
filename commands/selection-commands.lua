
local function add(selection, enclosure, index)
	selection:add(enclosure, index)
	return selection, enclosure
end

local function remove(selection, enclosure)
	local index = selection:remove(enclosure)
	return selection, enclosure, index
end

return {
	addToSelection = { add, remove },
	removeFromSelection = { remove, add },
}
