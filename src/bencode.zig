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

pub fn init_decoder(blob: []const u8, alloc: Allocator) Self {
    return Self{
        .blob = blob,
        .alloc = alloc,
    };
}

pub fn run(self: *Self) !ArrayList(Element) {
    var elements = ArrayList(Element).init(self.alloc);

    while (self.pos < self.blob.len) : (self.pos += 1) {
        const ch = self.blob[self.pos];
        if (ch == 'i') {
            try elements.append(self.parse_number());
        } else if (std.ascii.isDigit(ch)) {
            try elements.append(try self.parse_string());
        }
    }

    return elements;
}

fn parse_number(self: *Self) Element {
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

fn parse_string(self: *Self) !Element {
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
