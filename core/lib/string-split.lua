
local function split(str, sepPattern)
	local results = {}
	local pattern = "(.-)" .. sepPattern
	local lastEnd = 1
	local st, en, capture = str:find(pattern, 1)
	while st do
		if st ~= 1 or capture ~= "" then
			table.insert(results, capture)
		end
		lastEnd = en + 1
		st, en, capture = str:find(pattern, lastEnd)
	end
	if lastEnd-1 <= #str then -- Includes an empty string if the separator is at the end.
		capture = str:sub(lastEnd)
		table.insert(results, capture)
	end
	return results
end

return split
