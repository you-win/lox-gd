extends RefCounted

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

static func _define_ast(
	output_dir: String,
	base_name: String,
	types: Array
) -> int:
	output_dir = "%s/%s.gd" % [output_dir, base_name.to_lower()]
	
	var writer := FileAccess.open(output_dir, FileAccess.WRITE)
	if writer == null:
		return FileAccess.get_open_error()
	
	writer.store_line("extends RefCounted\n")
	writer.store_line("class %s:" % base_name)
	_define_visitor(writer, base_name, types.map(func(data: Dictionary) -> String:
		return data.name
	))
	
	for data in types:
		_define_type(writer, base_name, data.name, data.params)
	
	writer.store_line("\tfunc accept(visitor: Variant) -> Variant:\n\t\treturn null")
	
	return OK

static func _define_type(
	writer: FileAccess,
	base_name: String,
	clazz_name: String,
	fields: Array
) -> void:
	writer.store_line("\tclass %s extends %s:" % [clazz_name, base_name])
	
	var init_params := ""
	for field in fields:
		init_params = "%s: %s" % [field.name, field.type] if init_params.is_empty() else \
			"%s, %s: %s" % [init_params, field.name, field.type]
		writer.store_line("\t\tvar %s: %s" % [field.name, field.type])
	writer.store_line("\t\tfunc _init(%s):" % init_params)
	
	for field in fields.map(func(data: Dictionary) -> String:
		return data.name
	):
		writer.store_line("\t\t\tself.%s = %s" % [field, field])
	
	writer.store_line("\t\tfunc accept(visitor: Variant) -> Variant:")
	writer.store_line("\t\t\treturn visitor.visit_%s_%s(self)" % [
		clazz_name.to_lower(), base_name.to_lower()
	])
	
	writer.store_line("")

static func _define_visitor(
	writer: FileAccess,
	base_name: String,
	types: Array
) -> void:
	writer.store_line("\tclass Visitor:")

	for type in types:
		writer.store_line("\t\tfunc visit_%s_%s(%s: %s) -> Variant:" % [
			type.to_lower(), base_name.to_lower(),
			base_name.to_lower(), type
		])
		writer.store_line("\t\t\treturn null")

	writer.store_line("")

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

static func generate(out_dir: String, clazz_name: String, definitions: Array) -> int:
	return _define_ast(out_dir, clazz_name, definitions)
