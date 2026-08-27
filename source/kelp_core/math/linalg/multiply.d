module kelp_core.math.linalg.multiply;

import kelp_core.math.linalg;

public:
Vector!(Row, Type) multiply(
M : Matrix!(Row, Col, Type),
V:
	Vector!(Row, Type),
	size_t Row, size_t Col, Type,
)(in M mat, in V vec) pure nothrow @nogc @safe
{
	scope Vector!(Row, Type) result_vec;
	foreach (row; 0 .. Row)
	{
		result_vec.data[row] = 0.0;
		foreach (col; 0 .. Col)
		{
			result_vec.data[row] += mat[row, col] * vec[row];
		}
	}
	return result_vec;
}

Vector!(Row, Type) multiply(
M : Matrix!(Row, Col, Type),
V:
	Vector!(Col, Type),
	size_t Row, size_t Col, Type,
)(in V vec, in M mat,) pure nothrow @nogc @safe
{
	scope Vector!(Col, Type) result_vec;
	foreach (col; 0 .. Col)
	{
		result_vec.data[col] = 0.0;
		foreach (row; 0 .. Row)
		{
			result_vec.data[col] += vec[col] * mat[row, col];
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
	assert(multiply(mat, vec) == Vector!(4)(1f, 4f, 9f, 1f));
	assert(multiply(vec, mat) == Vector!(4)(1f, 4f, 9f, 1f));
}
