const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, absolute_path: []const u8) ![]u8 {
    const file = try std.fs.openFileAbsolute(absolute_path, .{});
    const stat = try file.stat();
    std.debug.print("file size: {d}\n", .{stat.size});
    const content = try allocator.alloc(u8, stat.size);
    std.debug.assert(try file.readAll(content) == stat.size);
    return content;
}

pub fn readInput(allocator: std.mem.Allocator, solutionSrcLoc: std.builtin.SourceLocation) ![]u8 {
    var splitIterator = std.mem.split(u8, solutionSrcLoc.file, ".");
    const tk = splitIterator.next() orelse unreachable;
    const problem_no = std.fmt.parseInt(u32, tk, 10) catch unreachable;
    var buffer: [256 * 3]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const fb_allocator = fba.allocator();
    const cwd_dir = comptime std.fs.cwd();

    const cwd_path = cwd_dir.realpathAlloc(fb_allocator, ".") catch unreachable;
    // defer fb_allocator.free(cwd_path);
    // std.debug.print("cwd_path: {s}\n", .{cwd_path});

    const input_filename = std.fmt.allocPrint(
        fb_allocator,
        "{d}.input",
        .{problem_no},
    ) catch unreachable;
    // defer fb_allocator.free(input_filename);
    // std.debug.print("input_filename: {s}\n", .{input_filename});

    const input_filepath = std.fs.path.join(
        fb_allocator,
        &.{ cwd_path, "inputs", input_filename },
    ) catch unreachable;
    // defer fb_allocator.free(input_filepath);
    std.debug.print("input_filepath: {s}\n", .{input_filepath});

    std.debug.assert(std.fs.path.isAbsolute(input_filepath));
    return readFile(allocator, input_filepath);
}

pub fn printPart1Result(result: usize) void {
    std.debug.print("Part 1: {d}\n", .{result});
}

pub fn printPart2Result(result: usize) void {
    std.debug.print("Part 2: {d}\n", .{result});
}
