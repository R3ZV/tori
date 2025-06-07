use bencode;

// Color of a node
export type Color = enum {
	Red,
	Black,
};

// Node of the tree
export type Node = struct {
	parent: nullable *Node,
	left: nullable *Node,
	right: nullable *Node,

	key: str,
	value: bencode::Element,
	color: Color,
};

fn new_node(key: str, value: bencode::Element) Node = {
	return Node {
		parent = null,
		left = null,
		right = null,
		key = key,
		value = value,
		color = Color::Red,
	};
};
