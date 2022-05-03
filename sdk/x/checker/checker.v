module checker

import ast

[heap]
pub struct Checker {
	files []&ast.File
	scope &ast.Scope
	table &ast.TypeTable
mut:
	working int
}

pub struct FileChecker {
mut:
	checker &Checker
	file    &ast.File

	scope &ast.Scope
}

pub fn create_checker(parsed_files []&ast.File, parsed_scope &ast.Scope, parsed_table &ast.TypeTable) &Checker {
	return &Checker{
		files: parsed_files
		scope: parsed_scope
		table: parsed_table
	}
}

pub fn (c Checker) check() (&ast.File, &ast.Scope, &ast.TypeTable) {
	for file in c.files {
		// go
		check_file(&c, file)
	}
}

pub fn check_file(checker &Checker, file &ast.File) {
}
