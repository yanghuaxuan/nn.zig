const std = @import("std");

const stdprint = std.debug.print;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

fn Dot(v1: anytype, v2: anytype) f32 {
    return @reduce(.Add, v1 * v2);
}


fn Mat(comptime T: type, comptime rows: usize, comptime cols: usize) type {
    comptime {
        return struct {
            rows: usize = rows,
            cols: usize = cols,
            v: [rows]@Vector(cols, T),

            /// Returns a new rows x cols Matrix with everything initialized to zero
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

            pub fn Add(self: *const Mat(T,rows,cols), B: *const Mat(T,rows,cols)) Mat(T, rows, cols) {
                var res = Mat(T, rows, cols).Init();
                inline for (0..rows) |i| {
                    res.v[i] = self.v[i] + B.v[i];
                }
                return res;
            }

            /// Matrix multiplication
            pub fn Mul(self: *const Mat(T, rows, cols), B: *const Mat(T, rows, cols)) Mat(T, rows, cols) {
               var res = Mat(T, rows, cols).Init();
               for (0..self.rows) |i| {
                for(0..B.cols) |j| {
                    res.v[i][j] = Dot(self.Row(i), B.Col(j));
                }
               }

               return res;
            }

            // Get the i-th row Vector of the Matrix
            pub fn Row(self: *const Mat(T, rows, cols), row: usize) @Vector(cols, T) {
                const zeroinit = [_]T{0} ** cols;
                var res: @Vector(cols, T) = zeroinit;

                inline for (0..cols) |i| {
                    res[i] = self.v[row][i];
                }

                return res;
            }

            // Get the j-th column Vector of the Matrix
            pub fn Col(self: *const Mat(T, rows, cols), col: usize) @Vector(cols, T) {
                const zeroinit = [_]T{0} ** cols;
                var res: @Vector(cols, T) = zeroinit;

                inline for (0..rows) |i| {
                    res[i] = self.v[i][col];
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
        .v = [_]@Vector(2, f32){@splat(1)} ** 2
    };
    const res = v1.Mul(&v2);
    res.DbgPrint();

    // v1.DbgPrint();
    // stdprint("{any}\n", .{v1.Col(0)});
}