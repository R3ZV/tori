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

pub const DecoderError = error{
    // Misc errors
    NULL_ROOT_VALUE,

    // number errors
    NEGATIVE_ZERO,
    LEADING_ZERO,
    NON_DIGIT_CHAR,

    // str errors
    NEGATIVE_STR_LEN,
    NO_STR_SEP,
    UNEXPECTED_EOF,
};

pub fn run(self: *Self) !Type {
    const ch = self.blob[self.pos];
    if (ch == 'i') {
        return self.decode_num();
    } else if (std.ascii.isDigit(ch)) {
        return self.decode_str();
    }
    return DecoderError.NULL_ROOT_VALUE;
}

fn decode_num(self: *Self) !Type {
    // skip the 'i'
    self.pos += 1;

    const is_negative = if (self.blob[self.pos] == '-')
        true
    else
        false;

    if (is_negative) self.pos += 1;

    const idx = self.pos;

    var num: i64 = 0;
    while (self.blob[self.pos] != 'e') : (self.pos += 1) {
        const ch = self.blob[self.pos];
        if (!std.ascii.isDigit(ch)) {
            return DecoderError.NON_DIGIT_CHAR;
        }

        // 48 is ascii for 0
        num = num * 10 + (self.blob[self.pos] - 48);
    }

    if (is_negative) {
        num = -num;
        if (num == 0) {
            return DecoderError.NEGATIVE_ZERO;
        }
    }

    if (num != 0 and self.blob[idx] == '0') {
        return DecoderError.LEADING_ZERO;
    }

    return Type{
        .num = num,
    };
}

fn decode_str(self: *Self) !Type {
    if (self.blob[self.pos] == '-') {
        return DecoderError.NEGATIVE_STR_LEN;
    }

    var start_idx: usize = self.pos;
    while (self.blob[self.pos] != ':') : (self.pos += 1) {
        if (!std.ascii.isDigit(self.blob[self.pos])) {
            return DecoderError.NO_STR_SEP;
        }
    }


    const str_len = try std.fmt.parseInt(usize, self.blob[start_idx..self.pos], 10);

    start_idx = self.pos + 1;
    self.pos += str_len;
    if (self.blob.len <= self.pos) {
        return DecoderError.UNEXPECTED_EOF;
    }
    return Type{
        .str = self.blob[start_idx .. self.pos + 1],
    };
}

test "decode number" {
    const blobs: [3][]const u8 = .{
        "i42e",
        "i-42e",
        "i0e",
    };

    const expected: [3]Type = .{
        .{ .num = 42 },
        .{ .num = -42 },
        .{ .num = 0 },
    };

    const alloc = std.testing.allocator;
    for (blobs, 0..) |blob, i| {
        var bencoder = init(blob, alloc);
        const result = try bencoder.run();
        switch (result) {
            TypeTag.str => |val| try std.testing.expectEqualSlices(u8, expected[i].str, val),
            TypeTag.num => |val| try std.testing.expectEqual(expected[i].num, val),
        }
    }
}

test "decode number errors" {
    const blobs: [4][]const u8 = .{
        "i-0e",
        "i09284e",
        "if9284e",
        "i92f84e",
    };
    const expected: [4]DecoderError = .{
        DecoderError.NEGATIVE_ZERO,
        DecoderError.LEADING_ZERO,
        DecoderError.NON_DIGIT_CHAR,
        DecoderError.NON_DIGIT_CHAR,
    };

    const alloc = std.testing.allocator;
    for (blobs, 0..) |blob, i| {
        var bencoder = init(blob, alloc);
        const result = bencoder.run();
        try std.testing.expectError(expected[i], result);
    }
}

test "decode strings" {
    const blobs: [3][]const u8 = .{
        "5:zeus",
        "3:k8s",
        "14:cotton eye joe"
    };

    const expected: [3]Type = .{
        .{.str = "zeus"},
        .{.str = "k8s"},
        .{.str = "cotton eye joe"},
    };

    const alloc = std.testing.allocator;
    for (blobs, 0..) |blob, i| {
        var bencoder = init(blob, alloc);
        const result = try bencoder.run();
        switch(result) {
            TypeTag.num => unreachable,
            TypeTag.str => |got| try std.testing.expectEqualSlices(u8, expected[i].str, got),
        }
    }
}

test "decode strings errors" {
    return error.SkipZigTest;
}
