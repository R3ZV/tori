use ascii;
use fmt;
use strings;
use strconv;

// Iterator should live as long as the decoder.
export type Decoder = struct {
	it: *strings::iterator,
};

// TODO: Add dict
// TODO: Find a better name
export type Element = (str | int | []Element);

export fn decode(self: *Decoder) []Element = {
	let elements: []Element = [];

	for (let ch => strings::next(self.it)) {
		if (ch == 'e') {
			break;
		};

		if (ascii::isdigit(ch)) {
			append(elements, decode_string(self))!;
		} else if (ch == 'i') {
			append(elements, decode_number(self))!;
		} else if (ch == 'l') {
			append(elements, decode(self))!;
		} else if (ch == 'd') {
			fmt::fatalf("TODO: Parsing dictionaries");
		} else {
			fmt::fatalf("[ERR]: Unexpected rune while decoding bencode '{}'", ch);
		};
	};
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

fn decode_dict(self: *Decoder) void = {
	// TODO:
	fmt::println("[TODO]: Decode dict")!;
};

fn equal(self: const []Element, other: const []Element) bool = {
	if (len(self) != len(other)) {
		return false;
	};

	for (let i = 0z; i < len(self); i += 1) {
		if (
			(self[i] is []Element && !(other[i] is []Element)) ||
			(self[i] is str && !(other[i] is str)) ||
			(self[i] is int && !(other[i] is int))
		) {
			return false;
		};

		if (self[i] is str) {
			if (self[i]: str != other[i]: str) {
				return false;
			};
		} else if (self[i] is int) {
			if (self[i]: int != other[i]: int) {
				return false;
			};
		} else if (self[i] is []Element) {
			if (!equal(self[i]: []Element, other[i]: []Element)) {
				return false;
			};
		} else {
			assert(false, "There is a limited number of possible element types");
		};
	};

	return true;
};
