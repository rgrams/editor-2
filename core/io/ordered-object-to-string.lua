
-- Same as philtre object-to-string, but sorts keys based on specified values.
local objectToString

local keySortValues = {
	x = 1, y = 2,
	isSceneFile = 1,
	class = 1, sceneFilepath = 1.5, properties = 2, children = 3,
	rootProperties = 1, childProperties = 2, addedObjects = 3,
}
local function keySorter(a, b)
	local va, vb = keySortValues[a], keySortValues[b]
	if va and vb then  return va < vb
	elseif va and not vb then  return true
	elseif vb and not va then  return false
	elseif type(a) == type(b) then  return a < b  end -- alphabetical or numerical order
end

local function worksAsIdentifier(k)
	if type(k) == 'number' then return true
	elseif type(k) == 'string' then
		if string.match(k, "^[%a_][%w_]*") then
			return true
		end
	end
	return false
end

local function tableToString(t, indent)
	indent = indent or ''
	local indent2 = indent .. '\t'
	local items = {}
	local len = 0
	-- Add named key/value pairs.
	local keys, lasti = {}, #t
	for k,v in pairs(t) do
		if type(k) ~= 'number' or k > lasti then
			table.insert(keys, k)
		end
	end
	table.sort(keys, keySorter)
	for i,k in ipairs(keys) do
		local v = t[k]
		if #items > 0 then len = len + string.len(', ') end
		local s
		if worksAsIdentifier(k) then s = k else
			s = '[' .. objectToString(k, indent2) .. ']'
		end
		s = s .. ' = ' .. objectToString(v, indent2)
		len = len + string.len(s)
		table.insert(items, s)
	end
	-- Add numbered values.
	for _,v in ipairs(t) do
		local s = objectToString(v, indent2)
		if len > 0 then len = len + string.len(', ') end
		len = len + string.len(s)
		table.insert(items, s)
	end
	-- Print all.
	local multi = (len > 70)
	local sep = multi and '\n' .. indent .. '\t' or ' '
	local s = '{' .. sep
	for i,item in ipairs(items) do
		if i > 1 then s = s .. ',' .. sep end
		s = s .. item
	end
	if multi then s = s .. '\n' .. indent .. '}'
	else s = s .. sep .. '}' end
	return s
end

local escapeSpecial = {
	['"'] = '\\"',
	['\n'] = '\\n'
}

objectToString = function(obj, indent)
	local t = type(obj)
	if t == 'string' then
		obj = string.gsub(obj, "[\"\n]", escapeSpecial)
		return '"' .. obj .. '"'
	elseif t == 'table' then
		return tableToString(obj, indent)
	else
		return tostring(obj)
	end
end

return objectToString
