extends VBoxContainer

class Ast extends VBoxContainer:
	var _title_le: LineEdit = null
	var _path_le: LineEdit = null
	var _items: VBoxContainer = null
	
	func _init(ast_name: String = "") -> void:
		var title := HBoxContainer.new()
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var title_label := Label.new()
		title_label.text = "Ast Name"
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var title_inner_hbox := HBoxContainer.new()
		title_inner_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		_title_le = LineEdit.new()
		_title_le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_title_le.text = ast_name
		
		var title_delete := Button.new()
		title_delete.text = "Delete"
		title_delete.pressed.connect(func() -> void:
			queue_free()
		)
		title_delete.focus_entered.connect(func() -> void:
			title_delete.find_next_valid_focus().grab_focus()
		)
		
		title_inner_hbox.add_child(_title_le)
		title_inner_hbox.add_child(title_delete)
		
		title.add_child(title_label)
		title.add_child(title_inner_hbox)
		
		add_child(title)
		
		var path := HBoxContainer.new()
		path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var add_item_button := Button.new()
		add_item_button.text = "Add Item"
		add_item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_item_button.pressed.connect(func() -> void:
			_items.add_child(AstItem.new())
		)
		
		add_child(add_item_button)
		
		_items = VBoxContainer.new()
		_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		add_child(_items)
		
		add_child(HSeparator.new())
	
	func get_items() -> VBoxContainer:
		return _items
	
	func get_ast_name() -> String:
		return _title_le.text
	
	func get_ast_items() -> Array:
		return _items.get_children()

class AstItem extends HBoxContainer:
	class Param extends HBoxContainer:
		var _param_name_hbox_le: LineEdit = null
		var _param_type_hbox_le: LineEdit = null
		
		func _init(param_name: String = "", param_type: String = "") -> void:
			add_child(VSeparator.new())
			
			var spacer := Control.new()
			spacer.custom_minimum_size.x = 20
			
			add_child(spacer)
			
			var field_names := VBoxContainer.new()
			field_names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var param_name_label := Label.new()
			param_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			param_name_label.text = "Param Name"
			
			field_names.add_child(param_name_label)
			
			var param_type_label := Label.new()
			param_type_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			param_type_label.text = "Param Type"
			
			field_names.add_child(param_type_label)
			
			var inner_hbox := HBoxContainer.new()
			inner_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var inner_vbox := VBoxContainer.new()
			inner_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			inner_hbox.add_child(inner_vbox)
			
			_param_name_hbox_le = LineEdit.new()
			_param_name_hbox_le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_param_name_hbox_le.text = param_name
			
			inner_vbox.add_child(_param_name_hbox_le)
			
			_param_type_hbox_le = LineEdit.new()
			_param_type_hbox_le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_param_type_hbox_le.text = param_type
			
			inner_vbox.add_child(_param_type_hbox_le)
			
			var delete_button := Button.new()
			delete_button.text = "Delete"
			delete_button.pressed.connect(func() -> void:
				queue_free()
			)
			delete_button.focus_entered.connect(func() -> void:
				delete_button.find_next_valid_focus().grab_focus()
			)
			
			inner_hbox.add_child(delete_button)
			
			add_child(field_names)
			add_child(inner_hbox)
		
		func get_param_name() -> String:
			return _param_name_hbox_le.text
		
		func get_param_type() -> String:
			return _param_type_hbox_le.text
	
	var _vbox: VBoxContainer = null
	
	var _title_le: LineEdit = null
	var _items: VBoxContainer = null
	
	func _init(item_name: String = "") -> void:
		add_child(VSeparator.new())
		
		var spacer := Control.new()
		spacer.custom_minimum_size.x = 20
		
		add_child(spacer)
		
		_vbox = VBoxContainer.new()
		_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		add_child(_vbox)
		
		var title := HBoxContainer.new()
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var title_label := Label.new()
		title_label.text = "Item Name"
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var inner_hbox := HBoxContainer.new()
		inner_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		_title_le = LineEdit.new()
		_title_le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_title_le.text = item_name
		
		inner_hbox.add_child(_title_le)
		
		var title_delete := Button.new()
		title_delete.text = "Delete"
		title_delete.pressed.connect(func() -> void:
			queue_free()
		)
		title_delete.focus_entered.connect(func() -> void:
			title_delete.find_next_valid_focus().grab_focus()
		)
		
		inner_hbox.add_child(title_delete)
		
		title.add_child(title_label)
		title.add_child(inner_hbox)
		
		_vbox.add_child(title)
		
		var add_item_button := Button.new()
		add_item_button.text = "Add Param"
		add_item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_item_button.pressed.connect(func() -> void:
			_items.add_child(Param.new())
		)
		
		_vbox.add_child(add_item_button)
		
		_items = VBoxContainer.new()
		_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		_vbox.add_child(_items)
	
	func get_items() -> VBoxContainer:
		return _items
	
	func get_item_name() -> String:
		return _title_le.text
	
	func get_item_params() -> Array:
		return _items.get_children()

