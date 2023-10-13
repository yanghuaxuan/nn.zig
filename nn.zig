const std = @import("std");

const stdprint = std.debug.print;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

fn Mat(comptime T: type, comptime rows: usize, comptime cols: usize) type {
    comptime {
        return struct {
            rows: usize = rows,
            cols: usize = cols,
            v: [rows]@Vector(cols, T),

            pub fn Init() Mat(T, rows, cols) {
                const zeroinit = [_]T{0} ** cols;
                const vec: @Vector(cols, T) = zeroinit;

                return Mat(T,rows,cols) {
                    .v =  [_]@Vector(cols,T){vec} ** rows
                };
            }

            pub fn DbgPrint(self: *const Mat(T, rows, cols)) void {
                for (0..rows) |i| {
                    for (0..cols) |j| {
                        stdprint("{d} ", .{self.v[i][j]});
                    }
                    stdprint("\n", .{});
                }
            }

            pub fn Add(self: *const Mat(T,rows,cols), v2: *const Mat(T,rows,cols)) Mat(T, rows, cols) {
                var res = Mat(T, rows, cols).Init();
                inline for (0..rows) |i| {
                    res.v[i] = self.v[i] + v2.v[i];
                }
                return res;
            }
        };
    }
}


pub fn main() !void {
    const v1 = Mat(f32, 2, 2) {
        .v = [_]@Vector(2, f32){@Vector(2,f32){1, 2}, @Vector(2, f32){3,4}}
    };
    const v2 = Mat(f32, 2, 2) {
        .v = [_]@Vector(2, f32){@Vector(2,f32){1, 1}} ** 2
    };
    const res = v1.Add(&v2);
    res.DbgPrint();
}