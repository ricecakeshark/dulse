module kelp_core.math.linalg.matrix;

import kelp_core.math.linalg;
import kelp_core.math.linalg.multiply;

import std.array : appender, Appender;
import std.conv : text;
import std.format : format;
import std.math;

// Matrix(Row-Major) 
struct Matrix(size_t Row, size_t Col, Type = float)
{
	Type[Col][Row] data;

	this(in typeof(this.data) new_matrix) pure nothrow @nogc @safe
	in (new_matrix.length == Row)
	in (new_matrix[0].length == Col)
	{
		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. Col)
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

	this(in Type[Row] new_vector) pure nothrow @nogc @safe
	{
		this.fill(0.0f);
		foreach (count; 0 .. Row)
		{
			this.index(count, count) = new_vector[count];
		}
		return;
	}

	@property bool is_normal() const pure nothrow @nogc @safe
	{
		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. Col)
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
		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. Col)
			{
				if (this.index(row, col).isNaN)
				{
					return true;
				}
			}
		}
		return false;
	}

	@property Vector!(Row, Type) row() const pure nothrow @nogc @safe
	{
		Vector!(Row, Type) ret_vec;
		foreach (row; 0 .. Row)
		{
			ret_vec.data[row] = this.index(row, 0u);
		}
		return ret_vec;
	}

	@property Vector!(Col, Type) column() const pure nothrow @nogc @safe
	{
		Vector!(Col, Type) ret_vec;
		foreach (col; 0 .. Col)
		{
			ret_vec.data[col] = this.index(0, col);
		}
		return ret_vec;
	}

	@property Vector!(Row, Type) diagonal()() const pure nothrow @nogc @safe
	if (Row == Col)
	{
		Vector!(Row, Type) ret_vec;
		foreach (index; 0 .. Row)
		{
			ret_vec[index] = this.index(index, index);
		}
		return ret_vec;
	}

	typeof(this.data) opAssign(in Type[Col][Row] assign_matrix) pure nothrow @safe
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

	Matrix!(R, C, Type) opCast(T : Matrix!(R, C, Type), size_t R, size_t C)() const pure nothrow @nogc @safe
	{
		scope Matrix!(R, C, Type) return_mat;
		foreach (col; 0 .. C)
		{
			foreach (row; 0 .. R)
			{
				return_mat[row, col] = (row < Row && col < Col) ? this.index(row, col) : 0.0f;
			}
		}
		return return_mat;
	}

	Matrix!(R, C, Type) resize(size_t R, size_t C)() const pure nothrow @nogc @safe
	in (R >= 1 && C >= 1)
	{
		scope Matrix!(R, C, Type) return_mat;
		foreach (col; 0 .. C)
		{
			foreach (row; 0 .. R)
			{
				return_mat[row, col] = (row < Row && col < Col)
					? this.index(row, col) : (row == col)
					? 1.0f : 0.0f;
			}
		}
		return return_mat;
	}

	string to_string() const pure @safe
	{
		scope Appender!string return_str = appender("Matrix");
		foreach (col; 0 .. Col)
		{
			return_str ~= format(" col%2d", col);
		}
		return_str ~= "\n";
		foreach (row; 0 .. Row)
		{
			return_str ~= format(" row%2d", row);
			foreach (col; 0 .. Col)
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

	string opCast(T : string)() const pure @safe
	{
		return this.to_string();
	}

	bool opEquals(in Matrix!(Row, Col, Type) rhs) const pure nothrow @nogc @safe
	{
		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. Col)
			{
				if (isClose(this[row, col], rhs[row, col]) == false)
				{
					return false;
				}
			}
		}
		return true;
	}

	bool opEquals(in Type[Col][Row] rhs) const pure nothrow @nogc @safe
	{
		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. Col)
			{
				if (isClose(this.index(row, col), rhs[row][col], 1e-10, 1e-6) == false)
				{
					return false;
				}
			}
		}
		return true;
	}
	// Matrix + Matrix
	Matrix!(Row, Col, Type) opBinary(
		string op : "+", size_t RhsRow, size_t RhsCol, RhsType,
	)(
		in Matrix!(RhsRow, RhsCol, RhsType) rhs,
	) const pure nothrow @nogc @safe
	in (RhsRow == Row)
	in (RhsCol == Col)
	{
		return add(this, rhs);
	}
	// Matrix - Matrix
	Matrix!(Row, Col, Type) opBinary(
		string op : "-", size_t RhsRow, size_t RhsCol, RhsType,
	)(
		in Matrix!(RhsRow, RhsCol, RhsType) rhs,
	) const pure nothrow @nogc @safe
	in (RhsRow == Row)
	in (RhsCol == Col)
	{
		return subtract(this, rhs);
	}
	// Matrix * Matrix
	Matrix!(Row, Col2, Type) opBinary(string op : "*", size_t Row2, size_t Col2)(
		in Matrix!(Row2, Col2, Type) rhs) const pure nothrow @nogc @safe
	{
		return multiply!(Matrix!(Row, Col, Type), Matrix!(Row2, Col2, Type))(this, rhs);
	}
	// Matrix * 2.0
	Matrix!(Row, Col, Type) opBinary(string op : "*")(
		in Type rhs) const pure nothrow @nogc @safe
	{
		return multiply!(Matrix!(Row, Col, Type))(this, rhs);
	}
	// Matrix / 2.0
	Matrix!(Row, Col, Type) opBinary(string op : "/")(
		in Type rhs) const pure nothrow @nogc @safe
	in (!rhs.isClose(0.0))
	{
		return devide!(Matrix!(Row, Col, Type))(this, rhs);
	}

	Vector!(Row, Type) opBinary(string op : "*")(
		Vector!(Row, Type) rhs) pure nothrow @nogc @safe
	{
		return multiply!(typeof(this), typeof(rhs), Row, Col, Type)(this, rhs);
	}

	typeof(this) fill(float value = 0.0) pure nothrow @nogc @safe
	{
		foreach (col; 0 .. Col)
		{
			foreach (row; 0 .. Row)
			{
				this.index(row, col) = value;
			}
		}
		return this;
	}

	typeof(this) indentify() pure nothrow @nogc @safe
	in (Row == Col)
	{
		this.fill(0.0f);
		foreach (count; 0 .. Col)
		{
			this.index(count, count) = 1.0f;
		}
		return this;
	}

	size_t toHash() const @nogc @safe pure nothrow
	{
		return hashOf(this.data);
	}
}

