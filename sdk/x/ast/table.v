module ast

[heap]
pub struct TypeTable {
pub mut:
	types     []&Type
	type_idxs map[string]int
}

pub fn create_table() &TypeTable {
	return &TypeTable{}
}

pub fn (mut table TypeTable) create_pointer(base &Type) &Type {
	if table.type_exists('$base.name*') {
		return table.get_type('$base.name*')
	}
	ptr := create_type('$base.name*', Pointer{ base: base })
	table.add_type(ptr)
	return ptr
}

pub fn (mut table TypeTable) add_unresolved_type(name string) &Type {
	t := &Type{
		name: name
		info: Unresolved{}
	}
	table.add_type(t)
	return t
}

pub fn (mut table TypeTable) remove_type(name string) {
	table.types = table.types.filter(it.name != name)
	table.type_idxs.delete(name)
}

pub fn (mut table TypeTable) add_type(typ &Type) {
	table.types << typ
	table.type_idxs[typ.name] = table.types.len - 1
}

pub fn (table TypeTable) type_exists(name string) bool {
	return name in table.type_idxs
}

pub fn (table TypeTable) type_data_exists(typ Type) bool {
	return table.types.filter(*it == typ).len > 0
}

pub fn (table TypeTable) type_ptr_exists(typ &Type) bool {
	return typ in table.types
}

pub fn (table TypeTable) get_type(name string) &Type {
	if !table.type_exists(name) {
		return create_type('', create_datatype(0, false))
	}
	return table.types[table.type_idxs[name]]
}

pub fn (mut table TypeTable) add_default_types() {
	// Void
	table.add_type(create_type('void', create_datatype(0, false)))

	// Numbers
	table.add_type(create_type('byte', create_datatype(1, false)))
	table.add_type(create_type('word', create_datatype(2, false)))
	table.add_type(create_type('dword', create_datatype(4, false)))
	table.add_type(create_type('qword', create_datatype(8, false)))
}
