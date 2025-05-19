local sanae_sp_ef, sanae_trail, sanae_frog, sanae_frog_ef, sanae_trail_ef, sanae_bullet, sanae_bullet_ef, sanae_trail_hit
sanae_player = Class(player_class)

function sanae_player:init()
    LoadTexture('sanae_player', 'THlib/player/sanae/sanae.png')
    LoadTexture('sanae_walk', 'THlib/player/sanae/sanae_walk.png')
    LoadTexture('sanae_walk2', 'THlib/player/sanae/sanae_walk2.png')
    LoadImageGroup('sanae_player', 'sanae_walk', 0, 0, 48, 60, 8, 3, 0, 0)
    LoadTexture('sanae_ef1', 'THlib/player/sanae/sanae_ef1.png')
    LoadTexture('sanae_ef2', 'THlib/player/sanae/sanae_ef2.png')
    LoadTexture('sanae_ef3', 'THlib/player/sanae/sanae_ef3.png')

    LoadAnimation('sanae_trail_bullet', 'sanae_player', 0, 160, 64, 16, 4, 1, 4)
    SetAnimationCenter('sanae_trail_bullet', 48, 8)
    LoadImage('sanae_bullet', 'sanae_player', 192, 176, 64, 16, 10, 10)
    SetImageCenter('sanae_bullet', 56, 8)
    SetImageState('sanae_bullet', '', Color(0x70FFFFFF))
    LoadAnimation('sanae_bullet_ef', 'sanae_player', 192, 192, 16, 16, 4, 1, 4)
    SetAnimationState('sanae_bullet_ef', '', Color(0x70FFFFFF))

    LoadImage('sanae_frog_bullet', 'sanae_player', 0, 176, 32, 32, 32, 32)
    LoadAnimation('sanae_frog_bullet_ef', 'sanae_player', 0, 224, 32, 32, 4, 1, 4)

    LoadImage('sanae_support', 'sanae_player', 64, 144, 16, 16)

    LoadImage('sanae_trail_ef', 'sanae_player', 32, 144, 16, 16)
    SetImageState('sanae_trail_ef', 'mul+add', Color(0x75FFFFFF))
    LoadPS('sanae_trail_hit', 'THlib/player/sanae/sanae_trail_hit.psi', 'parimg10')

    LoadImage('sanae_ef1', 'sanae_ef1', 0, 0, 100, 100, 100, 100)
    SetImageState('sanae_ef1', 'mul+add', Color(0x100FFFFFF))
    LoadImage('sanae_ef2', 'sanae_ef2', 0, 0, 100, 100, 100, 100)
    SetImageState('sanae_ef2', 'mul+add', Color(0x100FFFFFF))
    LoadImage('sanae_ef3', 'sanae_ef3', 0, 0, 100, 100, 100, 100)
    SetImageState('sanae_ef3', 'mul+add', Color(0x100FFFFFF))

    player_class.init(self)
    self.imgs = {}
    for i = 1, 24 do
        self.imgs[i] = 'sanae_player' .. i
    end
    self.A = 0.6
    self.B = 0.6
    self.hspeed = 4.5
    self.lspeed = 2
    self.slist = {{nil, nil, nil, nil}, {{0, 36, 0, 20, 90}, nil, nil, nil},
                  {{-40, 20, -40, 0, 120}, {40, 20, 40, 0, 60}, nil, nil},
                  {{-40, 20, -40, 0, 120}, {40, 20, 40, 0, 60}, {0, 36, 0, 20, 90}, nil},
                  {{-40, 20, -40, 0, 120}, {40, 20, 40, 0, 60}, {-20, 40, -20, 30, 105}, {20, 40, 20, 30, 75}},
                  {{-40, 20, -40, 0, 120}, {40, 20, 40, 0, 60}, {-20, 40, -20, 30, 105}, {20, 40, 20, 30, 75}}}
    self.anglist = {{nil, nil, nil, nil}, {90, nil, nil, nil}, {100, 80, nil, nil}, {110, 70, 90, nil},
                    {120, 60, 100, 80}}
    self.mdlist = {{nil, nil, nil, nil}, {0, nil, nil, nil}, {0, 0, nil, nil}, {0, 0, 12, nil}, {0, 0, 12, 12}}
