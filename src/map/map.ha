use bencode;
use strings;
use fmt;

// This is a Map that uses a Red-Black Tree to keep the keys sorted, specifically
// built to be used with bencodes, as such the keys are always strings and the
// values can be any bencode element.
//
// Due to the fact that this uses a Red-Black Tree all operations
// are going to be O(n log(n)) where n is the number of nodes.
export type Map = struct {
	root: nullable *Node,
};

// Returns an emtpy map with a null root.
export fn new_map() Map = {
	return Map {
		root = null
	};
};

// Checks to see if the key is present in the map.
export fn contains(self: const *Map, key: str) bool = {
	// TODO:
	return false;
};

// Retrieves the value of the specified key, if the key doesn't exist
// in the map, null will be returned.
export fn get(self: const *Map, key: str) bencode::Element = {
	// TODO:
	return 420;
};

// Inserts a (key, value) pair into the map and returns true if the value
// was inserted successfully or false otherwise.
export fn add(self: *Map, key: str, value: bencode::Element) bool = {
	if (self.root is null) {
		self.root = &new_node(key, value);
		return true;
	};
	return _add(self, new_node(key, value), self.root);
};

// TODO:
fn _add(self: *Map, node: Node, curr: nullable *Node, dir: Color = Color::Red) bool = {
	if (curr is null) {
		curr = &node;
		return true;
	};

	let curr: *Node = curr: *Node;

	if (strings::compare(curr.key, node.key) >= 0) {
		return _add(self, node, curr.left);
	};

	return _add(self, node, curr.right);
};

// Removes the pair specified by the key, if they key was found and removed
// true will be returned otherwise false.
export fn remove(self: const *Map, key: str, value: bencode::Element) bool = {
	// TODO:
	return false;
};

// Let X be the node we want to left rotate and Y the node to the right of X.
// When we rotate we are going to change the left child of Y to be X
// and the right child of X to be the left child of Y.
fn left_rotation() void = {
	// TODO:
	fmt::println("TODO")!;
};

// X is now the right child of Y and Y right child becomes X left child.
fn right_rotation() void = {
	fmt::println("TODO")!;
};
