module kelp_core.math.linalg.matrix;

struct Matrix(size_t Row, size_t Col, Type = float)
{
	Type[Col][Row] data;

	this(in Type default_value) pure nothrow @nogc @safe
	{
		//this.data = new Type[Row][Col]();
		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. Col)
			{
				this.data[row][col] = default_value;
			}
		}
		return;
	}

	this(in Type[Col][Row] new_matrix) pure nothrow @nogc @safe
	in (new_matrix.length == Row)
	in (new_matrix[0].length == Col)
	{
		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. Col)
			{
				this.data[row][col] = new_matrix[row][col];
			}
		}
		return;
	}

	Type[Col][Row] opAssign(in Type[Col][Row] assign_matrix) pure nothrow @safe
	{
		this.data = assign_matrix;
		return assign_matrix;
	}

	inout(Type) opIndex(in size_t row, in size_t col) inout pure nothrow @nogc @safe
	{
		return this.data[row][col];
	}

	string opCast(T : string)() const pure @safe
	{
		import std.format;

		string return_str;

		return_str = "Matrix";
		foreach (col; 0 .. Col)
		{
			return_str ~= format(" row%2d", col);
		}
		return_str ~= "\n";
		foreach (row; 0 .. Row)
		{
			return_str ~= format(" col%2d", row);
			foreach (col; 0 .. Col)
			{
				return_str ~= format(" %+2.2f", this.opIndex(row, col));
			}
			return_str ~= "\n";
		}
		return return_str;
	}

	Matrix!(Row, Col, Type) opBinary(string op : "+", size_t RhsRow, size_t RhsCol, RhsType)(
		in Matrix!(RhsRow, RhsCol, RhsType) rhs) const pure nothrow @nogc @safe
	in (RhsRow == Row)
	in (RhsCol == Col)
	{
		return add(this, rhs);
	}

	Matrix!(Row, Col, Type) opBinary(string op : "-", size_t RhsRow, size_t RhsCol, RhsType)(
		in Matrix!(RhsRow, RhsCol, RhsType) rhs) const pure nothrow @nogc @safe
	in (RhsRow == Row)
	in (RhsCol == Col)
	{
		return subtract(this, rhs);
	}

	Matrix!(Row, Col2, Type) opBinary(string op : "*", size_t Row2, size_t Col2)(
		in Matrix!(Row2, Col2, Type) rhs) const pure nothrow @nogc @safe
	{
		return multiply!(Matrix!(Row, Col, Type), Matrix!(Row2, Col2, Type))(this, rhs);
	}
}

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
			result_matrix.data[row][col] = lhs[row, col] + rhs[row, col];
		}
	}
	return result_matrix;
}

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
			result_matrix.data[row][col] = lhs[row, col] - rhs[row, col];
		}
	}
	return result_matrix;
}

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
				result_matrix.data[row][col] += lhs[row, count] * rhs[count, col];
			}
		}
	}
	return result_matrix;
}

unittest
{
	import std.stdio;

	Matrix!(2, 2) mat_a, mat_b, mat_ab, mat_ba;

	mat_a = Matrix!(2, 2)([[+2.0, -3.0], [+4.0, +1.0]]);
	mat_b = Matrix!(2, 2)([[+5.0, +2.0], [-1.0, +3.0]]);
	mat_ab = Matrix!(2, 2)([[+13.0, -5.0], [+19.0, +11.0]]);
	mat_ba = Matrix!(2, 2)([[+18.0, -13.0], [+10.0, +6.0]]);

	assert(mat_a * mat_b == mat_ab);
	assert(mat_b * mat_a == mat_ba);

	assert(
		Matrix!(2, 3)([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
			* Matrix!(3, 2)([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
			== Matrix!(2, 2)([[22.0, 28.0], [49.0, 64.0]])
	);

	assert(
		Matrix!(2, 2)([[1.0, 2.0], [3.0, 4.0]])
			+ Matrix!(2, 2)([[5.0, 6.0], [7.0, 8.0]])
			== Matrix!(2, 2)([[6.0, 8.0], [10.0, 12.0]])
	);
}
