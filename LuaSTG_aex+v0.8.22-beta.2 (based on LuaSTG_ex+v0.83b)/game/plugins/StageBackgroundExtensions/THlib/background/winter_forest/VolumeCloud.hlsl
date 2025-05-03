// 引擎参数不可修改
SamplerState screen_texture_sampler : register(s4); //纹理采样器
Texture2D screen_texture            : register(t4); // rt纹理
cbuffer engine_data : register(b1)
{
	float4 screen_texture_size; // 纹理大小
	float4 viewport;            // 视口
};

// 用户传递的浮点参数
cbuffer user_data : register(b0)
{
	float4 user_data_0; 
};

// 常量
static const float _AlphaFadeIn = 0.25;  // 水波的淡入位置
static const float _AlphaFadeOut = 1.0;   // 水波的淡出位置

// 辅助函数
float3 Light(float den, float3 lightColor)
{
	return lightColor * (1.0 - 0.4 * den);
}

float3 Shadow(float3 col, float2 tuv)
{
	float t = tuv.y;
	float gray = t * 0.9 + 0.1;
	gray *= 2.0;
	
	gray = clamp(gray,0.0,1.0);
	return gray * col;
}

// 主函数
struct PS_Input
{
	float4 sxy : SV_Position;
	float2 uv  : TEXCOORD0;
	float4 col : COLOR0;
};

struct PS_Output
{
	float4 col : SV_Target;
};

PS_Output main(PS_Input input)
{
	float2 xy = input.uv * screen_texture_size.xy;  
	if (xy.x < viewport.x || xy.x > viewport.z || xy.y < viewport.y || xy.y > viewport.w)
	{
		discard; // 抛弃不需要的像素
	}

	float4 col = screen_texture.Sample(screen_texture_sampler, input.uv);
	
	float timer = user_data_0.x;
	float _den = user_data_0.y;
	
	float denAdd = (input.uv.y) * 0.15 * col.r;
	col += float4(denAdd, denAdd, denAdd, denAdd);
	float gl_Color = 0.5 * abs(sin(timer/100));
	float4 texColor = col * gl_Color;
	
	float4 _tex = screen_texture.Sample(screen_texture_sampler, input.uv);
	float den = _tex.r * (_den + _den/3 * sin(timer/100));
	float3 tex_rgb = float3(texColor.r, texColor.g, texColor.b);
	float3 colo = Light(den, tex_rgb);
	colo = Shadow(col.rgb, input.uv);
	
	texColor = float4(colo, clamp(den * 4.0, 0, 1.0));
	float fadeA = saturate((_AlphaFadeOut - input.uv.y) / (_AlphaFadeOut - _AlphaFadeIn));
	texColor = texColor * fadeA;
	
	if (texColor.a < 0.01)
	{
		discard; // 替代clip函数
	}

	PS_Output output;
	output.col = texColor;
	return output;
}