// transpose matrix
Matrix!(Row, Col, Type) transpose(
M : Matrix!(Row, Col, Type),
	size_t Row, size_t Col, Type,
)(in M matrix) pure nothrow @nogc @safe
{
	Matrix!(Col, Row, Type) result_matrix = Matrix!(Col, Row, Type)(0.0);
	foreach (col; 0 .. Col)
	{
		foreach (row; 0 .. Row)
		{
			result_matrix[col, row] = matrix[row, col];
		}
	}
	return result_matrix;
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

// add Matrix (Mat + Mat)
Matrix!(Row1, Col1, Type1) add(
M1 : Matrix!(Row1, Col1, Type1), M2:
	Matrix!(Row2, Col2, Type2),
	size_t Row1, size_t Col1, Type1,
	size_t Row2, size_t Col2, Type2
)(in M1 lhs, in M2 rhs) pure nothrow @nogc @safe
in
{
	static assert(Row1 == Row2, "lhs row and rhs row are not same");
	static assert(Col1 == Col2, "lhs col and rhs col are not same");
}
do
{
	Matrix!(Row1, Col1, Type1) result_matrix = Matrix!(Row1, Col1, Type1)(0.0);
	static foreach (col; 0 .. Col1)
	{
		static foreach (row; 0 .. Row1)
		{
			result_matrix[row, col] = lhs[row, col] + rhs[row, col];
		}
	}
	return result_matrix;
}
// subtract matrix (Mat - Mat)
Matrix!(Row1, Col1, Type1) subtract(
M1 : Matrix!(Row1, Col1, Type1), M2:
	Matrix!(Row2, Col2, Type2),
	size_t Row1, size_t Col1, Type1,
	size_t Row2, size_t Col2, Type2
)(in M1 lhs, in M2 rhs) pure nothrow @nogc @safe
in
{
	static assert(Row1 == Row2, "lhs row and rhs row are not same");
	static assert(Col1 == Col2, "lhs col and rhs col are not same");
}
do
{
	Matrix!(Row1, Col1, Type1) result_matrix = Matrix!(Row1, Col1, Type1)(0.0);
	static foreach (col; 0 .. Col1)
	{
		static foreach (row; 0 .. Row1)
		{
			result_matrix[row, col] = lhs[row, col] - rhs[row, col];
		}
	}
	return result_matrix;
}
// multiply matrix (Mat * Mat)
Matrix!(Row1, Col2, Type) multiply(M1 : Matrix!(Row1, Col1, Type), M2:
	Matrix!(Row2, Col2, Type), size_t Row1, size_t Col1, size_t Row2, size_t Col2, Type)(
	in M1 lhs, in M2 rhs
) pure nothrow @nogc @safe
in
{
	static assert(Col1 == Row2, "lhs col and rhs row are NOT same");
}
do
{
	Matrix!(Row1, Col2, Type) result_matrix = Matrix!(Row1, Col2, Type)(0.0);

	foreach (row; 0 .. Row1)
	{
		foreach (col; 0 .. Col2)
		{
			foreach (count; 0 .. Col1)
			{
				result_matrix[row, col] += lhs[row, count] * rhs[count, col];
			}
		}
	}
	return result_matrix;
}
// multiply matrix and scalar (Mat * 2.0)
Matrix!(Row, Col, Type) multiply(
M1 : Matrix!(Row, Col, Type), size_t Row, size_t Col, Type
)(
	in M1 lhs, in Type rhs
) pure nothrow @nogc @safe
{
	Matrix!(Row, Col, Type) result_matrix;
	result_matrix = lhs;
	foreach (col; 0 .. Col)
	{
		foreach (row; 0 .. Row)
		{
			result_matrix[row, col] *= rhs;
		}
	}
	return result_matrix;
}

// devide matrix and scalar (Matrix / 2.0)
Matrix!(Row, Col, Type) devide(
M1 : Matrix!(Row, Col, Type), size_t Row, size_t Col, Type
)(
	in M1 lhs, in Type rhs
) pure nothrow @nogc @safe
{
	Matrix!(Row, Col, Type) result_matrix;
	result_matrix = lhs;
	foreach (col; 0 .. Col)
	{
		foreach (row; 0 .. Row)
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
// 
Matrix!(Size, Size) matrix_scale(size_t Size, Type = float)(Type[Size] value_list...) pure nothrow @nogc @safe
{
	scope Matrix!(Size, Size) temp;
	temp.fill(0.0f);
	foreach (count; 0 .. Size)
	{
		temp[count, count] = value_list[count];
	}
	return temp;
}

Matrix!(Size, Size) matrix_scale(size_t Size, Type = float)(in Type value) pure nothrow @nogc @safe
{
	scope Matrix!(Size, Size) temp;
	temp.fill(0.0f);
	foreach (count; 0 .. Size)
	{
		temp[count, count] = value;
	}
	return temp;
}

Matrix!(Size, Size) matrix_scale(size_t Size, Type = float)(in Vector!(Size, Type) vec) pure nothrow @nogc @safe
{
	scope Matrix!(Size, Size) temp;
	temp.fill(0.0f);
	foreach (count; 0 .. Size)
	{
		temp[count, count] = vec[count];
	}
	return temp;
}

Matrix!(Size, Size) matrix_translate(size_t Size, Type = float)(Type[Size] value_list) pure nothrow @nogc @safe
{
	scope Matrix!(Size, Size) temp;
	temp.fill(0.0f);
	foreach (index; 0 .. Size)
	{
		temp[index, Size - 1] = value_list[index];
	}
	return temp;
}

Matrix!(Size, Size) matrix_translate(size_t Size, Type = float)(Vector!(Size, Type) vec) pure nothrow @nogc @safe
{
	return matrix_translate(vec.data);
}

unittest
{
	scope Matrix!(3, 3) mat_s, mat_t;
	mat_s = matrix_scale([+1.0f, +2.0f, +3.0f]);
	assert(mat_s == Matrix!(3, 3)(
			[
			[+1.0f, 0.0f, 0.0f,],
			[0.0f, +2.0f, 0.0f,],
			[0.0f, 0.0f, +3.0f,],
		]
	));
}
// matrix operation
Matrix!(Row, Col, Type) multiply_ltor(size_t Row, size_t Col, Type)(
	Matrix!(Row, Col, Type)[] matrix_list...
)
{
	scope Matrix!(Row, Col, Type) temp = Matrix!(Row, Col, Type)(0.0f);
	temp.indentify();
	foreach (count; 0 .. matrix_list.length)
	{
		temp = temp * matrix_list[count];
	}
	return temp;
}

Matrix!(Row, Col, Type) multiply_rtol(size_t Row, size_t Col, Type)(
	Matrix!(Row, Col, Type)[] matrix_list...
)
{
	scope Matrix!(Row, Col, Type) temp = Matrix!(Row, Col, Type)(0.0f);
	temp.indentify();
	foreach_reverse (count; 0 .. matrix_list.length)
	{
		temp = temp * matrix_list[count];
	}
	return temp;
}
