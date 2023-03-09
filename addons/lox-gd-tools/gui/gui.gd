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
	ast.name = "AST Editor"
	views.add_child(ast)
	
	var repl: Control = load("res://addons/lox-gd-tools/gui/repl.tscn").instantiate()
	plugin.inject_tool(repl)
	repl.plugin = plugin
	repl.status_updated.connect(func(text: String) -> void:
		status.text = text
	)
	repl.name = "REPL"
	views.add_child(repl)

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

