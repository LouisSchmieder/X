module parser

import token
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

	ret_pos := p.pos
	mut return_type := p.p.table.get_type('void')

	if p.tok.typ in [.name, .key_struct] {
		return_type = p.typ()
	}

	p.check(.lcbr)
	p.next()
	mut stmts := []ast.Stmt{}
	p.open_scope()
	for param in fn_parameter {
		p.scope.add_var(ast.Variable{
			name: param.name
			typ: param.typ
		})
	}
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
		ret_pos: ret_pos
		return_type: return_type
		stmts: stmts
	}
}

fn (mut p FileParser) fn_call(name string, pos token.Position) ast.FnCallExpr {
	p.next()
	mut exprs := []ast.Expr{}
	for {
		exprs << p.expr()
		if p.tok.typ == .rbr {
			break
		}
	}
	return ast.FnCallExpr{
		pos: pos
		name: name
		parameter: exprs
	}
}

fn (mut p FileParser) parse_fn_parameter() []ast.FnParameter {
	mut parameter := []ast.FnParameter{}
	if p.tok.typ == .rbr {
		return parameter
	}

	for {
		pos := p.pos
		name := p.name()
		typ := p.typ()

		parameter << ast.FnParameter{
			name: name
			typ: typ
			pos: pos
		}

		if p.tok.typ == .comma {
			p.next()
			continue
		} else if p.tok.typ == .rbr {
			break
		} else {
			p.error('')
			return parameter
		}
	}
	return parameter
}
