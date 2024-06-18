-- 这个 lua 脚本是依赖 https://github.com/HalcyonAlcedo/MHWLuaScript
-- 上述内容安装完成后，才可运行下面内容

function GetAddress(Base_address, Offset, Last_Offset)
	local Add = System_Memory_GetOffsetAddress(string.format('%x', Base_address), '0')
	local i
	i = 1
	while true
	do
		if Offset[i] ~= nil
		then
			Add = System_Memory_GetOffsetAddress(Add, string.format('%x', Offset[i]))
		else
			break
		end
		i = i + 1
	end
	Add = string.format('%x', (tonumber(Add, 16) + Last_Offset))
	return Add
end

function GetAddressData(Add, Type)
	if Type == 'int' or Type == 'float' or Type == 'byte' or Type == 'bool'
	then
		local Value = System_Memory_GetAddressData(Add, Type)
		return Value
	else
		return nil
	end
end

function SetAddressData(Add, Type, Value)
	if Type == 'int' or Type == 'float' or Type == 'byte' or Type == 'bool'
	then
		System_Memory_SetAddressData(Add, Type, Value)
	end
end

function Timer_start(time, name)
	System_Chronoscope_AddChronoscope(time, name)
end

function Timer_end(name)
	return System_Chronoscope_CheckChronoscope(name)
end


