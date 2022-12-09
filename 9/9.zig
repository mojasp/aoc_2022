const std = @import("std");

const assert = std.debug.assert;
const abs = std.math.absInt;

const data = @embedFile("input.txt");

const motion = struct {
    const direction = enum { up, right, left, down };
    dir: direction,
    amount: i32,
};

const vec2 = struct {
    x: i32,
    y: i32,
};
const simulation = struct {
    visited_set: std.AutoHashMap(vec2, void),

    knots: [10]vec2,

    pub fn adjust_straight(from: *i32, to: i32) !void {
        assert(try std.math.absInt(to - from.*) == 2);
        if (from.* > to) {
            from.* -= 1;
        } else from.* += 1;
    }

    pub fn step(self: *simulation, dir: motion.direction) !void {
        //Head movement
        switch (dir) {
            .right => self.knots[0].x += 1,
            .left => self.knots[0].x -= 1,
            .up => self.knots[0].y += 1,
            .down => self.knots[0].y -= 1,
        }

        var i: usize = 1;
        while (i <= 9) : (i += 1) {
            const prev_idx = i - 1;
            const vecToHead = vec2{ .x = self.knots[prev_idx].x - self.knots[i].x, .y = self.knots[prev_idx].y - self.knots[i].y }; //swapped this

            if (vecToHead.x*vecToHead.x + vecToHead.y * vecToHead.y > 2) {
                //Moving the head in all cases is equivalent to moving one step (=math.sign()) towards the gradient (in both coordinates)
                self.knots[i].x += std.math.sign(vecToHead.x);
                self.knots[i].y += std.math.sign(vecToHead.y);
            }
        }
    }

    pub fn moveHead(self: *simulation, m: motion) !void {
        var i: i32 = 0;
        try self.visited_set.put(.{ .x = self.knots[9].x, .y = self.knots[9].y }, {});
        while (i < m.amount) : (i += 1) {
            try self.step(m.dir);
            try self.visited_set.put(.{ .x = self.knots[9].x, .y = self.knots[9].y }, {});
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    var alloc = arena.allocator();

    var motions = std.ArrayList(motion).init(alloc);

    var it = std.mem.tokenize(u8, data, " \n");
    while (it.next()) |token| {
        const dir: motion.direction = switch (token[0]) {
            'R' => .right,
            'L' => .left,
            'U' => .up,
            'D' => .down,
            else => unreachable,
        };
        const amount = try std.fmt.parseInt(i32, it.next().?, 10);
        try motions.append(.{ .dir = dir, .amount = amount });
    }

    var sim = simulation{ .knots = std.mem.zeroes([10]vec2), .visited_set = std.AutoHashMap(vec2, void).init(alloc) };

    for (motions.items) |m| {
        try sim.moveHead(m);
    }

    std.debug.print("Day 9 Part 1 solution: {d}\n", .{sim.visited_set.count()});
}
