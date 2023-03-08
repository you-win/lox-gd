extends RefCounted

const Token := Lox.Token
const TokenType := Lox.TokenType
const Expr := Lox.Expr
const Stmt := Lox.Stmt

var _tokens: Array[Token] = []
var _current: int = 0

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(tokens: Array[Token]) -> void:
	self._tokens = tokens

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _match(types: Array[TokenType]) -> bool:
	for type in types:
		if _check(type):
			_advance()
			return true
	
	return false

func _check(type: TokenType) -> bool:
	if _is_at_end():
		return false
	return _peek().type == type

func _advance() -> Token:
	if not _is_at_end():
		_current += 1
	return _previous()

func _is_at_end() -> bool:
	return _peek().type == TokenType.EOF

func _peek() -> Token:
	return _tokens[_current]

func _previous() -> Token:
	return _tokens[_current - 1]

func _expression() -> Expr:
	return _equality()

func _equality() -> Expr:
	var expr := _comparison()
	
	while _match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL]):
		var operator: Token = _previous()
		var right: Expr = _comparison()
		expr = Expr.Binary.new(expr, operator, right)
	
	return expr

func _comparison() -> Expr:
	var expr: Expr = _term()
	
	while _match([
		TokenType.GREATER, TokenType.GREATER_EQUAL,
		TokenType.LESS, TokenType.LESS_EQUAL
	]):
		var operator: Token = _previous()
		var right: Expr = _term()
		expr = Expr.Binary.new(expr, operator, right)
	
	return expr

func _term() -> Expr:
	var expr: Expr = _factor()
	
	while _match([TokenType.MINUS, TokenType.PLUS]):
		var operator: Token = _previous()
		var right: Expr = _factor()
		expr = Expr.Binary.new(expr, operator, right)
	
	return expr

func _factor() -> Expr:
	var expr: Expr = _unary()
	
	while _match([TokenType.SLASH, TokenType.STAR]):
		var operator: Token = _previous()
		var right: Expr = _unary()
		expr = Expr.Binary.new(expr, operator, right)
	
	return expr

func _unary() -> Expr:
	if _match([TokenType.BANG, TokenType.MINUS]):
		var operator: Token = _previous()
		var right: Expr = _unary()
		return Expr.Unary.new(operator, right)
	
	return _primary()

func _primary() -> Expr:
	if _match([TokenType.FALSE]):
		return Expr.Literal.new(false)
	if _match([TokenType.TRUE]):
		return Expr.Literal.new(true)
	if _match([TokenType.NIL]):
		return Expr.Literal.new(null)
	
	if _match([TokenType.NUMBER, TokenType.STRING]):
		return Expr.Literal.new(_previous().literal)
	
	if _match([TokenType.IDENTIFIER]):
		return Expr.Variable.new(_previous())
	
	if _match([TokenType.LEFT_PAREN]):
		var expr: Expr = _expression()
		_consume(TokenType.RIGHT_PAREN, "Expected ')' after expression.")
		return Expr.Grouping.new(expr)
	
	# GDScript does not have throw
	return null

func _consume(type: TokenType, message: String) -> Token:
	if _check(type):
		return _advance()
	
	Lox.error_simple(-1, "%s - %s" % [str(_peek()), message])
	
	# GDScript does not have throw
	return null

func _synchronize() -> void:
	_advance()
	
	while not _is_at_end():
		if _previous().type == TokenType.SEMICOLON:
			return
		
		# Reference impl uses a switch statement that falls through all applicable
		# types. We can instead just check if it exists here
		if _peek().type in [
			TokenType.CLASS, TokenType.FUN, TokenType.VAR, TokenType.FOR, TokenType.IF,
			TokenType.WHILE, TokenType.PRINT, TokenType.RETURN
		]:
			return
	
		_advance()

func _statement() -> Stmt:
	if _match([TokenType.PRINT]):
		return _print_statement()
	
	return _expression_statement()

func _print_statement() -> Stmt:
	var value: Expr = _expression()
	_consume(TokenType.SEMICOLON, "Expect ';' after expression.")
	
	return Stmt.LoxPrint.new(value)

func _expression_statement() -> Stmt:
	var expr: Expr = _expression()
	_consume(TokenType.SEMICOLON, "Expect ';' after expression.")
	
	return Stmt.LoxExpression.new(expr)

func _declaration() -> Stmt:
	if _match([TokenType.VAR]):
		return _var_declaration()
	
	var stmt := _statement()
	if stmt == null:
		_synchronize()
	
	return stmt

func _var_declaration() -> Stmt:
	var name: Token = _consume(TokenType.IDENTIFIER, "Expected variable name.")
	
	var initializer: Expr = null
	if _match([TokenType.EQUAL]):
		initializer = _expression()
	
	_consume(TokenType.SEMICOLON, "Expected ';' after variable declaration.")
	
	return Stmt.LoxVar.new(name, initializer)

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

# Differs from the reference impl because GDScript does not have throw
func parse() -> Array:
	var statements := []
	while not _is_at_end():
		statements.push_back(_declaration())
	
	return statements