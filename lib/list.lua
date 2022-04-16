
local M = {}

-- Get a - b.
-- AKA: Get the list of items that are -only- in `a`, -not- in `b`.
function M.getSubtraction(a, b)
	local has = {}
	for i=1,#a do  has[ a[i] ] = true  end
	for i=1,#b do  has[ b[i] ] = nil  end
	local onlyInA = {}
	for v,_ in pairs(has) do
		table.insert(onlyInA, v)
	end
	return onlyInA
end

-- Get the list of items that are -either- in `a` or `b` but not in both.
function M.getDifference(a, b)
	local has = {}
	for i=1,#a do
		has[ a[i] ] = true
	end
	for i=1,#b do
		local v = b[i]
		-- If `a` has it, nullify it, otherwise set it to true.
		has[v] = not has[v] or nil
	end
	local intersection = {}
	for v,_ in pairs(has) do
		table.insert(intersection, v)
	end
	return intersection
end

-- Get the sum of `a` and `b` without duplicates.
function M.getUnion(a, b)
	local has = {}
	local union = {}
	for i=1,#a do
		local v = a[i]
		has[v] = true
		union[i] = v
	end
	for i=1,#b do
		local v = b[i]
		if not has[v] then
			table.insert(union, v)
		end
	end
	return union
end

return M
