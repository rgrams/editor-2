
local M = {}

-- Each object class should add itself here:
local contains = {}
local nameOf = {}

function M.add(name, class)
	contains[name] = class
	nameOf[class] = name
	table.insert(M, class)
end

function M.get(name)
	return contains[name]
end

function M.getName(class)
	return nameOf[class]
end

return M
