-- 自机拓展，灵梦，魔理沙，咲夜
-- 加入了自制角色 --

lstg.plugin.RegisterEvent("afterTHlib", "Player Extensions", 100, function()
    lstg.DoFile("THlib/player/reimu/reimu.lua")
    lstg.DoFile("THlib/player/marisa/marisa.lua")
    lstg.DoFile("THlib/player/sakuya/sakuya.lua")
    lstg.DoFile("THlib/player/rin/Rin.lua")
end)
