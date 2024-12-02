const std = @import("std.zig");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;

const MinHeap = struct {
    heap: std.ArrayList(i64),
    len: u64,

    pub fn init(allocator: Allocator) MinHeap {
        return MinHeap{
            .heap = std.ArrayList(i64).init(allocator),
            .len = 0,
        };
    }

    pub fn deinit(self: *MinHeap) void {
        self.heap.deinit();
    }

    pub fn add(self: *MinHeap, item: i64) void {
        self.heap.append(item) catch {
            std.debug.panic("Failed to append to list", .{});
        };
        self.len += 1;

        var parent_index = self.parent_idx(self.len);
        var curr_index: usize = self.len - 1;
        while (parent_index) |idx| {
            const parent = self.heap.items[idx];
            if (item < parent) {
                self.heap.items[idx] = item;
                self.heap.items[curr_index] = parent;

                curr_index = idx;
                parent_index = self.parent_idx(idx);
            } else {
                break;
            }
        }
    }

    pub fn peak(self: *MinHeap) ?i64 {
        if (self.len == 0) {
            return null;
        }

        return self.heap.items[0];
    }

    pub fn pop(self: *MinHeap) ?i64 {
        if (self.len == 0) {
            return null;
        }

        const item = self.heap.items[0];
        const last_item = self.heap.pop();

        self.len -= 1;
        if (self.len == 0) {
            return last_item;
        }

        self.heap.items[0] = last_item;

        var index: usize = 0;
        while (true) {
            const left_child: usize = 2 * index + 1;
            const right_child: usize = 2 * index + 2;
            var smallest = index;

            if (left_child < self.len and self.heap.items[left_child] < self.heap.items[smallest]) {
                smallest = left_child;
            }

            if (right_child < self.len and self.heap.items[right_child] < self.heap.items[smallest]) {
                smallest = right_child;
            }

            if (smallest != index) {
                const old = self.heap.items[index];
                self.heap.items[index] = self.heap.items[smallest];
                self.heap.items[smallest] = old;
                index = smallest;
            } else {
                break;
            }
        }

        return item;
    }

    fn parent_idx(self: *MinHeap, idx: usize) ?usize {
        if (idx == 0) {
            return null;
        }

        if (idx - 1 > self.len) {
            return null;
        }

        return (idx - 1) / 2;
    }
};

test "can add items to heap and maintain min order" {
    const allocator = std.testing.allocator;

    var heap = MinHeap.init(allocator);
    defer heap.deinit();

    try expect(heap.len == 0);
    try expect(heap.peak() == null);

    heap.add(42);
    try expect(heap.len == 1);
    try expect(heap.peak() == 42);

    heap.add(24);
    try expect(heap.len == 2);
    try expect(heap.peak() == 24);

    heap.add(12);
    try expect(heap.len == 3);
    try expect(heap.peak() == 12);

    heap.add(6);
    try expect(heap.len == 4);
    try expect(heap.peak() == 6);

    heap.add(7);
    try expect(heap.len == 5);
    try expect(heap.peak() == 6);

    heap.add(6);
    try expect(heap.len == 6);
    try expect(heap.peak() == 6);
}

test "can find parent and children of node" {
    const allocator = std.testing.allocator;

    var heap = MinHeap.init(allocator);
    defer heap.deinit();

    heap.add(0);
    heap.add(1);
    heap.add(2);
    heap.add(3);
    heap.add(4);
    heap.add(5);
    heap.add(6);
    heap.add(7);

    // Parent of 0 should be null
    try expect(heap.parent_idx(0) == null);

    // Parent of 1 and 2 should be 0
    try expect(heap.parent_idx(1) == 0);
    try expect(heap.parent_idx(2) == 0);

    // Parent of 3 and 4 should be 1
    try expect(heap.parent_idx(3) == 1);
    try expect(heap.parent_idx(4) == 1);

    // Parent of 5 and 6 should be 2
    try expect(heap.parent_idx(5) == 2);
    try expect(heap.parent_idx(6) == 2);

    // Parent of 7 should be 3
    try expect(heap.parent_idx(7) == 3);
}

test "can pop items and maintain order" {
    const allocator = std.testing.allocator;

    var heap = MinHeap.init(allocator);
    defer heap.deinit();

    heap.add(42);
    heap.add(24);
    heap.add(12);
    heap.add(6);
    heap.add(6);
    heap.add(100);
    heap.add(6);
    heap.add(53);
    heap.add(13);
    heap.add(18);

    try expect(heap.pop() == 6);
    try expect(heap.pop() == 6);
    try expect(heap.pop() == 6);
    try expect(heap.pop() == 12);
    try expect(heap.pop() == 13);
    try expect(heap.pop() == 18);
    try expect(heap.pop() == 24);
    try expect(heap.pop() == 42);
    try expect(heap.pop() == 53);
    try expect(heap.pop() == 100);
    try expect(heap.pop() == null);
}
