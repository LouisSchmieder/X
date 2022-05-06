module parser

import token
import ast

fn (mut p FileParser) struct_init(name string, pos token.Position) ast.Expr {
	mut fields := map[string]ast.Expr{}
	p.next()

	for {
		field := p.name()

		p.check(.eq)
		p.next()

		expr := p.expr()
		fields[field] = expr
		if p.tok.typ == .rcbr {
			break
		}
	}

	return ast.StructInitExpr{
		pos: pos
		name: name
		fields: fields
	}
}

pub fn (mut p FileParser) parse_struct() &ast.Type {
	p.next()
	mut n := if p.tok.typ == .name {
		p.name()
	} else {
		'anon_struct_${p.tmp()}' 
	}
	p.check(.lcbr)
	p.next()

	mut field := []ast.StructField{}

	for {
		name := p.name()
		typ := p.typ()
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

	st := ast.create_type(n, ast.create_struct(field))
	p.p.table.add_type(st)
	return st
}
