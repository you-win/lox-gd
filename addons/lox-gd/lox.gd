class_name Lox
extends RefCounted

## Lox implemented in GDScript
##
## Should be fairly faithful to the reference Java implementation, however error handling
## is very different due to the fact that GDScript does not have exceptions.

const LoxEnvironment := preload("./environment.gd")
const LoxCallable := preload("./lox_callable.gd")
const LoxClass := preload("./lox_class.gd")
const LoxFunction := preload("./lox_function.gd")
const LoxInstance := preload("./lox_instance.gd")
const Interpreter := preload("./interpreter.gd")
const Parser := preload("./parser.gd")
const Resolver := preload("./resolver.gd")
const Scanner := preload("./scanner.gd")

const Expr := preload("./ast/expr.gd").Expr
const Stmt := preload("./ast/stmt.gd").Stmt

enum TokenType {
	NONE,
	
	# Single-character tokens
	LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
	COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,
	
	# One or two character tokens
	BANG, BANG_EQUAL,
	EQUAL, EQUAL_EQUAL,
	GREATER, GREATER_EQUAL,
	LESS, LESS_EQUAL,
	
	# Literals
	IDENTIFIER, STRING, NUMBER,
	
	# Keywords
	AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR,
	PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,
	
	EOF
}

class Token:
	var type := TokenType.NONE
	var lexeme := ""
	var literal: Variant = null
	var line: int = 0
	
	func _init(type: TokenType, lexeme: String, literal: Variant, line: int) -> void:
		self.type = type
		self.lexeme = lexeme
		self.literal = literal
		self.line = line
	
	func _to_string() -> String:
		return "%d %s %s" % [type, lexeme, str(literal)]

class ErrorHandler extends Node:
	var had_error := false
	
	var thrown_value: Variant = null
	func take() -> Variant:
		var val: Variant = thrown_value
		thrown_value = null
		
		return val
const ERROR_HANDLER_NAME := "LoxErrorHandler"

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

static func _report(line: int, where: String, message: String) -> void:
	print("[line %d] Error %s: %s" % [line, where, message])
	
	Engine.get_singleton(ERROR_HANDLER_NAME).had_error = true

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

## Needed so we can handle errors without forcing the developer to add Lox as an autoload.
static func init() -> void:
	Engine.register_singleton(ERROR_HANDLER_NAME, ErrorHandler.new())

## Probably not needed but it's nice to have.
static func deinit() -> void:
	Engine.get_singleton(ERROR_HANDLER_NAME).queue_free()
	Engine.unregister_singleton(ERROR_HANDLER_NAME)

static func had_error() -> bool:
	return Engine.get_singleton(ERROR_HANDLER_NAME).had_error

static func error_simple(line: int, message: String) -> void:
	_report(line, "", message)

static func error(token: Token, message: String) -> void:
	if token.type == TokenType.EOF:
		_report(token.line, " at end", message)
	else:
		_report(token.line, " at '%s'" % token.lexeme, message)

static func throw(value: Variant) -> Variant:
	Engine.get_singleton(ERROR_HANDLER_NAME).thrown_value = value
	
	return value

static func get_error_handler() -> ErrorHandler:
	return Engine.get_singleton(ERROR_HANDLER_NAME)
