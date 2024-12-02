const std = @import("std");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    var input = try std.fs.cwd().openFile("input.txt", .{});
    defer input.close();
    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var safe: i64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var is_safe = true;
        var parts = std.mem.tokenizeScalar(u8, line, ' ');
        var prev: i64 = 0;
        var first: i64 = 0;
        var increase: bool = false;
        var i: i64 = 0;
        while (parts.next()) |part| {
            const level = try std.fmt.parseInt(i64, part, 10);
            if (i == 0) {
                first = level;
            } else if (i == 1) {
                increase = level > first;
            } else {
                if (increase and level < prev) {
                    is_safe = false;
                    // std.debug.print("incr i: {}, level: {}, prev: {}\n", .{ i, level, prev });
                    break;
                }
                if (!increase and level > prev) {
                    // std.debug.print("decr i: {}, level: {}, prev: {}\n", .{ i, level, prev });
                    is_safe = false;
                    break;
                }
            }
            const diff = @abs(level - prev);
            if (i != 0 and (diff == 0 or diff > 3)) {
                // std.debug.print("gap i: {}, level: {}, prev: {}\n", .{ i, level, prev });
                is_safe = false;
                break;
            }
            i += 1;
            prev = level;
        }
        // std.debug.print("{s} {}\n", .{ line, is_safe });
        if (is_safe) {
            safe += 1;
        }
    }
    std.debug.print("{d}\n", .{safe});
}
