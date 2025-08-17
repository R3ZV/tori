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
    var writer = std.fs.File.stdout().writer(&.{});
    const stdout = &writer.interface;

    if (args.len < 2) {
        try stdout.print("Invalid number of arguments!\n", .{});
        try stdout.print("Use 'tori help' for more information\n", .{});
        try stdout.flush();
        return;
    }

    const command: []const u8 = args[1];

    if (std.mem.eql(u8, "help", command)) {
        try stdout.print("{s}\n", .{usage});
    } else if (std.mem.eql(u8, "decode", command)) {
        if (args.len < 3) {
            try stdout.print("Expected a bencoded string but none was found!\n", .{});
            try stdout.print("Use 'tori help' for more information\n", .{});
            try stdout.flush();
            return;
        }

        const blob = args[2];
        var bencoder = decoder.init(blob, alloc);

        const value = try bencoder.run();
        switch (value) {
            .str => |val| try stdout.print("{s}\n", .{val}),
            .number => |val| try stdout.print("{}\n", .{val}),
        }
    } else {
        try stdout.print("Invalid command\n", .{});
        try stdout.print("Use 'tori help'\n", .{});
        try stdout.flush();
    }

}

test {
    _ = @import("decoder.zig");
}
