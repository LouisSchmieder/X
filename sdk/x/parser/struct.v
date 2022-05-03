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
