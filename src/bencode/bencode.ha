use ascii;
use fmt;
use strings;
use strconv;

export type Decoder = struct {
	it: *strings::iterator,
};

// TODO: add list and dict
// and find a better name
export type Element = (str | int);

export fn decode(self: *Decoder) []Element = {
	fmt::println("Decoding...")!;
	let elements: []Element = [];

	for (let ch => strings::next(self.it)) {
		if (ascii::isdigit(ch)) {
			append(elements, decode_string(self))!;
		} else if (ch == 'i') {
			append(elements, decode_number(self))!;
		} else if (ch == 'l') {
			decode_list(self);
		} else if (ch == 'd') {
			decode_dict(self);
		} else {
			fmt::fatalf("[ERR]: Unexpected rune while decoding bencode '{}'", ch);
		};
	};
	fmt::println("Done decoding...")!;

	return elements;
};

fn decode_number(self: *Decoder) Element = {
	let num = 0;
	let negative = false;
	for (let ch => strings::next(self.it)) {
		if (ch == 'e') {
			break;
		};

		if (ch == '-') {
			negative = true;
			continue;
		};

		assert(ascii::isdigit(ch), "Rune is not a digit in decode_number");

		let digit = strings::fromrunes([ch])!;
		num = num * 10 + strconv::stoi(digit)!;
	};

	if (negative) {
		return -num;
	};

	return num;
};

fn decode_string(self: *Decoder) Element = {
	// Because in `decode` we next() and get the first the first digit
	// of the string length so we need to go back 1 rune because
	// there is no `curr()`.
	strings::prev(self.it);

	let str_len = "";
	for (let ch => strings::next(self.it)) {
		if (!ascii::isdigit(ch)) {
			break;
		};
		str_len = strings::concat(str_len, strings::fromrunes([ch])!)!;
	};

	let str_len = strconv::stoz(str_len)!;

	let value = "";
	for (let i = 0z; i < str_len; i += 1) {
		let ch = strings::next(self.it): rune;
		value = strings::concat(value, strings::fromrunes([ch])!)!;
	};

	return value;
};

fn decode_list(self: *Decoder) void = {
	// TODO:
	fmt::println("[TODO]: Decode list")!;
};

fn decode_dict(self: *Decoder) void = {
	// TODO:
	fmt::println("[TODO]: Decode dict")!;
};

@test fn number_decoding()  void = {
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
	assert(len(expected) == len(elements), "Invalid number of elements");

	for (let i = 0z; i < len(elements); i += 1) {
		assert(expected[i]: int == elements[i]: int);
	};
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
	assert(len(expected) == len(elements), "Invalid number of elements");

	for (let i = 0z; i < len(elements); i += 1) {
		assert(expected[i]: str == elements[i]: str);
	};
};
