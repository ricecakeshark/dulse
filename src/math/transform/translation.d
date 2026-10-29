module dulse.math.transform.translation;

import dulse.math.linalg;

Matrix!(Size + 1, Size + 1, Type) matrix_translate(
	bool RowMajor = true,
	size_t Size, Type,
)(in Vector!(Size, Type) vec) pure nothrow @nogc @safe
{
	static if (RowMajor == true)
	{
		return matrix_translate_row(vec.data);
	}
	else
	{
		return matrix_translate_col(vec.data);
	}
}

Matrix!(Size + 1, Size + 1, Type) matrix_translate(
	bool RowMajor = true,
	size_t Size, Type,
)(in Type[Size] vec_data...) pure nothrow @nogc @safe
{
	static if (RowMajor == true)
	{
		return matrix_translate_row(vec_data);
	}
	else
	{
		return matrix_translate_col(vec_data);
	}
}

Matrix!(Size + 1, Size + 1, Type) matrix_translate_row(size_t Size, Type,
)(in Type[Size] vec...) pure nothrow @nogc @safe
{
	Matrix!(Size + 1, Size + 1) temp;
	temp.identify();
	foreach (index; 0 .. Size)
	{
		temp[Size, index] = vec[index];
	}
	return temp;
}

Matrix!(Size + 1, Size + 1, Type) matrix_translate_col(size_t Size, Type)(
	in Vector!(Size, Type) vec) pure nothrow @nogc @safe
{
	return matrix_translate_col(vec.data);
}

Matrix!(Size + 1, Size + 1, Type) matrix_translate_col(size_t Size, Type)(
	in Type[Size] vec...) pure nothrow @nogc @safe
{
	Matrix!(Size + 1, Size + 1, Type) temp;
	temp.identify();
	foreach (index; 0 .. 3)
	{
		temp[index, Size] = vec[index];
	}
	return temp;
}

unittest
{
	assert(
		matrix_translate!true(Vector!(3)([
				1.0f, 2.0f, 3.0f
			])) == [
			[1.0f, 0.0f, 0.0f, 0.0f,],
			[0.0f, 1.0f, 0.0f, 0.0f,],
			[0.0f, 0.0f, 1.0f, 0.0f,],
			[1.0f, 2.0f, 3.0f, 1.0f,],
		]
	);
	assert(
		matrix_translate!true(
			1.0f, 2.0f, 3.0f
	) == [
		[1.0f, 0.0f, 0.0f, 0.0f,],
		[0.0f, 1.0f, 0.0f, 0.0f,],
		[0.0f, 0.0f, 1.0f, 0.0f,],
		[1.0f, 2.0f, 3.0f, 1.0f,],
	]
	);
}
