module scanner

import os
import token

pub struct Scanner {
mut:
	buf      []u8
	idx      int
	char_nr  u32
	line_nr  u32
	filename string
}

pub fn create_scanner(file string) &Scanner {
	bytes := os.read_bytes(file) or { []u8{} }
	return &Scanner{
		filename: file
		buf: bytes
	}
}

pub fn (mut scanner Scanner) next() (token.Token, token.Position) {
	scanner.eat_whitespace()
	defer {
		scanner.char_nr++
		scanner.idx++
	}
	if !scanner.valid() {
		return token.eof, scanner.pos('')
	}
	if scanner.now() in token.symbols {
		mut data := []u8{}
		if token.symbols[scanner.now()].typ in [.quote, .dquote] {
			c := scanner.now()
			scanner.idx++
			scanner.char_nr++
			for c != scanner.now() {
				data << scanner.now()
				scanner.idx++
				scanner.char_nr++
				if scanner.buf[scanner.idx] == `\n` {
					scanner.line_nr++
					scanner.char_nr = 0
				}
			}
			return token.str, scanner.pos(data.bytestr())
		}
		data << scanner.now()
		return token.symbols[scanner.now()], scanner.pos(data.bytestr())
	}
	if scanner.is_name() {
		name := scanner.name()
		scanner.idx--
		scanner.char_nr--
		if name in token.c_keywords {
			return token.c_keywords[name], scanner.pos(name)
		}
		if name in token.x_keywords {
			return token.x_keywords[name], scanner.pos(name)
		}
		if name in token.universal_keywords {
			return token.universal_keywords[name], scanner.pos(name)
		}
		return token.name, scanner.pos(name)
	}
	if scanner.is_number() {
		number := scanner.number()
		scanner.idx--
		scanner.char_nr--
		return token.number, scanner.pos(number)
	}
	return token.error, scanner.pos('')
}

fn (mut scanner Scanner) name() string {
	mut tok := []u8{}
	for scanner.valid() && (scanner.is_name() || scanner.is_number()) {
		tok << scanner.now()
		scanner.idx++
		scanner.char_nr++
	}

	return tok.bytestr()
}

fn (mut scanner Scanner) number() string {
	mut tok := []u8{}
	for scanner.valid() && (scanner.is_number() || scanner.now() in [`x`, `X`, `b`, `B`]
		|| (scanner.now() >= `a` && scanner.now() <= `f`)
		|| (scanner.now() >= `A` && scanner.now() <= `F`)) {
		tok << scanner.now()
		scanner.idx++
		scanner.char_nr++
	}
	return tok.bytestr()
}

fn (mut scanner Scanner) eat_whitespace() {
	for scanner.valid() && scanner.buf[scanner.idx] in [` `, `\t`, `\n`, `\r`] {
		scanner.char_nr++
		if scanner.buf[scanner.idx] == `\n` {
			scanner.line_nr++
			scanner.char_nr = 0
		}
		scanner.idx++
	}
}

fn (mut scanner Scanner) valid() bool {
	return scanner.idx < scanner.buf.len
}

fn (scanner Scanner) now() byte {
	return scanner.buf[scanner.idx]
}

fn (scanner Scanner) pos(tok string) token.Position {
	return token.Position{
		line_nr: scanner.line_nr
		char: scanner.char_nr
		tok: tok
	}
}

fn (scanner Scanner) is_name() bool {
	return (scanner.now() >= `A` && scanner.now() <= `Z`)
		|| (scanner.now() >= `a` && scanner.now() <= `z`) || scanner.now() == `_`
}

fn (scanner Scanner) is_number() bool {
	return scanner.now() >= `0` && scanner.now() <= `9`
}
