extends RefCounted

class Expr:
	class Visitor:
		func visit_assign_expr(expr: Assign) -> Variant:
			return null
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
		func visit_logical_expr(expr: Logical) -> Variant:
			return null
		func visit_call_expr(expr: Call) -> Variant:
			return null
		func visit_get_expr(expr: Get) -> Variant:
			return null
		func visit_set_expr(expr: Set) -> Variant:
			return null

	class Assign extends Expr:
		var name: Lox.Token
		var value: Expr
		func _init(name: Lox.Token, value: Expr):
			self.name = name
			self.value = value
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_assign_expr(self)

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

	class Logical extends Expr:
		var left: Expr
		var operator: Lox.Token
		var right: Expr
		func _init(left: Expr, operator: Lox.Token, right: Expr):
			self.left = left
			self.operator = operator
			self.right = right
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_logical_expr(self)

	class Call extends Expr:
		var callee: Expr
		var paren: Lox.Token
		var arguments: Array
		func _init(callee: Expr, paren: Lox.Token, arguments: Array):
			self.callee = callee
			self.paren = paren
			self.arguments = arguments
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_call_expr(self)

	class Get extends Expr:
		var object: Expr
		var name: Lox.Token
		func _init(object: Expr, name: Lox.Token):
			self.object = object
			self.name = name
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_get_expr(self)

	class Set extends Expr:
		var object: Expr
		var name: Lox.Token
		var value: Expr
		func _init(object: Expr, name: Lox.Token, value: Expr):
			self.object = object
			self.name = name
			self.value = value
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_set_expr(self)

	func accept(visitor: Variant) -> Variant:
		return null
