module ast

[heap]
pub struct Scope {
pub mut:
	vars   []Variable
	parent &Scope
}

pub struct Variable {
pub mut:
	typ  Type
	name string
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

pub fn (mut scope Scope) add_var(var Variable) {
	scope.vars << var
}
