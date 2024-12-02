const std = @import("std");
const File = std.fs.File;
const Arena = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;

const RunnerType = union(enum) { Example1, Problem1, Example2, Problem2 };

pub fn Runner(day: u8, runner_type: RunnerType, intermediate_type: type, accumulator_type: type, final_type: type) type {
    return struct {
        file: std.fs.File,
        arena: Arena,

        const Self = @This();

        pub fn init(allocator: Allocator) !Self {
            const problem_path = switch (runner_type) {
                .Example1 => "example1",
                .Example2 => "example2",
                .Problem1, .Problem2 => "input",
            };

            var buf: [32]u8 = undefined;
            const path = try std.fmt.bufPrint(&buf, "src/day{d}/{s}.txt", .{ day, problem_path });

            const file = try std.fs.cwd().openFile(path, .{});

            return Self{
                .arena = Arena.init(allocator),
                .file = file,
            };
        }

        pub fn deinit(self: *Self) void {
            self.file.close();
            self.arena.deinit();
        }

        const LineParser = fn (arena: Allocator, line: []const u8) intermediate_type;
        const Accumulator = fn (acc: accumulator_type, it: intermediate_type) accumulator_type;
        const FinalCalculation = fn (acc: accumulator_type) final_type;

        pub fn run(self: *Self, initial_value: accumulator_type, f: LineParser, acc_f: Accumulator, final_f: FinalCalculation) !final_type {
            var buf_reader = std.io.bufferedReader(self.file.reader());
            var reader = buf_reader.reader();
            const allocator = self.arena.allocator();

            var acc = initial_value;
            var buf: [256]u8 = undefined;
            while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
                const intermediate_value = f(allocator, line);
                acc = acc_f(acc, intermediate_value);
            }

            const desc = switch (runner_type) {
                .Example1 => "example 1",
                .Problem1 => "problem 1",
                .Example2 => "example 2",
                .Problem2 => "problem 2",
            };

            const result = final_f(acc);

            std.debug.print("Result for day {d} {s} is: {any}\n", .{ day, desc, result });
            return result;
        }
    };
}
