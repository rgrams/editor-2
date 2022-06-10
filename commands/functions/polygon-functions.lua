
local M = {}

function M.setVertexPos(caller, enclosure, i, x, y)
	local obj = enclosure[1]
	local oldX, oldY = obj:getVertPos(i)
	obj:setVertPos(i, x, y)
	return caller, enclosure, i, oldX, oldY
end

function M.insertVertex(caller, enclosure, i, x, y)
	local obj = enclosure[1]
	obj:insertVert(i, x, y)
	return caller, enclosure, i
end

function M.deleteVertex(caller, enclosure, i)
	local obj = enclosure[1]
	local oldX, oldY = obj:deleteVert(i)
	return caller, enclosure, i, oldX, oldY
end

function M.setMultiVertexPos(caller, argsList)
	local undoArgsList = {}
	for i,args in ipairs(argsList) do
		table.insert(undoArgsList, { M.setVertexPos(unpack(args)) })
	end
	return caller, undoArgsList
end

local function byIndexSorter(a, b)
	return a[1] < b[1]
end

function M.insertMultiVertex(caller, enclosure, points)
	table.sort(points, byIndexSorter) -- Yes, this can "destructively" modify the input table.
	local obj = enclosure[1]
	local newIndices = {}
	for i,point in ipairs(points) do
		table.insert(newIndices, point[1])
		obj:insertVert(unpack(point)) -- point = { index, x, y }
	end
	return caller, enclosure, newIndices
end

local function removeHolesInList(list, oldLength)
	local j = 1
	for i=1,oldLength do
		local val = list[i]
		if val then
			if i ~= j then
				list[i] = nil
				list[j] = val
			end
			j = j + 1
		end
	end
end

function M.deleteMultiVertex(caller, enclosure, indices)
	local obj = enclosure[1]
	local verts = obj:getProperty("vertices")
	local oldCount = #verts
	local oldPoints = {}
	for i,index in ipairs(indices) do
		local iy = index*2
		local oldX, oldY = verts[iy-1], verts[iy]
		verts[iy-1], verts[iy] = nil, nil
		table.insert(oldPoints, { index, oldX, oldY })
	end
	removeHolesInList(verts, oldCount)
	obj:setProperty("vertices", verts)
	return caller, enclosure, oldPoints
end

return M
