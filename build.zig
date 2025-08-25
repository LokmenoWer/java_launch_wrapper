//! zig version: 0.15.1

const std = @import("std");
const Arch = std.Target.Cpu.Arch;

const NATIVE_VERSION = "1.4.5";

const TARGET_ARCH = [_]Arch{
    .x86,
    .x86_64,
    .aarch64,
};

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});

    const jui = b.createModule(.{
        .root_source_file = b.path("lib/jui/src/jui.zig"),
    });

    inline for (TARGET_ARCH) |arch| {
        const target = b.resolveTargetQuery(std.Target.Query{ .cpu_arch = arch, .os_tag = .windows, .abi = .msvc });
        const lib = b.addLibrary(.{
            .name = "libjlw-" ++ @tagName(arch) ++ "-" ++ NATIVE_VERSION,
            .linkage = .dynamic,
            .version = try std.SemanticVersion.parse(NATIVE_VERSION),
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/main/zig/wrapper.zig"),
                .target = target,
                .optimize = optimize,
            }),
        });
        lib.root_module.addImport("jui", jui);
        b.installArtifact(lib);
    }
}
