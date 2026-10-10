module dulse.math.transform.scaling;

import dulse.math.linalg;

Matrix!(
	Size + ((Homogeneous) ? 1 : 0),
	Size + ((Homogeneous) ? 1 : 0),
	Type,
) matrix_scaling(
	bool Homogeneous = false,
	size_t Size, Type,
)(in Vector!(Size, Type) vec) pure nothrow @nogc @safe
{
	return matrix_scaling!Homogeneous(vec);
}

Matrix!(Size, Size, Type) matrix_scaling(
	bool Homogeneous : false,
	size_t Size, Type,)(
	in Vector!(Size, Type) vec) pure nothrow @nogc @safe
{
	scope Matrix!(Size, Size, Type) temp;
	temp.identify();
	foreach (index; 0 .. Size)
	{
		temp[index, index] = vec[index];
	}
	return temp;
}

Matrix!(Size + 1, Size + 1, Type) matrix_scaling(
	bool Homogeneous : true,
	size_t Size, Type,)(
	in Vector!(Size, Type) vec) pure nothrow @nogc @safe
{
	scope Matrix!(Size + 1, Size + 1, Type) temp;
	temp.identify();
	foreach (index; 0 .. Size)
	{
		temp[index, index] = vec[index];
	}
	return temp;
}

unittest
{
	//Matrix!(3, 3) mat_scale = ;
	assert(matrix_scaling(Vector!(3)([1.0f, 2.0f, 3.0f])) == [
			[1.0f, 0.0f, 0.0f,],
			[0.0f, 2.0f, 0.0f,],
			[0.0f, 0.0f, 3.0f,],
		]
	);
	assert(
		matrix_scaling!true(Vector!(3)([1.0f, 2.0f, 3.0f]))
			== [
				[1.0f, 0.0f, 0.0f, 0f,],
				[0.0f, 2.0f, 0.0f, 0f,],
				[0.0f, 0.0f, 3.0f, 0f,],
				[0f, 0f, 0f, 1f,]
			]
	);
}
