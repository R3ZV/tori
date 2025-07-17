const std = @import("std");
const builtin = @import("builtin");

const Status = enum {
    PASS,
    FAIL,
    SKIP,
};

const TestResult = struct {
    name: []const u8,
    err: anyerror,
    elapsed: i64,
    status: Status = Status.SKIP,
};

pub fn main() !void {
    const stdout_file = std.io.getStdOut();
    var out = stdout_file.writer();

    if (builtin.test_functions.len == 0) {
        try out.print("No tests found!\n", .{});
        return;
    }

    const start_time = std.time.milliTimestamp();

    const total_tests = builtin.test_functions.len;
    var cnt: usize = 0;
    try std.fmt.format(out, "{}/{} tests completed\n", .{ cnt, total_tests });
    var results: [100]TestResult = undefined;
    for (builtin.test_functions, 0..) |t, i| {
        cnt += 1;
        try out.print("\x1b[1A", .{});
        try out.print("\x1b[K", .{});
        try std.fmt.format(out, "{}/{} tests completed\n", .{ cnt, total_tests });

        const start = std.time.milliTimestamp();
        const result = t.func();
        const elapsed = std.time.milliTimestamp() - start;

        const name = extractName(t);
        results[i].name = name;
        results[i].elapsed = elapsed;

        if (result) |_| {
            results[i].status = .PASS;
        } else |err| {
            if (err != error.SkipZigTest) {
                results[i].status = .FAIL;
                results[i].err = err;
            }
        }
    }

    const tests_elapsed = std.time.milliTimestamp() - start_time;

    var passed: u32 = 0;
    var skipped: u32 = 0;
    var failed: u32 = 0;
    for (0..total_tests) |i| {
        try out.print("\r\x1b[0K", .{});
        const t = results[i];
        switch (t.status) {
            .SKIP => {
                skipped += 1;
                try out.print("{s:.<60}\x1b[90mSKIP\x1b[39m in {d}ms\n", .{ t.name, t.elapsed });
            },
            .PASS => {
                passed += 1;
                try out.print("{s:.<60}\x1b[32mPASS\x1b[39m in {d}ms\n", .{ t.name, t.elapsed });
            },
            .FAIL => {
                failed += 1;
                try out.print("{s:.<60}\x1b[31mFAIL\x1b[39m in {d}ms\n", .{ t.name, t.elapsed });
            },
        }
    }

    try out.print("\n", .{});
    for (0..total_tests) |i| {
        const t = results[i];
        switch (t.status) {
            .SKIP => {
                skipped += 1;

                try out.print("\x1b[90mSkipped \"{s}\"\x1b[39m\n", .{ t.name});
            },
            .PASS, .FAIL => {},
        }
    }

    try out.print("\n", .{});
    for (0..total_tests) |i| {
        const t = results[i];
        switch (t.status) {
            .SKIP, .PASS => {},
            .FAIL => {
                failed += 1;

                try out.print("Errors for \x1b[33m{s}\x1b[0m:\n{}\n", .{t.name, t.err});
            },
        }
    }


    try out.print("\n", .{});
    try out.print("\x1b[32m{}\x1b[39m passed; \x1b[31m{}\x1b[39m failed; {} skipped; {} completed in {}ms\n", .{
        passed,
        failed,
        skipped,
        total_tests,
        tests_elapsed,
    });

}

fn extractName(t: std.builtin.TestFn) []const u8 {
    const marker = std.mem.lastIndexOf(u8, t.name, ".test.") orelse return t.name;
    return t.name[marker + 6 ..];
}
