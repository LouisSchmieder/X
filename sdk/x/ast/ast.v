module ast

import token

pub type Stmt = TypeStmt | PackageStmt | BlockStmt | FnStmt | AssignStmt | ExprStmt

pub type Expr = IdentExpr | FnCallExpr

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
	parameter []IdentExpr
}

pub struct AssignStmt {
pub:
	pos token.Position
	left Expr
	right Expr
}

pub struct IdentExpr {
pub:
	typ IdentType
	lit string
}

pub enum IdentType {
	name
	variable
	typ
}

pub enum AccessType {
	private
	public
}

pub struct FnParameter {
pub:
	name string
	typ Type
}
