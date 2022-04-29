module parser

import ast

fn (mut p FileParser) fn_stmt(access_type ast.AccessType) ast.Stmt {
	pos := p.pos
	p.next()
	name := p.name()

	p.check(.lbr)
	p.next()
	fn_parameter := p.parse_fn_parameter()

	p.check(.rbr)
	p.next()

	mut return_type := p.p.table.get_type('void')

	if p.tok.typ == .name {
		return_type, _ = p.typ()
	}

	p.check(.lcbr)
	p.next()
	mut stmts := []ast.Stmt{}
	p.open_scope()
	for p.tok.typ != .rcbr {
		stmts << p.stmt()
	}
	fn_scope := p.scope
	p.close_scope()

	p.check(.rcbr)
	p.next()
 	

	return ast.FnStmt{
		pos: pos
		name: name
		scope: fn_scope
		parameter: fn_parameter
		return_type: return_type
		stmts: stmts
	}
}

fn (mut p FileParser) parse_fn_parameter() []ast.FnParameter {
	mut parameter := []ast.FnParameter{}
	if p.tok.typ == .rbr {
		return parameter
	}

	for {
		name := p.name()
		typ, _ := p.typ()
		
		parameter << ast.FnParameter{
			name: name
			typ: typ
		}

		if p.tok.typ == .comma {
			p.next()
			continue
		} else if p.tok.typ == .rbr {
			p.next()
			break
		} else {
			p.error('')
			return parameter
		}
	}
	return parameter
}
