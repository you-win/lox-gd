extends Lox.Expr.Visitor

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _parenthesize(name: String, exprs: Array[Expr]) -> String:
	var builder := PackedStringArray()
	
	builder.append("(")
	builder.append(name)
	
	for expr in exprs:
		builder.append(" ")
		builder.append(expr.accept(self))
	
	builder.append(")")
	
	return "".join(builder)

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func stringify(expr: Expr) -> String:
	return expr.accept(self)

func visit_binary_expr(expr: Expr.Binary) -> Variant:
	return _parenthesize(expr.operator.lexeme, [expr.left, expr.right])

func visit_grouping_expr(expr: Expr.Grouping) -> Variant:
	return _parenthesize("group", [expr.expression])

func visit_literal_expr(expr: Expr.Literal) -> Variant:
	if expr.value == null:
		return "nil"
	return str(expr.value)

func visit_unary_expr(expr: Expr.Unary) -> Variant:
	return _parenthesize(expr.operator.lexeme, [expr.right])
