const std = @import("std");

const allocator = std.heap.page_allocator;
pub const State = enum { start, m, mu, mul, mul_paren, mul_num1, mul_comma, mul_num2, d, do, don, don_, don_t, do_paren, don_t_paren };

pub fn main() !void {
    var input = try std.fs.cwd().openFile("input.txt", .{});
    defer input.close();
    const file_size = try input.getEndPos();
    const buffer: []u8 = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);
    _ = try input.readAll(buffer);

    var sum: i64 = 0;
    var state = State.start;
    var num1 = std.ArrayList(u8).init(allocator);
    defer num1.deinit();
    var num2 = std.ArrayList(u8).init(allocator);
    defer num2.deinit();
    var do = true;
    for (buffer, 0..) |c, i| {
        switch (c) {
            'd' => state = State.d,
            'o' => state = if (state == State.d) State.do else State.start,
            'n' => state = if (state == State.do) State.don else State.start,
            '\'' => state = if (state == State.don) State.don_ else State.start,
            't' => state = if (state == State.don_) State.don_t else State.start,
            'm' => state = State.m,
            'u' => state = if (state == State.m) State.mu else State.start,
            'l' => state = if (state == State.mu) State.mul else State.start,
            '(' => state = switch (state) {
                State.mul => State.mul_paren,
                State.do => State.do_paren,
                State.don_t => State.don_t_paren,
                else => State.start,
            },
            ')' => {
                switch (state) {
                    State.mul_num2 => if (do) {
                        std.debug.print("num1: {s}, num2: {s}\n", .{ num1.items, num2.items });
                        const n1 = try std.fmt.parseInt(i64, num1.items, 10);
                        const n2 = try std.fmt.parseInt(i64, num2.items, 10);
                        sum += n1 * n2;
                        state = State.start;
                    },
                    State.do_paren => {
                        do = true;
                        std.debug.print("do at {d}\n", .{i});
                    },
                    State.don_t_paren => {
                        do = false;
                        std.debug.print("dont at {d}\n", .{i});
                    },
                    else => state = State.start,
                }
            },
            ',' => if (state == State.mul_num1) {
                state = State.mul_comma;
            } else {
                state = State.start;
            },
            '0'...'9' => switch (state) {
                State.mul_paren => {
                    state = State.mul_num1;
                    num1.clearRetainingCapacity();
                    try num1.append(c);
                },
                State.mul_num1 => try num1.append(c),
                State.mul_comma => {
                    state = State.mul_num2;
                    num2.clearRetainingCapacity();
                    try num2.append(c);
                },
                State.mul_num2 => try num2.append(c),
                else => state = State.start,
            },
            else => state = State.start,
        }
    }
    std.debug.print("{d}\n", .{sum});
}
