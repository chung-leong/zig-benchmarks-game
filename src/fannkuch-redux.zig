const std = @import("std");

var buffer: [2048]u8 = undefined;
var fixed_allocator = std.heap.FixedBufferAllocator.init(buffer[0..]);
var allocator = fixed_allocator.allocator();

pub fn main() !void {
    var buffered_stdout = std.io.bufferedWriter(std.io.getStdOut().writer());
    defer buffered_stdout.flush() catch unreachable;
    const stdout = buffered_stdout.writer();

    var args = try std.process.argsAlloc(allocator);
    if (args.len < 2) return error.InvalidArguments;

    const n = try std.fmt.parseUnsigned(usize, args[1], 10);

    var perm = try allocator.alloc(usize, n);
    var perm1 = try allocator.alloc(usize, n);
    var count = try allocator.alloc(usize, n);

    var max_flips_count: usize = 0;
    var perm_count: usize = 0;
    var checksum: isize = 0;

    for (perm1, 0..) |*e, i| {
        e.* = i;
    }

    var r = n;
    loop: {
        while (true) {
            while (r != 1) : (r -= 1) {
                count[r - 1] = r;
            }

            for (perm, 0..) |_, i| {
                perm[i] = perm1[i];
            }

            var flips_count: usize = 0;

            while (true) {
                const k = perm[0];
                if (k == 0) {
                    break;
                }

                const k2 = (k + 1) >> 1;
                var i: usize = 0;
                while (i < k2) : (i += 1) {
                    std.mem.swap(usize, &perm[i], &perm[k - i]);
                }
                flips_count += 1;
            }

            max_flips_count = @max(max_flips_count, flips_count);
            if (perm_count % 2 == 0) {
                checksum += @intCast(flips_count);
            } else {
                checksum -= @intCast(flips_count);
            }

            while (true) : (r += 1) {
                if (r == n) {
                    break :loop;
                }

                const perm0 = perm1[0];
                var i: usize = 0;
                while (i < r) {
                    const j = i + 1;
                    perm1[i] = perm1[j];
                    i = j;
                }

                perm1[r] = perm0;
                count[r] -= 1;

                if (count[r] > 0) {
                    break;
                }
            }

            perm_count += 1;
        }
    }

    try stdout.print("{}\nPfannkuchen({}) = {}\n", .{ checksum, n, max_flips_count });
}
