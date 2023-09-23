const std = @import("std");

const stdprint = std.debug.print;
const Allocator = std.mem.Allocator;

const Mat = struct {
  rows: usize,
  cols: usize,
  m: [][]f32,


  /// Returns a new dynamically allocated matrix
  pub fn New(rows: usize, cols: usize, allocator: *const Allocator) !Mat {
    const m = try allocator.alloc([]f32, rows);
    // var start: usize = 0;
    for (0..rows) |i| {
        m[i] = try allocator.alloc(f32, cols);
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
  ///
  /// Returns an error if the number of rows in matrix B != number of cols in this matrix
  pub fn Dot(self: *const Mat, dest: *Mat, B: *Mat) !void {
    if (self.cols != B.rows) {
        return error.InvalidMatrixLength;
    }
    for (self.rows) |r| {
        for(B.cols) |c| {
            dest[r][c] = self.m[r][c] * B.m[r][c];
        }
    }
  }

  pub fn At(self: *const Mat, i: usize, j: usize) ?f32 {
    if (i > self.rows or j > self.cols) {
        return null;
    }
    return self.m[i][j];
  }

  /// Print visual representation of matrix
  pub fn Print(self: *const Mat) void {
    for (self.m) |*row| {
        stdprint("[ ", .{});
        for (row.*) |*col| {
            stdprint("{d} ", .{col.*});
        }
        stdprint("]\n", .{});
    }
  }

  /// Randomize values in matrix
  pub fn Randomize(self: *const Mat, floor: i32, ceil: i32) void {
    const cTime = @cImport(@cInclude("time.h"));

    var r = std.rand.DefaultPrng.init(@intCast(cTime.time(null)));

    for (self.m) |*row| {
        for (row.*) |*col| {
            col.* = r
                .random()
                .float(f32) * (@as(f32, @floatFromInt(ceil)) - @as(f32, @floatFromInt(floor))) + @as(f32, @floatFromInt(floor));
        }
    }
  }
};

pub fn main() !void {
    var alo = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alo.deinit();

    const rows = 5;
    const cols = 2;

    const matrix = try Mat.New(rows, cols, &alo.allocator());
    // _ = matrix;
    matrix.m[0][1] = 1;
    matrix.Print();
    stdprint("\n", .{});
    stdprint("[7, 2]: {d}\n", .{matrix.At(7, 2) orelse 0});
    stdprint("\n", .{});
    matrix.Randomize(1, 4);
    matrix.Print();
    // const twobytwo_1 = try Mat.New(2, 2, &alo.allocator());
    // const twobytwo_2 = try Mat.New(2, 2, &alo.allocator());
    // const res = try Mat.New(2, 2, &alo.allocator());
}