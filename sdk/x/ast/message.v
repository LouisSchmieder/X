module ast

import token

pub struct Message {
pub:
	pos token.Position
	msg string
}

pub fn create_msg(pos token.Position, msg string) Message {
	return Message{
		pos: pos
		msg: msg
	}
}
