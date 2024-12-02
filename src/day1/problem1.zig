const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const Runner = @import("../runner.zig").Runner;
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;

pub fn run(allocator: Allocator) !void {
    var runner = try Runner(1, .Problem1, Line, *Lists, u64).init(allocator);
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

    var buf1: [32]u8 = undefined;
    const first_string = std.fmt.bufPrint(&buf1, "{s}", .{first}) catch {
        unreachable;
    };

    assert(std.mem.eql(u8, first, first_string));

    const second = iter.next().?;
    const right = std.fmt.parseInt(i64, second, 10) catch {
        unreachable;
    };

    var buf2: [32]u8 = undefined;
    const second_string = std.fmt.bufPrint(&buf2, "{s}", .{second}) catch {
        unreachable;
    };

    assert(std.mem.eql(u8, second, second_string));

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

fn final_calc(lists: *Lists) u64 {
    if (lists.left_array.items.len != lists.right_array.items.len) {
        std.debug.panic("Lists are not the same length: {any}\n", .{lists});
    }

    std.mem.sort(i64, lists.left_array.items, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, lists.right_array.items, {}, comptime std.sort.asc(i64));

    var total_distance: u64 = 0;
    for (0..lists.left_array.items.len) |i| {
        const left_array = lists.left_array.items[i];
        const right_array = lists.right_array.items[i];

        const distance = @abs(left_array - right_array);
        total_distance += distance;
    }

    return total_distance;
}

test "example returns correct value" {
    const allocator = std.testing.allocator;
    var runner = try Runner(1, .Example1, Line, *Lists, u64).init(allocator);
    defer runner.deinit();

    var lists = Lists.init(allocator);
    defer lists.deinit();

    const result = try runner.run(&lists, line_parser, accumulator, final_calc);
    try expect(result == 11);
}
