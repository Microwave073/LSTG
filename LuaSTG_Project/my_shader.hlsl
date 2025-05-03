// 引擎参数
SamplerState screen_texture_sampler : register(s4);
Texture2D screen_texture : register(t4);
cbuffer engine_data : register(b1)
{
    float4 screen_texture_size;  // 纹理大小
    float4 viewport;            // 视口
};

// 用户参数
cbuffer user_data : register(b0)
{
    float4 center_pos;    // xy: 效果中心坐标
    float4 effect_color;  // rgba: 效果颜色
    float4 effect_param;  // x: 尺寸, y: 形变系数, z: 颜色扩散尺寸, w: 时间
};

// 常量
static const float PI = 3.14159265f;

// 辅助函数
float3 palette(float d)
{
    float3 a = float3(0.5f, 0.5f, 0.5f);
    float3 b = float3(0.5f, 0.5f, 0.5f);
    float3 c = float3(1.0f, 1.0f, 1.0f);
    float3 d_vec = float3(0.263f, 0.416f, 0.557f);
    return a + b * cos(6.28318f * (c * d + d_vec));
}

float2 rotate(float2 p, float a)
{
    float c = cos(a);
    float s = sin(a);
    return mul(float2x2(c, s, -s, c), p);
}

float map(float3 p, float time)
{
    float3 pos = p;
    float anim = time * 0.2f;  // 时间驱动动画
    
    for(int i = 0; i < 8; i++)
    {
        float t = anim;
        pos.xz = rotate(pos.xz, -t);
        pos.xy = rotate(pos.xy, t * 1.89f);
        pos.xz = abs(pos.xz);
        pos.xz -= 0.5f + sin(anim * 0.2f) * 0.1f;
    }
    return dot(sign(pos), pos) / 5.0f;
}

float4 raymarching(float3 ro, float3 rd, float time)
{
    float t = 0.0f;
    float3 col = float3(0.0f, 0.0f, 0.0f);
    float d;
    float anim = time * 0.2f;  // 时间驱动颜色变化
    
    [unroll(64)]
    for(int i = 0; i < 64; i++)
    {
        float3 p = ro + rd * t;
        d = map(p, time);
        
        if(d < 0.02f || d > 100.0f)
            break;
            
        float glow = exp(-d * 8.0f);
        col += palette(length(p) * 0.1f + anim * 0.2f) * glow * 0.2f;
        
        t += d;
    }
    return float4(col, 1.0f / (d * 100.0f));
}

// 主函数
struct PS_Input
{
    float4 sxy : SV_Position;
    float2 uv : TEXCOORD0;
    float4 col : COLOR0;
};

struct PS_Output
{
    float4 col : SV_Target;
};

PS_Output main(PS_Input input)
{
    // 检查视口范围
    float2 xy = input.uv * screen_texture_size.xy;
    if (xy.x < viewport.x || xy.x > viewport.z || xy.y < viewport.y || xy.y > viewport.w)
    {
        discard;
    }
    
    // 获取用户参数
    float2 center = center_pos.xy;  // 归一化坐标
    float time = effect_param.w;
    
    float2 screen_center = float2(center.x * screen_texture_size.x, center.y * screen_texture_size.y);
    float2 uv = (input.uv * 2.0f - 1.0f);
    uv.x *= screen_texture_size.x / screen_texture_size.y;
    
    // 设置相机位置和方向（左手坐标系）
    float3 ro = float3(0.0f, 0.0f, 50.0f);
    
    // 动态旋转相机（基于时间）
    float2 rot = float2(cos(time), sin(time));
    ro.xz = float2(ro.x * rot.x + ro.z * rot.y, -ro.x * rot.y + ro.z * rot.x);
    
    float3 cf = normalize(-ro);
    float3 cs = normalize(cross(float3(0.0f, 1.0f, 0.0f), cf));
    float3 cu = normalize(cross(cf, cs));
    
    float3 uuv = ro + cf * 3.0f + uv.x * cs + uv.y * cu;
    float3 rd = normalize(uuv - ro);
    
    // 光线步进
    float4 col = raymarching(ro, rd, time);
    
    // 混合纹理颜色
    float4 tex_color = screen_texture.Sample(screen_texture_sampler, input.uv);
    col = col * tex_color;
    col.a = 1.0f;
    
    PS_Output output;
    output.col = col;
    return output;
}