const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;

const Self = @This();

pub const TypeTag = enum {
    str,
    num,
};

const Type = union(TypeTag) {
    str: []const u8,
    num: i64,
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

pub const BencodeError = error{
    NULL_ROOT_VALUE,
};

pub fn run(self: *Self) !Type {
    const ch = self.blob[self.pos];
    if (ch == 'i') {
        return self.decode_num();
    } else if (std.ascii.isDigit(ch)) {
        return try self.decode_str();
    }
    return BencodeError.NULL_ROOT_VALUE;
}

fn decode_num(self: *Self) Type {
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

    return Type{
        .num = num,
    };
}

fn decode_str(self: *Self) !Type {
    var start_idx: usize = self.pos;
    while (self.blob[self.pos] != ':') : (self.pos += 1) {
        assert(std.ascii.isDigit(self.blob[self.pos]));
    }

    const str_len = try std.fmt.parseInt(usize, self.blob[start_idx..self.pos], 10);

    start_idx = self.pos + 1;
    self.pos += str_len;
    return Type{
        .str = self.blob[start_idx .. self.pos + 1],
    };
}
