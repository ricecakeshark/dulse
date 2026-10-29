module dulse.math.linalg.matrix;

import dulse.math.linalg;
import dulse.math.linalg.multiply;

import std.array : appender, Appender;
import std.conv : text;
import std.format : format;
import std.math;

// Matrix(Row-Major) 
struct Matrix(size_t Rows, size_t Cols, Type = float)
{
	Type[Cols][Rows] data;
	enum rows = Rows;
	enum cols = Cols;
	alias element_type = Type;

	this(in typeof(this.data) new_matrix) pure nothrow @nogc @safe
	in (new_matrix.length == Rows)
	in (new_matrix[0].length == Cols)
	{
		foreach (row; 0 .. Rows)
		{
			foreach (col; 0 .. Cols)
			{
				this.index(row, col) = new_matrix[row][col];
			}
		}
		return;
	}

	this(in Type value) pure nothrow @nogc @safe
	{
		this.fill(value);
		return;
	}

	this(in Type[Rows] new_vector) pure nothrow @nogc @safe
	{
		this.fill(0.0f);
		foreach (count; 0 .. Rows)
		{
			this.index(count, count) = new_vector[count];
		}
		return;
	}

	static typeof(this) identity() pure nothrow @nogc @safe
	{
		scope typeof(this) temp;
		temp.fill(0f);
		foreach (count; 0 .. Cols)
		{
			temp[count, count] = 1f;
		}
		return temp;
	}

	static typeof(this) scaling(bool Homogeneous : true)(in Vector!(Rows - 1, Type) vec) pure nothrow @nogc @safe
	{
		return matrix_scaling!(Homogeneous)(vec);
	}

	static typeof(this) scaling(bool Homogeneous : false)(in Vector!(Rows, Type) vec) pure nothrow @nogc @safe
	{
		return matrix_scaling!(Homogeneous)(vec);
	}

	@property bool is_normal() const pure nothrow @nogc @safe
	{
		foreach (row; 0 .. Rows)
		{
			foreach (col; 0 .. Cols)
			{
				if (!this.index(row, col).isNormal)
				{
					return false;
				}
			}
		}
		return true;
	}

	@property bool contain_nan() const pure nothrow @nogc @safe
	{
		foreach (row; 0 .. Rows)
		{
			foreach (col; 0 .. Cols)
			{
				if (this.index(row, col).isNaN)
				{
					return true;
				}
			}
		}
		return false;
	}

	@property Vector!(Rows, Type) row() const pure nothrow @nogc @safe
	{
		scope Vector!(Rows, Type) ret_vec;
		foreach (row; 0 .. Rows)
		{
			ret_vec.data[row] = this.index(row, 0u);
		}
		return ret_vec;
	}

	@property Vector!(Cols, Type) column() const pure nothrow @nogc @safe
	{
		scope Vector!(Cols, Type) ret_vec;
		foreach (col; 0 .. Cols)
		{
			ret_vec.data[col] = this.index(0, col);
		}
		return ret_vec;
	}

	@property Vector!(Rows, Type) diagonal()() const pure nothrow @nogc @safe
	if (Rows == Cols)
	{
		scope Vector!(Rows, Type) ret_vec;
		foreach (index; 0 .. Rows)
		{
			ret_vec[index] = this.index(index, index);
		}
		return ret_vec;
	}

	typeof(this.data) opAssign(in Type[Cols][Rows] assign_matrix) pure nothrow @safe
	{
		this.data = assign_matrix;
		return assign_matrix;
	}

	ref inout(Type) index(in size_t row, in size_t col) inout pure nothrow @nogc @safe
	{
		return this.data[row][col];
	}

	ref inout(Type) opIndex(in size_t row, in size_t col) inout pure nothrow @nogc @safe
	{
		return this.data[row][col];
	}

	bool opEquals(RhsType)(in Matrix!(Rows, Cols, RhsType) rhs) const pure nothrow @nogc @safe
	{
		return approx_equal(this, rhs);
	}

