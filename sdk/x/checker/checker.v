module checker

import ast
import token

[heap]
pub struct Checker {
	files []&ast.File
	scope &ast.Scope
	unres &ast.TypeTable
mut:
	table   &ast.TypeTable
	working int
}

pub struct FileChecker {
mut:
	checker &Checker
	file    &ast.File

	scope &ast.Scope

	required_return_type &ast.Type = &ast.Type(0)
	returns              int
}

pub fn create_checker(parsed_files []&ast.File, parsed_table &ast.TypeTable, parsed_unres &ast.TypeTable, parsed_scope &ast.Scope) &Checker {
	return &Checker{
		files: parsed_files
		scope: parsed_scope
		unres: parsed_unres
		table: parsed_table
	}
}

pub fn (mut c Checker) check() ? {
	for file in c.files {
		go check_file(mut &c, file)
		c.working++
	}
	for c.working > 0 {
	}
}

fn check_file(mut checker Checker, file &ast.File) {
	mut c := FileChecker{
		checker: checker
		file: file
		scope: file.scope
	}

	mut stmts := file.stmts

	for mut stmt in stmts {
		c.stmt(mut stmt)
	}

	file.write_errors()
	checker.working--
}

fn (mut c FileChecker) typ(typ &ast.Type, pos token.Position) {
	if !c.file.table.type_ptr_exists(typ) && !c.checker.table.type_ptr_exists(typ) {
		c.error('Unknown type `$typ.name`', pos)
	}
}

fn (mut c FileChecker) error(msg string, pos token.Position) {
	c.file.errors << ast.create_msg(pos, msg)
}

fn (mut c FileChecker) stmt(mut stmt ast.Stmt) {
	match mut stmt {
		ast.ExprStmt {
			c.expr(stmt.expr)
		}
		ast.BlockStmt {
			c.block_stmt(mut stmt)
		}
		ast.FnStmt {
			c.fn_stmt(mut stmt)
		}
		ast.AssignStmt {
			c.assign_stmt(mut stmt)
		}
		else {}
	}
}

fn (mut c FileChecker) expr(expr ast.Expr) &ast.Type {
	typ := match expr {
		ast.EmptyExpr {
			c.get_type('void')
		}
		ast.CastExpr {
			c.cast_expr(expr)
		}
		ast.FnCallExpr {
			c.get_type('void')
		}
		ast.IdentExpr {
			c.get_type('void')
		}
		ast.NameExpr {
			c.get_type('void')
		}
		ast.NumberExpr {
			c.get_type('dword')
		}
		ast.StringExpr {
			c.checker.table.create_pointer(c.get_unsigned_type('byte'))
		}
		ast.StructFieldExpr {
			c.get_type('void')
		}
		ast.StructInitExpr {
			c.struct_init(expr)
		}
	}
	return typ
}

fn (c FileChecker) get_type(name string) &ast.Type {
	return if c.checker.table.type_exists(name) {
		c.checker.table.get_type(name)
	} else if c.file.table.type_exists(name) {
		c.file.table.get_type(name)
	} else {
		voidptr(0)
	}
}

fn (c FileChecker) get_unsigned_type(name string) &ast.Type {
	return if c.checker.table.type_exists(name) {
		c.checker.table.get_unsigned_type(name)
	} else if c.file.table.type_exists(name) {
		c.file.table.get_unsigned_type(name)
	} else {
		voidptr(0)
	}
}

fn (mut c FileChecker) block_stmt(mut node ast.BlockStmt) {
	mut stmts := node.stmts
	for mut stmt in stmts {
		c.stmt(mut stmt)
	}
}

fn (mut c FileChecker) fn_stmt(mut node ast.FnStmt) {
	mut return_need := false
	c.scope = node.scope
	defer {
		c.scope = c.scope.parent
	}
	if node.return_type != c.get_type('void') {
		c.typ(node.return_type, node.ret_pos)
		c.required_return_type = node.return_type
		return_need = true
		defer {
			c.required_return_type = &ast.Type(0)
			c.returns = 0
		}
	}

	for param in node.parameter {
		c.typ(param.typ, param.pos)
	}

	mut stmts := node.stmts

	for mut stmt in stmts {
		c.stmt(mut stmt)
	}

	if return_need {
		if c.returns == 0 {
			c.error('Missing return at the end of function `$node.name`', node.pos)
		}
	}
}

fn (mut c FileChecker) assign_stmt(mut node ast.AssignStmt) {
	left := c.expr(node.left)
	right := c.expr(node.right)

	if left != right {
		c.error('Mismatched types expected: `$left.name` but got `$right.name`', node.pos)
	}
}

fn (mut c FileChecker) cast_expr(node ast.CastExpr) &ast.Type {
	c.expr(node.expr)
	return node.to
}

fn (mut c FileChecker) struct_init(node ast.StructInitExpr) &ast.Type {
	st := c.get_type(node.name).get_alias()
	info := st.get_struct_info()

	for key, val in node.fields {
		sf := info.get_struct_field(key)
		if sf.name != key {
			c.error('Unknown struct field', val.pos)
		}
		t := c.expr(val)
		if sf.typ != t {
			c.error('Mismatched types expected `$sf.typ.name` but got `$t.name`', val.pos)
		}
	}

	return st
}
