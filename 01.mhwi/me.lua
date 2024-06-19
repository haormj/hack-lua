
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
local LONG_SWORD_WEAPON_TYPE = 3

local playerPointer = = {
    Player = function() return GetAddress(0x145011760,{ 0x50 }) end,
    PlayerData = function() return GetAddress(0x145011760,{ 0x50, 0xC0, 0x98, 0x18, 0x70, 0xC8, 0xD0, 0x5D0, 0x20 }) end, 
    PlayerSaveData = function() return GetAddress(0x145011710,{ 0xa8 }) end, 
    Weapon = {
        Entity = function() return GetAddress(0x145011760,{ 0x50, 0x76B0 }) end,
        Data = function() return GetAddress(0x145011760,{ 0x50, 0xc0, 0x8, 0x78 }) end
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
	if player.Action.fsm.fsmTarget != 3 then
		return
	end

	-- 是否可以见切
	local isCanForesightSlash = false
	if player.Action.lmtID == 49257 and player.Frame.frame > 30 
	then
		isCanForesightSlash = true
	end

	-- 是否需要见切
	local isNeedForesightSlash = false
	if player.Action.lmtID == 4101 then
		isNeedForesightSlash = true
	end

	-- 只要可以且需要见切时候再执行
	if isCanForesightSlash and isNeedForesightSlash then
		player.Action.fsm.fsmID = 86
		palyer.Action.fsm.fsmTarget = 3
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


-- 其实整个过程就是一个状态机，根据当前的动作，已经结合帧的一些信息来判断是否需要跳转，从而应该将这些都放到状态机中来做
