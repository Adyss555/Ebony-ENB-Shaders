

float3 applyLetterbox(float3 Color, float2 coord)
{
	if(coord.x > 1.0 - vBoxSize || coord.y < hBoxSize)
	{
		Color = BoxColor;
	}
	if (coord.y > 1.0 - hBoxSize || coord.x < vBoxSize)
	{
		Color = BoxColor;
	}

	return Color;
}
