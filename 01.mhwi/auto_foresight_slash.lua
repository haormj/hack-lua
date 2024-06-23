local excludeMap = {
    [301] = true,
    [302] = true,
    [303] = true,
    [305] = true,
    [306] = true,
    [503] = true,
    [506] = true,
}

-- 太刀
-- 49153 拔刀 

local canForesightSlashMap = {
    [49253] = 68,
    [49254] = 68,
    [49255] = 70,
    [49256] = 56,
    [49257] = 30,
    [49258] = 54,
    [49259] = 35,
    [49260] = 105,
    [49262] = 56,
    [49263] = 70,
    [49279] = 70,
    [49289] = 70,
    [49301] = 60,
    [49306] = 12,
    [49308] = 12,
    [49310] = 12,
    [49314] = 12,
    [49326] = 75,
    [49459] = 50,
    [49497] = 68,
}

local needForesightSlashMap = {
    [4098] = true,
    [4100] = true,
    [4101] = true,
    [4104] = true,
    [4133] = true,
    [4145] = true,
    [4171] = true,
    [4172] = true,
    [4173] = true,
    [4193] = true,
    [4198] = true,
    [4207] = true,
    [4230] = true,
    [4250] = true,
    [4286] = true,
    [4320] = true,
    [8206] = true,
    [28863] = true,
    [49250] = true,
    [49366] = true,
    [49367] = true,
    [49603] = true,
}

local needForesightSlashMonsterMap = {
    [16385] = true,
}

-- 太刀
local LONG_SWORD_WEAPON_TYPE = 3

local playerPointer = {
    Player = function()
        return GetAddress(0x145011760, { 0x50 })
    end,
    PlayerData = function()
        return GetAddress(0x145011760, { 0x50, 0xC0, 0x98, 0x18, 0x70, 0xC8, 0xD0, 0x5D0, 0x20 })
    end,
    PlayerSaveData = function()
        return GetAddress(0x145011710, { 0xa8 })
    end,
    Weapon = {
        Entity = function()
            return GetAddress(0x145011760, { 0x50, 0x76B0 })
        end,
        Data = function()
            return GetAddress(0x145011760, { 0x50, 0xc0, 0x8, 0x78 })
        end
    }
}

local player = nil
local prevPlayer = nil

-- 每次时间变动执行的代码
function on_time()
    local mapId = engine.World:getMapId()
    -- 排除不处理的地图
    if excludeMap[mapId] then
        return
    end

    player = engine.Player:new()
    monster = engine.Monster:new()

    foresightSlash(prevPlayer, player, monster)

    prevPlayer = player
end

-- 判断是否执行见切
function foresightSlash(prevPlayer, player, monster)
    -- 见切无敌到期
    if CheckChronoscope('foresightSlashInvincibility') then
        SetAddressData(playerPointer:Player() + 0x7626, 'byte', 0) 
    end

    -- 见切霸体
    if CheckPresenceChronoscope('foresightSlashSuperArmor') then
        SetAddressData(playerPointer.Weapon:Entity() + 0x23a0, 'float', 1)
    end

    -- 见切霸体到期
    if CheckChronoscope('foresightSlashSuperArmor') then
        SetAddressData(playerPointer.Weapon:Entity() + 0x23a0, 'float', 0)
    end

    -- 没有上一帧信息
    if prevPlayer == nil then
        return
    end

    -- 只处理太刀
    if player.Weapon.type ~= LONG_SWORD_WEAPON_TYPE then
        return
    end

    -- 太刀气刃槽小于 0.1
    local spiritGauge = GetAddressData(playerPointer.Weapon:Entity() + 0x2368, 'float')
    -- Console_Info(spiritGauge)
    if spiritGauge < 0.1 then
        return
    end

    Console_Info("needForesightSlashMap" .. 
    "player action" .. player.Action.lmtID .. 
    "monster action" .. monster.Action.lmtID)
    -- 不需要见切
    if not needForesightSlashMap[player.Action.lmtID] then
    --    not needForesightSlashMonsterMap[monster.Action.lmtID] then
        return
    end


    -- 无法派生出见切
    if prevPlayer.Action.fsm.fsmTarget ~= 3 then
        return
    end

    -- 上一个动作允许派生见切
    local frameThreshold = canForesightSlashMap[prevPlayer.Action.lmtID]
    if frameThreshold ~= nil and prevPlayer.Frame.frame > frameThreshold then
        player.Action.fsm = { fsmID = 86, fsmTarget = 3 }
        -- 见切盯
        -- SetAddressData(playerPointer.Weapon:Entity() + 0x2399, 'byte', 1)

        -- 见切无敌
        SetAddressData(playerPointer:Player() + 0x7626, 'byte', 2) 
        -- 见切无敌时间
        AddChronoscope(0.15, 'foresightSlashInvincibility')

        -- 见切霸体
        SetAddressData(playerPointer.Weapon:Entity() + 0x23a0, 'float', 1)

        -- 见切霸体时间
        AddChronoscope(2, 'foresightSlashSuperArmor')
    end
end
