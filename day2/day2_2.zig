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

fn checkListWithout(list: std.ArrayList(i64), elem: u64) !bool {
    var removedList = try list.clone();
    _ = removedList.orderedRemove(elem);
    const increase = removedList.items[0] < removedList.items[1];

    for (removedList.items, 0..) |level, i| {
        if (i == 0) {
            continue;
        }
        if (!isSafe(removedList.items[i - 1], level, increase)) {
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
