const std = @import("std");

pub fn main() anyerror!void {
    //Create arraylist in zig
    var elves = std.ArrayList(i64).init(std.heap.page_allocator);
    defer elves.deinit();

    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();


    try elves.append(0); //first elf

    var line_buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        if (line.len == 0) {
            //next elf, init with capacity of 0
            try elves.append(0);
        } else {
            //update capacity of existing elf
            var to_add = try std.fmt.parseInt(i64, line, 10);
            var elf = &elves.items.ptr[elves.items.len - 1];
            elf.* = elf.* + to_add;
        }
    }

    std.sort.sort(i64, elves.items, {}, comptime std.sort.desc(i64));
    var first = elves.items[0];
    var second = elves.items[1];
    var third = elves.items[2];

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{first + second + third});
}
