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
float playerX < string binding = "playerX"; > = 0.f; 
float _AlphaFadeIn = 0.25;//水波的淡入位置
float _AlphaFadeOut = 1.0;	//水波的淡出位置
float2 params = float2(2, 4.4);	//Params = (频率/Hz, 每单位距离生成的波纹数)
static float centerX = 0; //水波中心x轴初始值
float centerXmax = 0.8; //水波中心最大x轴偏移
// 单个波纹生成
float wave(float2 pos, float t, float freq, float numWaves, float2 center) {
	float d = length(pos - center);
	d = log(1.0 + exp(d));
	return 1.0/(1.0+20.0*d*d) * sin(2.0*3.1415*(-numWaves*d + t*freq));
}

// 两个波纹合成
float height(float2 pos, float t) {
	float w;
	centerX=lerp(centerX,playerX/192*centerXmax,0.95);
	w =  wave(pos, t, params.x, params.y,float2(-centerX/2, -2.0));
	w += wave(pos, t, params.x, params.y,float2(centerX, 2.0));
	return w;
}

// 离散化
float2 normal(float2 pos, float t) {
	return 	float2(height(pos - float2(0.01, 0), t) - height(pos, t), 
				 height(pos - float2(0, 0.01), t) - height(pos, t));
}
//主函数
float4 PS_MainPass(float4 position:POSITION,float2 uv:TEXCOORD0):COLOR 
{
	float2 uvn = 2.0*uv - float2(1.0,1.0);	
	uv += normal(uvn, timer/120);
	float4 texColor = tex2D(ScreenTextureSampler,float2(0.7-uv.x, uv.y));
	float fadeA = saturate((_AlphaFadeOut - uv.y) / (_AlphaFadeOut - _AlphaFadeIn));
                texColor = texColor * fadeA;
				clip(texColor.a - 0.01);	//随y轴降低透明度降低，模拟水面反光效果
	return texColor;
}

technique Main
{
    pass MainPass
    {
        PixelShader = compile ps_3_0 PS_MainPass();
    }
}




