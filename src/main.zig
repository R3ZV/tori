const std = @import("std");
const bencode = @import("bencode.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const blob = "6:prolog4:rusti42ei-42e";
    var decoder = bencode.init_decoder(blob, alloc);

    const values = try decoder.run();
    for (values.items) |item| {
        switch (item) {
            .str => |val| std.debug.print("{s}\n", .{val}),
            .number => |val| std.debug.print("{}\n", .{val}),
        }
    }
}
