
local M = {}

local idLength = 6
local alpha = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local listAlphabet = {}
local alphabetLength = #alpha

for i=1,alphabetLength do
	listAlphabet[i] = string.sub(alpha, i, i)
end

local _t = {}

function M.new()
	for i=1,idLength do
		_t[i] = listAlphabet[math.random(alphabetLength)]
	end
	return table.concat(_t)
end

return M
