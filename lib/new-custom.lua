
-- Patch a custom loader onto philtre's `new` module.

local new = require "philtre.modules.new"

function new.custom(assetType, loaderFn, ...)
	local existing = new.loaded[assetType]
	if not existing then
		existing = {}
		new.loaded[assetType] = existing
	end
	local keys = {...}
	for i=1,#keys-1 do
		local key = keys[i]
		if not existing[key] then  existing[key] = {}  end
		existing = existing[key]
	end
	local finalKey = keys[#keys]
	if not existing[finalKey] then
		local asset = loaderFn(...)
		existing[finalKey] = asset
		new.paramsFor[asset] = keys
	end
	return existing[finalKey]
end
