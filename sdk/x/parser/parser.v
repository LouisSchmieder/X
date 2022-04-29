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

	eprintln('$p.tok.typ ($p.pos.line_nr:$p.pos.char)')

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
			p.inside_block = false
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
			return error('Test "$p.tok.typ" $p.pos.line_nr:$p.pos.char')
		}
	}
}

pub fn (mut p FileParser) expr() ast.Expr {
	pos := p.pos
	match p.tok.typ {
		.str {
			return p.parse_string() 
		}
		.number {
			num := p.number()
			return ast.NumberExpr{
				pos: pos
				num: num
			}
		}
		.name {
			mut name := p.pos.tok
			p.next()
			if p.tok.typ == .lbr {
				return p.fn_call(name, pos)
			} else if p.tok.typ == .lcbr {
				return p.struct_init(name, pos)
			}
			mut ident := ast.Expr(ast.IdentExpr{
				pos: pos
				name: name
			})
			for p.tok.typ == .dot {
				p.next()
				name = p.pos.tok
				ident = ast.StructFieldExpr{
					pos: p.pos
					name: name
					parent: ident
				}
				p.next()
			}
			return ident
		}
		else {}
	}
	return ast.EmptyExpr{}
}

pub fn (mut p FileParser) stmt() ast.Stmt {
	pos := p.pos
	left := p.expr()
	match left {
		ast.FnCallExpr {
			return ast.ExprStmt{expr: left}
		}
		ast.IdentExpr, ast.StructFieldExpr {
			mut assign_type := ast.AssignType.assign
			if p.tok.typ == .dcolon {
				p.next()
				assign_type = .declare
			}
			p.check(.eq)
			p.next()
			right := p.expr()
			return ast.AssignStmt{
				pos: pos
				typ: assign_type
				left: left
				right: right
			}
		}
		else {
			return ast.EmptyStmt{}
		}
	}

	return ast.EmptyStmt{}
}

pub fn (mut p FileParser) typ() (ast.Type, bool) {
	if p.tok.typ == .key_struct {
		return p.parse_struct(), false
	} else if p.tok.typ == .key_enum {
		return p.parse_enum(), false
	}

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

pub fn (mut p FileParser) parse_enum() ast.Type {
	p.next()
	p.check(.lcbr)
	p.next()

	mut options := map[string]int
	mut i := 0

	for {
		name := p.name()

		mut value := i
		if p.tok.typ == .eq {
			p.next()
			value = p.number()
		} else {
			i++
		}
		if name !in options {	
			options[name] = value
		}
		if p.tok.typ == .rcbr {
			break
		}	
	}

	p.check(.rcbr)
	p.next()

	en := ast.create_type('anon_enum', ast.create_enum(options))
	p.p.table.add_type(en)
	return en
}

pub fn (mut p FileParser) parse_struct() ast.Type {	
	p.next()
	p.check(.lcbr)
	p.next()

	mut field := []ast.StructField{}

	for {
		name := p.name()
		typ, _ := p.typ()
		field << ast.StructField{
			name: name
			typ: typ
		}
		if p.tok.typ == .rcbr {
			break
		}
	}

	p.check(.rcbr)
	p.next()

	st := ast.create_type('anon_struct', ast.create_struct(field))
	p.p.table.add_type(st)
	return st
}

pub fn (mut p FileParser) name() string {
	p.check(.name)
	name := p.pos.tok
	p.next()
	return name
}

pub fn (mut p FileParser) number() int {
	p.check(.number)
	num := p.pos.tok
	p.next()
	return num.int()
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
	name := p.pos.tok
	p.next()
	p.check(.eq)
	p.next()
	base, unsigned := p.typ()
	mut typ := ast.create_type(name, base.info)
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

pub fn (mut p FileParser) parse_string() ast.Expr {
	p.next()
	return ast.StringExpr{
		pos: p.pos
		lit: p.pos.tok
	}
}

pub fn (mut p FileParser) open_scope() {
	p.scope = ast.create_scope(p.scope)
}

pub fn (mut p FileParser) close_scope() {
	p.scope = p.scope.parent
}
