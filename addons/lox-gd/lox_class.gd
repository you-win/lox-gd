extends Lox.LoxCallable

var name := ""
var _methods := {}

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(name: String, methods: Dictionary) -> void:
	self.name = name
	_methods.merge(methods, true)

func _to_string() -> String:
	return name

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func lox_call(interpreter: Lox.Interpreter, arguments: Array) -> Variant:
	var instance := Lox.LoxInstance.new(self)
	return instance

func arity() -> int:
	return 0

func find_method(name: String) -> Lox.LoxFunction:
	return _methods.get(name, null)
