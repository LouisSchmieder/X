module ast

[heap]
pub struct File {
pub:
	name string
	once bool
pub mut:
	scope &Scope
	table &TypeTable
	stmts []Stmt
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
