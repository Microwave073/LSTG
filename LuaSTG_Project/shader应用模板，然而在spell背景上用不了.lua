spellcard2_background=Class(background) --构建一个名叫simple_background的对象

-- 定义背景图层常量
LAYER_BG = -700

function spellcard2_background:init() --这个背景对象被初始化时调用的方法
    background.init(self,false)
    --设置3D属性
    Set3D('eye',0,0,0)
    Set3D('at',1,0,0) 
    Set3D('up',0,1,0)
    Set3D('z',0.1,24) 
    Set3D('fovy',0.7)
    Set3D('fog',5,10,Color(255,255,255,255))
    
    -- 设置背景图层
    self.layer = LAYER_BG
    
    -- 创建渲染目标
    lstg.CreateRenderTarget("rt:background")
    lstg.CreateRenderTarget("rt:shader")
    
    -- 加载shader
    self.shader = lstg.LoadFX("my_shader.hlsl")
    
    -- 初始化shader参数
    self.shader_time = 0
end

function spellcard2_background:frame() 
    -- 更新shader时间参数
    self.shader_time = self.shader_time + 1/60
end

function spellcard2_background:render() 
    -- 渲染背景到渲染目标
    lstg.PushRenderTarget("rt:background")
    -- 这里可以添加原始背景的渲染代码
    -- 例如：lstg.RenderRect("background_image", -192, 192, -240, 240)
    lstg.PopRenderTarget()
    
    -- 应用shader效果
    lstg.PushRenderTarget("rt:shader")
    lstg.PostEffect("my_shader.hlsl", "rt:background", 6, "mul+alpha", {
        -- 传递shader参数
        {self.shader_time, 0, 0, 0},  -- user_data_0: 时间
        {0, 0.2, 0.5, 1},            -- user_data_1: 颜色
        {0, 0, 0, 0},                -- user_data_2: 位置
        {0, 0, 0, 0}                 -- user_data_3: 矩形
    })
    lstg.PopRenderTarget()
    
    -- 渲染最终结果到屏幕
    lstg.RenderRect("rt:shader", -192, 192, -240, 240)
end 