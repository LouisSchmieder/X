module parser

import scanner
import token
import ast

[heap]
pub struct Parser {
mut:
	files []&ast.File
	table &ast.TypeTable // Global table
	scope &ast.Scope
}

pub struct FileParser {
mut:
	p &Parser
	tok token.Token
	pos token.Position
	lit string
	s &scanner.Scanner
	path string
	file &ast.File

	scope &ast.Scope

	inside_block bool
	block_access_type ast.AccessType
}

pub fn create_parser() &Parser {
	mut table := ast.create_table()
	table.add_default_types()
	return &Parser{
		files: []&ast.File{}
		table: table
		scope: ast.create_scope(&ast.Scope(voidptr(0)))
	}
}

pub fn (mut p Parser) parse_file(path string) {
	file := ast.create_ast_file(path, p.scope)
	if p.files.filter(it.name == file.name && it.once).len == 0 {
		p.files << file
		/* go */ parse(&p, file)
	}
}

fn parse(p &Parser, file &ast.File) {
	mut parser := FileParser{
		p: p
		s: scanner.create_scanner(file.name)
		path: file.name
		file: file
		scope: file.scope
	}
	parser.next()

	for parser.tok.typ != .eof {
		stmt := parser.parse_top_level() or {
			if err.msg().len == 0 {
				continue
			}
			eprintln(err)
			break
		}
		parser.file.add_stmt(stmt)
	}
}

pub fn (mut p FileParser) error(msg string) {
}

pub fn (mut p FileParser) warn(msg string) {
}

pub fn (mut p FileParser) check(key ...token.TokenType) bool {
	if p.tok.typ !in key {
		p.error('Expected `$key` but got `$p.lit`')
		return false
	}
	return true
}

pub fn (mut p FileParser) next() {
	p.tok, p.pos = p.s.next()
	p.lit = p.pos.tok
}

pub fn (mut p FileParser) parse_top_level() ?ast.Stmt {
	mut access_type := ast.AccessType.private

	if p.tok.typ in [.key_pub, .key_priv] {
		access_type = if p.tok.typ == .key_pub { .public } else { .private }
		p.next()
	}

	if p.inside_block {
		access_type = p.block_access_type
	}

	match p.tok.typ {
		.hash {
			p.pre()
			return none
		}
		.lcbr {
			if p.inside_block {
				return error('Cannot create a block inside a block')
			}
			p.inside_block = true
			p.block_access_type = access_type
			mut b := p.block()
			return ast.BlockStmt{
				access_type: access_type
				stmts: b
			}
		}
		.key_type {
			p.type_stmt(access_type)
			return none
		}
		.key_fn {
			return p.fn_stmt(access_type)
		}
		else {
			return error('Test')
		}
	}
}

pub fn (mut p FileParser) stmt() ast.Stmt {
	p.next()
	return ast.AssignStmt{}
}

pub fn (mut p FileParser) typ() (ast.Type, bool) {
	mut unsigned := false
	if p.tok.typ == .key_unsigned {
		unsigned = true
		p.next()
	}
	typ := p.name()
	mut t := if p.file.table.type_exists(typ) {
		p.file.table.get_type(typ)
	} else {
		p.p.table.get_type(typ)
	}
	for p.tok.typ == .mult {
		t = p.p.table.create_pointer(t)
		p.next()
	}
	if t.info !is ast.DataType && unsigned {
		p.error('Only data types can be unsigned')
	}
	return t, unsigned
}

pub fn (mut p FileParser) name() string {
	p.check(.name)
	name := p.pos.tok
	p.next()
	return name
}

pub fn (mut p FileParser) block() []ast.Stmt {
	p.next()
	mut stmt := []ast.Stmt{}
	for {
		stmt << p.parse_top_level() or {
			if err.msg().len == 0 {
				continue
			}
			break
		}
	}
	p.check(.rcbr)
	p.next()
	return stmt
}

pub fn (mut p FileParser) type_stmt(access_type ast.AccessType) {
	p.next()
	left := ast.IdentExpr{
		typ: .name
		lit: p.name()
	}
	p.check(.eq)
	p.next()
	base, unsigned := p.typ()
	mut typ := ast.create_type(left.lit, base.info)
	match mut typ.info {
		ast.DataType {
			typ.info.unsigned = unsigned
		}
		else {}
	}
	if access_type == .public {
		p.p.table.add_type(typ)
	} else {
		p.file.table.add_type(typ)
	}
}

pub fn (mut p FileParser) open_scope() {
	p.scope = ast.create_scope(p.scope)
}

pub fn (mut p FileParser) close_scope() {
	p.scope = p.scope.parent
}
