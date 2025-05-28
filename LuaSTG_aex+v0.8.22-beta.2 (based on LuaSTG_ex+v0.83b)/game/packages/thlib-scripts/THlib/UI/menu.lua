LoadImageFromFile("arrow", "THlib/UI/arrow.png")
LoadImageFromFile("sanae", "THlib/UI/sanae.png")
LoadImageFromFile("rin", "THlib/UI/rin.png")
LoadImageFromFile("sanae_intro", "THlib/UI/sanae_intro.png")
LoadImageFromFile("rin_intro", "THlib/UI/rin_intro.png")
LoadImageFromFile("mask", "THlib/UI/mask.png")
LoadImageFromFile("menu_flowers", "THlib/UI/flower1.png")
--给健忘症的提醒之ui模式下原点在左下角，world模式在中间
menu = {}

function menu:FlyIn(dir)
    self.alpha = 1
    if dir == 'left' then
        self.x = screen.width * 0.5 - screen.width
    elseif dir == 'right' then
        self.x = screen.width * 0.5 + screen.width
    end
    task.Clear(self)
    task.New(self, function()
        task.MoveTo(screen.width * 0.5, self.y, 20, 2)
        self.locked = false
    end)
end

function menu:FlyOut(dir)
    local x
    if dir == 'left' then
        x = screen.width * 0.5 - screen.width
    elseif dir == 'right' then
        x = screen.width * 0.5 + screen.width
    end
    task.Clear(self)
    if not self.locked then
        task.New(self, function()
            self.locked = true
            task.MoveTo(x, self.y, 20, 1)
        end)
    end
end

function menu:FadeIn()
    self.x = screen.width * 0.5
    task.Clear(self)
    task.New(self, function()
        for i = 0, 29 do
            self.alpha = i / 29
            task.Wait()
        end
        self.locked = false
    end)
end

function menu:FadeOut()
    task.Clear(self)
    if not self.locked then
        task.New(self, function()
            self.locked = true
            for i = 29, 0, -1 do
                self.alpha = i / 29
                task.Wait()
            end
        end)
    end
end

function menu:MoveTo(x1, y1, x2, y2, t, mode)
    self.x = x1 or self.x
    self.y = y1 or self.y
    task.Clear(self)
    task.New(self, function()
        task.MoveTo(x2 or self.x, y2 or self.y, t, mode)
    end)
end

sc_pr_menu = Class(object)