	bool opEquals(in Type[Cols][Rows] rhs) const pure nothrow @nogc @safe
	{
		return approx_equal(this, Matrix!(Rows, Cols, Type)(rhs));
	}
	// Matrix + Matrix, Matrix - Matrix 
	Matrix!(Rows, Cols, Type) opBinary(
		string op, size_t RhsRows, size_t RhsCols, RhsType,
	)(
		in Matrix!(RhsRows, RhsCols, RhsType) rhs,
	) const pure nothrow @nogc @safe
	in (RhsRows == Rows && RhsCols == Cols)
	{
		static if (op == "+")
		{
			return add(this, rhs);
		}
		else static if (op == "-")
		{
			return subtract(this, rhs);
		}
	}
	// Matrix * Matrix
	Matrix!(Rows, Cols2, Type) opBinary(string op : "*", size_t Rows2, size_t Cols2)(
		in Matrix!(Rows2, Cols2, Type) rhs) const pure nothrow @nogc @safe
	{
		return multiply(this, rhs);
	}
	// Matrix * 2.0
	Matrix!(Rows, Cols, Type) opBinary(string op : "*")(
		in Type rhs) const pure nothrow @nogc @safe
	{
		return multiply!(Matrix!(Rows, Cols, Type))(this, rhs);
	}
	// Matrix * Vector
	Vector!(Rows, Type) opBinary(string op : "*")(
		Vector!(Rows, Type) rhs) pure nothrow @nogc @safe
	{
		return multiply!(typeof(this), typeof(rhs), Rows, Cols, Type)(this, rhs);
	}
	// Matrix / 2.0
	Matrix!(Rows, Cols, Type) opBinary(string op : "/")(
		in Type rhs) const pure nothrow @nogc @safe
	in (!rhs.isClose(0.0))
	{
		return devide!(Matrix!(Rows, Cols, Type))(this, rhs);
	}

	ref typeof(this) opOpAssign(string op)(in typeof(this) rhs) pure nothrow @nogc @safe
	{
		static if (op == "+")
		{
			this = add(this, rhs);
		}
		else static if (op == "-")
		{
			this = subtract(this, rhs);
		}
		return this;
	}

	ref typeof(this) fill(float value = 0.0) pure nothrow @nogc @safe
	{
		foreach (col; 0 .. Cols)
		{
			foreach (row; 0 .. Rows)
			{
				this.index(row, col) = value;
			}
		}
		return this;
	}

	Matrix!(R, C, Type) resize(size_t R, size_t C)() const pure nothrow @nogc @safe
	in (R >= 1 && C >= 1)
	{
		scope Matrix!(R, C, Type) return_mat;
		foreach (col; 0 .. C)
		{
			foreach (row; 0 .. R)
			{
				return_mat[row, col] = (row < Rows && col < Cols)
					? this.index(row, col) : (row == col)
					? 1.0f : 0.0f;
			}
		}
		return return_mat;
	}

	Matrix!(R, C, Type) opCast(T : Matrix!(R, C, Type), size_t R, size_t C)() const pure nothrow @nogc @safe
	{
		return this.resize!(R, C);
	}

	size_t toHash() const @nogc @safe pure nothrow
	{
		return hashOf(this.data);
	}

	string opCast(Type : string)() const pure @safe
	{
		return this.to_string();
	}

	string to_string() const pure @safe
	{
		scope Appender!string return_str = appender("Matrix");
		foreach (col; 0 .. Cols)
		{
			return_str ~= format(" col%2d", col);
		}
		return_str ~= "\n";
		foreach (row; 0 .. Rows)
		{
			return_str ~= format(" row%2d", row);
			foreach (col; 0 .. Cols)
			{
				return_str ~= format(" %+2.2f", this.index(row, col));
			}
			return_str ~= "\n";
		}
		return return_str[];
	}

	string to_string_raw() const pure @safe
	{
		return text(this.data);
	}
}

// fill a scalar matrix
ref M fill(M : Matrix!(Rows, Cols, Type), size_t Rows, size_t Cols, Type)(
	return ref M mat, Type value = 0.0,
) pure nothrow @nogc @safe
{
	foreach (col; 0 .. Cols)
	{
		foreach (row; 0 .. Rows)
		{
			this.index(row, col) = value;
		}
	}
	return mat;
}
// identify matrix
ref M identify(M : Matrix!(Size, Size, Type), size_t Size, Type)(return ref M mat) pure nothrow @nogc @safe
{
	mat.fill(0f);
	foreach (count; 0 .. Size)
	{
		mat[count, count] = 1f;
	}
	return mat;
}

