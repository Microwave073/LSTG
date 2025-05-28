winter_forest_background = Class(background)

function winter_forest_background:init()
    background.init(self,false)
    LoadTexture('winter_forest','THlib/background/winter_forest/winter_forest.png')
    LoadImage('winter_forest','winter_forest',0,0,512,512)
    LoadTexture('snowflakes','THlib/background/winter_forest/snowflakes.png')
    LoadImage('snowflakes','snowflakes',0,0,20,20)
    SetImageState('snowflakes','mul+add',Color(0xFFFFFFFF))

    Set3D('eye',0,2,1) Set3D('at',0,0,2) Set3D('up',0,3,1) Set3D('z',0.5,20) Set3D('fovy',0.6) Set3D('fog',1.6,2.1,Color(180,160,170,220))
    self.yos=0 self.speed=0.004
    -- 初始化雪花
    self.snowflakes = {}
    self.max_snowflakes = 110
    self.t = 0
    
    for i=1,self.max_snowflakes do
        table.insert(self.snowflakes,{
            x = ran:Float(-0.8,0.8),
            y = ran:Float(0,2.5),
            z = ran:Float(1.5,3),    
            speed_z = ran:Float(0.004,0.006),  
            speed_y = ran:Float(0.002,0.004),  
            size = ran:Float(0.04,0.05),       
            angle = ran:Float(0,360),
            rot_speed = ran:Float(-2,2)
        })
    end
end

function winter_forest_background:frame()
    self.yos=self.yos-self.speed

    for i=1,#self.snowflakes do
        local snow = self.snowflakes[i]
        snow.y = snow.y - snow.speed_y * 0.5
        snow.z = snow.z - snow.speed_z
        snow.angle = snow.angle + snow.rot_speed

        if snow.y < -0.5 then  
            self.snowflakes[i] = {
                x = ran:Float(-0.8,0.8),
                y = ran:Float(2,2.5),
                z = ran:Float(0,1),       
                speed_z = ran:Float(0.004,0.006),
                speed_y = ran:Float(0.002,0.004),
                size = ran:Float(0.03,0.05),
                angle = ran:Float(0,360),
                rot_speed = ran:Float(-2,2)
            }
        end
    end
end

function winter_forest_background:render()
    SetViewMode'3d'
    background.WarpEffectCapture()
    RenderClear(Color(180,200,220,255))
    
    -- 渲染背景
    local y=self.yos%1
    for i=-1,5 do 
        for i2=-1,1 do
            Render4V('winter_forest',
            -0.5+i2,0.5,1.5+i+y,
            0.5+i2,0.5,1.5+i+y,
            0.5+i2,0.5,0.5+i+y,
            -0.5+i2,0.5,0.5+i+y)
        end
	end

    local view_dir = {
        x = lstg.view3d.at[1] - lstg.view3d.eye[1],
        y = lstg.view3d.at[2] - lstg.view3d.eye[2],
        z = lstg.view3d.at[3] - lstg.view3d.eye[3]
    }
    local right = {
        x = view_dir.y * lstg.view3d.up[3] - view_dir.z * lstg.view3d.up[2],
        y = view_dir.z * lstg.view3d.up[1] - view_dir.x * lstg.view3d.up[3],
        z = view_dir.x * lstg.view3d.up[2] - view_dir.y * lstg.view3d.up[1]
    }
    local right_len = math.sqrt(right.x^2 + right.y^2 + right.z^2)
    right.x, right.y, right.z = right.x/right_len, right.y/right_len, right.z/right_len
    
    local up = {
        x = lstg.view3d.up[1],
        y = lstg.view3d.up[2],
        z = lstg.view3d.up[3]
    }

    for i=1,#self.snowflakes do
        local snow = self.snowflakes[i]
        local half_size = snow.size * 0.5
        local base_z = snow.z % 1

        for j=-1,5 do
            local pos = {
                x = snow.x,
                y = snow.y,
                z = base_z + j
            }
            local fog_factor = math.max(0, math.min(1, (pos.z - 2) / 4))  
            local alpha = math.floor((1 - fog_factor) * 255)
            SetImageState('snowflakes','mul+add',Color(255,255,255,255))
            local angle = math.rad(snow.angle)
            local cos_a = math.cos(angle)
            local sin_a = math.sin(angle)
            local depth_scale = math.max(0.6, 1 - fog_factor * 0.4) 
            local scaled_size = half_size * depth_scale
            -- 旋转计算
            local p1x = pos.x - scaled_size * cos_a
            local p1y = pos.y - scaled_size * sin_a
            local p2x = pos.x + scaled_size * cos_a
            local p2y = pos.y + scaled_size * sin_a
            local p3x = pos.x + scaled_size * cos_a
            local p3y = pos.y + scaled_size * sin_a
            local p4x = pos.x - scaled_size * cos_a
            local p4y = pos.y - scaled_size * sin_a
            -- 渲染雪花
            Render4V('snowflakes',
                p1x, p1y, pos.z,
                p2x, p2y, pos.z,
                p3x, p3y - snow.size * depth_scale, pos.z,
                p4x, p4y - snow.size * depth_scale, pos.z
            )
        end
    end
    
    background.WarpEffectApply()
    SetViewMode'world'
end
