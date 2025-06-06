use fmt;
use bencode;
use strings;

export fn main() void = {
	fmt::println("In progress...")!;

	let blob = "5:tests4:hare11:programming";
	let it = strings::iter(blob);
	let decoder = bencode::Decoder {
		it = &it,
	};

	let elements = bencode::decode(&decoder);
	for (let element .. elements) {
		if (element is str || element is int) {
			fmt::println(element: str)!;
		};
	};
};
