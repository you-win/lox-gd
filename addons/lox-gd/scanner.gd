extends RefCounted

const TokenType := Lox.TokenType
const Token := Lox.Token

const KEYWORDS := {
	"and" = TokenType.AND,
	"class" = TokenType.CLASS,
	"else" = TokenType.ELSE,
	"false" = TokenType.FALSE,
	"for" = TokenType.FOR,
	"fun" = TokenType.FUN,
	"if" = TokenType.IF,
	"nil" = TokenType.NIL,
	"or" = TokenType.OR,
	"print" = TokenType.PRINT,
	"return" = TokenType.RETURN,
	"super" = TokenType.SUPER,
	"this" = TokenType.THIS,
	"true" = TokenType.TRUE,
	"var" = TokenType.VAR,
	"while" = TokenType.WHILE
}

var _source := ""
var _tokens: Array[Token] = []
var _start: int = 0
var _current: int = 0
var _line: int = 1

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(source: String) -> void:
	self._source = source

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _is_at_end() -> bool:
	return _current >= _source.length()

func _scan_token() -> void:
	var c := _advance()
	match c:
		"(":
			_add_token(TokenType.LEFT_PAREN)
		")":
			_add_token(TokenType.RIGHT_PAREN)
		"{":
			_add_token(TokenType.LEFT_BRACE)
		"}":
			_add_token(TokenType.RIGHT_BRACE)
		",":
			_add_token(TokenType.COMMA)
		".":
			_add_token(TokenType.DOT)
		"-":
			_add_token(TokenType.MINUS)
		"+":
			_add_token(TokenType.PLUS)
		";":
			_add_token(TokenType.SEMICOLON)
		"*":
			_add_token(TokenType.STAR)
		"!":
			_add_token(TokenType.BANG_EQUAL if _match("=") else TokenType.BANG)
		"=":
			_add_token(TokenType.EQUAL_EQUAL if _match("=") else TokenType.EQUAL)
		"<":
			_add_token(TokenType.LESS_EQUAL if _match("=") else TokenType.LESS)
		">":
			_add_token(TokenType.GREATER_EQUAL if _match("=") else TokenType.GREATER)
		"/":
			if _match("/"):
				while _peek() != "\n" and not _is_at_end():
					_advance()
			else:
				_add_token(TokenType.SLASH)
		" ", "\r", "\t":
			pass # Intentionally do nothing
		"\n":
			_line += 1
		"\"":
			_string()
		_:
			if _is_digit(c):
				_number()
			elif _is_alpha(c):
				_identifier()
			else:
				Lox.error_simple(_line, "Unexpected character %s at line %d" % c)

func _advance() -> String:
	var current := _current
	_current += 1
	
	return _source[current]

func _add_token(type: TokenType, literal: Variant = null) -> void:
	var text := _source.substr(_start, _current - _start)
	_tokens.push_back(Token.new(type, text, literal, _line))

func _match(expected: String) -> bool:
	if _is_at_end():
		return false
	if _source[_current] != expected:
		return false
	
	_current += 1
	
	return true

func _peek() -> String:
	if _is_at_end():
		return ""
	return _source[_current]

func _peek_next() -> String:
	if _current + 1 >= _source.length():
		return ""
	return _source[_current + 1]

func _string() -> void:
	while _peek() != "\"" and not _is_at_end():
		if _peek() == "\n":
			_line += 1
		_advance()
	
	if _is_at_end():
		printerr("Unterminated string at line %d" % _line)
		return
	
	_advance()
	
	var value := _source.substr(_start + 1, _current - _start - 2)
	_add_token(TokenType.STRING, value)

# TODO this might be comparing ascii character position
func _is_digit(c: String) -> bool:
	return c >= "0" and c <= "9"

func _number() -> void:
	while _is_digit(_peek()):
		_advance()
	
	if _peek() == "." and _is_digit(_peek_next()):
		_advance()
	
	while _is_digit(_peek()):
		_advance()
	
	_add_token(TokenType.NUMBER, _source.substr(_start, _current - _start).to_float())

func _identifier() -> void:
	while _is_alpha_numeric(_peek()):
		_advance()
	
	var text := _source.substr(_start, _current - _start)
	var type: TokenType = KEYWORDS.get(text, TokenType.NONE)
	if type == TokenType.NONE:
		type = TokenType.IDENTIFIER
	
	_add_token(type)

# TODO this might be comparing ascii character position
func _is_alpha(c: String) -> bool:
	return (
		(c >= "a" and c <= "z") or
		(c >= "A" and c <= "Z") or
		c == "_"
	)

func _is_alpha_numeric(c: String) -> bool:
	return _is_alpha(c) or _is_digit(c)

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func scan_tokens() -> Array[Token]:
	while not _is_at_end():
		_start = _current
		_scan_token()
	
	_tokens.push_back(Token.new(TokenType.EOF, "", null, _line))
	
	return _tokens