end
function sanae_player:shoot()
    if self.timer % 4 == 0 then
        New(sanae_bullet, 'sanae_bullet', self.x + 10, self.y, 24, 90, 2.0)
        New(sanae_bullet, 'sanae_bullet', self.x - 10, self.y, 24, 90, 2.0)
        PlaySound('plst00', 0.15, self.x / 1024)
    end
    if self.slow == 1 then
        if self.timer % 8 == 0 then
            for i = 1, 4 do
                if self.sp[i] and self.sp[i][3] > 0.5 then
                    New(sanae_trail, self.supportx + self.sp[i][1] - 4, self.supporty + self.sp[i][2] + 16, 10, 90, 0.8)
                    New(sanae_trail, self.supportx + self.sp[i][1] + 4, self.supporty + self.sp[i][2] + 16, 10, 90, 0.8)
                end
            end
        end
    else
        local n = min(int(lstg.var.power / 100) + 1, 5)
        for i = 1, 4 do
            if self.sp[i] and self.sp[i][3] > 0.5 and self.timer % 24 == self.mdlist[n][i] then
                New(sanae_frog, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 8,
                    self.anglist[n][i] + 20, 1.2)
                New(sanae_frog, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 8,
                    self.anglist[n][i] - 20, 1.2)
                New(sanae_frog, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 8,
                    self.anglist[n][i] + 10, 1.2)
                New(sanae_frog, self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 8,
                    self.anglist[n][i] - 10, 1.2)
            end
        end
    end
end

function sanae_player:spell()
    self.collect_line = -224
    PlaySound('ch00', 1.0)
    PlaySound('slash', 1.0)
    misc.ShakeScreen(210, 3)
    New(tasker, function()
        for i = 1, 1 do
            New(sanae_sp_ef, 'sanae_ef1', self.x + 25 * cos(90), self.y + 25 * sin(90), 0, 0, 1)
            New(sanae_sp_ef, 'sanae_ef2', self.x + 25 * cos(210), self.y + 25 * sin(210), 0, 0, 1)
            New(sanae_sp_ef, 'sanae_ef3', self.x + 25 * cos(330), self.y + 25 * sin(330), 0, 0, 1)
        end
        task.Wait(100)
        PlaySound('enep02', 1.0)
    end)
    New(tasker, function()
        task.Wait(30)
        self.collect_line = 100
    end)
    self.nextspell = 270
    self.protect = 360
end

function sanae_player:frame()
    player_class.frame(self)
end

function sanae_player:render()
    local rate = (1 + 0.1 * sin(self.timer * 10))
    SetImageState('sanae_support', 'mul+add', Color(0x80FFFFFF))
    for i = 1, 4 do
        if self.sp[i] then
            Render('sanae_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 0,
                self.sp[i][3] * 1.4 * rate, 1.4 * rate)
        end
    end
    SetImageState('sanae_support', '', Color(0xFFFFFFFF))
    for i = 1, 4 do
        if self.sp[i] then
            Render('sanae_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 0,
                self.sp[i][3] * rate, 1 * rate)
        end
    end
    player_class.render(self)
end

-------------------------------------------------
-------
sanae_sp_ef = Class(object)
function sanae_sp_ef:init(img, x, y, v, angle, dmg)
    self.killflag = 1
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.vscale = 1.2
    self.hscale = 1.2
    self.a = self.a * 1.2
    self.b = self.b * 1.2
    self.x = x
    self.y = y
    self.rot = angle
    self.angle = angle
    self.v = v
    self.dmg = dmg
    self.DMG = dmg
    self.bound = false
    SetImgState(self, 'mul+add', 255, 255, 255, 255)
end
function sanae_sp_ef:frame()
    if self.timer < 100 then
        self.dmg = 0.5 * self.DMG
        self.a = self.timer * 1
        self.b = self.timer * 1
        self.vscale = self.timer * 0.01
        self.hscale = self.timer * 0.01
        for i, o in ObjList(GROUP_ENEMY_BULLET) do
            if Dist(self, o) < 5 then
                Kill(o)
            end
        end
    end
    if self.timer > 100 and self.timer < 200 then
        self.dmg = 1.5 * self.DMG
        self.a = (self.timer - 99) * 50
        self.b = (self.timer - 99) * 50
        self.vscale = (self.timer - 99) * 0.5
        self.hscale = (self.timer - 99) * 0.5
        SetImgState(self, 'mul+add', 255 - 255 * ((self.timer - 100) / 100), 255, 255, 255)
        for i, o in ObjList(GROUP_ENEMY_BULLET) do
            if self.timer > 100 then
                if Dist(self, o) < (self.timer - 99) * 30 then
                    Kill(o)
                end
            end
        end
    end
    if self.timer > 200 then
        Del(self)
    end
    task.Do(self)
