extends VSplitContainer

signal status_updated(text: String)

var plugin: Node = null

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

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _execute() -> void:
	Lox.init()
	
	var text: String = input.text
	
	output.text += "%s\n" % text
	
	var scanner := Lox.Scanner.new(text)
	var tokens := scanner.scan_tokens()

	var parser := Lox.Parser.new(tokens)
	var statements: Array = parser.parse()

	var interpreter := Lox.Interpreter.new()
	var resolver := Lox.Resolver.new(interpreter)
	resolver.resolve(statements)
	
	if Lox.had_error():
		return
	
	interpreter.interpret(statements)
	
	if not Lox.had_error():
		status_updated.emit("Error!")
	else:
		status_updated.emit("Success!")
	
	Lox.deinit()

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

