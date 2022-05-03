
local ffi = package.preload.ffi()
local OS = love.system.getOS()

local libPath

if OS == "Linux" then
	libPath = "lib/native-file-dialog/nfd.so"
elseif OS == "Windows" then
	libPath = "lib/native-file-dialog/nfd.dll"
elseif OS == "OS X" then
	libPath = "lib/native-file-dialog/libnfd.dylib"
end

local nfd = ffi.load(libPath)
ffi.cdef[[
	enum {
		NFD_ERROR,
		NFD_OKAY,
		NFD_CANCEL
	};
	unsigned int NFD_SaveDialog(const char *filterList, const char *defaultPath, char **outPath);
	unsigned int NFD_OpenDialog(const char *filterList, const char *defaultPath, char **outPath);
	const char *NFD_GetError(void);
]]

-- TODO: Add open multiple option.
-- Need to define `nfdpathset_t` struct type https://github.com/Alloyed/nativefiledialog/blob/master/src/include/nfd.h
-- unsigned int NFD_OpenDialogMultiple(const char *filterList, const char *defaultPath, nfdpathset_t *outPaths);

local dialog = {}

function dialog.save(filters, default_path)
	local out_path = ffi.new 'char*[1]'
	local r = nfd.NFD_SaveDialog(filters, default_path, out_path)
	if r == nfd.NFD_OKAY then
		return ffi.string(out_path[0])
	elseif r == nfd.NFD_CANCEL then
		print("User canceled dialog.")
	else
		print("Dialog error: " .. tostring(ffi.string(nfd.NFD_GetError())))
	end

	return nil
end

function dialog.open(filters, default_path, isOpenMultiple)
	local out_path = ffi.new 'char*[1]'
	local r = nfd.NFD_OpenDialog(filters, default_path, out_path)
	if r == nfd.NFD_OKAY then
		return ffi.string(out_path[0])
	elseif r == nfd.NFD_CANCEL then
		print("User canceled dialog.")
	else
		print("Dialog error: " .. tostring(ffi.string(nfd.NFD_GetError())))
	end

	return nil
end

return dialog
