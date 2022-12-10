const std = @import("std");
const data = @embedFile("input.txt");

//Adjust output terminal to width 40 for correct output

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer _ = arena.allocator();

    var tokens = std.ArrayList(token).init(arena.allocator());

    var lines = std.mem.tokenize(u8, data, "\n ");
    while (lines.next()) |l| {
        if (std.mem.eql(u8, l, "noop")) {
            try tokens.append(.noop);
        } else if (std.mem.eql(u8, l, "addx")) {
            const x = try std.fmt.parseInt(i32, lines.next().?, 10);
            try tokens.append(.{ .add = x });
        } else unreachable;
    }

    var X: i32 = 1;
    var cycle: i32 = 1;
    for (tokens.items) |tk| {
        switch (tk) {
            .noop => {
                on_cycle(cycle, X);
                cycle += 1;
            },
            .add => |a| {
                on_cycle(cycle, X);
                cycle += 1;
                on_cycle(cycle, X);
                cycle += 1;
                X += a;
            },
        }
    }
}

pub fn on_cycle(cycle: i32, x: i32) void {
    const cursor = @mod(cycle - 1, 40);
    var character: u8 = if (cursor >= x - 1 and cursor <= x + 1) '#' else '.';
    std.debug.print("{c}", .{character});
}

const token = union(enum) {
    noop,
    add: i32,
};
