const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

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

    var line_buf: [1024]u8 = undefined;
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

    var acc: i64 = 0;
    var group: usize =0;


    while  (group < lines.items.len) : (group += 3) {
        var common = try find_common(lines.items[group], lines.items[group+1], lines.items[group+2]);

        // try stdout.print("{s}: {s} {s}\n", .{line, first, second});
        acc += try get_Priority(common);

    }

    try stdout.print("Day 3 Solution: {d}\n", .{acc});
}

pub fn find_common(first: []const u8, second: []const u8, third: [] const u8) !u8 {
    for(first) |it1| {
        for (second) |it2| {
            if(it1 == it2) {
                for (third) |it3| {
                    if (it1 == it3) return it1;
                }
            }
        }
    }
    return error.NotFound;
}

pub fn get_Priority(item: u8) !i64 {
    if(item <= 90 and item >= 65) {
        //Prio 27-52
        return item - 64 + 26;
    }
    else if (item <= 122 and item >= 97){
        //lowercase: prio 1-26
        return item - 96;
    }
    return error.InvalidItem;
}

test "find_common" {
    try expectEqual ('p', find_common("vJrwpWtwJgWr", "hcsFMMfFFhFp"));
}

test "priority" {
    try expectEqual(16, get_Priority('p'));
    try expectEqual(38, get_Priority('L'));
    try expectEqual(42, get_Priority('P'));
    try expectEqual(22, get_Priority('v'));
    try expectEqual(20, get_Priority('t'));
    try expectEqual(19, get_Priority('s'));
}
