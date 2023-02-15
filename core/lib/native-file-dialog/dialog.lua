
local ffi = require "ffi"
local OS = love.system.getOS()

local saveDir = love.filesystem.getSaveDirectory()
local sourceDir = "core/lib/native-file-dialog/"

local libPath
if OS == "Linux" then
	libPath = "nfd.so"
elseif OS == "Windows" then
	if ffi.abi("64bit") then
		libPath = "nfd64.dll"
	else
		libPath = "nfd.dll"
	end
elseif OS == "OS X" then
	libPath = "libnfd.dylib"
end

-- Copy library file into save directory and load from there.
local libData, sizeOrError = love.filesystem.read(sourceDir..libPath)
love.filesystem.write(libPath, libData)

local nfd = ffi.load(saveDir.."/"..libPath)
ffi.cdef[[
	typedef char nfdchar_t;
	typedef struct {
		nfdchar_t *buf;
		size_t *indices; /* byte offsets into buf */
		size_t count;    /* number of indices into buf */
	}nfdpathset_t;

	typedef enum {
		NFD_ERROR,       /* programmatic error */
		NFD_OKAY,        /* user pressed okay, or successful return */
		NFD_CANCEL       /* user pressed cancel */
	}nfdresult_t;

	/* single file open dialog */
	nfdresult_t NFD_OpenDialog( const nfdchar_t *filterList,
	                            const nfdchar_t *defaultPath,
	                            nfdchar_t **outPath );
	/* multiple file open dialog */
	nfdresult_t NFD_OpenDialogMultiple( const nfdchar_t *filterList,
	                                    const nfdchar_t *defaultPath,
	                                    nfdpathset_t *outPaths );
	/* save dialog */
	nfdresult_t NFD_SaveDialog( const nfdchar_t *filterList,
	                            const nfdchar_t *defaultPath,
	                            nfdchar_t **outPath );
	/* select folder dialog */
	nfdresult_t NFD_PickFolder( const nfdchar_t *defaultPath,
	                            nfdchar_t **outPath);
	/* get last error -- set when nfdresult_t returns NFD_ERROR */
	const char *NFD_GetError( void );
	/* get the number of entries stored in pathSet */
	size_t      NFD_PathSet_GetCount( const nfdpathset_t *pathSet );
	/* Get the UTF-8 path at offset index */
	nfdchar_t  *NFD_PathSet_GetPath( const nfdpathset_t *pathSet, size_t index );
	/* Free the pathSet */
	void        NFD_PathSet_Free( nfdpathset_t *pathSet );
]]

-- 	File Filter Syntax:
-- A wildcard filter is always added to every dialog.
-- ';' Begin a new filter.
-- ',' Add a separate type to the filter.

-- EXAMPLE: 'txt' The default filter is for text files. There is a wildcard option in a dropdown.
-- EXAMPLE: 'png,jpg;psd' The default filter is for png and jpg files. A second filter is available for psd files. There is a wildcard option in a dropdown.

local dialog = {}

function dialog.save(default_path, filters)
	local out_path = ffi.new 'char*[1]'
	local r = nfd.NFD_SaveDialog(filters, default_path, out_path)
	if r == nfd.NFD_OKAY then
		return ffi.string(out_path[0])
	elseif r == nfd.NFD_CANCEL then
		print("User canceled dialog.")
	else
		print("Dialog error: " .. tostring(ffi.string(nfd.NFD_GetError())))
	end
end

function dialog.open(default_path, filters)
	local out_path = ffi.new('nfdchar_t *[1]')
	local result = nfd.NFD_OpenDialog(filters, default_path, out_path)
	if result == nfd.NFD_OKAY then
		return ffi.string(out_path[0])
	elseif result == nfd.NFD_CANCEL then
		print("User canceled dialog.")
	else
		print("Dialog error: " .. tostring(ffi.string(nfd.NFD_GetError())))
	end
end

function dialog.openMultiple(filters, default_path)
	local pathset = ffi.new('nfdpathset_t')
	local result = nfd.NFD_OpenDialogMultiple(filters, default_path, pathset)
	if result == nfd.NFD_OKAY then
		local paths = {}
		for i=1,tonumber(nfd.NFD_PathSet_GetCount(pathset)) do
			paths[i] = ffi.string(nfd.NFD_PathSet_GetPath(pathset, i-1))
		end
		nfd.NFD_PathSet_Free(pathset)
		return paths
	elseif result == nfd.NFD_CANCEL then
		print("User canceled dialog.")
	else
		print("Dialog error: " .. tostring(ffi.string(nfd.NFD_GetError())))
	end
end

function dialog.pickFolder(default_path)
	local out_path = ffi.new('nfdchar_t *[1]')
	local result = nfd.NFD_PickFolder(default_path, out_path)
	if result == nfd.NFD_OKAY then
		return ffi.string(out_path[0])
	elseif result == nfd.NFD_CANCEL then
		print("User canceled dialog.")
	else
		print("Dialog error: " .. tostring(ffi.string(nfd.NFD_GetError())))
	end
end

return dialog
