const std = @import("std");
const file = @embedFile("input.txt");

var data: [99][99]i8 = undefined;

pub fn main() !void {
    var lines = std.mem.tokenize(u8, file, "\n");
    {
        var x: usize = 0;
        while (lines.next()) |line| : (x += 1) {
            for (line) |_, y| {
                const item = try std.fmt.parseInt(i8, line[y..y+1], 10);
                data[x][y] = item;
                std.debug.print("{d} {d} {d}\n", .{x, y, item});
            }
        }
    }

    var cnt: i64 = 0;

    for (data) |line, y| {
        for (line) |elem, x| {
            _ = elem;
            // std.debug.print("{d} {d}: {d}\n", .{x, y, elem});
            if (visible_up(x, y)) {
                // std.debug.print("{s}\n", .{"up"});
                cnt += 1;
                continue;
            }
            if (visible_down(x, y)) {
                // std.debug.print("{s}\n", .{"down"});
                cnt += 1;
                continue;
            }
            if (visible_left(x, y)) {
                // std.debug.print("{s}\n", .{"left"});
                cnt += 1;
                continue;
            }
            if (visible_right(x, y)) {
                // std.debug.print("{s}\n", .{"right"});
                cnt += 1;
                continue;
            }
        }
    }
    std.debug.print("{d}\n", .{cnt});
}

pub fn visible_up(x: usize, y: usize) bool {
    if (y == 0) return true;

    const elem = data[x][y];
    var j: usize = 0;
    while (j < y) : (j += 1) {
        if (data[x][j] >= elem) return false;
    }
    return true;
}
pub fn visible_down(x: usize, y: usize) bool {
    if (y == 98) return true;

    const elem = data[x][y];
    var j: usize = y + 1;
    while (j < 99) : (j += 1) {
        if (data[x][j] >= elem) return false;
    }
    return true;
}
pub fn visible_left(x: usize, y: usize) bool {
    if (x == 0) return true;

    const elem = data[x][y];
    var i: usize = 0;
    while (i < x) : (i += 1) {
        if (data[i][y] >= elem) return false;
    }
    return true;
}
pub fn visible_right(x: usize, y: usize) bool {
    if (x == 98) return true;

    const elem = data[x][y];
    var i: usize = x + 1;
    while (i < 99) : (i += 1) {
        // std.debug.print("x={d} y={d}: i={d}\n", .{ x, y, i });
        if (data[i][y] >= elem) return false;
    }
    return true;
}
