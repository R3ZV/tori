const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;

const Self = @This();

const ElementType = enum {
    str,
    number,
};

const Element = union(ElementType) {
    str: []const u8,
    number: i64,
};

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
    const ch = self.blob[self.pos];
    if (ch == 'i') {
        return self.decode_number();
    }
    // } else if (std.ascii.isDigit(ch)) {
    // }
    return try self.decode_string();
}

fn decode_number(self: *Self) Element {
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
        assert(std.ascii.isDigit(ch));

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
        }
    }
}
