
local DialogBox = require "core.ui.dialogs.DialogBox"
local NewProjectDialog = DialogBox:extend()

local config = require "core.config"
local fileDialog = require "core.lib.native-file-dialog.dialog"
local Button = require "core.ui.widgets.Button"
local InputField = require "core.ui.widgets.InputField"
local InputFieldTheme = require "core.ui.widgets.themes.InputFieldTheme"

NewProjectDialog.width = 600
NewProjectDialog.height = 400

function NewProjectDialog.set(self, callback)
	NewProjectDialog.super.set(self, "New Project")
	assert(type(callback) == "function", "NewProjectDialog(callback) - Must provide a callback function, not: '"..tostring(callback).."'.")
	self.callback = callback
end

local defaultProjectName = "My Project"
local labelFontData = { "core/assets/font/OpenSans-Semibold.ttf", 16 }
local pathLabelFontData = { "core/assets/font/OpenSans-Regular.ttf", 14 }

local titleSet -- Callback for project title input field.
local selectParentFolder -- Callback for select parent folder button.
local createProject -- Callback for confirm/create project button.

function NewProjectDialog.addContent(self, contentBox)
	contentBox:setPad(15, 15)
	local contentColumn = gui.Column(10, false, -1, 500, 10, "C", "C", "fill", "fill", 10, 0)
	contentBox.children = { contentColumn }

	self.projectTitle = defaultProjectName
	self.folder = config.lastOpenFolder

	local projectTitle = gui.Text("Project Title:", labelFontData, 100, "C", "C", "center", "fill")
	local titleField = InputField(defaultProjectName, 250):setMode("none", "none")
	local parentFolder = gui.Text("Select Parent Folder:", labelFontData, 100, "C", "C", "center", "fill")
	local selectFolderBtn = Button("...", nil, "center")
	local finalPath = gui.Text("Final Project Path:", labelFontData, 100, "C", "C", "center", "fill")
	local path = gui.Text(self.folder..defaultProjectName, pathLabelFontData, 100, "C", "C", "center", "fill", true)
	path.color = {1, 1, 1, 0.5}
	contentColumn.children = {
		projectTitle,
		titleField,
		parentFolder,
		selectFolderBtn,
		finalPath,
		path
	}
	self.parentFolderLabel = parentFolder
	self.finalPathLabel = path
	local field = self.ruu:InputField(titleField, titleSet, defaultProjectName, InputFieldTheme)
	field:args(self, field)
	local folderBtn = self.ruu:Button(selectFolderBtn, selectParentFolder):args(self)
	self.titleField = field
	self.selectFolderBtn = folderBtn
end

function NewProjectDialog.addButtons(self, buttonBox)
	local btnWidth = 130
	local btnOX = btnWidth/2 + 10
	local cancelBtn = Button("Cancel", btnWidth, "center"):setPos(-btnOX)
	local confirmBtn = Button("Create Project", btnWidth, "center"):setPos(btnOX)
	buttonBox.children = { cancelBtn, confirmBtn }
	local btn1 = self.ruu:Button(cancelBtn, self.cancel):args(self)
	local btn2 = self.ruu:Button(confirmBtn, createProject):args(self)
	self.ruu:mapNextPrev({ self.titleField, self.selectFolderBtn, btn1, btn2 })
	self.ruu:mapNeighbors({
		{ self.titleField },
		{ self.selectFolderBtn },
		{ btn1, btn2 }
	})
	btn2.neighbor.up = self.selectFolderBtn
	self.initialFocusWidget = self.titleField
end

function titleSet(self, field)
	self.finalPathLabel.text = self.folder .. field.text
	self.projectTitle = field.text
end

function selectParentFolder(self)
	local filepath = fileDialog.pickFolder(self.folder)
	if filepath then
		if not filepath:sub(-1, -1):match("[\\/]") then
			filepath = filepath .. "/"
		end
		self.folder = filepath
		self.finalPathLabel.text = self.folder .. self.projectTitle
	end
end

function createProject(self)
	self:close()
	self.callback(self.projectTitle, self.folder)
end

return NewProjectDialog
