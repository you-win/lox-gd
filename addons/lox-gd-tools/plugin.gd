@tool
extends EditorPlugin

const GenerateAst := preload("./generate_ast.gd")

const Gui := preload("res://addons/lox-gd-tools/gui/gui.tscn")
var gui: Control = null
const LOX_GUI_NAME := "Lox Tools"

func _enter_tree() -> void:
	gui = Gui.instantiate()
	inject_tool(gui)
	gui.plugin = self
	
	add_control_to_bottom_panel(gui, LOX_GUI_NAME)

func _exit_tree() -> void:
	if gui != null:
		remove_control_from_bottom_panel(gui)
		gui.free()

func inject_tool(node: Node) -> int:
	var script: GDScript = node.get_script().duplicate()
	script.source_code = "@tool\n%s" % script.source_code
	
	var err := script.reload()
	if err != OK:
		return err
	
	node.set_script(script)
	
	return OK
