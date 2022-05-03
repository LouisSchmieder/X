module token

pub enum TokenType {
	eof
	error
	// Name, numbers, etc.
	name
	number
	str
	// Brackets
	lcbr // {
	rcbr // }
	lsbr // [
	rsbr // ]
	lbr // (
	rbr // )
	// Symbols
	dcolon // :
	scolon // ;
	dot // .
	comma // ,
	gt // >
	lt // <
	hash // #
	quote // '
	// Bitwise
	and // &
	@or // |
	xor // ^
	shift_left // <<
	shift_right // >>
	// Bool
	bool // true / false
	// Maths
	plus // +
	minus // -
	div // /
	mult // *
	eq // =
	// Doubles
	dplus // ++
	dminus // --
	ddiv // //
	dand // &&
	dor // ||
	deq // ==
	dquote // "
	// Keywords
	key_use
	key_def
	key_pub
	key_priv
	key_stat
	key_type
	key_return
	key_struct
	key_enum
	key_unsigned
	key_once
	key_if
	key_ifdef
	key_else
	key_endif
	key_fn
}

pub struct Token {
pub:
	typ  TokenType
	lang Language
	eq   bool
}

pub enum Language {
	c
	x
	non
}

fn create_token(typ TokenType, c Language) Token {
	return Token{
		typ: typ
		lang: c
	}
}

fn create_math_token(typ TokenType, eq bool) Token {
	return Token{
		typ: typ
		lang: .non
		eq: eq
	}
}

pub const (
	eof                = create_token(.eof, .non)
	name               = create_token(.name, .non)
	number             = create_token(.number, .non)
	error              = create_token(.error, .non)
	str                = create_token(.str, .non)
	universal_keywords = {
		'return':   create_token(.key_return, .non)
		'struct':   create_token(.key_struct, .non)
		'enum':     create_token(.key_enum, .non)
		'unsigned': create_token(.key_unsigned, .non)
		'true':     create_math_token(.bool, true)
		'false':    create_math_token(.bool, false)
	}
	x_keywords = {
		'use':   create_token(.key_use, .x)
		'def':   create_token(.key_def, .x)
		'priv':  create_token(.key_priv, .x)
		'pub':   create_token(.key_pub, .x)
		'stat':  create_token(.key_stat, .x)
		'type':  create_token(.key_type, .x)
		'once':  create_token(.key_once, .x)
		'if':    create_token(.key_if, .x)
		'ifdef': create_token(.key_ifdef, .x)
		'else':  create_token(.key_else, .x)
		'endif': create_token(.key_endif, .x)
		'fn':    create_token(.key_fn, .x)
	}
	c_keywords = {
		'include': create_token(.key_use, .c)
		'define':  create_token(.key_def, .c)
		'private': create_token(.key_priv, .c)
		'public':  create_token(.key_pub, .c)
		'static':  create_token(.key_stat, .c)
		'if':      create_token(.key_if, .c)
		'ifndef':  create_token(.key_ifdef, .c)
		'else':    create_token(.key_else, .c)
		'endif':   create_token(.key_endif, .c)
	}
	symbols = {
		`{`: create_math_token(.lcbr, false)
		`}`: create_math_token(.rcbr, false)
		`[`: create_math_token(.lsbr, false)
		`]`: create_math_token(.rsbr, false)
		`(`: create_math_token(.lbr, false)
		`)`: create_math_token(.rbr, false)
		`:`: create_math_token(.dcolon, false)
		`;`: create_math_token(.scolon, false)
		`.`: create_math_token(.dot, false)
		`,`: create_math_token(.comma, false)
		`>`: create_math_token(.gt, false)
		`<`: create_math_token(.lt, false)
		`#`: create_math_token(.hash, false)
		`&`: create_math_token(.and, false)
		`|`: create_math_token(.@or, false)
		`^`: create_math_token(.xor, false)
		`+`: create_math_token(.plus, false)
		`-`: create_math_token(.minus, false)
		`*`: create_math_token(.mult, false)
		`/`: create_math_token(.div, false)
		`=`: create_math_token(.eq, false)
		`'`: create_math_token(.quote, false)
		`"`: create_math_token(.dquote, false)
	}
)

/*
'+=': create_math_token(.plus,  true)
		'-=': create_math_token(.minus, true)
		'*=': create_math_token(.mult,  true)
		'/=': create_math_token(.div,   true)
		'==': create_math_token(.deq,  false)

		'++': create_math_token(.dplus, false)
		'--': create_math_token(.dminus, false)
		'//': create_math_token(.ddiv, false)
		'&&': create_math_token(.dand, false)
		'||': create_math_token(.dor, false)

		
		'<<': create_math_token(.shift_left, false)
		'>>': create_math_token(.shift_right, false)
		'&=': create_math_token(.and, true)
		'|=': create_math_token(.@or, true)
		'^=': create_math_token(.xor, true)
		'<<=': create_math_token(.shift_left, true)
		'>>=': create_math_token(.shift_right, true)
*/
