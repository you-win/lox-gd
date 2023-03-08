extends CanvasLayer

@onready
var output := %Output
@onready
var input := %Input

var _can_execute := true
var _ctrl_pressed := false
var _enter_pressed := false

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _ready() -> void:
	%Execute.pressed.connect(func() -> void:
		_execute()
	)
	input.gui_input.connect(func(event: InputEvent) -> void:
		if not event is InputEventKey:
			return
		
		if event.keycode == KEY_ENTER:
			_enter_pressed = event.pressed
		elif event.keycode == KEY_CTRL:
			_ctrl_pressed = event.pressed
		
		if _can_execute and _enter_pressed and _ctrl_pressed:
			_can_execute = false
			_execute()
		
		if not _enter_pressed and not _ctrl_pressed:
			_can_execute = true
	)
	
	var util := preload("res://addons/lox-gd/tools/generate_ast.gd").new()
	util.generate("res://addons/lox-gd/ast", "Expr", [
		"Assign   : name: Lox.Token, value: Expr",
		"Binary   : left: Expr, operator: Lox.Token, right: Expr",
		"Grouping : expression: Expr",
		"Literal  : value: Variant",
		"Unary    : operator: Lox.Token, right: Expr",
		"Variable : name: Lox.Token"
	])
	util.generate("res://addons/lox-gd/ast", "Stmt", [
		"Block         : statements: Array",
		"If            : condition: Lox.Expr, then_branch: Stmt, else_branch: Stmt",
		"LoxExpression : expression: Lox.Expr",
		"LoxPrint      : expression: Lox.Expr",
		"LoxVar        : name: Lox.Token, initializer: Lox.Expr"
	])

	Lox.init()

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _execute() -> void:
	var text: String = input.text
	
	output.text += "%s\n" % text
	
	var scanner := Lox.Scanner.new(text)
	var tokens := scanner.scan_tokens()

	var parser := Lox.Parser.new(tokens)
	var statements: Array = parser.parse()

	var interpreter := Lox.Interpreter.new()
	interpreter.interpret(statements)

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#
