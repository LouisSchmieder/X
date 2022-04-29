module main

import parser

fn main() {
	mut parser := parser.create_parser()
	parser.parse_file('../std/types.xh')
	eprintln(parser)
}