// Letterbox/Vingette Shader by Adyss

float3 applyLetterbox(float3 color, float2 coord)
{
	float2 oriCoord = coord;

	if (boxRotation > 0.0)
	{
	float 	 rotSin 		= sin(boxRotation);
	float	 rotCos 		= cos(boxRotation);
    float2x2 rotationMatrix = float2x2(rotCos, -rotSin, rotSin, rotCos);
			 rotationMatrix *= 0.5; // Matrix Correction to fix on center point
			 rotationMatrix += 0.5;
			 rotationMatrix = rotationMatrix * 2 - 1;
	float2	 rotationCoord  = mul(coord - 0.5, rotationMatrix);
			 rotationCoord += 0.5;
			 coord 			= rotationCoord;
	}

	if(enableLetterbox)
	{
		coord.x = smoothstep(vBoxSize, 1 - vBoxSize, coord.x);
		coord.y = smoothstep(hBoxSize, 1 - hBoxSize, coord.y);
	}

	if(!enableVingette) // Fallback to old system
	{
		if((coord.x == 0.0 || coord.x == 1.0) && enableLetterbox)
		{
			color = 0.0;
		}
		if ((coord.y == 0.0 || coord.y == 1.0) && enableLetterbox)
		{
			color = 0.0;
		}
	}

	if(enableVingette)
	color *= pow(16.0 * coord.x * coord.y * (1.0 - coord.x) * (1.0 - coord.y), vingetteIntesity); // fast and simpel

	return color;
}
