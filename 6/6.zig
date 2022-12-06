const std = @import("std");

const Allocator = std.mem.Allocator;
const testing = std.testing;
const assert = std.debug.assert;

pub fn expectEqual(expected: anytype, actual: anytype) !void {
    try testing.expectEqual(@as(@TypeOf(actual), expected), actual);
}

// read input.txt into an arraylist of strings and return it
pub fn readLines(allocator: Allocator, filename: []const u8) anyerror!*std.ArrayList([]const u8) {
    var lines = try allocator.create(std.ArrayList([]const u8));
    lines.* = std.ArrayList([]const u8).init(allocator);

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var line_buf: [4096]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        var str = try allocator.dupe(u8, line);
        try lines.append(str);
    }
    return lines;
}

pub fn main() anyerror!void {
    //zig create arraylist of strings
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const lines = try readLines(arena.allocator(), "input.txt");

    const stdout = std.io.getStdOut().writer();

    var input = lines.items[0];

    var idx : usize = 13;
    const result = blk : while(true) : (idx +=1) {
        if(slice_all_unequal(input[idx-13..idx+1]))
            break :blk idx+1;
    };

    try stdout.print("Day 5 Solution: {d}\n", .{result});
}

pub fn slice_all_unequal (slice: [] const u8) bool {
    var i : usize = 0;
    while (i < slice.len-1) : (i+=1) {
        if (contains(slice[i+1..slice.len], slice[i]))
            return false;
    }
    return true;
}

pub fn contains(slice : [] const u8, item : u8) bool {
    for (slice)|i| {
        if (i == item) return true;
    }
    return false;
}

//for 6-1
pub fn alldifferent (a: u8, b: u8, c:u8, d:u8) bool {
    if (a==b) return false;
    if (a==c) return false;
    if (a==d) return false;

    if (b==c) return false;
    if (b==d) return false;

    if(c==d) return false;
    return true;
}
