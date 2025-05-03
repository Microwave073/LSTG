// 由PostEffect过程捕获到的纹理
texture2D ScreenTexture:POSTEFFECTTEXTURE;  // 纹理
sampler2D ScreenTextureSampler = sampler_state {  // 采样器
    texture = <ScreenTexture>;
    AddressU  = BORDER;
    AddressV = BORDER;
    Filter = MIN_MAG_LINEAR_MIP_POINT;
};

// 自动设置的参数
float4 screen : SCREENSIZE;  // 屏幕缓冲区大小

float timer < string binding = "timer"; > = 0.f;  // 外部计时器
float _den < string binding = "_den"; > = 0.f;  // 

float _AlphaFadeIn = 0.25;//水波的淡入位置
float _AlphaFadeOut = 1.0;	//水波的淡出位置
//以下代码改自BE的体积云，感谢BE
float3 Light(float den,float3 lightColor)
{
	return lightColor * (1.0-0.4*den);
}

float3 Shadow(float3 col,float2 tuv)
{
	float t = tuv.y;
	float gray = t * 0.9 + 0.1;
	gray *= 2.0;
	
	gray = clamp(gray,0.0,1.0);
	return gray * col;
}

float4 PS_MainPass(float4 position:POSITION,float2 uv:TEXCOORD0):COLOR 
{
	float4 col = tex2D(ScreenTextureSampler,uv);
	
	float denAdd = (uv.y) * 0.15 * col.r;
	col += float4(denAdd,denAdd ,denAdd ,denAdd );
	float  gl_Color=0.5*abs(sin(timer/100));
	float4 texColor =  col* gl_Color;
	
	float4 _tex = tex2D(ScreenTextureSampler,uv);
	float den=+_tex.r*(_den+_den/3*sin(timer/100));
	float3 tex_rgb=(texColor.r,texColor.g,texColor.b);
	float3 colo = Light(den,tex_rgb);
	colo = Shadow(col,uv);
	
	texColor= float4(colo,clamp(den*4.0,0,1.0));
	float fadeA = saturate((_AlphaFadeOut - uv.y) / (_AlphaFadeOut - _AlphaFadeIn));
                texColor = texColor * fadeA;
				clip(texColor.a - 0.01);	//随y轴降低透明度降低
	return texColor;
}

technique Main
{
    pass MainPass
    {
        PixelShader = compile ps_3_0 PS_MainPass();
    }
}






