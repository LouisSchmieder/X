module asm

import ast

pub struct Gen {
mut:
	files []&ast.File
	table &ast.TypeTable
	file_table &ast.TypeTable

	consts string
	main string
	data string
}

pub fn create_gen(files []&ast.File, table &ast.TypeTable) &Gen {
	return &Gen{
		files: files
		table: table
		file_table: files[0].table
	}
}

pub fn (mut gen Gen) write_const(data string) {
	gen.consts += data
}

pub fn (mut gen Gen) write_main(data string) {
	gen.main += data
}

pub fn (mut gen Gen) write(data string) {
	gen.data += data
}

pub fn (mut gen Gen) writeln_const(data string) {
	gen.consts += data
	gen.consts += '\n'
}

pub fn (mut gen Gen) writeln_main(data string) {
	gen.main += data
	gen.main += '\n'
}

pub fn (mut gen Gen) writeln(data string) {
	gen.data += data
	gen.data += '\n'
}

pub fn (mut gen Gen) gen() string {
	for file in gen.files {
		gen.table = file.table
		gen.gen_file(file)
	}
}

pub fn (mut gen Gen) gen_file(file &File) {
	
}
