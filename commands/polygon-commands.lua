
local signals = require "signals"
local polyFn = require "commands.functions.polygon-functions"

local function setVertexPos(caller, enclosure, i, x, y)
	local _, _, _, oldX, oldY = polyFn.setVertexPos(caller, enclosure, i, x, y)
	if enclosure[1].isSelected then  signals.send("selected objects modified", caller)  end
	return caller, enclosure, i, oldX, oldY
end

local function insertVertex(caller, enclosure, i, x, y)
	polyFn.insertVertex(caller, enclosure, i, x, y)
	if enclosure[1].isSelected then  signals.send("selected objects modified", caller)  end
	return caller, enclosure, i
end

local function addVertex(caller, enclosure, x, y)
	local obj = enclosure[1]
	local verts = obj:getProperty("vertices")
	local index = #verts/2 + 1
	return insertVertex(caller, enclosure, index, x, y)
end

local function deleteVertex(caller, enclosure, i)
	local _, _, _, oldX, oldY = polyFn.deleteVertex(caller, enclosure, i)
	if enclosure[1].isSelected then  signals.send("selected objects modified", caller)  end
	return caller, enclosure, i, oldX, oldY
end

local function setMultiVertexPos(caller, argsList)
	local undoArgsList = {}
	for i,args in ipairs(argsList) do
		table.insert(undoArgsList, { setVertexPos(unpack(args)) })
	end
	local enclosure = argsList[1][2]
	if enclosure[1].isSelected then  signals.send("selected objects modified", caller)  end
	return caller, undoArgsList
end

local function insertMultiVertex(caller, enclosure, points)
	local _, _, newIndices = polyFn.insertMultiVertex(caller, enclosure, points)
	if enclosure[1].isSelected then  signals.send("selected objects modified", caller)  end
	return caller, enclosure, newIndices
end

local function deleteMultiVertex(caller, enclosure, indices)
	local _, _, oldPoints = polyFn.deleteMultiVertex(caller, enclosure, indices)
	if enclosure[1].isSelected then  signals.send("selected objects modified", caller)  end
	return caller, enclosure, oldPoints
end

return {
	setVertexPos = { setVertexPos, setVertexPos },
	addVertex = { addVertex, deleteVertex },
	insertVertex = { insertVertex, deleteVertex },
	deleteVertex = { deleteVertex, insertVertex },
	setMultiVertexPos = { setMultiVertexPos, setMultiVertexPos },
	insertMultiVertex = { insertMultiVertex, deleteMultiVertex },
	deleteMultiVertex = { deleteMultiVertex, insertMultiVertex },
}
