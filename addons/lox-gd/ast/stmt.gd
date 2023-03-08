extends RefCounted

class Stmt:
	class Visitor:
		func visit_loxexpression_stmt(stmt: LoxExpression) -> Variant:
			return null
		func visit_loxprint_stmt(stmt: LoxPrint) -> Variant:
			return null
		func visit_loxvar_stmt(stmt: LoxVar) -> Variant:
			return null

	class LoxExpression extends Stmt:
		var expression: Lox.Expr
		func _init(expression: Lox.Expr):
			self.expression = expression
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_loxexpression_stmt(self)

	class LoxPrint extends Stmt:
		var expression: Lox.Expr
		func _init(expression: Lox.Expr):
			self.expression = expression
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_loxprint_stmt(self)

	class LoxVar extends Stmt:
		var name: Lox.Token
		var initializer: Lox.Expr
		func _init(name: Lox.Token, initializer: Lox.Expr):
			self.name = name
			self.initializer = initializer
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_loxvar_stmt(self)

	func accept(visitor: Variant) -> Variant:
		return null
