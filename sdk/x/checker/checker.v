module checker

import ast
import token

[heap]
pub struct Checker {
	files []&ast.File
	scope &ast.Scope
	unres &ast.TypeTable
	table &ast.TypeTable
mut:
	working int
}

pub struct FileChecker {
mut:
	checker &Checker
	file    &ast.File

	scope &ast.Scope

	required_return_type &ast.Type = &ast.Type(0)
	returns int
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

fn check_file(mut checker &Checker, file &ast.File) {
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

fn (mut c FileChecker) error(msg string, pos token.Position) {
	c.file.errors << ast.create_msg(pos, msg)
}

fn (mut c FileChecker) stmt(mut stmt ast.Stmt) {
	match mut stmt {
		ast.ExprStmt {
			c.expr(mut stmt.expr)
		}
		ast.BlockStmt {
			c.block_stmt(mut stmt)
		}
		ast.FnStmt {
			c.fn_stmt(mut stmt)
		}
		else {}
	}
}

fn (mut c FileChecker) expr(mut expr ast.Expr) {
}

fn (mut c FileChecker) block_stmt(mut node ast.BlockStmt) {

}

fn (mut c FileChecker) fn_stmt(mut node ast.FnStmt) {
	mut return_need := false
	if node.return_type != c.checker.table.get_type('void') {
		c.required_return_type = node.return_type
		return_need = true
		defer {
			c.required_return_type = &ast.Type(0)
			c.returns = 0
		}
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
