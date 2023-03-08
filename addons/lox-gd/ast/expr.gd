extends RefCounted

class Expr:
	class Visitor:
		func visit_binary_expr(expr: Binary) -> Variant:
			return null
		func visit_grouping_expr(expr: Grouping) -> Variant:
			return null
		func visit_literal_expr(expr: Literal) -> Variant:
			return null
		func visit_unary_expr(expr: Unary) -> Variant:
			return null
		func visit_variable_expr(expr: Variable) -> Variant:
			return null

	class Binary extends Expr:
		var left: Expr
		var operator: Lox.Token
		var right: Expr
		func _init(left: Expr, operator: Lox.Token, right: Expr):
			self.left = left
			self.operator = operator
			self.right = right
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_binary_expr(self)

	class Grouping extends Expr:
		var expression: Expr
		func _init(expression: Expr):
			self.expression = expression
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_grouping_expr(self)

	class Literal extends Expr:
		var value: Variant
		func _init(value: Variant):
			self.value = value
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_literal_expr(self)

	class Unary extends Expr:
		var operator: Lox.Token
		var right: Expr
		func _init(operator: Lox.Token, right: Expr):
			self.operator = operator
			self.right = right
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_unary_expr(self)

	class Variable extends Expr:
		var name: Lox.Token
		func _init(name: Lox.Token):
			self.name = name
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_variable_expr(self)

	func accept(visitor: Variant) -> Variant:
		return null