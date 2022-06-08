module ast

pub type TypeInfo = Alias | DataType | Enum | Pointer | Struct | Unresolved

[heap]
pub struct Type {
pub mut:
	name string
	info TypeInfo
}

pub fn (typ Type) size() int {
	match typ.info {
		Struct {
			return typ.info.size()
		}
		Enum {
			return 4
		}
		DataType {
			return typ.info.size
		}
		Pointer {
			return typ.info.size
		}
		Unresolved {
			return 0
		}
		Alias {
			return typ.get_alias().size()
		}
	}
}

pub fn (typ Type) get_struct_info() Struct {
	return typ.info as Struct
}

pub fn (typ Type) get_enum_info() Enum {
	return typ.info as Enum
}

pub fn (typ Type) get_data_info() DataType {
	return typ.info as DataType
}

pub fn (typ Type) get_pointer() Pointer {
	return typ.info as Pointer
}

pub fn (typ Type) get_alias() &Type {
	return (typ.info as Alias).base
}

pub struct Unresolved {}

pub struct Struct {
pub:
	fields []StructField
}

pub struct Enum {
pub:
	options map[string]int
}

pub struct DataType {
pub mut:
	size     int
	unsigned bool
}

pub struct StructField {
pub mut:
	name string
	typ  &Type
}

pub struct Pointer {
pub mut:
	base &Type
	size int = 4
}

pub struct Alias {
pub mut:
	base &Type
}

pub fn create_type(name string, info TypeInfo) &Type {
	return &Type{
		name: name
		info: info
	}
}

pub fn create_alias(name string, typ &Type) &Type {
	return create_type(name, Alias{ base: typ })
}

pub fn create_struct(fields []StructField) Struct {
	return Struct{
		fields: fields
	}
}

pub fn create_enum(options map[string]int) Enum {
	return Enum{
		options: options
	}
}

pub fn create_datatype(size int, unsigned bool) DataType {
	return DataType{
		size: size
		unsigned: unsigned
	}
}

pub fn (mut t Type) set_unsigned() {
	if mut t.info is DataType {
		t.info.unsigned = true
	}
}

pub fn (st Struct) size() int {
	return st.offset('')
}

pub fn (st Struct) get_struct_field(name string) StructField {
	arr := st.fields.filter(it.name == name)
	if arr.len == 0 {
		return StructField{
			typ: 0
		}
	}
	return arr[0]
}

pub fn (st Struct) offset(name string) int {
	mut i := 0
	for field in st.fields {
		if field.name == name {
			return i
		}
		i += field.typ.size()
	}
	return i
}

pub fn (t Type) == (t2 Type) bool {
	if t.info is Alias {
		return t.get_alias() == t2
	}
	if t2.info is Alias {
		return t == t2.get_alias()
	}
	if t.info is Enum {
		if t2.info is Enum {
			for key, value in t.get_enum_info().options {
				if t2.get_enum_info().options[key] != value {
					return false
				}
			}
			return true
		}
	}
	if t.info is Struct {
		if t2.info is Struct {
			for i in 0 .. t.get_struct_info().fields.len {
				if t.get_struct_info().fields[i].typ != t2.get_struct_info().fields[i].typ {
					return false
				}
				// Add strict name mode
			}
			return true
		}
	}
	if t.info is Pointer {
		if t2.info is Pointer {
			if t.get_pointer().size != t2.get_pointer().size {
				return false
			}
			// Strict pointer type mode
			return true
		}
	}
	if t.info is DataType {
		if t2.info is DataType {
			if t.get_data_info().size != t2.get_data_info().size {
				return false
			}
			if t.get_data_info().unsigned != t2.get_data_info().unsigned {
				return false
			}
			return true
		}
	}
	return false
}