// transpose matrix
Matrix!(Rows, Cols, Type) transpose(
M : Matrix!(Rows, Cols, Type),
	size_t Rows, size_t Cols, Type,
)(in M matrix) pure nothrow @nogc @safe
{
	Matrix!(Cols, Rows, Type) result_matrix = Matrix!(Cols, Rows, Type)(0.0);
	foreach (col; 0 .. Cols)
	{
		foreach (row; 0 .. Rows)
		{
			result_matrix[col, row] = matrix[row, col];
		}
	}
	return result_matrix;
}

unittest
{
	assert(
		Matrix!(4, 4).identity() ==
			[
				[1f, 0f, 0f, 0f],
				[0f, 1f, 0f, 0f],
				[0f, 0f, 1f, 0f],
				[0f, 0f, 0f, 1f],
			]
	);

	Matrix!(2, 2) mat_a, mat_b;
	mat_a = [
		[1.0f, 2.0f],
		[3.0f, 4.0f],
	];
	mat_b = [
		[5.0f, 6.0f],
		[7.0f, 8.0f],
	];

	assert(mat_a.row == Vec2(1.0f, 3.0f));
	assert(mat_a.column == Vec2(1.0f, 2.0f));
	assert(mat_a.diagonal == Vec2(1.0f, 4.0f));

	assert(mat_a.transpose() == Matrix!(2, 2)([[1.0f, 3.0f], [2.0f, 4.0f]]));
	assert(mat_b.transpose() == [[5.0f, 7.0f], [6.0f, 8.0f]]);
}
// calculate adjugate matrix(2x2)
Matrix!(2, 2) adjugate(Type)(in Matrix!(2, 2, Type) mat) pure nothrow @nogc @safe
{
	return Matrix!(2, 2, Type)([
		[+mat[1, 1], -mat[0, 1]],
		[-mat[1, 0], +mat[0, 0]],
	]);
}
// calculate determinant matrix(2x2)
Type determinant(Type)(in Matrix!(2, 2, Type) mat) pure nothrow @nogc @safe
{
	return mat[0, 0] * mat[1, 1] - mat[1, 0] * mat[0, 1];
}
// calculate inverse matrix(2x2)
Matrix!(2, 2) invert(Type)(in Matrix!(2, 2, Type) mat) pure nothrow @nogc @safe
in (mat.determinant != 0.0)
{
	Type det;
	det = mat[0, 0] * mat[1, 1] - mat[1, 0] * mat[0, 1];
	return Matrix!(2, 2, Type)([
		[+mat[1, 1], -mat[0, 1]],
		[-mat[1, 0], +mat[0, 0]],
	]) * (1.0 / det);
}

unittest
{
	Matrix!(2, 2) mat_a, mat_b;
	mat_a = [
		[1.0f, 2.0f],
		[3.0f, 4.0f],
	];
	mat_b = [
		[5.0f, 6.0f],
		[7.0f, 8.0f],
	];
	assert(mat_a.determinant == -2.0);
	assert(mat_b.determinant == -2.0);
	assert(mat_a.adjugate() == Matrix!(2, 2)([[4.0, -2.0], [-3.0, 1.0]]));
	assert(mat_b.adjugate() == [[8.0, -6.0], [-7.0, 5.0]]);
	assert(mat_a.invert() == Matrix!(2, 2)([[-2.0f, +1.0], [+1.5, -0.5]]));
	assert(mat_b.invert() == [[-4.0, +3.0], [+3.5f, -2.5]]);
}
// adjugate 3x3
Matrix!(3, 3) adjugate(Type)(in Matrix!(3, 3, Type) mat) pure nothrow @nogc @safe
{
	return Matrix!(3, 3, Type)([
		[
			mat[1, 1] * mat[2, 2] - mat[1, 2] * mat[2, 1],
			mat[0, 2] * mat[2, 1] - mat[0, 1] * mat[2, 2],
			mat[0, 1] * mat[1, 2] - mat[0, 2] * mat[1, 1],
		],
		[
			mat[1, 2] * mat[2, 0] - mat[1, 0] * mat[2, 2],
			mat[0, 0] * mat[2, 2] - mat[0, 2] * mat[2, 0],
			mat[0, 2] * mat[1, 0] - mat[0, 0] * mat[1, 2],
		],
		[
			mat[1, 0] * mat[2, 1] - mat[1, 1] * mat[2, 0],
			mat[0, 1] * mat[2, 0] - mat[0, 0] * mat[2, 1],
			mat[0, 0] * mat[1, 1] - mat[0, 1] * mat[1, 0],
		],
	]);
}
// determinant 3x3
Type determinant(Type)(in Matrix!(3, 3, Type) mat) pure nothrow @nogc @safe
{
	return mat[0, 0] * mat[1, 1] * mat[2, 2]
		+ (mat[0, 1] * mat[1, 2] * mat[2, 0])
		+ (mat[0, 2] * mat[1, 0] * mat[2, 1])
		- (mat[0, 2] * mat[1, 1] * mat[2, 0])
		- (mat[0, 0] * mat[1, 2] * mat[2, 1])
		- (mat[0, 1] * mat[1, 0] * mat[2, 2]);
}
// inverse matrix 3x3
Matrix!(3, 3) invert(Type)(in Matrix!(3, 3, Type) mat) pure nothrow @nogc @safe
{
	return mat.adjugate / mat.determinant;
}

