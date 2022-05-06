module util

pub struct TmpVar {
mut:
	idx int
}

pub fn new_tmp_var_instance() &TmpVar {
	return &TmpVar{
		idx: 0
	}
}

pub fn (mut var TmpVar) tmp_var() string {
	return 't${var.idx++}'
}
