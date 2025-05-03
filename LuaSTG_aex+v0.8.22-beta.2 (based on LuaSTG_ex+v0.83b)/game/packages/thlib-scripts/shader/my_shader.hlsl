// 引擎参数
SamplerState screen_texture_sampler : register(s4);// RenderTarget 纹理的采样器
Texture2D screen_texture : register(t4);// RenderTarget 纹理

cbuffer engine_data : register(b1)
{
    float4 screen_texture_size;
    float4 viewport;
};

// 用户参数
cbuffer user_data : register(b0)
{
    float4 user_data_0;  // 用于存储时间和其他参数
    float4 user_data_1;  // 用于存储颜色
    float4 user_data_2;  // 用于存储位置
    float4 user_data_3;  // 用于存储矩形
};

// 常量定义
static const float PI = 3.14159265f;
static const float REPEAT = 5.0f;

// 辅助函数
float2 rot(float a, float2 p)
{
    float c = cos(a), s = sin(a);
    return float2(
        p.x * c - p.y * s,
        p.x * s + p.y * c
    );
}

float sdBox(float3 p, float3 b)
{
    float3 q = abs(p) - b;
    return length(max(q, 0.0f)) + min(max(q.x, max(q.y, q.z)), 0.0f);
}

float box(float3 pos, float scale)
{
    pos *= scale;
    float base = sdBox(pos, float3(0.4f, 0.4f, 0.1f)) / 1.5f;
    pos.xy *= 5.0f;
    pos.y -= 3.5f;
    pos.xy = rot(0.75f, pos.xy);
    return -base;
}

float box_set(float3 pos, float time)
{
    float3 pos_origin = pos;
    
    // Box 1
    pos = pos_origin;
    pos.y += sin(time * 0.4f) * 2.5f;
    pos.xy = rot(0.8f, pos.xy);
    float box1 = box(pos, 2.0f - abs(sin(time * 0.4f)) * 1.5f);
    
    // Box 2
    pos = pos_origin;
    pos.y -= sin(time * 0.4f) * 2.5f;
    pos.xy = rot(0.8f, pos.xy);
    float box2 = box(pos, 2.0f - abs(sin(time * 0.4f)) * 1.5f);
    
    // Box 3
    pos = pos_origin;
    pos.x += sin(time * 0.4f) * 2.5f;
    pos.xy = rot(0.8f, pos.xy);
    float box3 = box(pos, 2.0f - abs(sin(time * 0.4f)) * 1.5f);
    
    // Box 4
    pos = pos_origin;
    pos.x -= sin(time * 0.4f) * 2.5f;
    pos.xy = rot(0.8f, pos.xy);
    float box4 = box(pos, 2.0f - abs(sin(time * 0.4f)) * 1.5f);
    
    // Box 5 & 6
    pos = pos_origin;
    pos.xy = rot(0.8f, pos.xy);
    float box5 = box(pos, 0.5f) * 6.0f;
    pos = pos_origin;
    float box6 = box(pos, 0.5f) * 6.0f;
    
    return max(max(max(max(max(box1, box2), box3), box4), box5), box6);
}

float map(float3 pos, float time)
{
    return box_set(pos, time);
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
    // 获取时间和分辨率
    float time = user_data_0.x;
    float2 resolution = screen_texture_size.xy;
    
    // 计算UV坐标
    float2 p = (input.uv * 2.0f - 1.0f) * float2(resolution.x/resolution.y, 1.0f);
    
    // 设置射线起点和方向
    float3 ro = float3(0.0f, -0.2f, time * 4.0f);
    float3 ray = normalize(float3(p, 1.5f));
    ray.xy = rot(sin(time * 0.03f) * 5.0f, ray.xy);
    ray.yz = rot(sin(time * 0.05f) * 0.2f, ray.yz);
    
    float t = 0.1f;
    float3 col = float3(0.0f, 0.0f, 0.0f);
    float ac = 0.0f;
    
    // 光线步进
    for (int i = 0; i < 99; i++)
    {
        float3 pos = ro + ray * t;
        pos = fmod(pos - 2.0f, 4.0f) - 2.0f;
        float gTime = time - float(i) * 0.01f;
        
        float d = map(pos, time);
        d = max(abs(d), 0.01f);
        ac += exp(-d * 23.0f);
        
        t += d * 0.55f;
    }
    
    col = float3(ac * 0.02f, ac * 0.02f, ac * 0.02f);
    col += float3(0.0f, 0.2f * abs(sin(time)), 0.5f + sin(time) * 0.2f);
    
    PS_Output output;
    output.col = float4(col, 1.0f - t * (0.02f + 0.02f * sin(time)));
    return output;
}