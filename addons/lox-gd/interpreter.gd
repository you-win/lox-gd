extends RefCounted

## Lox interpreter
##
## Currently does not implement number checking since we cannot throw anyways.
## Will likely need to emulate a tuple and propogate errors like Golang.

const Expr := Lox.Expr
const Stmt := Lox.Stmt
const TokenType := Lox.TokenType

class Clock extends Lox.LoxCallable:
	func _to_string() -> String:
		return "<native fn>"
	
	func arity() -> int:
		return 0
	
	func lox_call(interpreter: Lox.Interpreter, arguments: Array) -> Variant:
		return Time.get_time_string_from_system()

var globals := Lox.LoxEnvironment.new()
var _environment := globals
var _locals := {}

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init() -> void:
	globals.define("clock", Clock.new())
	pass

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

func _look_up_variable(name: Lox.Token, expr: Expr) -> Variant:
	var distance: int = _locals.get(expr, -1)
	if distance != null:
		return _environment.get_value_at(distance, name.lexeme)
	else:
		return globals.get_value(name)

func _execute(stmt: Stmt) -> void:
	stmt.accept(self)

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func execute_block(statements: Array, environment: Lox.LoxEnvironment) -> void:
	var previous := _environment
	
	_environment = environment
	
	for statement in statements:
		_execute(statement)
	
	_environment = previous

func visit_assign_expr(expr: Expr.Assign) -> Variant:
	var value: Variant = _evaluate(expr.value)
	_environment.assign(expr.name, value)
	
	var distance: int = _locals.get(expr, -1)
	if distance > 0:
		_environment.assign_at(distance, expr.name, value)
	else:
		globals.assign(expr.name, value)
	
	return value

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
	return _look_up_variable(expr.name, expr)

func visit_logical_expr(expr: Expr.Logical) -> Variant:
	var left: Variant = _evaluate(expr.left)
	
	if expr.operator.type == TokenType.OR:
		if _is_truthy(left):
			return left
	elif not _is_truthy(left):
		return left
	
	return _evaluate(expr.right)

func visit_call_expr(expr: Expr.Call) -> Variant:
	var callee: Variant = _evaluate(expr.callee)
	
	var arguments := []
	for argument in expr.arguments:
		arguments.push_back(_evaluate(argument))
	
	if not callee is Lox.LoxCallable:
		Lox.error(expr.pare, "Can only call functions and classes.")
		return
	
	var function: Lox.LoxCallable = callee
	if arguments.size() != function.arity():
		Lox.error(expr.paren, "Expected %d arguments but got %d." % [
			function.arity(), arguments.size()
		])
		return
	
	return function.lox_call(self, arguments)

func visit_if_stmt(stmt: Stmt.If) -> Variant:
	if _is_truthy(_evaluate(stmt.condition)):
		_execute(stmt.then_branch)
	elif stmt.else_branch != null:
		_execute(stmt.else_branch)
	
	return null

func visit_block_stmt(stmt: Stmt.Block) -> Variant:
	execute_block(stmt.statements, Lox.LoxEnvironment.new(_environment))
	
	return null

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

func visit_while_stmt(stmt: Stmt.While) -> Variant:
	while _is_truthy(_evaluate(stmt.condition)):
		_execute(stmt.body)
	
	return null

func visit_function_stmt(stmt: Stmt.Function) -> Variant:
	var function := Lox.LoxFunction.new(stmt, _environment)
	_environment.define(stmt.name.lexeme, function)
	
	return null

func visit_return_stmt(stmt: Stmt.Return) -> Variant:
	var value: Variant = null
	if stmt.value != null:
		value = _evaluate(stmt.value)
	
	return Lox.throw(value)

func interpret(statements: Array) -> void:
	for statement in statements:
		_execute(statement)

func resolve(expr: Expr, depth: int) -> void:
	_locals[expr] = depth
