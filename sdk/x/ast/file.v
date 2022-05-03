module ast

import os

[heap]
pub struct File {
pub:
	name string
	once bool
pub mut:
	scope &Scope
	table &TypeTable
	stmts []Stmt

	errors []Message
	warns  []Message
}

pub fn create_ast_file(name string, parent &Scope) &File {
	return &File{
		name: name
		scope: create_scope(parent)
		table: create_table()
		stmts: []Stmt{}
	}
}

pub fn (mut file File) get_dir() string {
	mut data := file.name
	data = data.replace('\\', '/')
	mut args := data.split('/')
	args = args[0..args.len - 1]
	return args.join('/')
}

pub fn (mut file File) add_stmt(stmt Stmt) {
	file.stmts << stmt
}

pub fn (file File) get_scope() &Scope {
	return file.scope
}

pub fn (file File) write_errors() {
	content := os.read_file(file.name) or { '' }
	lines := content.split_into_lines()
	for error in file.errors {
		println('$file.name $error.pos.line_nr:$error.pos.char - $error.msg')
		println(lines[error.pos.line_nr])
		mut space := []u8{len: int(error.pos.char - 1), init: ` `}
		space << []u8{len: error.pos.tok.len, init: `~`}
		println(space.bytestr())
	}
}
