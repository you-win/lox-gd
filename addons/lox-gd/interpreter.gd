extends RefCounted

## Lox interpreter
##
## Currently does not implement number checking since we cannot throw anyways.
## Will likely need to emulate a tuple and propogate errors like Golang.

const Expr := Lox.Expr
const Stmt := Lox.Stmt
const TokenType := Lox.TokenType

var _environment := Lox.LoxEnvironment.new()

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _evaluate(expr: Expr) -> Variant:
	return expr.accept(self)

func _is_truthy(object: Variant) -> bool:
	if object == null:
		return false
	if object is bool:
		return object
	return true

func _is_equal(a: Variant, b: Variant) -> bool:
	if a == null and b == null:
		return true
	if a == null:
		return false
	
	return a == b

func _stringify(object: Variant) -> String:
	if object == null:
		return "nil"
	
	if object is float:
		var text: String = str(object)
		if text.ends_with(".0"):
			text = text.substr(0, text.length() - 2)
		
		return text
	
	return str(object)

func _execute(stmt: Stmt) -> void:
	stmt.accept(self)

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func visit_literal_expr(expr: Expr.Literal) -> Variant:
	return expr.value

func visit_grouping_expr(expr: Expr.Grouping) -> Variant:
	return _evaluate(expr.expression)

func visit_unary_expr(expr: Expr.Unary) -> Variant:
	var right: Variant = _evaluate(expr.right)
	
	match expr.operator.type:
		TokenType.BANG:
			return not _is_truthy(right)
		TokenType.MINUS:
			return -(right as float)
	
	return null

func visit_binary_expr(expr: Expr.Binary) -> Variant:
	var left: Variant = _evaluate(expr.left)
	var right: Variant = _evaluate(expr.right)
	
	match expr.operator.type:
		TokenType.BANG_EQUAL:
			return not _is_equal(left, right)
		TokenType.EQUAL_EQUAL:
			return _is_equal(left, right)
		TokenType.GREATER:
			return (left as float) > (right as float)
		TokenType.GREATER_EQUAL:
			return (left as float) >= (right as float)
		TokenType.LESS:
			return (left as float) < (right as float)
		TokenType.LESS_EQUAL:
			return (left as float) <= (right as float)
		TokenType.MINUS:
			return (left as float) - (right as float)
		TokenType.PLUS:
			# Technically not necessary since Godot will cast the Variants for us but whatever
			if left is float and right is float:
				return (left as float) + (right as float)
			if left is String and right is String:
				return (left as String) + (right as String)
		TokenType.SLASH:
			return (left as float) / (right as float)
		TokenType.STAR:
			return (left as float) * (right as float)
	
	return null

func visit_variable_expr(expr: Expr.Variable) -> Variant:
	return _environment.get_value(expr.name)

func visit_loxexpression_stmt(stmt: Stmt.LoxExpression) -> Variant:
	_evaluate(stmt.expression)
	
	return null

func visit_loxprint_stmt(stmt: Stmt.LoxPrint) -> Variant:
	var value := _evaluate(stmt.expression)
	print(_stringify(value))
	
	return null

func visit_loxvar_stmt(stmt: Stmt.LoxVar) -> Variant:
	var value: Variant = null
	if stmt.initializer != null:
		value = _evaluate(stmt.initializer)
	
	_environment.define(stmt.name.lexeme, value)
	
	return null

func interpret(statements: Array) -> void:
	for statement in statements:
		_execute(statement)
