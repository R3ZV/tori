const std = @import("std");

const Compile = std.Build.Step.Compile;
const OptimizeMode = std.builtin.OptimizeMode;
const ResolvedTarget = std.Build.ResolvedTarget;

const C_FLAGS = .{
    "-std=c23",
    "-O2",
    "-pedantic",
    "-Wall",
    "-Wextra",
    "-Werror",
    "-Wshadow",
    "-Wconversion",
    "-Wsign-conversion",
    "-Wformat=2",
    "-Wnull-dereference",
    "-fstack-protector-strong",
    "-D_FORTIFY_SOURCE=2",
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    build_bin(b, target, optimize);
    build_tests(b, target, optimize);
}

const bin_files = .{ "cmd/tori/main.c" } ++ src_files;

const src_files = .{
    "src/bencode.c",
    "src/decoder.c",
};

fn build_bin(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) void {
    const exe = b.addExecutable(.{
        .name = "tori",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    exe.linkLibC();

    exe.addCSourceFiles(.{
        .files = &bin_files,
        .flags = &C_FLAGS,
    });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the binary");
    run_step.dependOn(&run_cmd.step);

    b.installArtifact(exe);

}

const test_files = .{
    "tests/runner.c",
    "tests/decoder_tests.c",
} ++ src_files;

fn build_tests(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) void {
    const unit_tests = b.addExecutable(.{
        .name = "tests",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .imports = &.{},
        }),
    });

    unit_tests.linkLibC();

    unit_tests.addCSourceFiles(.{
        .files = &test_files,
        .flags = &C_FLAGS,
    });

    b.installArtifact(unit_tests);

    const test_cmd = b.addRunArtifact(unit_tests);
    test_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        test_cmd.addArgs(args);
    }

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&test_cmd.step);
}