signal status_updated(text: String)

const AST_DIR := "res://addons/lox-gd/ast"
const DEF_DIR := "res://addons/lox-gd-tools/__ast_definitions"

var plugin: EditorPlugin = null

@onready
var _workspace := %Workspace

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _ready() -> void:
	%AddAst.pressed.connect(func() -> void:
		_workspace.add_child(Ast.new())
	)
	%ImportAst.pressed.connect(func() -> void:
		var dir := DirAccess.open(DEF_DIR)
		if dir == null:
			printerr(DirAccess.get_open_error())
			status_updated.emit("Error occurred while opening directory %s: %d" % [
				DEF_DIR, DirAccess.get_open_error()]
			)
			return
		
		for file_name in dir.get_files():
			var contents := FileAccess.get_file_as_string("%s/%s" % [DEF_DIR, file_name])
			var data: Variant = JSON.parse_string(contents)
			if data == null:
				printerr("Unable to parse definition from %s/%s" % [DEF_DIR, file_name])
				status_updated.emit("Unable to parse definition from %s/%s" % [DEF_DIR, file_name])
				continue
			
			var already_exists := false
			for child in _workspace.get_children():
				if child.get_ast_name() == data.name:
					already_exists = true
					break
			if already_exists:
				print("Definition for %s/%s already exists in the editor" % [DEF_DIR, file_name])
				status_updated.emit("Definition for %s/%s already exists in the editor" % [DEF_DIR, file_name])
				continue
			
			var ast := Ast.new(data.name)
			var ast_items := ast.get_items()
			for item in data.items:
				var ast_item := AstItem.new(item.name)
				var ast_item_items := ast_item.get_items()
				for param in item.params:
					ast_item_items.add_child(AstItem.Param.new(param.name, param.type))
				
				ast_items.add_child(ast_item)
			
			_workspace.add_child(ast)
		
		status_updated.emit("Successfully imported AST definitions")
	)
	%Generate.pressed.connect(func() -> void:
		for ast in _workspace.get_children():
			var data := {
				"name" = "",
				"items" = []
			}
			data.name = ast.get_ast_name()
			for item in ast.get_ast_items():
				var params := []
				for param in item.get_item_params():
					params.push_back({
						"name": param.get_param_name(), "type": param.get_param_type()
					})
				
				data.items.push_back({
					"name" = item.get_item_name(),
					"params" = params
				})
			
			plugin.GenerateAst.generate(AST_DIR, data.name, data.items)
			
			var err := DirAccess.make_dir_absolute(DEF_DIR)
			if err != OK and err != ERR_ALREADY_EXISTS:
				printerr(err)
				status_updated.emit("Error occurred while making AST definition directory at %s" % \
					DEF_DIR)
				return
			
			var file := FileAccess.open("%s/%s.json" % [DEF_DIR, data.name.to_lower()], FileAccess.WRITE)
			if file == null:
				printerr(FileAccess.get_open_error())
				status_updated.emit("Error occurred while saving AST definition at %s: %d" % [
					"%s/%s.json" % [DEF_DIR, data.name.to_lower()], FileAccess.get_open_error()])
				return
			
			file.store_string(JSON.stringify(data, "\t", false))
		
		plugin.get_editor_interface().get_resource_filesystem().scan()
		
		status_updated.emit("Successfully generated AST files")
	)

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#
