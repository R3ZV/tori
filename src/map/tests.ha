@test fn insert_empty_tree() void = {
	let map = new_map();
	add(&map, "gta_version", 6);

	match (map.root) {
	case null => assert(false, "Root is null");
	case let node: *Node => assert(node.value == 6, "Root not set correctly");
	};
};