unittest
{
	Matrix!(3, 3) mat = Matrix!(3, 3)([
		[1.0, 2.0, 2.0,],
		[2.0, 1.0, 3.0,],
		[1.0, 3.0, 3.0,],
	]);
	assert(mat.determinant == -2.0);
	assert(mat.adjugate == Matrix!(3, 3)([
			[-6.0, 0.0, 4.0,],
			[-3.0, 1.0, 1.0,],
			[5.0, -1.0, -3.0,],
		])
	);
	assert(mat.invert() == Matrix!(3, 3)([
			[+3.0, 0.0, -2.0],
			[+1.5, -0.5, -0.5,],
			[-2.5, +0.5, +1.5,],
		])
	);
}
// adjugate
Matrix!(4, 4, Type) adjugate(Type)(in Matrix!(4, 4, Type) mat) pure nothrow @nogc @safe
{
	Matrix!(4, 4, Type) mat_adj;
	mat_adj[0, 0] = mat[1, 1] * mat[2, 2] * mat[3, 3]
		+ mat[1, 2] * mat[2, 3] * mat[3, 1]
		+ mat[1, 3] * mat[2, 1] * mat[3, 2]
		- mat[1, 1] * mat[2, 3] * mat[3, 2]
		- mat[1, 2] * mat[2, 1] * mat[3, 3]
		- mat[1, 3] * mat[2, 2] * mat[3, 1];
	mat_adj[0, 1] = mat[0, 1] * mat[2, 3] * mat[3, 2]
		+ mat[0, 2] * mat[2, 1] * mat[3, 3]
		+ mat[0, 3] * mat[2, 2] * mat[3, 1]
		- mat[0, 1] * mat[2, 2] * mat[3, 3]
		- mat[0, 2] * mat[2, 3] * mat[3, 1]
		- mat[0, 3] * mat[2, 1] * mat[3, 2];
	mat_adj[0, 2] = mat[0, 1] * mat[1, 2] * mat[3, 3]
		+ mat[0, 2] * mat[1, 3] * mat[3, 1]
		+ mat[0, 3] * mat[1, 1] * mat[3, 2]
		- mat[0, 1] * mat[1, 3] * mat[3, 2]
		- mat[0, 2] * mat[1, 1] * mat[3, 3]
		- mat[0, 3] * mat[1, 2] * mat[3, 1];
	mat_adj[0, 3] = mat[0, 1] * mat[1, 3] * mat[2, 2]
		+ mat[0, 2] * mat[1, 1] * mat[2, 3]
		+ mat[0, 3] * mat[1, 2] * mat[2, 1]
		- mat[0, 1] * mat[1, 2] * mat[2, 3]
		- mat[0, 2] * mat[1, 3] * mat[2, 1]
		- mat[0, 3] * mat[1, 1] * mat[2, 2];
	mat_adj[1, 0] = mat[1, 0] * mat[2, 3] * mat[3, 2]
		+ mat[1, 2] * mat[2, 0] * mat[3, 3]
		+ mat[1, 3] * mat[2, 2] * mat[3, 0]
		- mat[1, 0] * mat[2, 2] * mat[3, 3]
		- mat[1, 2] * mat[2, 3] * mat[3, 0]
		- mat[1, 3] * mat[2, 0] * mat[3, 2];
	mat_adj[1, 1] = mat[0, 0] * mat[2, 2] * mat[3, 3]
		+ mat[0, 2] * mat[2, 3] * mat[3, 0]
		+ mat[0, 3] * mat[2, 0] * mat[3, 2]
		- mat[0, 0] * mat[2, 3] * mat[3, 2]
		- mat[0, 2] * mat[2, 0] * mat[3, 3]
		- mat[0, 3] * mat[2, 2] * mat[3, 0];
	mat_adj[1, 2] = mat[0, 0] * mat[1, 3] * mat[3, 2]
		+ mat[0, 2] * mat[1, 0] * mat[3, 3]
		+ mat[0, 3] * mat[1, 2] * mat[3, 0]
		- mat[0, 0] * mat[1, 2] * mat[3, 3]
		- mat[0, 2] * mat[1, 3] * mat[3, 0]
		- mat[0, 3] * mat[1, 0] * mat[3, 2];
	mat_adj[1, 3] = mat[0, 0] * mat[1, 2] * mat[2, 3]
		+ mat[0, 2] * mat[1, 3] * mat[2, 0]
		+ mat[0, 3] * mat[1, 0] * mat[2, 2]
		- mat[0, 0] * mat[1, 3] * mat[2, 2]
		- mat[0, 2] * mat[1, 0] * mat[2, 3]
		- mat[0, 3] * mat[1, 2] * mat[2, 0];
	mat_adj[2, 0] = mat[1, 0] * mat[2, 1] * mat[3, 3]
		+ mat[1, 1] * mat[2, 3] * mat[3, 0]
		+ mat[1, 3] * mat[2, 0] * mat[3, 1]
		- mat[1, 0] * mat[2, 3] * mat[3, 1]
		- mat[1, 1] * mat[2, 0] * mat[3, 3]
		- mat[1, 3] * mat[2, 1] * mat[3, 0];
	mat_adj[2, 1] = mat[0, 0] * mat[2, 3] * mat[3, 1]
		+ mat[0, 1] * mat[2, 0] * mat[3, 3]
		+ mat[0, 3] * mat[2, 1] * mat[3, 0]
		- mat[0, 0] * mat[2, 1] * mat[3, 3]
		- mat[0, 1] * mat[2, 3] * mat[3, 0]
		- mat[0, 3] * mat[2, 0] * mat[3, 1];
	mat_adj[2, 2] = mat[0, 0] * mat[1, 1] * mat[3, 3]
		+ mat[0, 1] * mat[1, 3] * mat[3, 0]
		+ mat[0, 3] * mat[1, 0] * mat[3, 1]
		- mat[0, 0] * mat[1, 3] * mat[3, 1]
		- mat[0, 1] * mat[1, 0] * mat[3, 3]
		- mat[0, 3] * mat[1, 1] * mat[3, 0];
	mat_adj[2, 3] = mat[0, 0] * mat[1, 3] * mat[2, 1]
		+ mat[0, 1] * mat[1, 0] * mat[2, 3]
		+ mat[0, 3] * mat[1, 1] * mat[2, 0]
		- mat[0, 0] * mat[1, 1] * mat[2, 3]
		- mat[0, 1] * mat[1, 3] * mat[2, 0]
		- mat[0, 3] * mat[1, 0] * mat[2, 1];
	mat_adj[3, 0] = mat[1, 0] * mat[2, 2] * mat[3, 1]
		+ mat[1, 1] * mat[2, 0] * mat[3, 2]
		+ mat[1, 2] * mat[2, 1] * mat[3, 0]
		- mat[1, 0] * mat[2, 1] * mat[3, 2]
		- mat[1, 1] * mat[2, 2] * mat[3, 0]
		- mat[1, 2] * mat[2, 0] * mat[3, 1];
	mat_adj[3, 1] = mat[0, 0] * mat[2, 1] * mat[3, 2]
		+ mat[0, 1] * mat[2, 2] * mat[3, 0]
		+ mat[0, 2] * mat[2, 0] * mat[3, 1]
		- mat[0, 0] * mat[2, 2] * mat[3, 1]
		- mat[0, 1] * mat[2, 0] * mat[3, 2]
		- mat[0, 2] * mat[2, 1] * mat[3, 0];
	mat_adj[3, 2] = mat[0, 0] * mat[1, 2] * mat[3, 1]
		+ mat[0, 1] * mat[1, 0] * mat[3, 2]
		+ mat[0, 2] * mat[1, 1] * mat[3, 0]
		- mat[0, 0] * mat[1, 1] * mat[3, 2]
		- mat[0, 1] * mat[1, 2] * mat[3, 0]
		- mat[0, 2] * mat[1, 0] * mat[3, 1];
	mat_adj[3, 3] = mat[0, 0] * mat[1, 1] * mat[2, 2]
		+ mat[0, 1] * mat[1, 2] * mat[2, 0]
		+ mat[0, 2] * mat[1, 0] * mat[2, 1]
		- mat[0, 0] * mat[1, 2] * mat[2, 1]
		- mat[0, 1] * mat[1, 0] * mat[2, 2]
		- mat[0, 2] * mat[1, 1] * mat[2, 0];
	return mat_adj;
}

