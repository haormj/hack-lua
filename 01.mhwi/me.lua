local excludeMap = {
    [301] = true,
    [302] = true,
    [303] = true,
    [305] = true,
    [306] = true,
    [503] = true,
    [506] = true
}

-- 太刀
local LONG_SWORD_WEAPON_TYPE = 3

local playerPointer = {
    Player = function()
        return GetAddress(0x145011760, {0x50})
    end,
    PlayerData = function()
        return GetAddress(0x145011760, {0x50, 0xC0, 0x98, 0x18, 0x70, 0xC8, 0xD0, 0x5D0, 0x20})
    end,
    PlayerSaveData = function()
        return GetAddress(0x145011710, {0xa8})
    end,
    Weapon = {
        Entity = function()
            return GetAddress(0x145011760, {0x50, 0x76B0})
        end,
        Data = function()
            return GetAddress(0x145011760, {0x50, 0xc0, 0x8, 0x78})
        end
    }
}

-- 游戏初始化执行的代码
function on_init()
end

-- 每次切换场景执行的代码
function on_switch_scenes()
end

-- 每次时间变动执行的代码
function on_time()
    local mapId = engine.World:getMapId()
    -- 排除不处理的地图
    if excludeMap[mapId] then
        return
    end

    local player = engine.Player:new()

    -- 这里只处理太刀
    if player.Weapon.type ~= LONG_SWORD_WEAPON_TYPE then
        return
    end

    -- 获取太刀气刃槽
    local spiritGauge = GetAddressData(playerPointer.Weapon:Entity() + 0x2368, 'float')
    if spiritGauge < 0.1 then
        return
    end

    -- 执行对象，1为人物派生，3为战斗派生
    if player.Action.fsm.fsmTarget ~= 3 then
        return
    end

    -- 是否可以见切
    if (player.Action.lmtID == 49257 and player.Frame.frame > 30) or 
        (action == 49259 and actionFrame > 35) or
        ((action == 49253 or action == 49254 or action == 49497) and actionFrame > 68) or
        ((action == 49289 or action == 49279 or action == 49263 or action == 49255) and actionFrame > 70) or
        ((action == 49256 or action == 49262) and actionFrame > 56) or 
        (action == 49258 and actionFrame > 54) or
        (action == 49260 and actionFrame > 105) or
        (action == 49459 and actionFrame > 50) or
        ((action == 49306 or action == 49308 or action == 49310 or action == 49314) and actionFrame > 12) or
        (action == 49301 and actionFrame > 60) or 
        (action == 49326 and actionFrame > 75) then
        Lua_Variable_SaveIntVariable("isCanForesightSlash", 1)
        Lua_Variable_SaveIntVariable("canForesightSlashAction", player.Action.lmtID)
        elseif 
    end

    -- 这里其实还需要判断哪些状态下其实是无法见切的
    -- 这个状态机需要梳理出来
    -- 他这个比较复杂的是，不是但状态机，而是一个前后还有关系的，


    -- 是否需要见切
    local isNeedForesightSlash = false
    if player.Action.lmtID == 4101 or
       action == 4104 or 
       action == 4133 or 
       action == 4100 or 
       action == 4230 or 
       action == 4198 or
       action == 4173 or 
       action == 4286 or 
       action == 4172 or 
       action == 4171 or 
       action == 4193 or 
       action == 49250 or
       action == 4145 or 
       action == 4250 or 
       action == 49367 or 
       action == 4098 or 
       action == 49366 or 
       action == 49603 or
       action == 8206 or 
       action == 4320 or 
       action == 4207 or 
       action == 28863  then
        Lua_Variable_SaveIntVariable("isNeedForesightSlash", 1)
    end

    -- 只要可以且需要见切时候再执行
    if Lua_Variable_ReadIntVariable("isCanForesightSlash") == 1 and Lua_Variable_ReadIntVariable("isNeedForesightSlash") ==
        1 then
        player.Action.fsm = {
            fsm = 86,
            fsmTarget = 3
        }
        Lua_Variable_SaveIntVariable("isCanForesightSlash", 0)
        Lua_Variable_SaveIntVariable("isNeedForesightSlash", 0)
    end
end

-- 图形绘制代码放这里
function on_imgui()
end

-- 每次生成怪物时执行的代码
function on_monster_create()
end

-- 每次销毁怪物时执行的代码
function on_monster_destroy()
end


-- 需要两个状态机
-- 一个是人物状态机
-- 一个是战斗状态机
-- weaponFsm 
-- playerFsm
-- [[

-- ]]
state 
event 
-- 如果以上这些跑通了，那么后续就可以做一个模型了，输入当前state，然后输出action
-- 这个游戏目前是最可行的方式
-- 这个还是很有意思，也能学习到不少东西的
-- 先涉及好这个状态机器吧
-- 先将之前的那个代码移值过来，后续可以在改进为状态机方式

