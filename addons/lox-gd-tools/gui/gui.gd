extends PanelContainer

var plugin: EditorPlugin = null

@onready
var views := %Views

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _ready() -> void:
	var status := %Status
	
	var ast: Control = load("res://addons/lox-gd-tools/gui/ast.tscn").instantiate()
	plugin.inject_tool(ast)
	ast.plugin = plugin
	ast.status_updated.connect(func(text: String) -> void:
		status.text = text
	)
	views.add_child(ast)

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