Type determinant(Type)(in Matrix!(4, 4, Type) mat) pure nothrow @nogc @safe
{
	return mat[0, 0] * mat[1, 1] * mat[2, 2] * mat[3, 3]
		+ mat[0, 0] * mat[1, 2] * mat[2, 3] * mat[3, 1]
		+ mat[0, 0] * mat[1, 3] * mat[2, 1] * mat[3, 2]
		+ mat[0, 1] * mat[1, 0] * mat[2, 3] * mat[3, 2]
		+ mat[0, 1] * mat[1, 2] * mat[2, 0] * mat[3, 3]
		+ mat[0, 1] * mat[1, 3] * mat[2, 2] * mat[3, 0]
		+ mat[0, 2] * mat[1, 0] * mat[2, 1] * mat[3, 3]
		+ mat[0, 2] * mat[1, 1] * mat[2, 3] * mat[3, 0]
		+ mat[0, 2] * mat[1, 3] * mat[2, 0] * mat[3, 1]
		+ mat[0, 3] * mat[1, 0] * mat[2, 2] * mat[3, 1]
		+ mat[0, 3] * mat[1, 1] * mat[2, 0] * mat[3, 2]
		+ mat[0, 3] * mat[1, 2] * mat[2, 1] * mat[3, 0]
		- mat[0, 0] * mat[1, 1] * mat[2, 3] * mat[3, 2]
		- mat[0, 0] * mat[1, 2] * mat[2, 1] * mat[3, 3]
		- mat[0, 0] * mat[1, 3] * mat[2, 2] * mat[3, 1]
		- mat[0, 1] * mat[1, 0] * mat[2, 2] * mat[3, 3]
		- mat[0, 1] * mat[1, 2] * mat[2, 3] * mat[3, 0]
		- mat[0, 1] * mat[1, 3] * mat[2, 0] * mat[3, 2]
		- mat[0, 2] * mat[1, 0] * mat[2, 3] * mat[3, 1]
		- mat[0, 2] * mat[1, 1] * mat[2, 0] * mat[3, 3]
		- mat[0, 2] * mat[1, 3] * mat[2, 1] * mat[3, 0]
		- mat[0, 3] * mat[1, 0] * mat[2, 1] * mat[3, 2]
		- mat[0, 3] * mat[1, 1] * mat[2, 2] * mat[3, 0]
		- mat[0, 3] * mat[1, 2] * mat[2, 0] * mat[3, 1];
}

