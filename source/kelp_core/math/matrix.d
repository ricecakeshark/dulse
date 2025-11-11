module source.kelp_core.math.matrix;

struct Matrix(size_t Row, size_t Col, Type = float)
{
	Type[Col][Row] data;

	this(Type default_value)
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

	this(Type[][] new_matrix)
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

	Type[Col][Row] opAssign(Type[Col][Row] assign_matrix) pure nothrow @safe
	{
		this.data = assign_matrix;
		return assign_matrix;
	}

	inout(Type) opIndex(const size_t row, const size_t col) inout pure nothrow @nogc @safe
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

	Matrix!(Row, K, Type) opBinary(string op : "*", size_t K)(Matrix!(Col, K, Type) rhs) const pure nothrow @safe
	{
		Matrix!(Row, K, Type) result_matrix = Matrix!(Row, K, Type)(0.0);

		foreach (row; 0 .. Row)
		{
			foreach (col; 0 .. K)
			{
				foreach (count; 0 .. Col)
				{
					result_matrix.data[row][col] += this[row, count] * rhs[count, col];
				}
			}
		}
		return result_matrix;
	}
}

unittest
{
	import std.stdio;

	Matrix!(2, 2) mat_a, mat_b, mat_ab, mat_ba;

	mat_a = Matrix!(2, 2)([[+2.0, -3.0], [+4.0, +1.0]]);
	mat_b = Matrix!(2, 2)([[+5.0, +2.0], [-1.0, +3.0]]);
	mat_ab = Matrix!(2, 2)([[+13.0, -5.0], [+19.0, +11.0]]);
	mat_ba = Matrix!(2, 2)([[+18.0, -13.0], [+10.0, +6.0]]);

	writeln(cast(string) mat_a);
	writeln(cast(string) mat_b);
	writeln(cast(string)(mat_a * mat_b));
	writeln(cast(string)(mat_ab));

	assert(mat_a * mat_b == mat_ab);
	assert(mat_b * mat_a == mat_ba);

	assert(
		Matrix!(2, 3)([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
			* Matrix!(3, 2)([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
			== Matrix!(2, 2)([[22.0, 28.0], [49.0, 64.0]])
	);
}
