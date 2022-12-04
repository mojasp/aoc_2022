const std = @import("std");
const Allocator = std.mem.Allocator;
const t = std.testing;

pub fn main() anyerror!void {
    //zig create arraylist of strings
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const stdout = std.io.getStdOut().writer();

    const lines = try readLines(arena.allocator(), "input.txt");
    var score: i64 = 0;

    for (lines.items) |line| {
        const enemy_ctext = line[0];
        const enemy = decrypt(enemy_ctext);
        const desired_outcome = line[2];

        const action = getAction(enemy, desired_outcome);

        score += getScore(enemy, action);
        //try stdout.print("{c}, {c}: {d}\n", .{ enemy, action, getScore(enemy, action) });
    }

    try stdout.print("{d}\n", .{score});
}

const RPS = enum { r, p, s };

pub fn getAction(enemy: RPS, outcome: u8) RPS {
    return switch (outcome) {
        'X' => switch (enemy) { //lose
            RPS.r => RPS.s,
            RPS.p => RPS.r,
            RPS.s => RPS.p,
        },
        'Y' => enemy, //draw
        'Z' => switch (enemy) {
            RPS.r => RPS.p,
            RPS.p => RPS.s,
            RPS.s => RPS.r,
        },
        else => unreachable,
    };
}

pub fn decrypt(ctext: u8) RPS {
    return switch (ctext) {
        'A' => RPS.r,
        'B' => RPS.p,
        'C' => RPS.s,
        else => unreachable,
    };
}

pub fn duel(theirs: RPS, ours: RPS) i32 {
    if (theirs == ours) return 3; //draw
    switch (theirs) {
        RPS.r => if (ours == RPS.p) return 6 else return 0,
        RPS.p => if (ours == RPS.s) return 6 else return 0,
        RPS.s => if (ours == RPS.r) return 6 else return 0,
    }
}

pub fn getScore(theirs: RPS, ours: RPS) i64 {
    var sc: i32 = 0;
    sc = switch (ours) {
        RPS.r => 1,
        RPS.p => 2,
        RPS.s => 3,
    };
    sc += duel(theirs, ours);
    return sc;
}

// read input.txt into an arraylist of strings and return it
pub fn readLines(allocator: Allocator, filename: []const u8) anyerror!*std.ArrayList([]const u8) {
    var lines = try allocator.create(std.ArrayList([]const u8));
    lines.* = std.ArrayList([]const u8).init(allocator);

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var line_buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        var str = try allocator.dupe(u8, line);
        try lines.append(str);
    }
    return lines;
}

test "getScore" {
    try t.expectEqual(getScore(RPS.r, RPS.p), 8);
    try t.expectEqual(getScore(RPS.p, RPS.r), 1);
    try t.expectEqual(getScore(RPS.s, RPS.s), 6);

    //    try te.expectEqual(getScore('B', 'Z'), 9);
    try t.expectEqual(duel(RPS.p, RPS.s), 6);

    try t.expectEqual(getAction(RPS.r, 'Y'), RPS.r);
    try t.expectEqual(getAction(RPS.p, 'X'), RPS.r);
    try t.expectEqual(getAction(RPS.s, 'Z'), RPS.r);
}
