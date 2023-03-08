extends RefCounted

var values := {}

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func define(name: String, value: Variant) -> void:
	values[name] = value

func get_value(token: Lox.Token) -> Variant:
	if values.has(token.lexeme):
		return values[token.lexeme]
	
	Lox.error(token, "Undefined variable '%s'." % token.lexeme)
	
	return null
