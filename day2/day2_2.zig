const std = @import("std");

const allocator = std.heap.page_allocator;

fn isSafe(prev: i64, level: i64, increase: bool) bool {
    const diff = @abs(level - prev);
    if (increase and level < prev) {
        return false;
    }
    if (!increase and level > prev) {
        return false;
    }
    if (diff == 0 or diff > 3) {
        return false;
    }
    return true;
}

fn checkListWithout(list: std.ArrayList(i64), elem: usize) !bool {
    const fi: u64 = if (elem < 2) 2 else 1;
    const increase = list.items[0] < list.items[if (elem < 2) 2 else 1];

    for (list.items, 0..) |level, i| {
        if (i < fi) continue;
        std.debug.print("{d}\n", .{i});
        const offset: usize = if (elem == i - 1) 2 else 1;
        std.debug.print("{d}\n", .{offset});
        if (!isSafe(list.items[i - offset], level, increase)) {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    var input = try std.fs.cwd().openFile("input.txt", .{});
    defer input.close();
    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var safe: i64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var list = std.ArrayList(i64).init(allocator);
        var parts = std.mem.tokenizeScalar(u8, line, ' ');
        while (parts.next()) |part| {
            try list.append(try std.fmt.parseInt(i64, part, 10));
        }
        for (list.items, 0..) |_, i| {
            if (try checkListWithout(list, i)) {
                safe += 1;
                break;
            }
        }
    }
    std.debug.print("{d}\n", .{safe});
}
