module parser

pub fn (mut p FileParser) pre() {
	p.next()
	match p.tok.typ {
		.key_once {
			p.pre_once()
		}
		.key_use {
			p.pre_use()
		}
		else {}
	}
}

pub fn (mut p FileParser) pre_once() {
	p.check(.key_once)
	p.next()
}

pub fn (mut p FileParser) pre_use() {
	p.check(.key_use)
	p.next()
	p.check(.str)
	path := '${p.file.get_dir()}/${p.pos.tok}'
	eprintln(path)
	p.p.parse_file(path)
}