Matrix!(4, 4, Type) invert(Type)(in Matrix!(4, 4, Type) mat) pure nothrow @nogc @safe
{
	return mat.adjugate / mat.determinant;
}

unittest
{
	Matrix!(4, 4) mat = Matrix!(4, 4)([
		[2.0, 1.0, 0.0, 3.0,],
		[0.0, 3.0, 1.0, 4.0,],
		[0.0, 0.0, 5.0, 2.0,],
		[0.0, 0.0, 0.0, 1.0,],
	]);
	assert(mat.determinant == 30.0);
	assert(mat.adjugate == [
			[15.0, -5.0, 1.0, -27.0,],
			[0.0, 10.0, -2.0, -36.0,],
			[0.0, 0.0, 6.0, -12.0,],
			[0.0, 0.0, 0.0, 30.0,],
		]);
	assert(mat.invert == [
			[1.0 / 2, -1.0 / 6, +1.0 / 30, -9.0 / 10,],
			[0.0, 1.0 / 3.0, -1.0 / 15, -6.0 / 5,],
			[0.0, 0.0, 1.0 / 5, -2.0 / 5,],
			[0.0, 0.0, 0.0, 1.0,],
		]);
}
// return equality Matrices approximently (Mat == Mat)
bool approx_equal(
	size_t Rows, size_t Cols, LhsType, RhsType,
)(
	in Matrix!(Rows, Cols, LhsType) lhs,
	in Matrix!(Rows, Cols, RhsType) rhs,
) pure nothrow @nogc @safe
{
	enum error_margin = (is(LhsType == float) && is(RhsType == float)) ? 1e-5 : 1e-10;
	foreach (row; 0 .. Rows)
	{
		foreach (col; 0 .. Cols)
		{
			if (!isClose(lhs[row, col], rhs[row, col], error_margin, error_margin))
			{
				return false;
			}
		}
	}
	return true;
}
// return quality Matrices strictly (Mat == Mat)
bool strict_equal(
	size_t Rows, size_t Cols, LhsType, RhsType,
)(
	in Matrix!(Rows, Cols, LhsType) lhs,
	in Matrix!(Rows, Cols, RhsType) rhs,
) pure nothrow @nogc @safe
{
	foreach (row; 0 .. Rows)
	{
		foreach (col; 0 .. Cols)
		{
			if (lhs[row, col] != rhs[row, col])
			{
				return false;
			}
		}
	}
	return true;
}

