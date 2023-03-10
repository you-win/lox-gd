extends RefCounted

class Stmt:
	class Visitor:
		func visit_block_stmt(stmt: Block) -> Variant:
			return null
		func visit_if_stmt(stmt: If) -> Variant:
			return null
		func visit_loxexpression_stmt(stmt: LoxExpression) -> Variant:
			return null
		func visit_loxprint_stmt(stmt: LoxPrint) -> Variant:
			return null
		func visit_loxvar_stmt(stmt: LoxVar) -> Variant:
			return null
		func visit_while_stmt(stmt: While) -> Variant:
			return null
		func visit_function_stmt(stmt: Function) -> Variant:
			return null
		func visit_return_stmt(stmt: Return) -> Variant:
			return null
		func visit_class_stmt(stmt: Class) -> Variant:
			return null

	class Block extends Stmt:
		var statements: Array
		func _init(statements: Array):
			self.statements = statements
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_block_stmt(self)

	class If extends Stmt:
		var condition: Lox.Expr
		var then_branch: Stmt
		var else_branch: Stmt
		func _init(condition: Lox.Expr, then_branch: Stmt, else_branch: Stmt):
			self.condition = condition
			self.then_branch = then_branch
			self.else_branch = else_branch
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_if_stmt(self)

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

	class While extends Stmt:
		var condition: Lox.Expr
		var body: Stmt
		func _init(condition: Lox.Expr, body: Stmt):
			self.condition = condition
			self.body = body
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_while_stmt(self)

	class Function extends Stmt:
		var name: Lox.Token
		var params: Array
		var body: Array
		func _init(name: Lox.Token, params: Array, body: Array):
			self.name = name
			self.params = params
			self.body = body
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_function_stmt(self)

	class Return extends Stmt:
		var keyword: Lox.Token
		var value: Lox.Expr
		func _init(keyword: Lox.Token, value: Lox.Expr):
			self.keyword = keyword
			self.value = value
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_return_stmt(self)

	class Class extends Stmt:
		var name: Lox.Token
		var methods: Array
		func _init(name: Lox.Token, methods: Array):
			self.name = name
			self.methods = methods
		func accept(visitor: Variant) -> Variant:
			return visitor.visit_class_stmt(self)

	func accept(visitor: Variant) -> Variant:
		return null