function sc_pr_menu:init(exit_func)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.exit_func = exit_func
    self.x = screen.width * 0.5 + screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.npage = max(int((#_sc_table - 1) / ui.menu.sc_pr_line_per_page) + 1, 1)
    self.page = 0
    self.pos = 1
    self.pos_changed = 0
end

function sc_pr_menu:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if GetLastKey() == setting.keys.up then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    if GetLastKey() == setting.keys.down then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    self.pos = (self.pos + ui.menu.sc_pr_line_per_page - 1) % ui.menu.sc_pr_line_per_page + 1
    if GetLastKey() == setting.keys.left then
        self.page = self.page - 1
        self.pos_changed = ui.menu.shake_time
        PlaySound('select00', 0.3)
    end
    if GetLastKey() == setting.keys.right then
        self.page = self.page + 1
        self.pos_changed = ui.menu.shake_time
        PlaySound('select00', 0.3)
    end
    self.page = (self.page + self.npage) % self.npage
    if KeyIsPressed 'shoot' then
        local index = self.pos + self.page * ui.menu.sc_pr_line_per_page
        if _sc_table[index] then
            if self.exit_func then
                self.exit_func(index)
            end
            PlaySound('ok00', 0.3)
        else
            PlaySound('invalid', 0.5)
        end
    elseif KeyIsPressed 'spell' then
        PlaySound('cancel00', 0.3)
        if self.exit_func then
            self.exit_func(nil)
        end
    end
end

function sc_pr_menu:render()
    --[[
        ui.DrawMenu('View Replay',self.text,self.pos,self.x,self.y+ui.menu.line_height,self.alpha,self.timer,self.pos_changed)
        SetFontState('menu','',Color(self.alpha*255,unpack(ui.menu.title_color)))
        RenderText('menu',string.format('<-  page %d/%d  ->',self.page+1,self.npage),self.x,self.y-5.5*ui.menu.line_height,ui.menu.font_size,'centerpoint')
        --]]
    SetViewMode('ui')
    SetImageState('white', '', Color(0xC0000000))
    RenderRect('white', self.x - ui.menu.sc_pr_width * 0.5 - ui.menu.sc_pr_margin,
            self.x + ui.menu.sc_pr_width * 0.5 + ui.menu.sc_pr_margin,
            self.y - ui.menu.sc_pr_line_height * (ui.menu.sc_pr_line_per_page + 2) * 0.5 - ui.menu.sc_pr_margin,
            self.y + ui.menu.sc_pr_line_height * (ui.menu.sc_pr_line_per_page + 2) * 0.5 + ui.menu.sc_pr_margin)
    local text1 = {}
    local text2 = {}
    local offset = self.page * ui.menu.sc_pr_line_per_page
    for i = 1, ui.menu.sc_pr_line_per_page do
        if _sc_table[i + offset] then
            text1[i] = _editor_class[_sc_table[i + offset][1]].name
            text2[i] = _sc_table[i + offset][2]
        else
            text1[i] = '---'
            text2[i] = '---'
        end
    end
    ui.DrawMenuTTF('sc_pr', '', text1, self.pos, self.x - ui.menu.sc_pr_width * 0.5, self.y, self.alpha, self.timer, self.pos_changed, 'left')
    ui.DrawMenuTTF('sc_pr', '', text2, self.pos, self.x + ui.menu.sc_pr_width * 0.5, self.y, self.alpha, self.timer, self.pos_changed, 'right')
    RenderTTF('sc_pr', 'Spell Practice', self.x, self.x, self.y + (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, self.y + (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, Color(self.alpha * 255, unpack(ui.menu.title_color)), 'centerpoint')
    RenderTTF('sc_pr', string.format('<-  page %d/%d  ->', self.page + 1, self.npage), self.x, self.x, self.y - (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, self.y - (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, Color(self.alpha * 255, unpack(ui.menu.title_color)), 'centerpoint')

end

simple_menu = Class(object)

function simple_menu:init(title, content, keyslot, offx)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.offx = offx or 0
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.title = title
    self.content = content
    self.text = {}
    self.func = {}
    for i = 1, #content do
        self.text[i] = content[i][1]
        self.func[i] = content[i][2]
    end
    self.pos = 1
    self.pos_pre = 1
    self.pos_changed = 0
    self.no_pos_change = false
    self.keyslot = keyslot
    if content[#content][1] == 'exit' then
        self.exit_func = content[#content][2]
        self.text[#content] = nil
        self.func[#content] = nil
    end

end

function simple_menu:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if GetLastKey(self.keyslot) == setting.keys.up and (not self.no_pos_change) then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.down and (not self.no_pos_change) then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    self.pos = (self.pos - 1 + #(self.text)) % (#(self.text)) + 1
    if KeyIsPressed('shoot', self.keyslot) and self.func[self.pos] then
        self.func[self.pos]()
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell', self.keyslot) and self.exit_func then
        self.exit_func()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos

end

function simple_menu:render()
    SetViewMode('ui')
    ui.DrawMenu(self.title, self.text, self.pos, self.x + self.offx, self.y, self.alpha, self.timer, self.pos_changed)
    
end

simple_image = Class(object)
function simple_image:init(img, size)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.img = img
    self.hscale = size
    self.vscale = size
    self.x = screen.width * 0.5 - 448
    self.y = screen.height * 0.5
    self.alpha = 1
end
function simple_image:frame()
    task.Do(self)
end
function simple_image:render()
    SetViewMode('ui')
    SetImageState(self.img, '', Color(self.alpha * 255, 255, 255, 255))
    object.render(self)
end

------------------------------------------------------------

LoadTTF("replayfnt", 'assets/font/SourceHanSansCN-Bold.otf', 30)
LoadImageFromFile('replay_title', 'THlib/UI/replay_title.png')
LoadImageFromFile('save_rep_title', 'THlib/UI/save_rep_title.png')

local REPLAY_USER_NAME_MAX = 8
local REPLAY_DISPLAY_FORMAT1 = "%02d %s %" .. tostring(REPLAY_USER_NAME_MAX) .. "s %012d"
local REPLAY_DISPLAY_FORMAT2 = "%02d ----/--/-- --:--:-- %" .. tostring(REPLAY_USER_NAME_MAX) .. "s %012d"

local function FetchReplaySlots()
    local ret = {}
    ext.replay.RefreshReplay()

    for i = 1, ext.replay.GetSlotCount() do
        local text = {}
        local slot = ext.replay.GetSlot(i)
        if slot then
            -- 使用第一关的时间作为录像时间
            local date = os.date("!%Y/%m/%d", slot.stages[1].stageDate + setting.timezone * 3600)

            -- 统计总分数
            local totalScore = 0
            local diff, stage_num = 0, 0
            local tmp
            for i, k in ipairs(slot.stages) do
                totalScore = totalScore + slot.stages[i].score
                diff = string.match(k.stageName, '^.+@(.+)$')
                tmp = string.match(k.stageName, '^(.+)@.+$')
                if string.match(tmp, '%d+') == nil then
                    stage_num = tmp
                else
                    stage_num = 'St' .. string.match(tmp, '%d+')
                end
            end
            if diff == 'Spell Practice' then
                diff = 'SpellCard'
            end
            if tmp == 'Spell Practice' then
                stage_num = 'SC'
            end
            if slot.group_finish == 1 then
                stage_num = 'All'
            end
            text = { string.format('No.%02d', i), slot.userName, date, slot.stages[1].stagePlayer, diff, stage_num }
        else
            text = { string.format('No.%02d', i), '--------', '----/--/--', '--------', '--------', '---' }
        end
        --[[
                    text = string.format(REPLAY_DISPLAY_FORMAT1, i, date, slot.userName, totalScore)
                else
                    text = string.format(REPLAY_DISPLAY_FORMAT2, i, "N/A", 0)
                end
            ]]
        table.insert(ret, text)
    end
    return ret
end

------------------replay_saver-------------------------
local _keyboard = {}
do
    for i = 65, 90 do
        table.insert(_keyboard, i)
    end
    for i = 97, 122 do
        table.insert(_keyboard, i)
    end
    for i = 48, 57 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 43, 45, 61, 46, 44, 33, 63, 64, 58, 59, 91, 93, 40, 41, 95, 47, 123, 125, 124, 126, 94 }) do
        table.insert(_keyboard, i)
    end
    for i = 35, 38 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 42, 92, 127, 34 }) do
        table.insert(_keyboard, i)
    end
end

replay_saver = Class(object)

function replay_saver:init(stages, finish, exitCallback)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5

    self.locked = true
    self.finish = finish or 0
    self.stages = stages
    self.exitCallback = exitCallback

    self.shakeValue = 0

    self.state = 0
    self.state1Selected = 1
    self.state1Text = FetchReplaySlots()
    self.state2CursorX = 0
    self.state2CursorY = 0
    self.state2UserName = ""
end

function replay_saver:frame()
    task.Do(self)
    if self.locked then
        return
    end

    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 跳转到录像保存状态
            self.state = 1
            --self.state2CursorX = 0
            --self.state2CursorY = 0
            --self.state2UserName = ""
            if scoredata.repsaver == nil then
                scoredata.repsaver = ""
            end
            self.state2UserName = scoredata.repsaver
            if self.state2UserName ~= "" then
                self.state2CursorX = 12
                self.state2CursorY = 6
            else
                self.state2CursorX = 0
                self.state2CursorY = 0
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state2CursorY = self.state2CursorY - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state2CursorY = self.state2CursorY + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.left then
            self.state2CursorX = self.state2CursorX - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.right then
            self.state2CursorX = self.state2CursorX + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            if self.state2CursorX == 12 and self.state2CursorY == 6 then
                if self.state2UserName == "" then
                    self.state2UserName = "Anonymous"
                else
                    scoredata.repsaver = self.state2UserName
                    SaveScoreData()
                end

                -- 保存录像
                ext.replay.SaveReplay(self.stages, self.state1Selected, self.state2UserName, self.finish)

                if self.exitCallback then
                    self.exitCallback()
                end
                PlaySound("extend", 0.5)
            end

            if #self.state2UserName == REPLAY_USER_NAME_MAX then
                self.state2CursorX = 12
                self.state2CursorY = 6
            elseif self.state2CursorX == 11 and self.state2CursorY == 6 then
                if #self.state2UserName == 0 then
                    self.state = 0
                else
                    self.state2UserName = string.sub(self.state2UserName, 1, -2)
                end
                PlaySound('cancel00', 0.3)
            elseif self.state2CursorX == 10 and self.state2CursorY == 6 then
                local char = string.char(0x20)
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            else
                local char = string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1])
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if #self.state2UserName == 0 then
                self.state = 0
            else
                self.state2UserName = string.sub(self.state2UserName, 1, -2)
            end
            --			self.state = 0
            PlaySound('cancel00', 0.3)
        end

        self.state2CursorX = (self.state2CursorX + 13) % 13
        self.state2CursorY = (self.state2CursorY + 7) % 7
    end
end

function replay_saver:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
                "replayfnt",
                "save_rep_title",
                self.state1Text,
                self.state1Selected,
                self.x,
                self.y,
                1,
                self.timer,
                self.shakeValue
        )
    elseif self.state == 1 then
        -- 先渲染输入内容
        SetFontState("replay", "", Color(255, unpack(ui.menu.keyboard_color)))
        RenderText("replay", self.state2UserName, self.x, self.y + 3.0 * ui.menu.keyboard_line_height, ui.menu.font_size, "centerpoint")
        
        Render("save_rep_title", self.x, self.y + 150)

        -- 未选中
        SetFontState("replay", "", Color(255, unpack(ui.menu.keyboard_color)))
        for x = 0, 12 do
            for y = 0, 6 do
                if x ~= self.state2CursorX or y ~= self.state2CursorY then
                    RenderText(
                            "replay",
                            string.char(_keyboard[y * 13 + x + 1]),
                            self.x + (x - 5.5) * ui.menu.char_width,
                            self.y - 2.5 * ui.menu.keyboard_line_height - (y - 3.5) * ui.menu.keyboard_line_height,
                            ui.menu.font_size,
                            'centerpoint'
                    )
                end
            end
        end
        -- 激活
        local color = {}
        local k = cos(self.timer * ui.menu.blink_speed) ^ 2
        for i = 1, 3 do
            color[i] = ui.menu.focused_color1[i] * k + ui.menu.focused_color2[i] * (1 - k)
        end
        SetFontState("replay", "", Color(255, unpack(color)))
        RenderText(
                "replay",
                string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1]),
                self.x + (self.state2CursorX - 5.5) * ui.menu.char_width + ui.menu.shake_range * sin(ui.menu.shake_speed * self.shakeValue),
                self.y - 2.5 * ui.menu.keyboard_line_height - (self.state2CursorY - 3.5) * ui.menu.keyboard_line_height,
                ui.menu.font_size,
                "centerpoint"
        )
    end
end
----------------------------------------------------------------------------
-------------------------replay_loader--------------------------------------
replay_loader = Class(object)

function replay_loader:init(exitCallback)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.x = screen.width * 0.5 + screen.width
    self.y = screen.height * 0.5

    -- 是否可操作
    self.locked = true

    self.exitCallback = exitCallback

    self.shakeValue = 0

    self.state = 0
    self.state1Selected = 1
    self.state1Text = {}
    self.state2Selected = 1
    self.state2Text = {}

    replay_loader.Refresh(self)
end

function replay_loader:Refresh()
    self.state1Text = FetchReplaySlots()
end

function replay_loader:frame()
    task.Do(self)
    if self.locked then
        return
    end

    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 构造关卡列表
            local slot = ext.replay.GetSlot(self.state1Selected)
            if slot ~= nil then
                self.state = 1
                self.state2Text = {}
                self.state2Selected = 1
                self.shakeValue = ui.menu.shake_time

                for i, v in ipairs(slot.stages) do
                    local stage = string.match(v.stageName, '^(.+)@.+$')
                    local score = string.format("%012d", v.score)
                    table.insert(self.state2Text, { stage, score })
                end
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        local slot = ext.replay.GetSlot(self.state1Selected)
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state2Selected = max(1, self.state2Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state2Selected = min(#slot.stages, self.state2Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 转场
            local slot = ext.replay.GetSlot(self.state1Selected)
            if self.exitCallback then
                self.exitCallback(slot.path, slot.stages[self.state2Selected].stageName)
            end
            PlaySound('ok00', 0.3)
        elseif KeyIsPressed("spell") then
            self.shakeValue = ui.menu.shake_time
            self.state = 0
        end
    end
end

function replay_loader:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
                "replayfnt",
                "replay_title",
                self.state1Text,
                self.state1Selected,
                self.x,
                self.y,
                1,
                self.timer,
                self.shakeValue
        )
    elseif self.state == 1 then
        ui.DrawRepText2(
                "replayfnt",
                "replay_title",
                self.state2Text,
                self.state2Selected,
                self.x,
                self.y + 120,
                1,
                self.timer,
                self.shakeValue,
                "center")
    end
end
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
    
petal_effect = Class(object)


function petal_effect:init()
    self.layer = LAYER_BG + 1
    self.group = GROUP_GHOST
    self.bound = false
    self.petal = {}
    for i = 1, 30 do
        self.petal[i] = {
            x = ran:Float(0, screen.width),
            y = ran:Float(0, screen.height),
            vx = ran:Float(-0.2, 0.2),   
            vy = ran:Float(-2, -1),     
            rot = ran:Float(0, 360),      
            omiga = ran:Float(-2, 2), --这是个自带的旋转速度参数    
            scale = ran:Float(0.2, 0.8),
            alpha = ran:Float(150, 255),
            img = "menu_flowers"
        }
    end
end

function petal_effect:frame()
    for _, p in ipairs(self.petal) do
        p.x = p.x + p.vx
        p.y = p.y + p.vy
        p.rot = p.rot + p.omiga 
        
        if p.y < 0 then
            p.y = screen.height
            p.x = ran:Float(0, screen.width)
            p.vy = ran:Float(-2, -1)
            p.vx = ran:Float(-0.2, 0.2)
        end
        if p.x < 0 then
            p.x = screen.width
        elseif p.x > screen.width then
            p.x = 0
        end
    end
end

function petal_effect:render()
    SetViewMode("ui")
    for _, p in ipairs(self.petal) do
        SetImageState(p.img, "", Color(p.alpha, 255, 255, 255))
        Render(p.img, p.x, p.y, p.rot, p.scale, p.scale)
    end
end

player_menu = Class(object)

function player_menu:init(title, content, keyslot, offx)
    simple_menu.init(self, title, content, keyslot, offx)
    self.x = screen.width * 0.5
    self.alpha = 0
    self.AA = {}
    for i = 1, #content - 1 do
        self.AA[i] = 0
    end
    self.AA[1] = 1
    self.alpha1 = 0
end

function player_menu:frame()
    simple_menu.frame(self)
    for i = 1, #self.AA do
        if i == self.pos then
            self.AA[i] = (self.AA[i] * 5 + 1) / 6
        else
            self.AA[i] = (self.AA[i] * 5 + 0) / 6
        end
    end
    self.alpha1 = (self.alpha1 * 4 + self.alpha) / 5
    if self.locked then
        return
    end
    if GetLastKey() == setting.keys.left then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    if GetLastKey() == setting.keys.right then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
end


player_menu = Class(object)

function player_menu:init(title, content, keyslot, offx)
    simple_menu.init(self, title, content, keyslot, offx)
    self.x = screen.width * 0.5
    self.alpha = 0
    self.AA = {}
    for i = 1, #content - 1 do
        self.AA[i] = 0
    end
    self.AA[1] = 1
    self.alpha1 = 0
end

function player_menu:frame()
    simple_menu.frame(self)
    for i = 1, #self.AA do--透明度渐变效果，5/6这个比例越大渐变速度越快，来自yyl，能用就别动
        if i == self.pos then
            self.AA[i] = (self.AA[i] * 5 + 1) / 6
        else
            self.AA[i] = (self.AA[i] * 5 + 0) / 6
        end
    end
    self.alpha1 = (self.alpha1 * 4 + self.alpha) / 5
    if self.locked then
        return
    end
    if GetLastKey() == setting.keys.left then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    if GetLastKey() == setting.keys.right then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
end

function player_menu:render()
    -- check alive
    local alf = self.alpha1
    if alf <= 0.001 then
        return
    end   
    SetViewMode('ui')
    local xoffset, yoffset = 0, 40
    -- 选人界面立绘比例 
    local yoffsett = { { 15, 5 }, { 15, 5 } }       
    local xoffsett_ch = { { 0, -10 }, { 0, 0 } }     
    local xoffsett_tx = { { 0, 0 }, { 0, 20 } }       
    local t = self.AA
    --SetImageState('white', '', Color(var1 * 96, 0, 0, 0))背景遮罩，效果太丑被爆破
    --RenderRect('white', 0, 640, 0, 480)
    for i = 1, 2 do  
        local var1 = t[i] * alf
        local color = Color(var1 * 255, var1 * 255, var1 * 255, var1 * 255)  
        local color_n = Color(0, var1 * 255, var1 * 255, var1 * 255)
        if i == 1 then
            SetImageState('mask', '', Color(var1 * 200 , 255 , 255 , 255))
            Render('mask', self.x + 70 + xoffset - var1 * 55 + xoffsett_ch[i][2], self.y - 45 + yoffset + yoffsett[i][2], 0,
                    0.5, 0.5)
            SetImageState('rin_intro', '', Color(var1 * 255 , 255 , 255 , 255))
            Render('rin_intro', self.x + 70 + xoffset - var1 * 55 + xoffsett_ch[i][2], self.y - 45 + yoffset + yoffsett[i][2], 0,
                    0.5, 0.5)
        else
            SetImageState('mask', '', Color(var1 * 200 , 255 , 255 , 255))
            Render('mask', self.x + 65 + xoffset - var1 * 55 + xoffsett_ch[i][2], self.y - 45 + yoffset + yoffsett[i][2], 0,
                    0.5, 0.5)
            SetImageState('sanae_intro', '', Color(var1 * 255 , 255 , 255 , 255))
            Render('sanae_intro', self.x + 70 + xoffset - var1 * 55 + xoffsett_ch[i][2], self.y - 45 + yoffset + yoffsett[i][2], 0,
                    0.5, 0.5)
        end
    end
    SetImageState('arrow', '', Color(alf * 255, alf * 255, alf * 255, alf * 255))
    Render('arrow', self.x + xoffset, self.y + yoffset + 150 + sin(self.timer * 5) * -5, 90, 0.8, 0.8)
    Render('arrow', self.x + xoffset, self.y + yoffset - 230 + sin(self.timer * 5) * 5, -90, 0.8, 0.8)
end

--[[新菜单施工中
title_menu = Class(object)
function title_menu:init(title, content, keyslot, offx)
    simple_menu.init(self, title, content, keyslot, offx)
    self.x = screen.width * 0.5
    self.alpha = 0
    self.AA = {}
    for i = 1, #content - 1 do
        self.AA[i] = 0
    end
    self.AA[1] = 1
    self.alpha1 = 0
end
function title_menu:frame()
end

function title_menu:render()
    SetViewMode 'ui'
end
----------------------------------------------------

--[[测试中的难度选择界面
difficulty_menu = Class(object)

function difficulty_menu:init(title, content, keyslot, offx)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.offx = offx or 0
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.title = title
    self.content = content
    self.text = {}
    self.func = {}
    for i = 1, #content do
        self.text[i] = content[i][1]
        self.func[i] = content[i][2]
    end
    self.pos = 1
    self.pos_pre = 1
    self.pos_changed = 0
    self.no_pos_change = false
    self.keyslot = keyslot
    if content[#content][1] == 'exit' then
        self.exit_func = content[#content][2]
        self.text[#content] = nil
        self.func[#content] = nil
    end
    self.AA = {}
    for i = 1, #content - 1 do
        self.AA[i] = 0
    end
    self.AA[1] = 1
    self.alpha1 = 0
end

function difficulty_menu:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if GetLastKey(self.keyslot) == setting.keys.up and (not self.no_pos_change) then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.down and (not self.no_pos_change) then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    self.pos = (self.pos - 1 + #(self.text)) % (#(self.text)) + 1
    if KeyIsPressed('shoot', self.keyslot) and self.func[self.pos] then
        self.func[self.pos]()
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell', self.keyslot) and self.exit_func then
        self.exit_func()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos

    for i = 1, #self.AA do
        if i == self.pos then
            self.AA[i] = (self.AA[i] * 5 + 1) / 6
        else
            self.AA[i] = (self.AA[i] * 5 + 0) / 6
        end
    end
    self.alpha1 = (self.alpha1 * 4 + self.alpha) / 5
end

function difficulty_menu:render()
    local alf = self.alpha1
    if alf <= 0.001 then return end   
    
    SetViewMode('ui')
    local xoffset, yoffset = 0, 40
    local t = self.AA
    local cur = 1
    if self.pos <= #t then
        cur = self.pos
    end

    for i = 1, #t do
        local sr = 0
        local isr = 0
        local tox = 250  -- 标题移动时x方向上的偏移
        local toy = 120  -- 标题移动时y方向上的偏移
        
        if cur ~= i then
            if self.pos_pre > self.pos then
                sr = (cur - i + 1) / (cur - i) - t[cur] / (cur - i)
            else
                sr = t[cur] / (cur - i) + (cur - i - 1) / (cur - i)
            end
        else
            if self.pos_pre > self.pos then
                isr = 1 - t[cur]
            else
                isr = t[cur] - 1
            end
        end

        -- 渲染难度选项
        SetImageState('title_item_eff2', '', Color(alf * (t[i] * 150), 255, 255, 255))
        Render('title_item_eff2', self.x + t[i] * 20 + xoffset - 80,
            self.y - i * 36 + yoffset + 80 - 6, 0, t[i] * 3, t[i] * 0.55)

        -- 渲染难度图标
        if CheckRes('img', 'diffitem_' .. i) then
            SetImageState('diffitem_' .. i, '', Color(alf * (t[i] * 128 + 127), 255, 255, 255))
            Render('diffitem_' .. i, self.x - tox * isr + sr * -tox * (cur - i) + xoffset,
                self.y + toy * isr + sr * toy * (cur - i), 0, 0.4, 0.4)
            SetImageState('diffitem_' .. i, 'mul+add',
                Color((alf * t[i] * 128 + sin(alf * 90) * 60) / 8 + alf * t[i] * sin(self.timer * 6) * 8, 255, 255, 255))
        end

        -- 渲染文字
        local x, y = self.x + t[i] * 20 + xoffset + 20, self.y - i * 36 + yoffset + 80
        local align = 'left'
        RenderTTF2Border('menuttf1', self.text[i], x, x, y,
            y, 1, Color(alf * (t[i] * 128 + 127), 0, 150, 200), align,
            "left", "vcenter")
        RenderTTF2('menuttf1', self.text[i], x, x, y,
            y, 1, Color(alf * (t[i] * 128 + 127), 255, 255, 255), align,
            "left", "vcenter")
    end

    -- 渲染标题和底部装饰
    SetImageState('title_btm', '', Color(alf * 255, 255, 255, 255))
    Render('title_btm', self.x + xoffset, self.y + 105 + alf * 20 + yoffset, 0, 0.32, 0.32)
    SetImageState('title_1', '', Color(alf * 255, 255, 255, 255))
    SetImageState('title_2', '', Color(alf * 255, 255, 255, 255))
    Render('title_1', self.x + xoffset, self.y + 120 + alf * 20 + yoffset, 0, 0.35, 0.35)
    Render('title_2', self.x + xoffset, self.y + 60 + alf * 30 + yoffset, 0, 0.35, 0.35)
    SetImageState('title_1', 'mul+add', Color(alf * 128, 255, 255, 255))
    SetImageState('title_2', 'mul+add', Color(alf * 128, 255, 255, 255))
    Render('title_1', self.x + xoffset, self.y + 120 + alf * 20 + yoffset, 0, 0.35, 0.35)
    Render('title_2', self.x + xoffset, self.y + 60 + alf * 30 + yoffset, 0, 0.35, 0.35)
end
]]


