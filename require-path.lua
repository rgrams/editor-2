
local M = {}

-- Modify require paths to allow loading editor scripts that require modules
--   from the project folder.

-- NOTE: Löve adds new loaders (before Lua default loaders) to look for files in
--   the game and save directories. You can modify the paths it searches with
--   love.filesystem.get/setRequirePath, but that doesn't do any good because it
--   still won't allow loading files outside of the game and save directories...
--
--   So to actually prepend a new path, you need to mount it with URFS.

local urfs = require "lib.urfs"

function M.prepend(folder)
	urfs.mount(folder)
end

function M.unPrepend(folder)
	urfs.unmount(folder)
end

return M
