const std = @import("std");
const utils = @import("utils.zig");

const Data = struct {
    left: []u32,
    right: []u32,
};

fn fromText(text: []u8, allocator: std.mem.Allocator) !Data {
    const pairs_count = std.mem.count(u8, text, "\n");
    const data = Data{
        .left = try allocator.alloc(u32, pairs_count),
        .right = try allocator.alloc(u32, pairs_count),
    };
    var lineIterator = std.mem.splitScalar(u8, text, '\n');
    var i: usize = 0;
    while (lineIterator.next()) |line| : (i += 1) {
        if (std.mem.eql(u8, line, "")) break;
        var pairsIterator = std.mem.split(u8, line, "   ");
        var first = true;
        while (pairsIterator.next()) |tk| {
            if (std.mem.eql(u8, tk, "")) continue;
            defer first = false;
            if (first) {
                data.left[i] = try std.fmt.parseInt(u32, tk, 10);
            } else {
                data.right[i] = try std.fmt.parseInt(u32, tk, 10);
            }
        }
    }
    return data;
}

fn lessThanFn(_: void, lhs: u32, rhs: u32) bool {
    return std.math.compare(lhs, .lt, rhs);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input = try utils.readInput(allocator, @src());
    defer allocator.free(input);

    const data = try fromText(input, allocator);
    // .........................................

    std.mem.sort(u32, data.left, void{}, lessThanFn);
    std.mem.sort(u32, data.right, void{}, lessThanFn);

    {
        var result: u32 = 0;
        for (data.left, data.right) |left, right| {
            var distance: i32 = @intCast(left);
            distance -= @intCast(right);
            if (distance < 0) distance = -distance;
            result += @intCast(distance);
        }
        std.debug.print("Part 1: {d}\n", .{result});
    }
    {
        // naive impl
        var result: u32 = 0;
        for (data.left) |l| {
            var count: usize = 0;
            for (data.right) |r| {
                if (l == r) count += 1;
            }
            result += l * @as(u32, @intCast(count));
        }
        std.debug.print("Part 2: {d}\n", .{result});
    }
}
