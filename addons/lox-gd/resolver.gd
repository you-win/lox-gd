extends RefCounted

const Expr := Lox.Expr
const Stmt := Lox.Stmt
const Token := Lox.Token

enum FunctionType {
	NONE,
	FUNCTION
}

var _interpreter: Lox.Interpreter = null
var _scopes := []
var _current_function: FunctionType = FunctionType.NONE

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(interpreter: Lox.Interpreter) -> void:
	_interpreter = interpreter

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _resolve(variant: Variant) -> void:
	variant.accept(self)

func _begin_scope() -> void:
	_scopes.push_back({})

func _end_scope() -> void:
	_scopes.pop_back()

func _declare(name: Token) -> void:
	if _scopes.is_empty():
		return
	
	var scope: Dictionary = _scopes.back()
	if scope.has(name.lexeme):
		Lox.error(name, "There is already a variable with this name in this scope.")
	scope[name.lexeme] = false

func _define(name: Token) -> void:
	if _scopes.is_empty():
		return
	
	_scopes.back()[name.lexeme] = true

func _resolve_local(expr: Expr, name: Token) -> void:
	var i: int = _scopes.size() - 1
	while i >= 0:
		if _scopes[i].has(name.lexeme):
			_interpreter.resolve(expr, _scopes.size() - 1 - i)
			return
		
		i -= 1

func _resolve_function(function: Stmt.Function, type: FunctionType) -> void:
	var enclosing_function = _current_function
	_current_function = type
	
	_begin_scope()
	
	for param in function.params:
		_declare(param)
		_define(param)
	
	resolve(function.body)
	
	_end_scope()
	
	_current_function = enclosing_function

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func visit_assign_expr(expr: Expr.Assign) -> Variant:
	_resolve(expr.value)
	_resolve_local(expr, expr.name)
	
	return null

func visit_literal_expr(expr: Expr.Literal) -> Variant:
	return null

func visit_grouping_expr(expr: Expr.Grouping) -> Variant:
	_resolve(expr.expression)
	
	return null

func visit_unary_expr(expr: Expr.Unary) -> Variant:
	_resolve(expr.right)
	
	return null

func visit_binary_expr(expr: Expr.Binary) -> Variant:
	_resolve(expr.left)
	_resolve(expr.right)
	
	return null

func visit_variable_expr(expr: Expr.Variable) -> Variant:
	if not _scopes.is_empty() and _scopes.back().get(expr.name.lexeme, false) == false:
		Lox.error(expr.name, "Cannot read local variable in its own initializer")
	
	return null

func visit_logical_expr(expr: Expr.Logical) -> Variant:
	_resolve(expr.left)
	_resolve(expr.right)
	
	return null

func visit_call_expr(expr: Expr.Call) -> Variant:
	_resolve(expr.callee)
	
	for argument in expr.arguments:
		_resolve(argument)
	
	return null

func visit_if_stmt(stmt: Stmt.If) -> Variant:
	_resolve(stmt.condition)
	_resolve(stmt.then_branch)
	if stmt.else_branch != null:
		_resolve(stmt.else_branch)
	
	return null

func visit_block_stmt(stmt: Stmt.Block) -> Variant:
	_begin_scope()
	resolve(stmt.statements)
	_end_scope()
	
	return null

func visit_loxexpression_stmt(stmt: Stmt.LoxExpression) -> Variant:
	_resolve(stmt.expression)
	
	return null

func visit_loxprint_stmt(stmt: Stmt.LoxPrint) -> Variant:
	_resolve(stmt.expression)
	
	return null

func visit_loxvar_stmt(stmt: Stmt.LoxVar) -> Variant:
	_declare(stmt.name)
	if stmt.initializer != null:
		_resolve(stmt.initializer)
	
	_define(stmt.name)
	
	return null

func visit_while_stmt(stmt: Stmt.While) -> Variant:
	_resolve(stmt.condition)
	_resolve(stmt.body)
	
	return null

func visit_function_stmt(stmt: Stmt.Function) -> Variant:
	_declare(stmt.name)
	_define(stmt.name)
	
	_resolve_function(stmt, FunctionType.FUNCTION)
	
	return null

func visit_return_stmt(stmt: Stmt.Return) -> Variant:
	if _current_function == FunctionType.NONE:
		Lox.error(stmt.keyword, "Cannot return from top-level code.")
	
	if stmt.value != null:
		_resolve(stmt.value)
	
	return null

func resolve(statements: Array) -> void:
	for statement in statements:
		_resolve(statement)
