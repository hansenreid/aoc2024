const std = @import("std");
const problem1 = @import("problem1.zig");
const Allocator = std.mem.Allocator;

pub fn run(allocator: Allocator) !void {
    try problem1.run(allocator);
}
