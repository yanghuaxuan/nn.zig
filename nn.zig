const std = @import("std");

const stdprint = std.debug.print;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

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
  /// Multiply this matrix by matrix B, returning its result as another matrix
  ///
  /// Returns an error if the number of rows in matrix B != number of cols in this matrix
  pub fn Mul(self: *const Mat, B: *const Mat) !Mat {
    if (self.cols != B.rows) {
        return error.InvalidMatrixLength;
    }
    const row = self.rows;
    const col = B.cols;

    const m = try Mat.New(row, col, self.allocator);

    for (0..self.rows) |i| {
        for (0..B.cols) |j| {
            var sum: f32 = 0;

            for (0..self.cols) |k| {
                sum += self.m[i][k] * B.m[k][j];
            }

            m.m[i][j] = sum;
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

  // Fills all elements in matrix with val
  pub fn Fill(self: *const Mat, val: f32) void {
    for (self.m) |*row| {
        for (row.*) |*col| {
            col.* = val;
        }
    }
  }

  // Returns true if all elements in B are the same
  pub fn Eq(self: *const Mat, B: *const Mat) bool {
    if (self.rows != B.rows or self.cols != B.cols) {
        return false;
    }

    for (0..self.rows) |r| {
        for (0..self.cols) |c| {
           if (self.m[r][c] != B.m[r][c]) {
                return false;
           }
        }
    }

    return true;
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

    
test "Matrix Eq works" {
    const alo = std.testing.allocator;

    const mat12_1 = try Mat.New(3, 3, &alo);
    defer mat12_1.Free();
    const mat12_2 = try Mat.New(3, 3, &alo);
    defer mat12_2.Free();
    mat12_1.Fill(12);
    mat12_2.Fill(12);

    const mat2 = try Mat.New(3, 3, &alo);
    defer mat2.Free();
    mat2.Fill(1);

    assert(mat12_1.Eq(&mat12_2));
    assert(!mat2.Eq(&mat12_2));
}

test "Matrix multiplication works" {
    const alo = std.testing.allocator;

    // 2 2 2
    // 2 2 2
    const twobythree = try Mat.New(2, 3, &alo);
    defer twobythree.Free();
    // 3 3
    // 3 3
    // 3 3
    const threebytwo = try Mat.New(3, 2, &alo);
    defer threebytwo.Free();
    threebytwo.Fill(2);
    twobythree.Fill(3);
    const res_1 = try threebytwo.Mul(&twobythree);
    defer res_1.Free();
    const expected_1 = try Mat.New(3, 3, &alo);
    expected_1.Fill(12);
    defer expected_1.Free();
    assert(expected_1.Eq(&res_1));

    const one = try Mat.New(1, 1, &alo);
    defer one.Free();
    const two = try Mat.New(1, 1, &alo);
    defer two.Free();
    one.Fill(1);
    two.Fill(2);
    const res_2 = try one.Mul(&two);
    defer res_2.Free();
}

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

    const twobythree_1 = try Mat.New(2, 3, &alo.allocator());
    defer twobythree_1.Free();
    const threebytwo_2 = try Mat.New(3, 2, &alo.allocator());
    defer threebytwo_2.Free();

    // const sum_res = try twobythree_1.Add(&threebytwo_2);
    // sum_res.Print();

    stdprint("\n", .{});

    stdprint("Multiplying ...\n", .{});
    //const dot_res = try twobythree_1.Dot(&threebytwo_2);
    const dot_res = try twobythree_1.Mul(&threebytwo_2);
    dot_res.Print();
}