const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const Mat = struct {
  rows: usize,
  cols: usize,
  m: [][]f32,


  /// Returns a new dynamically allocated matrix
  pub fn New(rows: usize, cols: usize, allocator: *const Allocator) !Mat {
    const m = try allocator.alloc([]f32, @sizeOf(f32) * rows);
    // var start: usize = 0;
    for (0..rows) |i| {
        m[i] = try allocator.alloc(f32, @sizeOf(f32) * cols);
        for (0..cols) |a| {
            m[i][a] = 0;
        }
    }
    return Mat {
        .rows = rows,
        .cols = cols,
        .m = m
    };
  }
  /// Dot products this matrix by matrix B, storing its result in dest
  pub fn dot(self: *Mat, dest: *Mat, B: *Mat) !void {
    if (self.cols != B.rows) {
        return error.InvalidMatrixLength;
    }
    for (self.rows) |r| {
        for(B.cols) |c| {
            dest[r][c] = self.m[r][c] * B.m[r][c];
        }
    }
  }
};

pub fn main() !void {
    var alo = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const rows = 5;
    const cols = 2;
    defer alo.deinit();

    const matrix = try Mat.New(rows, cols, &alo.allocator());
    // _ = matrix;
    matrix.m[0][1] = 1;
    print("{d}\n", .{matrix.m[0][1]});
}