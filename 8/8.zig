const std = @import("std");
const file = @embedFile("input.txt");
const assert = std.debug.assert;

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

    var best_score : usize = 0;
    for (data) |line, y| {
        for (line) |_ , x| {
            const score = look_up(x, y) * look_down(x,y) * look_left(x,y) * look_right(x,y);
            if(score > best_score)
                best_score = score;
        }
    }
    std.debug.print("{d}\n", .{best_score});
}

pub fn look_up(x: usize, y: usize) usize {
    if (y == 0) return 0;

    const elem = data[x][y];
    var j: usize = 0;
    while (true) {
        std.debug.print("{d}\n", .{j});
        j+=1;
        var idx = y - j;
        if (data[x][idx] >= elem) return j;
        if(idx == 0) return j;
    }
}

pub fn look_down(x: usize, y: usize) usize {
    if (y == 98) return 0;

    const elem = data[x][y];
    var j: usize = 0;
    while (true) {
        j+=1;
        var idx = y+j;
        if (data[x][idx] >= elem) return j;
        if(idx == 98) return j;
    }
}

pub fn look_left(x: usize, y: usize) usize {
    if (x == 0) return 0;

    const elem = data[x][y];
    var i: usize = 0;
    while (true) {
        i+=1;
        var idx = x - i;
        if (data[idx][y] >= elem) return i;
        if(idx == 0) return i;
    }
}

pub fn look_right(x: usize, y: usize) usize {
    if (x == 98) return 0;
    assert(x < 98);

    const elem = data[x][y];
    var i: usize = 0;
    while (true) {
        i+=1;
        var idx = x + i;
        if (data[idx][y] >= elem) return i;
        if(idx == 98) return i;
    }
}
