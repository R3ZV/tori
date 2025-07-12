const std = @import("std");
const builtin = @import("builtin");

pub fn main() !void {
    var buffer: [256]u8 = undefined;
    const stdout_file = std.fs.File.stdout();
    var file_writer = stdout_file.writer(&buffer);
    const out = &file_writer.interface;

    if (builtin.test_functions.len == 0) {
        try out.print("No tests found!\n", .{});
        try out.flush();
        return;
    }

    // TODO: progress bar
    for (builtin.test_functions) |t| {
        const start = std.time.milliTimestamp();
        const result = t.func();
        const elapsed = std.time.milliTimestamp() - start;

        try out.print("\r\x1b[0K", .{});
        try out.flush();
        const name = extractName(t);
        if (result) |_| {
            // TODO: output in second 0.23s
            try out.print("{s:.<60}\x1b[32mPASS\x1b[39m in {d}ms\n", .{ name, elapsed });
            try out.flush();
        } else |err| {
            try out.print("{s} failed - {}\n", .{ t.name, err });
            try out.flush();
        }
    }
    // TODO: print each test that was skipped
    // e.g. Skipped name
    // TODO: statistic
    // 30 passed; 0 failed; 8 skipped; 587 completed in 2.341s
}

fn extractName(t: std.builtin.TestFn) []const u8 {
    const marker = std.mem.lastIndexOf(u8, t.name, ".test.") orelse return t.name;
    return t.name[marker + 6 ..];
}
