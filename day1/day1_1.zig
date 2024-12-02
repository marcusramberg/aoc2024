const std = @import("std");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    var left_list = std.ArrayList(i64).init(allocator);
    defer left_list.deinit();
    var right_list = std.ArrayList(i64).init(allocator);
    defer right_list.deinit();
    var input = try std.fs.cwd().openFile("input.txt", .{});
    defer input.close();
    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, ' ');
        try left_list.append(try std.fmt.parseInt(i64, parts.next().?, 10));
        try right_list.append(try std.fmt.parseInt(i64, parts.next().?, 10));
    }

    std.mem.sort(i64, left_list.items, {}, std.sort.asc(i64));
    std.mem.sort(i64, right_list.items, {}, std.sort.asc(i64));
    var distance: u64 = 0;
    for (left_list.items, right_list.items) |left, right| {
        // std.debug.print("distance between: {d}:{d} (so far: {d})\n", .{ num, right_list.items[index], distance });
        distance += @abs(left - right);
    }
    std.debug.print("{d}\n", .{distance});
}
