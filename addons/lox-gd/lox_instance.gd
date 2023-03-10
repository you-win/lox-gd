extends RefCounted

var _clazz: Lox.LoxClass = null
var _fields := {}

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(clazz: Lox.LoxClass) -> void:
	_clazz = clazz

func _to_string() -> String:
	return "%s instance" % _clazz.name

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func get_value(name: Lox.Token) -> Variant:
	if _fields.has(name.lexeme):
		return _fields[name.lexeme]
	
	var method := _clazz.find_method(name.lexeme)
	if method != null:
		return method
	
	Lox.error(name, "Undefined property '%s'." % name.lexeme)
	
	return Lox.throw(name)

func set_value(name: Lox.Token, value: Variant) -> void:
	_fields[name.lexeme] = value
