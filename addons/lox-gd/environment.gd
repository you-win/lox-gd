extends RefCounted

var enclosing: Lox.LoxEnvironment = null

var values := {}

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(enclosing: Lox.LoxEnvironment = null) -> void:
	self.enclosing = enclosing

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func define(name: String, value: Variant) -> void:
	values[name] = value

func assign(name: Lox.Token, value: Variant) -> void:
	if values.has(name.lexeme):
		values[name.lexeme] = value
		return
	
	if enclosing != null:
		enclosing.assign(name, value)
		return
	
	Lox.error(name, "Undefined variable '%s'." % str(name.lexeme))

func get_value(token: Lox.Token) -> Variant:
	if values.has(token.lexeme):
		return values[token.lexeme]
	
	if enclosing != null:
		return enclosing.get_value(token)
	
	Lox.error(token, "Undefined variable '%s'." % token.lexeme)
	
	return null
