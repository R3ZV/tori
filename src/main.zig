const std = @import("std");
const decoder = @import("decoder.zig");

const usage =
    \\Usage: tori <COMMAND> [args]
    \\
    \\Commands:
    \\help                      prints this message
    \\decode <value>            decodes a bencoded string
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);

    if (args.len < 2) {
        std.debug.print("Invalid number of arguments!\n", .{});
        std.debug.print("Use 'tori help' for more information\n", .{});
        return;
    }

    const command: []const u8 = args[1];

    if (std.mem.eql(u8, "help", command)) {
        std.debug.print("{s}\n", .{usage});
    } else if (std.mem.eql(u8, "decode", command)) {
        if (args.len < 3) {
            std.debug.print("Expected a bencoded string but none was found!\n", .{});
            std.debug.print("Use 'tori help' for more information\n", .{});
            return;
        }

        const blob = args[2];
        var bencoder = decoder.init(blob, alloc);

        const value = try bencoder.run();
        switch (value) {
            .str => |val| std.debug.print("{s}\n", .{val}),
            .number => |val| std.debug.print("{}\n", .{val}),
        }
    } else {
        std.debug.print("Invalid command\n", .{});
        std.debug.print("Use 'tori help'\n", .{});
    }

}

test {
    _ = @import("decoder.zig");
}
