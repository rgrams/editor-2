return {
	properties = { { "useProjectLocalPaths", true, "bool" } },
	isSceneFile = true,
	{
		children = {
			{
				class = "GUI Row",
				properties = {
					{ "id", "BMFK6Q", "string" },
					{ "name", "Toolbar", "string" },
					{ "size", { x = 100, y = 26 }, "vec2" },
					{ "modeX", "fill", "GUIResizeMode" },
					{ isExtra = true, "Class", "core/ui/Toolbar.lua", "file" }
				}
			},
			{
				children = {
					{
						children = {
							{
								class = "GUI Row",
								properties = {
									{ "id", "7qnDLa", "string" },
									{ "name", "TabBar", "string" },
									{ "size", { x = 100, y = 24 }, "vec2" },
									{ "modeX", "fill", "GUIResizeMode" },
									{ "spacing", 2, "float" },
									{ isExtra = true, "Class", "core/ui/TabBar.lua", "file" }
								}
							},
							{
								class = "GUI Node",
								properties = {
									{ "id", "5DixsW", "string" },
									{ "name", "Viewport", "string" },
									{ "size", { x = 50, y = 50 }, "vec2" },
									{ "modeX", "fill", "GUIResizeMode" },
									{ "modeY", "fill", "GUIResizeMode" },
									{ isExtra = true, "isGreedy", true, "bool" },
									{ isExtra = true, "Class", "core/ui/Viewport.lua", "file" }
								}
							}
						},
						class = "GUI Column",
						properties = {
							{ "id", "nsgHG0", "string" },
							{ "name", "VPColumn", "string" },
							{ "modeX", "fill", "GUIResizeMode" },
							{ "modeY", "fill", "GUIResizeMode" },
							{ isExtra = true, "isGreedy", true, "bool" }
						}
					},
					{
						class = "GUI Node",
						properties = {
							{ "id", "vk73mJ", "string" },
							{ "name", "ResizeHandle", "string" },
							{ "size", { x = 6, y = 6 }, "vec2" },
							{ "modeY", "fill", "GUIResizeMode" },
							{ isExtra = true, "Class", "core/ui/widgets/ResizeHandle.lua", "file" },
							{ isExtra = true, "target", "/Window/UI/MainRow/PropertyPanel", "string" }
						}
					},
					{
						class = "GUI Column",
						properties = {
							{ "id", "BhT1KG", "string" },
							{ "name", "PropertyPanel", "string" },
							{ "size", { x = 300, y = 600 }, "vec2" },
							{ "pivot", "E", "cardinalDir" },
							{ "anchor", "E", "cardinalDir" },
							{ "modeX", "fill", "GUIResizeMode" },
							{ "modeY", "fill", "GUIResizeMode" },
							{ "pad", { x = 4, y = 4 }, "vec2" },
							{ isExtra = true, "Class", "core/ui/PropertyPanel.lua", "file" }
						}
					}
				},
				class = "GUI Row",
				properties = {
					{ "id", "i6fFTu", "string" },
					{ "name", "MainRow", "string" },
					{ "modeX", "fill", "GUIResizeMode" },
					{ "modeY", "fill", "GUIResizeMode" },
					{ isExtra = true, "isGreedy", true, "bool" }
				}
			}
		},
		class = "GUI Column",
		properties = {
			{ "id", "4VmrwF", "string" },
			{ "name", "UI", "string" },
			{ "size", { x = 1600, y = 900 }, "vec2" },
			{ isExtra = true, "Class", "core/ui/UI.lua", "file" }
		}
	}
}