// add Matrix (Mat + Mat)
Matrix!(Rows1, Cols1, Type1) add(
M1 : Matrix!(Rows1, Cols1, Type1), M2:
	Matrix!(Rows2, Cols2, Type2),
	size_t Rows1, size_t Cols1, Type1,
	size_t Rows2, size_t Cols2, Type2
)(in M1 lhs, in M2 rhs) pure nothrow @nogc @safe
in
{
	static assert(Rows1 == Rows2, "lhs row and rhs row are not same");
	static assert(Cols1 == Cols2, "lhs col and rhs col are not same");
}
do
{
	Matrix!(Rows1, Cols1, Type1) result_matrix = Matrix!(Rows1, Cols1, Type1)(0.0);
	static foreach (col; 0 .. Cols1)
	{
		static foreach (row; 0 .. Rows1)
		{
			result_matrix[row, col] = lhs[row, col] + rhs[row, col];
		}
	}
	return result_matrix;
}
// subtract matrix (Mat - Mat)
Matrix!(Rows1, Cols1, Type1) subtract(
M1 : Matrix!(Rows1, Cols1, Type1), M2:
	Matrix!(Rows2, Cols2, Type2),
	size_t Rows1, size_t Cols1, Type1,
	size_t Rows2, size_t Cols2, Type2
)(in M1 lhs, in M2 rhs) pure nothrow @nogc @safe
in
{
	static assert(Rows1 == Rows2, "lhs row and rhs row are not same");
	static assert(Cols1 == Cols2, "lhs col and rhs col are not same");
}
do
{
	Matrix!(Rows1, Cols1, Type1) result_matrix = Matrix!(Rows1, Cols1, Type1)(0.0);
	static foreach (col; 0 .. Cols1)
	{
		static foreach (row; 0 .. Rows1)
		{
			result_matrix[row, col] = lhs[row, col] - rhs[row, col];
		}
	}
	return result_matrix;
}
// multiply matrix (Mat * Mat)
Matrix!(Rows1, Cols2, Type) multiply(M1 : Matrix!(Rows1, Cols1, Type), M2:
	Matrix!(Rows2, Cols2, Type), size_t Rows1, size_t Cols1, size_t Rows2, size_t Cols2, Type)(
	in M1 lhs, in M2 rhs
) pure nothrow @nogc @safe
in
{
	static assert(Cols1 == Rows2, "lhs col and rhs row are NOT same");
}
do
{
	Matrix!(Rows1, Cols2, Type) result_matrix = Matrix!(Rows1, Cols2, Type)(0.0);

	foreach (row; 0 .. Rows1)
	{
		foreach (col; 0 .. Cols2)
		{
			foreach (count; 0 .. Cols1)
			{
				result_matrix[row, col] += lhs[row, count] * rhs[count, col];
			}
		}
	}
	return result_matrix;
}
// multiply matrix and scalar (Mat * 2.0)
Matrix!(Rows, Cols, Type) multiply(
M1 : Matrix!(Rows, Cols, Type), size_t Rows, size_t Cols, Type
)(
	in M1 lhs, in Type rhs
) pure nothrow @nogc @safe
{
	Matrix!(Rows, Cols, Type) result_matrix;
	result_matrix = lhs;
	foreach (col; 0 .. Cols)
	{
		foreach (row; 0 .. Rows)
		{
			result_matrix[row, col] *= rhs;
		}
	}
	return result_matrix;
}

