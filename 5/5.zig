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

    var s = try State.init(arena.allocator());
    try stdout.print("Crates: {d}\n", .{s.numcrates()});
    for (lines.items[10..]) |line| {
        std.debug.print("{s}\n", .{line});
        var instruction = try Instruction.from_line(line);
        try s.process(instruction);
    }

    try stdout.print("Crates: {d}\n", .{s.numcrates()});
    try stdout.print("Day 5 Solution: {s}\n", .{try s.getResult(arena.allocator())});
}

const Instruction = struct {
    amount: i64,
    from: usize,
    to: usize,
    pub fn from_line(line: []const u8) !Instruction {
        var it = std.mem.split(u8, line, " ");

        assert(std.mem.eql(u8, it.first(), "move"));

        const amount = try std.fmt.parseInt(i64, it.next().?, 10);
        assert(amount > 0);

        assert(std.mem.eql(u8, it.next().?, "from"));
        const from = try std.fmt.parseInt(usize, it.next().?, 10);
        assert(from > 0);
        assert(from <= 9);

        assert(std.mem.eql(u8, it.next().?, "to"));
        const to = try std.fmt.parseInt(usize, it.next().?, 10);
        assert(to > 0);
        assert(to <= 9);

        assert(it.next() == null);

        return Instruction{ .amount = amount, .from = from, .to = to };
    }
};

const State = struct {
    stacks: [10]std.ArrayList(u8),

    pub fn init(allocator: Allocator) !State {
        var self = State{ .stacks = [_]std.ArrayList(u8){
            undefined,
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
            std.ArrayList(u8).init(allocator),
        } };
        try self.stacks[1].appendSlice("PFMQWGRT");
        try self.stacks[2].appendSlice("HFR");
        try self.stacks[3].appendSlice("PZRVGHSD");
        try self.stacks[4].appendSlice("QHPBFWG");
        try self.stacks[5].appendSlice("PSMJH");
        try self.stacks[6].appendSlice("MZTHSRPL");
        try self.stacks[7].appendSlice("PTHNML");
        try self.stacks[8].appendSlice("FDQR");
        try self.stacks[9].appendSlice("DSCNLPH");
        return self;
    }

    pub fn process(self: *State, instr: Instruction) !void {
        var from = self.*.stacks[instr.from];
        const idx: i64 = @intCast(i64, from.items.len) - instr.amount;

        std.debug.print("{d} {d} {d}\n", .{ from.items.len, instr.amount, idx });

        const items = from.items[@intCast(usize, idx)..];

        std.debug.print("to: {s} => ", .{self.*.stacks[instr.to].items});

        try self.*.stacks[instr.to].appendSlice(items);

        std.debug.print("{s}\n", .{self.*.stacks[instr.to].items});
        std.debug.print("from: {s} => ", .{self.*.stacks[instr.from].items});

        var i = instr.amount;
        while (i > 0) : (i -= 1) {
            _ = self.stacks[instr.from].pop();
        }

        std.debug.print("{s}\n", .{self.*.stacks[instr.from].items});
    }

    pub fn getResult(self: State, allocator: Allocator) ![]u8 {
        var acc = try std.fmt.allocPrint(allocator, "{s}", .{""});
        for (self.stacks[1..]) |s| {
            std.debug.print("{c}\n", .{s.items[s.items.len - 1]});
            acc = try std.fmt.allocPrint(allocator, "{s}{c}", .{ acc, s.items[s.items.len - 1] });
        }
        return acc;
    }
    pub fn numcrates(self: State) i64 {
        var acc: i64 = 0;
        for (self.stacks[1..]) |s| {
            acc += @intCast(i64, s.items.len);
        }
        return acc;
    }
};

test "stacks init" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var s = try State.init(arena.allocator());
    assert(s.stacks[1].items[0] == 'P');
    assert(std.mem.eql(u8, s.stacks[1].items, "PFMQWGRT"));
}