end
----------
sanae_trail = Class(object)
function sanae_trail:init(x, y, v, rot, dmg)
    self.img = 'sanae_trail_bullet'
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.x = x
    self.y = y
    self.dmg = dmg
    self.a = 20
    self.b = 10
    self.rect = true
    self.rot = rot
    self.vx = v * cos(self.rot)
    self.vy = v * sin(self.rot)
    self.v = v
    self.flag = 0
    self.killflag = false
    SetImgState(self, 'mul+add', 255, 255, 255, 255)
end

function sanae_trail:frame()
    if self.flag == 0 then
        for i, o in ObjList(GROUP_ENEMY) do
            if o.colli then
                if abs(o.y - self.y) <= 10 then
                    self.vx = 30 * (abs(o.x - self.x) / (o.x - self.x))
                    self.vy = 0
                    self.navi = true
                    New(sanae_trail_ef, 'sanae_trail_ef', self.x, self.y)
                    self.flag = 1
                    self.hscale = 1
                    break
                elseif abs(o.y - self.y) <= 35 then
                    self.hscale = abs(o.y - self.y) / 35
                end
            end
        end
        for i, o in ObjList(GROUP_NONTJT) do
            if o.colli then
                if abs(o.y - self.y) <= 10 then
                    self.vx = 30 * (abs(o.x - self.x) / (o.x - self.x))
                    self.vy = 0
                    self.navi = true
                    New(sanae_trail_ef, 'sanae_trail_ef', self.x, self.y)
                    self.flag = 1
                    self.hscale = 1
                    break
                elseif abs(o.y - self.y) <= 35 then
                    self.hscale = abs(o.y - self.y) / 35
                end
            end
        end
    end
end

function sanae_trail:kill()
    if self.flag == 0 then
        New(sanae_trail_ef, 'sanae_trail_ef', self.x, self.y)
    end
    New(sanae_trail_hit, self.x, self.y, self.rot)
end
----------
----
sanae_frog = Class(object)

function sanae_frog:init(x, y, v, rot, dmg)
    self.img = 'sanae_frog_bullet'
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.x = x
    self.y = y
    self.dmg = dmg
    self.a = 30
    self.b = 30
    self.rot = rot
    self.vx = v * cos(self.rot)
    self.vy = v * sin(self.rot)
    self.v = v
    SetImgState(self, 'mul+add', 255, 255, 255, 255)
end
function sanae_frog:frame()
    self.vscale, self.hscale = 1.2 + 0.1 * sin(self.timer * 12), 1.2 + 0.1 * sin(self.timer * 12)
end

function sanae_frog:kill()
    PlaySound('msl2', 0.3)
    New(sanae_frog_ef, self.x, self.y, self.dmg / 3)
end

sanae_frog_ef = Class(object)

function sanae_frog_ef:init(x, y, dmg)
    self.x = x
    self.y = y
    self.a = 16
    self.b = 16
    self.img = 'sanae_frog_bullet_ef'
    self.group = GROUP_PLAYER_BULLET
    self.dmg = dmg
    self.killflag = true
    self.layer = LAYER_PLAYER_BULLET
end

function sanae_frog_ef:frame()
    local size = 1 + self.timer / 15 * 2
    self.hscale, self.vscale = size, size
    self.a, self.b = size * 16, size * 16
    if self.timer >= 15 then
        Del(self)
    end
end

sanae_trail_ef = Class(object)
function sanae_trail_ef:init(img, x, y)
    self.img = img
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET + 1
    self.x = x
    self.y = y
end

function sanae_trail_ef:frame()
    self.hscale, self.vscale = 2 - (self.timer / 5), 2 - (self.timer / 5)
    if self.timer > 5 then
        Del(self)
    end
end
----------
sanae_bullet = Class(player_bullet_straight)

function sanae_bullet:kill()
    New(sanae_bullet_ef, self.x, self.y, self.rot)
end

sanae_bullet_ef = Class(object)

function sanae_bullet_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = 1.5 * cos(rot)
    self.vy = 1.5 * sin(rot)
    self.img = 'sanae_bullet_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
end

function sanae_bullet_ef:frame()
    local size = 1 + self.timer / 15 * 1.5
    self.hscale, self.vscale = size, size
    if self.timer >= 15 then
        Del(self)
    end
end

----------
sanae_trail_hit = Class(object)

function sanae_trail_hit:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot + 180
    self.vx = 1 * cos(rot)
    self.vy = 1 * sin(rot)
    self.img = 'sanae_trail_hit'
    self.layer = LAYER_PLAYER_BULLET + 50
end

function sanae_trail_hit:frame()
    if self.timer == 3 then
        ParticleStop(self)
    end
    if self.timer == 45 then
        Del(self)
    end
end

AddPlayerToPlayerList("Kochiya sanae", "sanae_player", "sanae")