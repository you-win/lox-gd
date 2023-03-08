extends RefCounted

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init() -> void:
	pass

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _define_ast(
	output_dir: String,
	base_name: String,
	types: Array[String]
) -> int:
	var path := "%s/%s.gd" % [output_dir, base_name.to_lower()]
	var writer := FileAccess.open(path, FileAccess.WRITE)
	if writer == null:
		printerr("Failed to create AST at path %s" % path)
		return ERR_FILE_CANT_WRITE
	
	writer.store_line("extends RefCounted\n")
	writer.store_line("class %s:" % base_name)
	_define_visitor(writer, base_name, types)
	
	for type in types:
		var clazz_name := type.split(":", false, 1)[0].strip_edges()
		var fields := type.split(":", false, 1)[1].strip_edges()
		_define_type(writer, base_name, clazz_name, fields)
	
	writer.store_line("\tfunc accept(visitor: Variant) -> Variant:\n\t\treturn null")
	
	return OK

func _define_type(
	writer: FileAccess,
	base_name: String,
	clazz_name: String,
	field_list: String
) -> void:
	writer.store_line("\tclass %s extends %s:" % [clazz_name, base_name])
	
	var fields := field_list.split(", ")
	for field in fields:
		writer.store_line("\t\tvar %s" % field)
	
	writer.store_line("\t\tfunc _init(%s):" % field_list)
	for field in fields:
		var name := field.split(":")[0]
		writer.store_line("\t\t\tself.%s = %s" % [name, name])
	
	writer.store_line("\t\tfunc accept(visitor: Variant) -> Variant:")
	writer.store_line("\t\t\treturn visitor.visit_%s_%s(self)" % [
		clazz_name.to_lower(), base_name.to_lower()
	])
	
	writer.store_line("")

func _define_visitor(
	writer: FileAccess,
	base_name: String,
	types: Array[String]
) -> void:
	writer.store_line("\tclass Visitor:")
	
	for type in types:
		var type_name := type.split(":")[0].strip_edges()
		writer.store_line("\t\tfunc visit_%s_%s(%s: %s) -> Variant:" % [
			type_name.to_lower(), base_name.to_lower(),
			base_name.to_lower(), type_name
		])
		writer.store_line("\t\t\treturn null")
	
	writer.store_line("")

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func generate(out_dir: String, clazz_name: String, definitions: Array[String]) -> int:
	return _define_ast(out_dir, clazz_name, definitions)
