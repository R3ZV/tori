const std = @import("std");
const decoder = @import("decoder.zig");

const usage =
    \\Usage: tori <COMMAND> [args]
    \\
    \\Commands:
    \\  help                prints this message
    \\  decode              decodes given bencoded blob
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var buffer: [256]u8 = undefined;
    const stdout_file = std.fs.File.stdout();
    var file_writer = stdout_file.writer(&buffer);
    const out = &file_writer.interface;

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    const cmd = if (args.len < 2)
        undefined
    else
        args[1];

    if (std.mem.eql(u8, cmd, "decode")) {
        if (args.len < 3) {
            try out.print("Invalid number of arguments!\n", .{});
            try out.print("Expected a bencoded blob!\n", .{});
            try out.flush();
            return;
        }
        const blob = args[2];
        var bencoder = decoder.init(blob, alloc);
        const result = try bencoder.run();
        switch (result) {
            decoder.TypeTag.str => |val| try out.print("Result: {s}\n", .{val}),
            decoder.TypeTag.num => |val| try out.print("Result: {}\n", .{val}),
        }
    } else if (std.mem.eql(u8, cmd, "help")) {
        try out.print("{s}\n", .{usage});
    } else {
        try out.print("Unsupported command!\n", .{});
        try out.print("Use 'tori help' for available commands!\n", .{});
    }
    try out.flush();
}

test {
    _ = @import("decoder.zig");
}
