const std = @import("std");
const data = @embedFile("input.txt");

const Allocator = std.mem.Allocator;

pub fn main() anyerror!void {
    //zig create arraylist of strings
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    arena.deinit();

    var filesystem = try fs.init(arena.allocator());

    var cmd_it = std.mem.tokenize(u8, data, "$");
    while (cmd_it.next()) |line| {
        var in = line[1..]; //skip whitespace

        if (std.mem.eql(u8, in[0..2], "cd")) {
            //CD
            const arg = in[3 .. in.len - 1]; //remove whitespace before and linebreak after arg
            var cmd: cd_cmd = if (std.mem.eql(u8, arg, "..")) .up else if (std.mem.eql(u8, arg, "/")) .root else .{ .down = arg };
            filesystem.cd(cmd);
        } else if (std.mem.eql(u8, in[0..2], "ls")) {
            //LS
            var ls_it = std.mem.tokenize(u8, in, "\n ");
            _ = ls_it.next(); //Skip "ls" line input
            try filesystem.ls(&ls_it);
        } else unreachable;
    }

    const result = try filesystem.solve();
    std.debug.print("{d}\n", .{result});
}

const cd_cmd = union(enum) { up, root, down: []const u8 };

const inode = struct {
    inode_type: union(enum) { file: i64, dir: std.StringHashMap(inode) },
    name: []const u8,
    parent: ?*inode,
};

const fs = struct {
    alloc: Allocator,

    current_dir: *inode,
    root: *inode,

    pub fn init(alloc: Allocator) !fs {
        var root = try alloc.create(inode);
        root.* = inode{
            .name = "/",
            .inode_type = .{ .dir = std.StringHashMap(inode).init(alloc) },
            .parent = null,
        };
        return fs{
            .alloc = alloc,
            .current_dir = root,
            .root = root,
        };
    }

    pub fn cd(self: *fs, cmd: cd_cmd) void {
        switch (cmd) {
            .up => self.current_dir = self.current_dir.parent.?,
            .root => self.current_dir = self.root,
            .down => |target| self.current_dir = self.current_dir.inode_type.dir.getPtr(target).?,
        }
    }

    pub fn ls(self: fs, output: *std.mem.TokenIterator(u8)) !void {
        while (output.*.next()) |first| {
            const name = output.*.next().?;
            if (std.mem.eql(u8, first, "dir")) {
                const node: inode = inode{
                    .inode_type = .{ .dir = std.StringHashMap(inode).init(self.alloc) },
                    .name = name,
                    .parent = self.current_dir,
                };
                try self.current_dir.inode_type.dir.put(name, node);
            } else {
                const filesize = try std.fmt.parseInt(i64, first, 10);
                const node: inode = inode{
                    .inode_type = .{ .file = filesize },
                    .name = name,
                    .parent = self.current_dir,
                };
                try self.current_dir.inode_type.dir.put(name, node);
            }
        }
    }

    pub fn solve(self: *fs) !i64 {
        //Doing 2 nested DFS is pretty stupid, but still runs in < 0.5 seconds...
        const limit = 100000;
        var count : i64 = 0;
        //DFS over fs
        var to_visit = std.ArrayList(*inode).init(self.alloc);
        try to_visit.append(self.root);

        while (to_visit.popOrNull()) |node| {
            switch (node.inode_type) {
                .dir => |map| {
                    //SOLVE for current directory
                    self.current_dir = node;
                    const sz = try self.dirSize();
                    if(sz <= limit ) count += sz;

                    //add remaining directories for DFS
                    var it = map.iterator();
                    while (it.next()) |v| {
                        try to_visit.append(v.value_ptr);
                    }
                },
                .file => {
                },
            }
        }
        return count;
    }

    pub fn dirSize(self: fs) !i64 {
        var count : i64 = 0;
        //DFS over fs
        var to_visit = std.ArrayList(*inode).init(self.alloc);
        try to_visit.append(self.current_dir);

        while (to_visit.popOrNull()) |node| {
            switch (node.inode_type) {
                .dir => |map| {
                    //DFS
                    var it = map.iterator();
                    while (it.next()) |v| {
                        try to_visit.append(v.value_ptr);
                    }
                },
                .file => |filesz|{
                    count += filesz;
                },
            }
        }
        return count;
    }
};
