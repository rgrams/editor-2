
local signals = require "signals"

local function setVertexPos(caller, enclosure, i, x, y)
	local obj = enclosure[1]
	local oldX, oldY = obj:getVertPos(i)
	obj:setVertPos(i, x, y)
	if obj.isSelected then
		signals.send("selected objects modified", caller)
	end
	return caller, enclosure, i, oldX, oldY
end

local function insertVertex(caller, enclosure, i, x, y)
	local obj = enclosure[1]
	obj:insertVert(i, x, y)
	if obj.isSelected then
		signals.send("selected objects modified", caller)
	end
	return caller, enclosure, i
end

local function addVertex(caller, enclosure, x, y)
	local obj = enclosure[1]
	local index = #obj.vertices/2 + 1
	return insertVertex(caller, enclosure, index, x, y)
end

local function deleteVertex(caller, enclosure, i)
	local obj = enclosure[1]
	local oldX, oldY = obj:deleteVert(i)
	if obj.isSelected then
		signals.send("selected objects modified", caller)
	end
	return caller, enclosure, i, oldX, oldY
end

return {
	setVertexPos = { setVertexPos, setVertexPos },
	addVertex = { addVertex, deleteVertex },
	insertVertex = { insertVertex, deleteVertex },
	deleteVertex = { deleteVertex, insertVertex },
}