// devide matrix and scalar (Matrix / 2.0)
Matrix!(Rows, Cols, Type) devide(
M1 : Matrix!(Rows, Cols, Type), size_t Rows, size_t Cols, Type
)(
	in M1 lhs, in Type rhs
) pure nothrow @nogc @safe
{
	Matrix!(Rows, Cols, Type) result_matrix;
	result_matrix = lhs;
	foreach (col; 0 .. Cols)
	{
		foreach (row; 0 .. Rows)
		{
			result_matrix[row, col] /= rhs;
		}
	}
	return result_matrix;
}

unittest
{
	scope Matrix!(2, 2) mat_a, mat_b;
	mat_a = [
		[1.0f, 2.0f],
		[3.0f, 4.0f],
	];
	mat_b = [
		[5.0f, 6.0f],
		[7.0f, 8.0f],
	];
	assert(mat_a + mat_b == Matrix!(2, 2)([[6.0, 8.0], [10.0, 12.0]]));
	assert(mat_a - mat_b == Matrix!(2, 2)([[-4.0, -4.0], [-4.0, -4.0]]));

	assert(mat_a * mat_b == Matrix!(2, 2)([[19.0, 22.0], [43.0, 50.0]]));
	assert(mat_b * mat_a == Matrix!(2, 2)([[23.0, 34.0], [31.0, 46.0]]));
	assert(
		Matrix!(2, 3)([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
			* Matrix!(3, 2)([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
			== Matrix!(2, 2)([[22.0, 28.0], [49.0, 64.0]])
	);
	assert(
		Matrix!(3, 2)([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]) *
			Matrix!(2, 3)([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
			== Matrix!(3, 3)([
				[9.0, 12.0, 15.0],
				[19.0, 26.0, 33.0],
				[29.0, 40.0, 51.0],
			])
	);
}
// generate matrix for using case
// identity matrix
Matrix!(Size, Size, Type) matrix_identity(size_t Size, Type = float)() pure nothrow @nogc @safe
in (Size != 0)
{
	scope Matrix!(4, 4, Type) temp_mat;
	temp_mat.fill(0.0f);
	foreach (count; 0 .. Size)
	{
		temp_mat[count, count] = 1.0f;
	}
	return temp_mat;
}

// matrix operation
Matrix!(Rows, Cols, Type) multiply(bool rtol = false, size_t Rows, size_t Cols, Type)(
	Matrix!(Rows, Cols, Type)[] matrix_list...
)
{
	scope Matrix!(Rows, Cols, Type) temp = Matrix!(Rows, Cols, Type)(0.0f);
	temp.indentify();
	if (rtol == false)
	{
		// left to right
		foreach (count; 0 .. matrix_list.length)
		{
			temp = temp * matrix_list[count];
		}

	}
	else
	{
		// right to left
		foreach_reverse (count; 0 .. matrix_list.length)
		{
			temp = temp * matrix_list[count];
		}
	}
	return temp;
}
