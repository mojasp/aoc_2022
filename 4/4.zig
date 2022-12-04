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
    var count: i64 = 0;

    for (lines.items) |line| {
        var it = std.mem.split(u8, line, ",");
        var r1_string = it.first();
        var r2_string = it.next() orelse return error.InvalidInput;
        assert(it.next() == null);

        var r1 = try Range.init_from_string(r1_string);
        var r2 = try Range.init_from_string(r2_string);

        if (r1.contains(r2) or r2.contains(r1)) count += 1;
        // try stdout.print("{s}: {s} {s}\n", .{line, first, second});
    }

    try stdout.print("Day 4 Solution: {d}\n", .{count});
}

const Range = struct {
    begin: i64,
    end: i64,

    pub fn init_from_string(range_string: []const u8) !Range {
        var it = std.mem.split(u8, range_string, "-");
        var r: Range = undefined;
        r.begin = try std.fmt.parseInt(i64, it.first(), 10);
        r.end = try std.fmt.parseInt(i64, it.next() orelse return error.InvalidInput, 10);
        assert(it.next() == null);
        return r;
    }

    //returns true if self contains other
    pub fn contains(self: Range, other: Range) bool {
        return self.begin <= other.begin and self.end >= other.end;
    }
};

test "range" {
    const r = try Range.init_from_string("25-98");
    try expectEqual(25, r.begin);
    try expectEqual(98, r.end);

    const r2 = try Range.init_from_string("26-99");
    const r3 = try Range.init_from_string("26-98");
    const r4 = try Range.init_from_string("25-98");
    const r5 = try Range.init_from_string("24-98");

    try testing.expect(!r.contains(r2));
    try testing.expect(r.contains(r3));
    try testing.expect(r.contains(r4));
    try testing.expect(!r.contains(r5));

    try testing.expect(r5.contains(r));
    try testing.expect(!r2.contains(r));
    try testing.expect(!r3.contains(r));
}
