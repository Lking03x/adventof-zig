const std = @import("std");
const utils = @import("utils.zig");

const Reports = std.ArrayList(u8);
const ReportsOffsets = std.ArrayList(u8);
const Data = struct {
    reports: Reports,
    offsets: ReportsOffsets,
};

fn fromText(text: []u8, allocator: std.mem.Allocator) !Data {
    var reports = Reports.init(allocator);
    var offsets = Reports.init(allocator);
    var lineIterator = std.mem.splitScalar(u8, text, '\n');
    while (lineIterator.next()) |line| {
        if (std.mem.eql(u8, line, "")) break;
        var pairsIterator = std.mem.split(u8, line, " ");
        var i: usize = 0;
        while (pairsIterator.next()) |tk| : (i += 1) {
            if (std.mem.eql(u8, tk, "")) {
                std.debug.panic("Should this happens: in [pairsIterator]", .{});
                continue;
            }
            try reports.append(try std.fmt.parseInt(u8, tk, 10));
        }
        try offsets.append(@intCast(i));
    }
    reports.shrinkAndFree(reports.items.len);
    offsets.shrinkAndFree(offsets.items.len);
    return .{ .reports = reports, .offsets = offsets };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var allocator = gpa.allocator();
    const input = try utils.readInput(allocator, @src());
    defer allocator.free(input);

    const data = try fromText(input, allocator);
    defer data.reports.deinit();
    defer data.offsets.deinit();
    // .........................................
    try part1(data);
}

pub fn part1(data: Data) !void {
    const reports = data.reports;
    const offsets = data.offsets;
    var i: usize = 0; // global index
    var k: usize = 0; // index of current report len/offset
    var report_safety_count: u32 = 0;
    while (i < reports.items.len) : ({
        i += offsets.items[k];
        k += 1;
    }) {
        // std.debug.print("\n\nNext: {d}\n", .{offsets.items[k]});
        var onlyIncreasing = true;
        var onlyDecreasing = true;
        const report_safety: bool = blk: for (i..i + offsets.items[k] - 1) |cursor| {
            // std.debug.print("comp: {d} {d}\n", .{ reports.items[cursor], reports.items[cursor + 1] });
            var diff: i16 = reports.items[cursor + 1];
            diff -= reports.items[cursor];
            // std.debug.print("diff: {d}\n", .{diff});
            const slope = if (diff >= 1 and diff <= 3) true else if (diff <= -1 and diff >= -3)
                false
            else
                break :blk false;

            // std.debug.print("slope: {s}\n", .{if (slope) "increasing" else "decreasing"});

            if (slope == true) {
                onlyDecreasing = false;
            } else {
                onlyIncreasing = false;
            }

            if (onlyIncreasing == onlyDecreasing) break :blk false;
        } else true;
        report_safety_count += @intFromBool(report_safety);
        // std.debug.print("report_safety: {}\n", .{report_safety});
    }
    utils.printPart1Result(report_safety_count);
}
