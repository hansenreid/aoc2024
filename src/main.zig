const std = @import("std");
const expect = std.testing.expect;
const day1 = @import("day1/runner.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("FAILED TO FREE MEMORY");
    }

    try day1.run(allocator);
}
