const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const Writer = std.Io.Writer;

pub const Error = error {
    empty_root,
    invalid_root,
    invalid_number,
    invalid_encoding,
};

const Self = @This();

const ElementType = enum {
    str,
    number,
    list,
};

pub const Element = union(ElementType) {
    str: []const u8,
    number: i64,
    list: ArrayList(Element),
};

pub fn print(self: *const Element, stdout: *Writer) !void {
    try _print(self, stdout);
    try stdout.print("\n", .{});
}

fn _print(self: *const Element, stdout: *Writer) !void {
    switch (self.*) {
        .str => |val| try stdout.print("{s}", .{val}),
        .number => |val| try stdout.print("{}", .{val}),
        .list => |vals| {
            try stdout.print("[", .{});
            for (vals.items, 0..) |val, i| {
                try _print(&val, stdout);
                if (i + 1 != vals.items.len) {
                    try stdout.print(", ", .{});
                }
            }
            try stdout.print("]", .{});
        },
    }
}

pos: usize = 0,
blob: []const u8,
alloc: Allocator,

pub fn init(blob: []const u8, alloc: Allocator) Self {
    return Self{
        .blob = blob,
        .alloc = alloc,
    };
}

pub fn run(self: *Self) !Element {
    if (self.blob.len == 0) {
        return Error.empty_root;
    }

    const ch = self.blob[self.pos];
    if (ch == 'e') {
        return Error.invalid_encoding;
    }

    if (ch == 'i') {
        return self.decode_number();
    }

    if (ch == 'l') {
        self.pos += 1;
        var elems: ArrayList(Element) = .empty;
        while (self.pos < self.blob.len and self.blob[self.pos] != 'e') {
            const elem = try self.run(); 
            std.debug.print("List item: {}\n", .{elem});
            try elems.append(self.alloc, elem);
            self.pos += 1;
        }
        self.pos += 1;
        return Element {.list = elems };
    }

    if (ch == 'd') {
        unreachable;
    }

    if (std.ascii.isDigit(ch)) {
        return try self.decode_string();
    }

    return Error.invalid_root;
}

fn decode_number(self: *Self) Error!Element {
    // skip the 'i'
    self.pos += 1;

    const is_negative = if (self.blob[self.pos] == '-')
        true
    else
        false;

    if (is_negative) self.pos += 1;

    var num: i64 = 0;
    while (self.blob[self.pos] != 'e') : (self.pos += 1) {
        const ch = self.blob[self.pos];
        if (!std.ascii.isDigit(ch)) {
            return Error.invalid_number;
        }

        // 48 is ascii for 0
        num = num * 10 + (self.blob[self.pos] - 48);
    }

    if (is_negative) {
        num = -num;
    }

    return Element{
        .number = num,
    };
}

fn decode_string(self: *Self) !Element {
    var start_idx: usize = self.pos;
    while (self.blob[self.pos] != ':') : (self.pos += 1) {
        assert(std.ascii.isDigit(self.blob[self.pos]));
    }

    const str_len = try std.fmt.parseInt(usize, self.blob[start_idx..self.pos], 10);

    start_idx = self.pos + 1;
    self.pos += str_len;
    return Element{
        .str = self.blob[start_idx .. self.pos + 1],
    };
}

test "parsing numbers" {
    const alloc = std.testing.allocator;

    const blobs: [4][]const u8 = .{
        "i2425910823242e",
        "i-424252352e",
        "i59284e",
        "i49991824e",
    };

    const expected: [4]Element = .{
        Element{ .number = 2425910823242 },
        Element{ .number = -424252352 },
        Element{ .number = 59284 },
        Element{ .number = 49991824 },
    };

    for (0..expected.len) |i| {
        var decoder = init(blobs[i], alloc);
        const value = try decoder.run();

        switch (expected[i]) {
            .number => assert(expected[i].number == value.number),
            .str => unreachable,
            .list => unreachable,
        }
    }
}
