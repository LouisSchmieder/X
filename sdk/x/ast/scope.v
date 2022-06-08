module ast

[heap]
pub struct Scope {
pub mut:
	vars   []Variable
	fns    []Function
	parent &Scope
}

pub struct Variable {
pub mut:
	typ     &Type
	name    string
	created bool
}

pub struct Function {
pub mut:
	ret_type  &Type
	name      string
	parameter []FnParameter
}

pub fn create_scope(parent &Scope) &Scope {
	return &Scope{
		parent: parent
	}
}

pub fn (mut scope Scope) find_var(name string) ?&Variable {
	var := scope.vars.filter(it.name == name)
	if var.len == 1 {
		return &Variable(var.data)
	}
	if scope.parent == voidptr(0) {
		return error('Variable `$name` not found')
	}
	return scope.parent.find_var(name)
}

pub fn (mut scope Scope) find_fn(name string) ?&Function {
	func := scope.fns.filter(it.name == name)
	if func.len == 1 {
		return &Function(func.data)
	}
	if scope.parent == voidptr(0) {
		return error('Function `$name` not found')
	}
	return scope.parent.find_fn(name)
}

pub fn (mut scope Scope) add_var(var Variable) {
	scope.vars << var
}

pub fn (mut scope Scope) add_fn(func Function) {
	scope.fns << func
}