function run()
    Lua_Variable_SaveStringVariable('自动见切开关', '开')

    Lua_Variable_SaveStringVariable('自动居合开关', '开')
    Lua_Variable_SaveFloatVariable('特殊纳刀时间', 3.5)

    Lua_Variable_SaveStringVariable('平滑转向开关', '开')

    Lua_Variable_SaveStringVariable('翻滚取消后摇开关', '开')

    Lua_Variable_SaveIntVariable('小居合键VK', 1)
    Lua_Variable_SaveIntVariable('大居合键VK', 6)
    Lua_Variable_SaveIntVariable('翻滚键VK', 32)
    Lua_Variable_SaveIntVariable('前vk', 87)
    Lua_Variable_SaveIntVariable('左vk', 65)
    Lua_Variable_SaveIntVariable('右vk', 68)
    Lua_Variable_SaveIntVariable('后vk', 83)



    local MapId = Game_World_GetMapId()
    if MapId ~= 301 and MapId ~= 302 and MapId ~= 303 and MapId ~= 305 and MapId ~= 306 and MapId ~= 503 and MapId ~=
        506 and Game_Player_Weapon_GetWeaponType() == 3 then
        local action = Game_Player_GetPlayerActionId()                   -- 获取动作id
        local actionFrame, actionFrameEnd = Game_Player_GetActionFrame() -- 获取动作帧
        local target, id = Game_Player_GetFsmData()                      -- 获取派生招式id
        local Angle = Game_Player_GetPlayerAngle()                       -- 获取角色角度

        if Lua_Variable_ReadStringVariable('自动见切开关') == '开' then
            -- 自动见切
            if target == 3
                and GetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x2368), 'float') >= 0.1 -- 太刀气刃槽
            then
                if (action == 49257 and actionFrame > 30)
                    or
                    (action == 49259 and actionFrame > 35)
                    or
                    ((action == 49253 or action == 49254 or action == 49497) and actionFrame > 68)
                    or
                    ((action == 49289 or action == 49279 or action == 49263 or action == 49255) and actionFrame > 70)
                    or
                    ((action == 49256 or action == 49262) and actionFrame > 56)
                    or
                    (action == 49258 and actionFrame > 54)
                    or
                    (action == 49260 and actionFrame > 105)
                    or
                    (action == 49459 and actionFrame > 50)
                    or
                    ((action == 49306 or action == 49308 or action == 49310 or action == 49314) and actionFrame > 12)
                    or
                    (action == 49301 and actionFrame > 60)
                    or
                    (action == 49326 and actionFrame > 75)
                then
                    if Lua_Variable_ReadIntVariable('见切标志') ~= 1
                    then
                        Lua_Variable_SaveIntVariable('见切标志', 1)
                        Lua_Variable_SaveIntVariable('可见切动作', action)
                        Game_Player_SetPlayerBuffDuration("Whistle Divine Protection", 10)
                        Game_Player_SetPlayerBuffDuration("Palico Divine Protection", 10)
                        Game_Player_SetPlayerBuffDuration("Whistle All Ailments Negated", 10)
                        Game_Player_SetPlayerBuffDuration("Whistle Blight Negated", 10)
                        Game_Player_SetPlayerBuffDuration("Whistle Knockbacks Negated", 10)
                        Lua_Variable_SaveFloatVariable('受击前转身衣装时间',
                            GetAddressData(GetAddress(0x145011760, { 0x50, 0x80, 0x80, 0x18 }, 0xef0), 'float'))
                    end
                end
            end
            if Lua_Variable_ReadIntVariable('见切标志') == 1
            then
                if Lua_Variable_ReadIntVariable('可见切动作') ~= action then
                    --[判断是否被地面控制]--
                    if action == 4101 or action == 4104 or action == 4133 or action == 4100 or action == 4230 or action == 4198 or
                        action == 4173 or action == 4286 or action == 4172 or action == 4171 or action == 4193 or action == 49250 or
                        action == 4145 or action == 4250 or action == 49367 or action == 4098 or action == 49366 or action == 49603 or
                        action == 8206 or action == 4320 or action == 4207 or action == 28863
                    then
                        Game_Player_RunFsmAction(3, 86) --见切
                        Timer_start(0.15, '见切无敌时间')
                        SetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x2399), 'byte', 1) -- 见切盯
                        SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 2) -- 无法选中
                        SetAddressData(GetAddress(0x145011760, { 0x50, 0x80, 0x80, 0x18 }, 0xef0),
                            'float', Lua_Variable_ReadFloatVariable('受击前转身衣装时间')) --转身衣装时间恢复
                        Timer_start(2, '见切霸体时间')
                        Lua_Variable_SaveIntVariable('跳帧标志', 1)
                        Lua_Variable_SaveIntVariable('见切标志', 0)
                    elseif action == 4115 or action == 4109 --[判断是否被击飞控制]--
                    then
                        Lua_Variable_SaveIntVariable('见切标志', 2)
                        SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x14a4), 'float', -3000) --下落速度
                    else
                        Lua_Variable_SaveIntVariable('见切标志', 0)
                    end
                    Game_Player_SetPlayerBuffDuration("Whistle Divine Protection", 0)
                    Game_Player_SetPlayerBuffDuration("Palico Divine Protection", 0)
                    Game_Player_SetPlayerBuffDuration("Whistle All Ailments Negated", 0)
                    Game_Player_SetPlayerBuffDuration("Whistle Blight Negated", 0)
                    Game_Player_SetPlayerBuffDuration("Whistle Knockbacks Negated", 0)
                end
            end
            if Lua_Variable_ReadIntVariable('见切标志') == 2 and action == 4111 then
                Game_Player_RunFsmAction(3, 86) --见切
                Timer_start(0.15, '见切无敌时间')
                SetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x2399), 'byte', 1) -- 见切盯
                SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 2) -- 无法选中
                SetAddressData(GetAddress(0x145011760, { 0x50, 0x80, 0x80, 0x18 }, 0xef0),
                    'float', Lua_Variable_ReadFloatVariable('受击前转身衣装时间')) --转身衣装时间恢复
                Timer_start(2, '见切霸体时间')
                Lua_Variable_SaveIntVariable('跳帧标志', 1)
                Lua_Variable_SaveIntVariable('见切标志', 0)
            end

            if Timer_end('见切无敌时间')
            then
                SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 0) -- 无法选中
                SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x76a8), 'byte', 1) -- 人物是否持刀
            end
            if System_Chronoscope_CheckPresenceChronoscope('见切霸体时间')
            then
                SetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x23a0), 'float', 1) -- 太刀见切霸体
            end
            if Timer_end('见切霸体时间')
            then
                SetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x23a0), 'float', 0) -- 太刀见切霸体
            end
        end
        if Lua_Variable_ReadStringVariable('自动居合开关') == '开' then
            -- 自动居合
            if target == 3 and id == 99 then
                if Lua_Variable_ReadIntVariable('居合标志') == 0
                then
                    Lua_Variable_SaveIntVariable('居合标志', 1)
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 2) -- 无法选中
                    Timer_start(Lua_Variable_ReadFloatVariable('特殊纳刀时间'), '居合时间')
                end
            end
            if Lua_Variable_ReadIntVariable('居合标志') == 1
            then
                if GetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x2CED), 'byte') == 1 -- 居合盯
                then
                    Timer_start(0.2, '大居合无敌时间')

                    Timer_start(2, '大居合霸体时间')
                    Game_Player_RunFsmAction(3, 102)
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x76a8), 'byte', 1)         -- 人物是否持刀
                    SetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x2CED), 'byte', 1) -- 居合盯
                    Lua_Variable_SaveIntVariable('跳帧标志', 1)
                    Lua_Variable_SaveIntVariable('居合标志', 0)
                elseif System_Keyboard_CheckKeyIsPressed(Lua_Variable_ReadIntVariable('小居合键VK'))
                then
                    Game_Player_RunFsmAction(3, 101)
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x76a8), 'byte', 1) -- 人物是否持刀
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 0) -- 无法选中
                    Lua_Variable_SaveIntVariable('居合标志', 0)
                elseif System_Keyboard_CheckKeyIsPressed(Lua_Variable_ReadIntVariable('大居合键VK'))
                then
                    Game_Player_RunFsmAction(3, 102)
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x76a8), 'byte', 1) -- 人物是否持刀
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 0) -- 无法选中
                    Lua_Variable_SaveIntVariable('居合标志', 0)
                elseif Timer_end('居合时间')
                then
                    Game_Player_RunFsmAction(3, 100)
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 0) -- 无法选中
                    Lua_Variable_SaveIntVariable('居合标志', 0)
                else
                    Game_Player_RunFsmAction(3, 101)
                    SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x76a8), 'byte', 0) -- 人物是否持刀
                end
            end
            if target == 3 and (id == 102 and actionFrame < 3) and Lua_Variable_ReadIntVariable('跳帧标志') == 1 then
                Lua_Variable_SaveIntVariable('跳帧标志', 0)
                Game_Player_SetActionFrame(3)
            elseif target == 3 and (id == 86 and actionFrame < 5) and Lua_Variable_ReadIntVariable('跳帧标志') == 1 then
                Lua_Variable_SaveIntVariable('跳帧标志', 0)
                Game_Player_SetActionFrame(5)
            end

            if Timer_end('大居合无敌时间')
            then
                SetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7626), 'byte', 0) -- 无法选中
            end
            if System_Chronoscope_CheckPresenceChronoscope('大居合霸体时间')
            then
                SetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x23a0), 'float', 1) -- 太刀见切霸体
            end
            if Timer_end('大居合霸体时间')
            then
                SetAddressData(GetAddress(0x145011760, { 0x50, 0x76B0 }, 0x23a0), 'float', 0) -- 太刀见切霸体
            end
        end
        if Lua_Variable_ReadStringVariable('平滑转向开关') == '开' then
            -- [获取视角欧拉角x值]--
            Lua_Variable_SaveFloatVariable('欧拉角X',
                GetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7dc0), 'float'))
            -- [获取视角欧拉角z值]--
            Lua_Variable_SaveFloatVariable('欧拉角Z',
                GetAddressData(GetAddress(0x145011760, { 0x50 }, 0x7dc8), 'float'))

            -- [用欧拉角计算出面向角度]--
            if Lua_Variable_ReadFloatVariable('欧拉角Z') >= 0
            then
                Lua_Variable_SaveFloatVariable('视角朝向', math.asin(Lua_Variable_ReadFloatVariable('欧拉角X')))
            elseif Lua_Variable_ReadFloatVariable('欧拉角Z') < 0 and Lua_Variable_ReadFloatVariable('欧拉角X') > 0
            then
                Lua_Variable_SaveFloatVariable('视角朝向', math.acos(Lua_Variable_ReadFloatVariable('欧拉角Z')))
            elseif Lua_Variable_ReadFloatVariable('欧拉角Z') < 0 and Lua_Variable_ReadFloatVariable('欧拉角X') < 0
            then
                Lua_Variable_SaveFloatVariable('视角朝向', -math.acos(Lua_Variable_ReadFloatVariable('欧拉角Z')))
            end
            if target == 3 and (id == 69 or id == 86 or id == 91 or (id == 87 and actionFrame <= 90)) and
                System_Keyboard_CheckKeyIsPressed(Lua_Variable_ReadIntVariable('前vk')) and Lua_Variable_ReadIntVariable('转向标志位') == 0
            then
                -- [平滑转向]--
                if Angle - Lua_Variable_ReadFloatVariable('视角朝向') > 0.1 or Angle -
                    Lua_Variable_ReadFloatVariable('视角朝向') < -0.1 then
                    if Angle < Lua_Variable_ReadFloatVariable('视角朝向') then
                        if Lua_Variable_ReadFloatVariable('视角朝向') - Angle > 3.14159 then
                            if Angle - 0.075 < -3.14159 then
                                Angle = Angle - 0.075 + 2 * 3.1415923
                            else
                                Angle = Angle - 0.075
                            end
                            Game_Player_SetPlayerAngle(Angle)
                        else
                            Angle = Angle + 0.075
                            Game_Player_SetPlayerAngle(Angle)
                        end
                    else
                        if Angle - Lua_Variable_ReadFloatVariable('视角朝向') > 3.14159 then
                            if Angle + 0.075 > 3.14159 then
                                Angle = Angle + 0.075 - 2 * 3.1415923
                            else
                                Angle = Angle + 0.075
                            end
                            Game_Player_SetPlayerAngle(Angle)
                        else
                            Angle = Angle - 0.075
                            Game_Player_SetPlayerAngle(Angle)
                        end
                    end
                end
            elseif target == 3 and (id == 102 and actionFrame < 2) and System_Keyboard_CheckKeyIsPressed(87) then
                Game_Player_SetPlayerAngle(Lua_Variable_ReadFloatVariable('视角朝向'))
                Game_Player_SetActionFrame(10)
            end
        end
        if Lua_Variable_ReadStringVariable('翻滚取消后摇开关') == '开' then
            --[翻滚取消后摇]--
            if target == 3 and ((id == 102 and actionFrame > 70) or (id == 92 and actionFrame > 30))
            then
                if System_Keyboard_CheckKeyIsPressed(Lua_Variable_ReadIntVariable('翻滚键VK'))
                then
                    if System_Keyboard_CheckKeyIsPressed(Lua_Variable_ReadIntVariable('左vk'))
                    then
                        Game_Player_RunFsmAction(3, 20)
                    elseif System_Keyboard_CheckKeyIsPressed(Lua_Variable_ReadIntVariable('右vk'))
                    then
                        Game_Player_RunFsmAction(3, 21)
                    elseif System_Keyboard_CheckKeyIsPressed(Lua_Variable_ReadIntVariable('后vk'))
                    then
                        Game_Player_RunFsmAction(3, 22)
                    else
                        Game_Player_RunFsmAction(3, 19)
                    end
                end
            end
        end
    end
end
