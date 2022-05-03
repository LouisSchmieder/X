module ast

pub type TypeInfo = DataType | Enum | Pointer | Struct | Unresolved

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

pub fn create_type(name string, info TypeInfo) &Type {
	return &Type{
		name: name
		info: info
	}
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
