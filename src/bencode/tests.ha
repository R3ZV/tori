use strings;

@test fn single_elements() void = {
	let one: []Element = ["bencode", -20];
	let two: []Element = ["bencode", -21];

	assert(equal(one, two) == false, "First failed");

	let one: []Element = ["bencode", -20];
	let two: []Element = ["bencode", -20];

	assert(equal(one, two) == true, "Second failed");
};

@test fn single_elements() void = {
	let one: []Element = [["bencode", -20]];
	let two: []Element = [["bencode", -20]];

	assert(equal(one, two) == true);
};

@test fn number_decoding() void = {
	let blob = "i5248219ei-4326e";
	let it = strings::iter(blob);
	let decoder = Decoder {
		it = &it,
	};

	let expected: []Element = [
		5248219,
		-4326
	];

	let elements = decode(&decoder);
	assert(equal(expected, elements));
};

@test fn string_decoding()  void = {
	let blob = "5:tests4:hare11:programming";
	let it = strings::iter(blob);
	let decoder = Decoder {
		it = &it,
	};

	let expected: []Element = [
		"tests",
		"hare",
		"programming"
	];

	let elements = decode(&decoder);
	assert(equal(expected, elements));
};

@test fn list_decoding()  void = {
	let blob = "l7:bencodei-20ee";
	let it = strings::iter(blob);
	let decoder = Decoder {
		it = &it,
	};

	let expected: []Element = [
		["bencode", -20],
	];

	let elements = decode(&decoder);
	assert(equal(expected, elements));
};

@test fn list_of_lists()  void = {
	let blob = "lll7:bencodei-20eeee";
	let it = strings::iter(blob);
	let decoder = Decoder {
		it = &it,
	};

	let expected: []Element = [
		[[["bencode", -20]]],
	];

	let elements = decode(&decoder);
	assert(equal(expected, elements));
};

@test fn empty_list_decoding()  void = {
	let blob = "le";
	let it = strings::iter(blob);
	let decoder = Decoder {
		it = &it,
	};

	let expected: []Element = [[]];

	let elements = decode(&decoder);
	assert(equal(expected, elements));
};
