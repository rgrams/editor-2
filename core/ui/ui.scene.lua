return {
	isSceneFile = true,
	lastUsedExporter = "lua export for runtime",
	lastExportFilepath = "core/ui/ui.lua",
	properties = { { name = "useProjectLocalPaths", value = true, type = "bool" } },
	{
		class = "GUI Column",
		children = {
			{
				properties = {
					{ name = "id", value = "BMFK6Q", type = "string" },
					{ name = "name", value = "Toolbar", type = "string" },
					{ name = "size", value = { x = 100, y = 26 }, type = "vec2" },
					{ name = "modeX", value = "fill", type = "GUIResizeMode" },
					{ name = "Class", value = "core/ui/Toolbar.lua", type = "file" }
				},
				class = "GUI Row"
			},
			{
				class = "GUI Row",
				children = {
					{
						class = "GUI Column",
						children = {
							{
								properties = {
									{ name = "id", value = "7qnDLa", type = "string" },
									{ name = "name", value = "TabBar", type = "string" },
									{ name = "size", value = { x = 100, y = 24 }, type = "vec2" },
									{ name = "modeX", value = "fill", type = "GUIResizeMode" },
									{ name = "spacing", value = 2, type = "float" },
									{ name = "Class", value = "core/ui/TabBar.lua", type = "file" }
								},
								class = "GUI Row"
							},
							{
								properties = {
									{ name = "id", value = "5DixsW", type = "string" },
									{ name = "name", value = "Viewport", type = "string" },
									{ name = "size", value = { x = 50, y = 50 }, type = "vec2" },
									{ name = "modeX", value = "fill", type = "GUIResizeMode" },
									{ name = "modeY", value = "fill", type = "GUIResizeMode" },
									{ name = "isGreedy", value = true, type = "bool" },
									{ name = "Class", value = "core/ui/Viewport.lua", type = "file" }
								},
								class = "GUI Node"
							}
						},
						properties = {
							{ name = "id", value = "nsgHG0", type = "string" },
							{ name = "name", value = "VPColumn", type = "string" },
							{ name = "modeX", value = "fill", type = "GUIResizeMode" },
							{ name = "modeY", value = "fill", type = "GUIResizeMode" },
							{ name = "isGreedy", value = true, type = "bool" }
						}
					},
					{
						properties = {
							{ name = "id", value = "vk73mJ", type = "string" },
							{ name = "name", value = "ResizeHandle", type = "string" },
							{ name = "size", value = { x = 6, y = 6 }, type = "vec2" },
							{ name = "modeY", value = "fill", type = "GUIResizeMode" },
							{
								name = "Class",
								value = "core/ui/widgets/ResizeHandle.lua",
								type = "file"
							},
							{
								name = "target",
								value = "/Window/UI/MainRow/PropertyPanel",
								type = "string"
							}
						},
						class = "GUI Node"
					},
					{
						properties = {
							{ name = "id", value = "BhT1KG", type = "string" },
							{ name = "name", value = "PropertyPanel", type = "string" },
							{ name = "size", value = { x = 250, y = 600 }, type = "vec2" },
							{ name = "pivot", value = "E", type = "cardinalDir" },
							{ name = "anchor", value = "E", type = "cardinalDir" },
							{ name = "modeX", value = "fill", type = "GUIResizeMode" },
							{ name = "modeY", value = "fill", type = "GUIResizeMode" },
							{ name = "pad", value = { x = 4, y = 4 }, type = "vec2" },
							{ name = "Class", value = "core/ui/PropertyPanel.lua", type = "file" }
						},
						class = "GUI Column"
					}
				},
				properties = {
					{ name = "id", value = "i6fFTu", type = "string" },
					{ name = "name", value = "MainRow", type = "string" },
					{ name = "modeX", value = "fill", type = "GUIResizeMode" },
					{ name = "modeY", value = "fill", type = "GUIResizeMode" },
					{ name = "isGreedy", value = true, type = "bool" }
				}
			}
		},
		properties = {
			{ name = "id", value = "4VmrwF", type = "string" },
			{ name = "name", value = "UI", type = "string" },
			{ name = "size", value = { x = 1600, y = 900 }, type = "vec2" },
			{ name = "Class", value = "core/ui/UI.lua", type = "file" }
		}
	}
}
