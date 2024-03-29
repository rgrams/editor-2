
local M = {}

local subscribers = {}

function M.send(signal, sender, ...)
	local list = subscribers[signal]
	if not list then
		return
	end
	for i,sub in ipairs(list) do
		sub.fn(sub.obj, sender, signal, ...)
	end
end

local function getSubscriberList(signal)
	local list = subscribers[signal]
	if not list then
		list = {}
		subscribers[signal] = list
	end
	return list
end

function M.subscribe(obj, fn, ...)
	local signals = {...}
	for i,signal in ipairs(signals) do
		local list = getSubscriberList(signal)
		table.insert(list, { obj = obj, fn = fn })
	end
end

function M.unsubscribe(obj, fn, ...)
	local signals = {...}
	for _,signal in ipairs(signals) do
		local list = subscribers[signal]
		if list then
			for i=#list,1,-1 do
				local entry = list[i]
				if entry.obj == obj and entry.fn == fn then
					table.remove(list, i)
				end
			end
		end
	end
end

return M
