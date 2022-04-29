module ast

import token

pub type Stmt = TypeStmt | PackageStmt | BlockStmt | FnStmt | AssignStmt | ExprStmt | EmptyStmt

pub type Expr = IdentExpr | FnCallExpr | StringExpr | EmptyExpr | NumberExpr | NameExpr | StructFieldExpr | StructInitExpr

pub struct PackageStmt {
pub:
	pos token.Position
	name IdentExpr
}

pub struct TypeStmt {
pub:
	access_type AccessType
	pos token.Position
	left IdentExpr
	right Type
}

pub struct ExprStmt {
pub:
	expr Expr
}

pub struct BlockStmt {
pub:
	access_type AccessType
	stmts []Stmt
}

pub struct FnStmt {
pub:
	pos token.Position
	name string
	scope &Scope
	parameter []FnParameter
	return_type Type
	stmts []Stmt
}

pub struct FnCallExpr {
pub:
	pos token.Position
	name string
	parameter []Expr
}

pub struct AssignStmt {
pub:
	pos token.Position
	typ AssignType
	left Expr
	right Expr
}

pub struct EmptyStmt {

}

pub struct StructInitExpr {
pub:
	pos token.Position
	name string
	fields map[string]Expr
}

pub struct StructFieldExpr {
pub:
	pos token.Position
	parent Expr
	name string
}

pub struct IdentExpr {
pub:
	pos token.Position
	name string
}

pub struct EmptyExpr {}

pub struct NameExpr {
pub:
	pos token.Position
	lit string
}

pub struct StringExpr {
pub:
	pos token.Position
	lit string
}

pub struct NumberExpr {
pub:
	pos token.Position
	num int
}

pub enum AccessType {
	private
	public
}

pub enum AssignType {
	declare
	assign
}

pub struct FnParameter {
pub:
	name string
	typ Type
}
