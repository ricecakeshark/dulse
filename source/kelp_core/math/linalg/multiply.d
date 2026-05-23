module kelp_core.math.linalg.multiply;

import kelp_core.math.linalg;
import std.algorithm;
import std.range;

public:
Vector!(Row, Type) multiply(
M : Matrix!(Row, Col, Type),
V:Vector!(Row, Type),
	size_t Row, size_t Col, Type,
)(in M mat, in V vec) pure nothrow @nogc @safe
{
	Vector!(Row, Type) result_vec;
	static foreach (row; 0 .. Row)
	{
		result_vec.data[row] = 0.0;
		static foreach (col; 0 .. Col)
		{
			result_vec.data[row] += mat[row, col] * vec[row];
		}
	}
	return result_vec;
}

unittest
{
	Matrix!(4, 4) mat;
	Vector!(4) vec;
	mat = [
		[1f, 0f, 0f, 0f],
		[0f, 2f, 0f, 0f],
		[0f, 0f, 3f, 0f],
		[0f, 0f, 0f, 1f],
	];
	vec = [1f, 2f, 3f, 1f];
	assert(mat * vec == Vector!(4)(1f, 4f, 9f, 1f));
}


Matrix!(4,4) to_matrix(Vector!(4) vec)
{
	Matrix!(4,4) ret_mat;
	ret_mat.indentify();
	foreach(index;0..4)
	{
		ret_mat[index,index] = vec[index];
	}
	return ret_mat;
}