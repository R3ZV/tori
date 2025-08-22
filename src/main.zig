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
    var buff: [256]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&buff);
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

        const res = bencoder.run();
        if (res) |value| {
            try decoder.print(&value, stdout);
        } else |err| switch(err) {
            decoder.Error.empty_root => try stdout.print("Empty root blob provided!\n", .{}),
            decoder.Error.invalid_number => try stdout.print("One of the provided number is invalid!\n", .{}),
            decoder.Error.invalid_root => {
                try stdout.print("Invalid root provided!\n", .{});
                try stdout.print("Expected one of the following:\n", .{});
                try stdout.print("1. number         i.e. i42e           -> 42\n", .{});
                try stdout.print("2. string         i.e. 4:tori         -> tori\n", .{});
                try stdout.print("3. list           i.e. li42e          -> [42]\n", .{});
                try stdout.print("4. dictionary     i.e. d4:toii42e    -> [tori: 42]\n", .{});
            },
            else => try stdout.print("Error: {}\n", .{err}),
        }
    } else {
        try stdout.print("Invalid command\n", .{});
        try stdout.print("Use 'tori help'\n", .{});
    }

    try stdout.flush();

}

test {
    _ = @import("decoder.zig");
}
