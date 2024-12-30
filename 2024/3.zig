const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var allocator = gpa.allocator();
    const input = try utils.readInput(allocator, @src());
    defer allocator.free(input);

    // // .........................................
    // const sample_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    utils.show_debug_print(false);
    try part1(input);
    try part2(input);
}

pub fn part1(data: []const u8) !void {
    const State = enum {
        invalid,
        lparent,
        rparent,
        mul_kw,
        numbers, // with the ',' eg. "34,194"
    };
    var result: usize = 0;
    var numbers: [2]u32 = undefined;
    var numbers_tk_len: usize = undefined;
    var state: State = .invalid; // previous state
    var index: usize = 0; // current start index
    parser_step: while (index < data.len) {
        utils.dbg("\nindex: {}, first character: {c}, state: {s}\n", .{ index, data[index], @tagName(state) });
        // if (data.len < 80) {
        //     utils.dbg("{s}\n", .{data});
        //     for (0..index) |_| {
        //         utils.dbg(" ", .{});
        //     }
        //     utils.dbg("^\n", .{});
        // }
        switch (state) {
            .invalid => {
                if (index + 3 >= data.len) {
                    break;
                }
                if (std.mem.eql(u8, data[index .. index + 3], "mul")) {
                    state = .mul_kw;
                    index += 3;
                } else {
                    index += 1;
                }
                continue;
            },
            .mul_kw => {
                state = if (data[index] == '(') .lparent else .invalid;
                index += 1;
                continue;
            },
            .lparent => {
                // try parsing numbers "x,y"
                const indexOf_rparent = std.mem.indexOfScalarPos(u8, data, index, ')') orelse {
                    index += 1;
                    state = .invalid;
                    utils.dbg("Invalidation: ')' not found\n", .{});
                    continue;
                };
                numbers_tk_len = indexOf_rparent - index;
                if (numbers_tk_len > 7) {
                    index += 1;
                    state = .invalid;
                    utils.dbg("Invalidation: numbers_tk_len > 7 (value = {d})\n", .{numbers_tk_len});
                    continue;
                }
                var iter = std.mem.split(u8, data[index..indexOf_rparent], ",");
                var nn: usize = 0;
                while (iter.next()) |number| : (nn += 1) {
                    utils.dbg("find number {d}: {s}\n", .{ nn, number });
                    const n = std.fmt.parseUnsigned(u32, number, 10) catch {
                        index += 1;
                        state = .invalid;
                        utils.dbg("Invalidation: cannot parse '{s}' as uint\n", .{number});
                        continue :parser_step;
                    };
                    switch (nn) {
                        0 => numbers[0] = n,
                        1 => numbers[1] = n,
                        else => {
                            index += 1;
                            state = .invalid;
                            utils.dbg("Invalidation: too many number to parse\n", .{});
                            continue :parser_step;
                        },
                    }
                }
                index += numbers_tk_len;
                state = .numbers;
                continue;
            },
            .numbers => {
                if (data[index] == ')') {
                    state = .rparent;
                    index += 1;
                } else {
                    index += 1;
                    state = .invalid;
                    utils.dbg("Invalidation: expected ')' found '{c}'\n", .{data[index]});
                }
                continue;
            },
            .rparent => {
                // commit
                result += numbers[0] * numbers[1];
                utils.dbg("Commiting: `{d} * {d}`, result is now {d}\n", .{ numbers[0], numbers[1], result });
                state = .invalid;
                // index += 0;
                continue;
            },
        }
    }
    utils.printPart1Result(result);
}

pub fn part2(data: []const u8) !void {
    const State = enum {
        invalid,
        lparent,
        rparent,
        mul_kw,
        numbers, // with the ',' eg. "34,194"
    };
    var result: usize = 0;
    var numbers: [2]u32 = undefined;
    var numbers_tk_len: usize = undefined;
    var state: State = .invalid; // previous state
    var index: usize = 0; // current start index
    var should_do = true;
    parser_step: while (index < data.len) {
        utils.dbg("\nindex: {}, first character: {c}, state: {s}\n", .{ index, data[index], @tagName(state) });
        // if (data.len < 80) {
        //     utils.dbg("{s}\n", .{data});
        //     for (0..index) |_| {
        //         utils.dbg(" ", .{});
        //     }
        //     utils.dbg("^\n", .{});
        // }
        const dont_string = "don't()";
        const do_string = "do()";
        if (index + do_string.len < data.len and std.mem.eql(u8, data[index .. index + do_string.len], do_string)) {
            should_do = true;
            index += do_string.len;
        } else if (index + dont_string.len < data.len and std.mem.eql(u8, data[index .. index + dont_string.len], dont_string)) {
            should_do = false;
            index += dont_string.len;
        }
        if (!should_do) {
            index += 1;
            continue;
        }
        switch (state) {
            .invalid => {
                if (index + 3 >= data.len) {
                    break;
                }
                if (std.mem.eql(u8, data[index .. index + 3], "mul")) {
                    state = .mul_kw;
                    index += 3;
                } else {
                    index += 1;
                }
                continue;
            },
            .mul_kw => {
                state = if (data[index] == '(') .lparent else .invalid;
                index += 1;
                continue;
            },
            .lparent => {
                // try parsing numbers "x,y"
                const indexOf_rparent = std.mem.indexOfScalarPos(u8, data, index, ')') orelse {
                    index += 1;
                    state = .invalid;
                    utils.dbg("Invalidation: ')' not found\n", .{});
                    continue;
                };
                numbers_tk_len = indexOf_rparent - index;
                if (numbers_tk_len > 7) {
                    index += 1;
                    state = .invalid;
                    utils.dbg("Invalidation: numbers_tk_len > 7 (value = {d})\n", .{numbers_tk_len});
                    continue;
                }
                var iter = std.mem.split(u8, data[index..indexOf_rparent], ",");
                var nn: usize = 0;
                while (iter.next()) |number| : (nn += 1) {
                    utils.dbg("find number {d}: {s}\n", .{ nn, number });
                    const n = std.fmt.parseUnsigned(u32, number, 10) catch {
                        index += 1;
                        state = .invalid;
                        utils.dbg("Invalidation: cannot parse '{s}' as uint\n", .{number});
                        continue :parser_step;
                    };
                    switch (nn) {
                        0 => numbers[0] = n,
                        1 => numbers[1] = n,
                        else => {
                            index += 1;
                            state = .invalid;
                            utils.dbg("Invalidation: too many number to parse\n", .{});
                            continue :parser_step;
                        },
                    }
                }
                index += numbers_tk_len;
                state = .numbers;
                continue;
            },
            .numbers => {
                if (data[index] == ')') {
                    state = .rparent;
                    index += 1;
                } else {
                    index += 1;
                    state = .invalid;
                    // if we are in 'numbers' state that means ')' was found
                    // utils.dbg("Invalidation: expected ')' found '{c}'\n", .{data[index]});
                }
                continue;
            },
            .rparent => {
                // commit
                result += numbers[0] * numbers[1];
                utils.dbg("Commiting: `{d} * {d}`, result is now {d}\n", .{ numbers[0], numbers[1], result });
                state = .invalid;
                // index += 0;
                continue;
            },
        }
    }
    utils.printPart2Result(result);
}
