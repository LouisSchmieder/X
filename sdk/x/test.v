module main

import parser
import checker

fn main() {
	mut parser := parser.create_parser()
	parser.parse_file('../std/array.xh')
	files, table, unres, scope := parser.get_data()
	//eprintln(table)
	mut checker := checker.create_checker(files, table, unres, scope)
	checker.check() or {
		return
	}
}
