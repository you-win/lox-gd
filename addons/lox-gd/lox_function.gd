extends Lox.LoxCallable

var _declaration: Lox.Stmt.Function = null
var _closure: Lox.LoxEnvironment = null

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(declaration: Lox.Stmt.Function, closure: Lox.LoxEnvironment) -> void:
	_declaration = declaration
	_closure = closure

func _to_string() -> String:
	return "<fn %s >" % _declaration.name.lexeme

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func arity() -> int:
	return _declaration.params.size()

func lox_call(interpreter: Lox.Interpreter, arguments: Array) -> Variant:
	var environment := Lox.LoxEnvironment.new(_closure)
	for i in _declaration.params.size():
		environment.define(_declaration.params[i].lexeme, arguments[i])
	
	interpreter.execute_block(_declaration.body, environment)
	
	return Lox.get_error_handler().take()
