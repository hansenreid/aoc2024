const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const Runner = @import("../runner.zig").Runner;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;

pub fn run(allocator: Allocator) !void {
    var runner = try Runner(1, .Problem2, Line, *Lists, i64).init(allocator);
    defer runner.deinit();

    var lists = Lists.init(allocator);
    defer lists.deinit();

    _ = try runner.run(&lists, line_parser, accumulator, final_calc);
}

const Line = struct {
    left: i64,
    right: i64,
};

const Lists = struct {
    left_array: ArrayList(i64),
    right_array: ArrayList(i64),

    pub fn init(allocator: Allocator) Lists {
        return Lists{
            .left_array = ArrayList(i64).init(allocator),
            .right_array = ArrayList(i64).init(allocator),
        };
    }

    pub fn deinit(self: *Lists) void {
        self.left_array.deinit();
        self.right_array.deinit();
    }
};

fn line_parser(_: Allocator, line: []const u8) Line {
    var iter = std.mem.splitSequence(u8, line, "   ");
    const first = iter.next().?;
    const left = std.fmt.parseInt(i64, first, 10) catch {
        std.debug.panic("Failed to parse into i64: {s}", .{first});
    };

    const second = iter.next().?;
    const right = std.fmt.parseInt(i64, second, 10) catch {
        unreachable;
    };

    return Line{
        .left = left,
        .right = right,
    };
}

fn accumulator(acc: *Lists, line: Line) *Lists {
    acc.left_array.append(line.left) catch {
        unreachable;
    };

    acc.right_array.append(line.right) catch {
        unreachable;
    };

    return acc;
}

fn final_calc(allocator: Allocator, lists: *Lists) i64 {
    const value_type = struct {
        num_left: i64,
        num_right: i64,
    };

    var map = AutoHashMap(i64, value_type).init(allocator);

    for (lists.left_array.items) |item| {
        if (map.get(item)) |found| {
            map.put(
                item,
                .{ .num_left = found.num_left + 1, .num_right = found.num_right },
            ) catch {
                unreachable;
            };
        } else {
            map.put(item, .{ .num_left = 1, .num_right = 0 }) catch {
                unreachable;
            };
        }
    }

    for (lists.right_array.items) |item| {
        if (map.get(item)) |found| {
            map.put(
                item,
                .{ .num_left = found.num_left, .num_right = found.num_right + 1 },
            ) catch {
                unreachable;
            };
        }
    }

    var total: i64 = 0;
    var iter = map.iterator();
    while (iter.next()) |entry| {
        const left = entry.key_ptr.*;
        const right = entry.value_ptr.*;
        total += left * right.num_left * right.num_right;
    }

    return total;
}

test "example returns correct value" {
    const allocator = std.testing.allocator;
    var runner = try Runner(1, .Example2, Line, *Lists, i64).init(allocator);
    defer runner.deinit();

    var lists = Lists.init(allocator);
    defer lists.deinit();

    const result = try runner.run(&lists, line_parser, accumulator, final_calc);
    try expect(result == 31);
}
