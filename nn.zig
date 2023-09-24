const std = @import("std");

const stdprint = std.debug.print;
const Allocator = std.mem.Allocator;

/// The *real* matrix is dynamically allocated
const Mat = struct {
  rows: usize,
  cols: usize,
  m: [][]f32,
  allocator: *const Allocator,

  /// Returns a new initialized matrix
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
        .m = m,
        .allocator = allocator,
    };
  }
  /// Dot products this matrix by matrix B, returning its result as another matrix
  ///
  /// Returns an error if the number of rows in matrix B != number of cols in this matrix
  pub fn Dot(self: *const Mat, B: *Mat) !Mat {
    if (self.cols != B.rows) {
        return error.InvalidMatrixLength;
    }
    const row = self.rows;
    const col = self.cols;

    const m = Mat.New(row, col);

    for (self.rows) |r| {
        for(B.cols) |c| {
            m.m[r][c] = self.m[r][c] * B.m[r][c];
        }
    }

    return m;
  }

  /// Add this matrix by B, returning its result as another matrix
  ///
  /// Returns an error if dimensions of matrix B are not the same
  pub fn Add(self: *const Mat, B: *const Mat) !Mat {
    if (self.rows != B.rows or self.cols != self.rows) {
        return error.InvalidMatrixLength;
    }

    const m = try Mat.New(self.rows, self.cols, self.allocator);

    for (0..self.rows) |i| {
        for (0..self.cols) |j| {
            m.m[i][j] = self.m[i][j] + B.m[i][j];
        }
    }
    
    return m;
  }

  pub fn At(self: *const Mat, row: usize, col: usize) ?f32 {
    if (row > self.rows or col > self.cols) {
        return null;
    }
    return self.m[row][col];
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

  /// Free memory allocated for self.*m*
  ///
  /// Should be called once the matrix is not needed anymore
  ///
  /// ```
  /// const m = try Mat.New(1, 1, &alo.allocator());
  /// defer m.Free()
  /// ```
  pub fn Free(self: *const Mat) void {
    for (self.m) |*row| {
       self.allocator.free(row.*);
    }
    self.allocator.free(self.m);
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
    // defer matrix.Free();
    // _ = matrix;
    matrix.m[0][1] = 1;
    matrix.Print();
    stdprint("\n", .{});
    stdprint("[7, 2]: {d}\n", .{matrix.At(7, 2) orelse 0});
    stdprint("\n", .{});
    matrix.Randomize(1, 4);
    matrix.Print();

    stdprint("\n", .{});

    const twobytwo_1 = try Mat.New(2, 2, &alo.allocator());
    defer twobytwo_1.Free();
    const twobytwo_2 = try Mat.New(2, 2, &alo.allocator());
    defer twobytwo_2.Free();

    twobytwo_1.Randomize(1, 2);
    twobytwo_2.Randomize(1, 2);
    const res = try twobytwo_1.Add(&twobytwo_2);
    res.Print();
}