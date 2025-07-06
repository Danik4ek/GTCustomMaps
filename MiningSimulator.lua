local minX, maxX = -4.95, 4.95
local minY, maxY = -51.339, -11.339
local minZ, maxZ = 10.84, 19.84

--Инициализация
local isStarted = false
local blockMap = {}
local lastSellTime = 0
local lastUpgradeTime = 0
local COOLDOWN_TIME = 1.0
local SHAFT_REGENERATION_TIME = 600
local lastShaftRegenerationTime = 0
local fingerTipOffset = Vec3.new(0, 0.2, 0)
local fingerTipRotL = Quat.fromEuler(0, 10, 21)
local fingerTipRotR = Quat.fromEuler(0, -10, -21)
local Pickaxe_Hitbox = GameObject.findGameObject("Pickaxe_Hitbox")
local previusPos = Vec3.new(0,0,0)
local lastSoundTime = 0
--Рюкзак
local BackPackUpgrades = {
    {slots = 25,  cost = 50},    -- Было 45
    {slots = 50,  cost = 600},    -- Было 350
    {slots = 100, cost = 1800},   -- Новый промежуточный уровень
    {slots = 145, cost = 3600},   -- Было 1200
    
    -- Средние уровни (мидгейм)
    {slots = 220, cost = 7500},   -- Новый уровень
    {slots = 300, cost = 14000},  -- Было 3500
    {slots = 400, cost = 22000},  -- Новый уровень
    
    -- Поздние уровни (энтгейм)
    {slots = 550, cost = 35000},  -- Было 5000
    {slots = 750, cost = 50000},  -- Было 7500
    {slots = 1000, cost = 75000}, -- Новый уровень
    {slots = 1250, cost = 100000},-- Было 15000
    {slots = 2000, cost = 150000} -- Было 25000
}
local currentBackPackUpgradeIndex = -1
local BackPackText = GameObject.findGameObject("BackPack")
local UpgradeBackPack = GameObject.findGameObject("Upgrade_BackPack")
local arrow3D = GameObject.findGameObject("MSArrow1")
local arrow3D_1 = GameObject.findGameObject("MSArrow2")
local UpgradeBackPackText = GameObject.findGameObject("Upgrade_BackPack_Text")
local Slots = 0
local SlotsLimit = 10
local BackPack = {}
local isSlotsFull = false

--Кирка
local PickaxeUpgrades = {
    {level = 1, cost = 0,    speed = 1.0},
    {level = 2, cost = 750,  speed = 1.25},  -- Было 500
    {level = 3, cost = 3000, speed = 1.5},   -- Было 2000
    {level = 4, cost = 7500, speed = 1.75}, -- Было 5000
    {level = 5, cost = 15000, speed = 2.0},  -- Было 10000
    {level = 6, cost = 30000, speed = 2.5}   -- Было 20000
}

local currentPickaxeLevel = 1
local PickaxeModels = {
    ["Broken"] = {
        obj = GameObject.findGameObject("Broken_Pickaxe"),
        rotation = Quat.fromEuler(0, 0, 90)
    },
    ["Stone"] = {
        obj = GameObject.findGameObject("Stone_Pickaxe"), 
        rotation = Quat.fromEuler(0, 0, 180)
    },
    ["Iron"] = {
        obj = GameObject.findGameObject("Iron_Pickaxe"),
        rotation = Quat.fromEuler(0, 0, 180)
    },
    ["Gold"] = {
        obj = GameObject.findGameObject("Gold_Pickaxe"),
        rotation = Quat.fromEuler(0, 90, -90)
    },
    ["Diamond"] = {
        obj = GameObject.findGameObject("Diamond_Pickaxe"),
        rotation = Quat.fromEuler(0, 90, -90)
    },
    ["Banana"] = {
        obj = GameObject.findGameObject("Banana_Pickaxe"),
        rotation = Quat.fromEuler(0, 0, 0)
    }
}
local currentPickaxeModel = PickaxeModels["Broken"]
local PickaxeMiningTiers = {
    [1] = {"Stone", "Coal_Ore",},               -- Уровень 1: только камень
    [2] = {"Stone", "Coal_Ore", "Iron_Ore"}, -- +уголь
    [3] = {"Stone", "Coal_Ore", "Iron_Ore", "Gold_Ore", "Diamond_Ore", "Deepslate", "Deepslate_Coal_Ore"}, -- +железо
    [4] = {"Stone", "Deepslate", "Coal_Ore", "Deepslate_Coal_Ore", "Iron_Ore", "Deepslate_Iron_Ore", "Gold_Ore", "Deepslate_Gold_Ore", "Diamond_Ore", "Deepslate_Diamond_Ore"}, -- +золото
    [5] = {"Stone", "Deepslate", "Coal_Ore", "Deepslate_Coal_Ore", "Iron_Ore", "Deepslate_Iron_Ore", "Gold_Ore", "Deepslate_Gold_Ore", "Diamond_Ore", "Deepslate_Diamond_Ore"}, -- +алмазы
    [6] = {"Stone", "Deepslate", "Coal_Ore", "Deepslate_Coal_Ore", "Iron_Ore", "Deepslate_Iron_Ore", "Gold_Ore", "Deepslate_Gold_Ore", "Diamond_Ore", "Deepslate_Diamond_Ore"} -- Макс уровень
}
local UpgradePickaxeText = GameObject.findGameObject("Upgrade_Pickaxe_Text")
local UpgradePickaxe = GameObject.findGameObject("Upgrade_Pickaxe")

--Зона продажи и Баланс
local BalanceText = GameObject.findGameObject("Balance")
local SellZone = GameObject.findGameObject("Sell_Zone")
local SellZoneVisual = GameObject.findGameObject("SellZoneVisual")
local SellZoneParticle = GameObject.findGameObject("SellZoneParticle")
SellZoneParticle:setActive(false)
local BuyZoneVisual = GameObject.findGameObject("BuyZoneVisual")
local BuyZoneParticle = GameObject.findGameObject("BuyZoneParticle")
BuyZoneParticle:setActive(false)
local BuyZone = GameObject.findGameObject("Buy_Zone")
local Balance = 0
local BuyZoneText = GameObject.findGameObject("BuyZoneText")
local BackPackUI = GameObject.findGameObject("BackPackUI")
local PickaxeUI = GameObject.findGameObject("PickaxeUI")

local miningCooldowns = {
    Stone = 0.3,
    Coal_Ore = 0.4,
    Iron_Ore = 0.5,
    Gold_Ore = 0.6,
    Diamond_Ore = 0.7,
    Deepslate = 0.8,
    Deepslate_Coal_Ore = 0.9,
    Deepslate_Iron_Ore = 1,
    Deepslate_Gold_Ore = 1.1,
    Deepslate_Diamond_Ore = 1.2
}

--Шахта
local HowMuchBlocksMined = 0
local lastMinedTime = 0
local blocksTop = {
    {name = "Stone", objects = {}},
    {name = "Coal_Ore", objects = {}},
    {name = "Iron_Ore", objects = {}},
    {name = "Gold_Ore", objects = {}},
    {name = "Diamond_Ore", objects = {}},
}
local blocksBottom = {
    {name = "Deepslate", objects = {}},
    {name = "Deepslate_Coal_Ore", objects = {}},
    {name = "Deepslate_Iron_Ore", objects = {}},
    {name = "Deepslate_Gold_Ore", objects = {}},
    {name = "Deepslate_Diamond_Ore", objects = {}}
}
local blockCounts = {1500, 250, 150, 74, 26}
local ShaftTeleporter = GameObject.findGameObject("ShaftTeleporter")

local DelayedFunctions = {}
function setTimeout(delay, func)
    local timeout = {
        endTime = os.clock() + delay,
        callback = func,
    }
    table.insert(DelayedFunctions, timeout)
end
function handleTimeouts()
    local currentTime = os.clock()

    -- Проходим по таблице отложенных функций в обратном порядке
    for i = #DelayedFunctions, 1, -1 do
        local timeout = DelayedFunctions[i]

        -- Если время выполнения наступило
        if currentTime >= timeout.endTime then
            timeout.callback() -- Вызываем функцию
            table.remove(DelayedFunctions, i) -- Удаляем из таблицы
        end
    end
end

local function loadAllBlocks()
    for blockType = 1, #blocksTop do
        local loaded = 0
        for i = 1, blockCounts[blockType] do
            local objName = blocksTop[blockType].name .. " (" .. i .. ")"
            local obj = GameObject.findGameObject(objName)
            if obj then
                blocksTop[blockType].objects[i] = obj
                loaded = loaded + 1
            end
        end
    end
    
    for blockType = 1, #blocksBottom do
        local loaded = 0
        for i = 1, blockCounts[blockType] do
            local objName = blocksBottom[blockType].name .. " (" .. i .. ")"
            local obj = GameObject.findGameObject(objName)
            if obj then
                blocksBottom[blockType].objects[i] = obj
                loaded = loaded + 1
            end
        end
    end
end

local function generateShaft()
    local topCopy = {}
    for i = 1, #blocksTop do
        topCopy[i] = {
            name = blocksTop[i].name,
            objects = table.clone(blocksTop[i].objects)
        }
    end
    
    local bottomCopy = {}
    for i = 1, #blocksBottom do
        bottomCopy[i] = {
            name = blocksBottom[i].name,
            objects = table.clone(blocksBottom[i].objects)
        }
    end

    local blocksToActivate = {} -- Таблица для хранения блоков, которые нужно активировать
    local blocksPerFrame = 50 -- Количество блоков для активации за один кадр

    local function placeBlock(x, y, z, blocksTable)
        if #blocksTable == 0 then return false end

        local index = math.random(#blocksTable)
        if #blocksTable[index].objects == 0 then
            table.remove(blocksTable, index)
            if #blocksTable == 0 then return false end
            index = math.random(#blocksTable)
        end

        local block = blocksTable[index].objects[#blocksTable[index].objects]
        block.position = Vec3.new(x, y, z)
        table.remove(blocksTable[index].objects)

        if #blocksTable[index].objects == 0 then
            table.remove(blocksTable, index)
        end

        -- Сохраняем блок для последующей активации
        table.insert(blocksToActivate, {
            block = block,
            key = math.floor(x).."|"..math.floor(y).."|"..math.floor(z)
        })

        return true
    end

    -- Сначала размещаем все блоки, но не активируем их
    for y = minY, maxY do
        for x = minX, maxX do
            for z = minZ, maxZ do
                if y >= -31.339 then
                    if not placeBlock(x, y, z, topCopy) then
                        break
                    end
                else
                    if not placeBlock(x, y, z, bottomCopy) then
                        break
                    end
                end
            end
        end
    end

    -- Функция для постепенной активации блоков
    local function activateBlocksBatch(startIndex)
        local endIndex = math.min(startIndex + blocksPerFrame - 1, #blocksToActivate)
        
        for i = startIndex, endIndex do
            local data = blocksToActivate[i]
            data.block:setVisibility(true)
            data.block:setCollision(true)
            blockMap[data.key] = data.block
        end

        -- Если остались блоки, планируем следующую партию
        if endIndex < #blocksToActivate then
            setTimeout(0, function() 
                activateBlocksBatch(endIndex + 1) 
            end)
        end
    end

    -- Начинаем процесс активации
    activateBlocksBatch(1)
end

local function getBlockNameByObject(obj)
    if not obj then return nil end
    -- Поиск в blocksTop
    for _, blockType in ipairs(blocksTop) do
        for _, blockObj in ipairs(blockType.objects) do
            if blockObj == obj then
                return blockType.name
            end
        end
    end

    -- Поиск в blocksBottom
    for _, blockType in ipairs(blocksBottom) do
        for _, blockObj in ipairs(blockType.objects) do
            if blockObj == obj then
                return blockType.name
            end
        end
    end

    return nil -- если объект не найден
end

-- Функция для вычисления обратного кватерниона
local function quatInverse(q)
    -- Для единичного кватерниона обратный равен сопряжённому
    return Quat.new(-q.x, -q.y, -q.z, q.w)
end

-- Обновлённая функция isButtonPressed с поддержкой вращения
function isButtonPressed(gameObject)
    
    local hitboxPos = Pickaxe_Hitbox.position
    local hitboxRot = Pickaxe_Hitbox.rotation
    local hitboxScale = Pickaxe_Hitbox.scale
    
    -- Вычисляем обратное вращение
    local invRot = quatInverse(hitboxRot)
    
    -- Преобразуем позицию блока в локальное пространство хитбокса
    local toBlock = gameObject.position - hitboxPos
    local relativePos = Vec3.rotate(toBlock, invRot)
    
    -- Рассчитываем границы хитбокса
    local halfHitbox = hitboxScale * 0.5
    local minHitbox = -halfHitbox
    local maxHitbox = halfHitbox
    
    -- Рассчитываем границы блока
    local halfBlock = gameObject.scale * 0.5
    local minBlock = -halfBlock
    local maxBlock = halfBlock
    
    -- Проверяем пересечение по осям в локальном пространстве
    return (relativePos.x + maxBlock.x >= minHitbox.x) and
           (relativePos.x + minBlock.x <= maxHitbox.x) and
           (relativePos.y + maxBlock.y >= minHitbox.y) and
           (relativePos.y + minBlock.y <= maxHitbox.y) and
           (relativePos.z + maxBlock.z >= minHitbox.z) and
           (relativePos.z + minBlock.z <= maxHitbox.z)
end

function isInZone(gameObject)
	local body = LocalPlayer.bodyPosition

	local minBounds = gameObject.position - (gameObject.scale * 0.5)
	local maxBounds = gameObject.position + (gameObject.scale * 0.5)

	local function isWithinBounds(hand)
		return hand.x >= minBounds.x
			and hand.x <= maxBounds.x
			and hand.y >= minBounds.y
			and hand.y <= maxBounds.y
			and hand.z >= minBounds.z
			and hand.z <= maxBounds.z
	end

	return isWithinBounds(body)
end

function checkTouchedBlocks()
    local hands = {
        LocalPlayer.leftHandPosition,
        LocalPlayer.rightHandPosition
    }

    for _, hand in ipairs(hands) do
        local cx = math.floor(hand.x + 0.5)
        local cy = math.floor(hand.y + 0.5)
        local cz = math.floor(hand.z + 0.5)

        for dx = -1, 1 do
            for dy = -1, 1 do
                for dz = -1, 1 do
                    local key = (cx + dx).."|"..(cy + dy).."|"..(cz + dz)
                    local obj = blockMap[key]
                    if obj and isButtonPressed(obj) then
                        return obj
                    end
                end
            end
        end
    end

    return nil
end

local function saveGameData()
    local saveData = dataLoad() or {}  -- Загружаем существующие данные или создаём пустую таблицу
    
    saveData["Balance"] = Balance
    saveData["BackPack"] = BackPack
    saveData["currentPickaxeLevel"] = currentPickaxeLevel
    saveData["currentBackPackUpgradeIndex"] = currentBackPackUpgradeIndex
    
    dataSave(saveData)  -- Сохраняем данные
end

function onEvent(tag, data)
    if tag == "BlockMined" then
        local x, y, z = data[1], data[2], data[3]
        local key = math.floor(x).."|"..math.floor(y).."|"..math.floor(z)
        if blockMap[key] then
            blockMap[key]:setVisibility(false)
            blockMap[key]:setCollision(false)
            blockMap[key] = nil
        end
        HowMuchBlocksMined = HowMuchBlocksMined + 1
    end
end

function isUpgradePressed(gameObject)
    local newFingerTipRotR = LocalPlayer.rightHandRotation * fingerTipRotR
    local newFingerOffsetR = Vec3.rotate(fingerTipOffset, newFingerTipRotR)
    local rightFingerPos = LocalPlayer.rightHandPosition + newFingerOffsetR
    local newFingerTipRotL = LocalPlayer.leftHandRotation * fingerTipRotL
    local newFingerOffsetL = Vec3.rotate(fingerTipOffset, newFingerTipRotL)
    local leftFingerPos = LocalPlayer.leftHandPosition + newFingerOffsetL

    local minBounds = gameObject.position - (gameObject.scale * 0.5)
    local maxBounds = gameObject.position + (gameObject.scale * 0.5)

    local function isWithinBounds(hand)
        return hand.x >= minBounds.x
            and hand.x <= maxBounds.x
            and hand.y >= minBounds.y
            and hand.y <= maxBounds.y
            and hand.z >= minBounds.z
            and hand.z <= maxBounds.z
    end

    return isWithinBounds(leftFingerPos) or isWithinBounds(rightFingerPos)
end

local function updatePickaxeModel()
    -- Сначала скрываем все модели
    for _, model in pairs(PickaxeModels) do
        if model.obj then
            model.obj:setVisibility(false)
        end
    end
    
    -- Определяем текущую модель по уровню
    local modelName
    if currentPickaxeLevel == 1 then
        modelName = "Broken"
    elseif currentPickaxeLevel == 2 then
        modelName = "Stone"
    elseif currentPickaxeLevel == 3 then
        modelName = "Iron"
    elseif currentPickaxeLevel == 4 then
        modelName = "Gold"
    elseif currentPickaxeLevel == 5 then
        modelName = "Diamond"
    else -- Уровень 6 и выше
        modelName = "Banana"
    end
    
    -- Показываем нужную модель
    currentPickaxeModel = PickaxeModels[modelName]
    if currentPickaxeModel and currentPickaxeModel.obj then
        currentPickaxeModel.obj:setVisibility(true)
    end
end

function tick()
    handleTimeouts()
    local currentTime = os.clock()
    if not isStarted then
        isStarted = true
        loadAllBlocks()
        ShaftTeleporter:setCollision(false)
        SellZoneParticle.position = SellZoneVisual.position
        BuyZoneParticle.position = BuyZoneVisual.position

        local saveData = dataLoad() or {}
        
        Balance = saveData["Balance"] or 0
        BackPack = saveData["BackPack"] or {}
        currentPickaxeLevel = saveData["currentPickaxeLevel"] or 1
        if currentPickaxeLevel > #PickaxeUpgrades then
            currentPickaxeLevel = #PickaxeUpgrades
        end
        currentBackPackUpgradeIndex = saveData["currentBackPackUpgradeIndex"] or -1
        
        -- Устанавливаем SlotsLimit в зависимости от уровня
        if currentBackPackUpgradeIndex == -1 then
            SlotsLimit = 10
            UpgradeBackPackText:setText("UPGRADE BACKPACK\nCOST: " .. BackPackUpgrades[1].cost)
        else
            SlotsLimit = BackPackUpgrades[currentBackPackUpgradeIndex + 1].slots
            -- Проверяем, есть ли следующий уровень
            if currentBackPackUpgradeIndex + 1 < #BackPackUpgrades then
                UpgradeBackPackText:setText("UPGRADE BACKPACK\nCOST: " .. BackPackUpgrades[currentBackPackUpgradeIndex + 2].cost)
            else
                UpgradeBackPackText:setText("BACKPACK MAXED!")
                UpgradeBackPack:setVisibility(false)
            end
        end

            Slots = #BackPack

            -- Обновляем UI
        if currentPickaxeLevel < #PickaxeUpgrades then
            UpgradePickaxeText:setText("UPGRADE PICKAXE\nCOST: " .. PickaxeUpgrades[currentPickaxeLevel + 1].cost)
        else
            UpgradePickaxeText:setText("PICKAXE MAXED!")
            UpgradePickaxe:setVisibility(false)
        end
        BackPackText:setText("BACKPACK" .. "\n" .. Slots .. "/" .. SlotsLimit)
        BalanceText:setText("$" .. Balance)
        generateShaft()
        lastShaftRegenerationTime=os.clock()

        for _, model in pairs(PickaxeModels) do
            if model.obj then
                model.obj:setVisibility(false)
                  model.obj:setCollision(false)
            end
        end

        if currentPickaxeModel.obj then
            currentPickaxeModel.obj:setVisibility(true)
        end

        updatePickaxeModel()
        previusPos = Vec3.new(LocalPlayer.rightHandPosition.x,LocalPlayer.rightHandPosition.y, LocalPlayer.rightHandPosition.z)
    end

    dist = Vec3.new(LocalPlayer.rightHandPosition.x,LocalPlayer.rightHandPosition.y, LocalPlayer.rightHandPosition.z):distance(previusPos)
    previusPos = Vec3.new(LocalPlayer.rightHandPosition.x,LocalPlayer.rightHandPosition.y, LocalPlayer.rightHandPosition.z)

    if (HowMuchBlocksMined >= 4000 or (currentTime - lastShaftRegenerationTime) >= SHAFT_REGENERATION_TIME) then 
        generateShaft()
        lastShaftRegenerationTime=currentTime
        HowMuchBlocksMined = 0
    end

    BackPackText.position = LocalPlayer.leftHandPosition + Vec3.new(0,0.05,0)
    BackPackText.rotation = LocalPlayer.leftHandRotation * Quat.fromEuler(0, -90, 90)
    BalanceText.position = LocalPlayer.rightHandPosition + Vec3.new(0,0.05,0)
    BalanceText.rotation = LocalPlayer.rightHandRotation * Quat.fromEuler(0, 90, -90)
    if currentPickaxeModel and currentPickaxeModel.obj then
        currentPickaxeModel.obj.position = LocalPlayer.rightHandPosition
        currentPickaxeModel.obj.rotation = LocalPlayer.rightHandRotation * currentPickaxeModel.rotation
        Pickaxe_Hitbox.position = LocalPlayer.rightHandPosition + Vec3.rotate(Vec3.new(0, 0, 0.4), LocalPlayer.rightHandRotation)
        Pickaxe_Hitbox.rotation = LocalPlayer.rightHandRotation
    end

    local touchedBlock = checkTouchedBlocks()
    if touchedBlock then
        if isSlotsFull then
            if currentTime - lastSoundTime >= 1 then
                playSound(6, LocalPlayer.bodyPosition, 0.7)
                lastSoundTime = currentTime
            end
        else
            local blockName = getBlockNameByObject(touchedBlock)
            if blockName then
        
            -- Получаем список доступных блоков для текущего уровня кирки
                local allowedBlocks = PickaxeMiningTiers[currentPickaxeLevel] or {}
                local canMine = false
            
                -- Проверяем, есть ли текущий блок в списке доступных
                for _, allowedBlock in ipairs(allowedBlocks) do
                    if blockName == allowedBlock then
                        canMine = true
                        break
                    end
                end
            
                if canMine then
                    -- Если блок можно добывать текущей киркой
                    local blockCooldown = miningCooldowns[blockName]
                    local miningSpeed = blockCooldown / PickaxeUpgrades[currentPickaxeLevel].speed
                
                    if (currentTime - lastMinedTime) >= miningSpeed and dist>=0.04 then
                        playSound(3, LocalPlayer.bodyPosition, 0.1)
                        startVibration(false, 0.3, 0.1)
                    
                        lastMinedTime = currentTime
                        table.insert(BackPack, blockName)
                        local pos = touchedBlock.position
                        emitEvent("BlockMined", {pos.x, pos.y, pos.z})
                        onEvent("BlockMined", {pos.x, pos.y, pos.z})
                        Slots = Slots + 1
                        BackPackText:setText("BACKPACK" .. "\n" .. Slots .. "/" .. SlotsLimit)
                    
                        if Slots >= SlotsLimit then
                            isSlotsFull = true 
                        end
                    end
                end
            end
        end
    end



    if isInZone(SellZone) and (os.clock() - lastSellTime) >= COOLDOWN_TIME then
        if #BackPack > 0 then
            SellZoneParticle:setActive(true)
            setTimeout(1, function() 
                SellZoneParticle:setActive(false)
            end)
            lastSellTime = os.clock()
            local prices = {
                Stone = 1,              -- (45% блоков)
                Coal_Ore = 4,           -- Было 6
                Iron_Ore = 15,          -- Было 23
                Gold_Ore = 40,          -- Было 60
                Diamond_Ore = 100,      -- Было 200
        
                Deepslate = 2,          -- Было 3
                Deepslate_Coal_Ore = 8, -- Было 12
                Deepslate_Iron_Ore = 20,-- Было 30
                Deepslate_Gold_Ore = 80,-- Было 120
                Deepslate_Diamond_Ore = 200 -- Было 400
            }

            for i = #BackPack, 1, -1 do
                local blockType = BackPack[i]
                local price = prices[blockType] or 0
                Balance = Balance + price
                table.remove(BackPack, i)
            end

            Slots = 0
            isSlotsFull = false

            BackPackText:setText("BACKPACK" .. "\n" .. Slots .. "/" .. SlotsLimit)
            BalanceText:setText("$" .. Balance)
            saveGameData()
        end
    end
    
    if isUpgradePressed(UpgradeBackPack) and (os.clock() - lastUpgradeTime) >= COOLDOWN_TIME then
        local nextIndex = currentBackPackUpgradeIndex + 2  -- +2 потому что начинаем с -1
        if nextIndex <= #BackPackUpgrades then
            local nextUpgrade = BackPackUpgrades[nextIndex]
            if nextUpgrade and nextUpgrade.cost <= Balance then
                BuyZoneParticle:setActive(true)
                setTimeout(1, function() 
                BuyZoneParticle:setActive(false)
                end)
                lastUpgradeTime = os.clock()
                Balance = Balance - nextUpgrade.cost
                SlotsLimit = nextUpgrade.slots
                currentBackPackUpgradeIndex = currentBackPackUpgradeIndex + 1
                BalanceText:setText("$" .. Balance)
                BackPackText:setText("BACKPACK" .. "\n" .. Slots .. "/" .. SlotsLimit)
                
                -- Обновляем текст следующего апгрейда
                if currentBackPackUpgradeIndex + 2 <= #BackPackUpgrades then
                    UpgradeBackPackText:setText("UPGRADE BACKPACK\nCOST: " .. BackPackUpgrades[currentBackPackUpgradeIndex + 2].cost)
                else
                    UpgradeBackPackText:setText("BACKPACK MAXED!")
                    UpgradeBackPack:setVisibility(false)
                end
                saveGameData()
            end
        end
    end

    if isUpgradePressed(UpgradePickaxe) and (os.clock() - lastUpgradeTime) >= COOLDOWN_TIME then
        -- Проверяем, есть ли следующий уровень
        if currentPickaxeLevel < #PickaxeUpgrades then
            local nextUpgrade = PickaxeUpgrades[currentPickaxeLevel + 1]
            if nextUpgrade and nextUpgrade.cost <= Balance then
                BuyZoneParticle:setActive(true)
                setTimeout(1, function() 
                    BuyZoneParticle:setActive(false)
                end)
                lastUpgradeTime = os.clock()
                Balance = Balance - nextUpgrade.cost
                currentPickaxeLevel = currentPickaxeLevel + 1
                updatePickaxeModel()
                BalanceText:setText("$" .. Balance)
                
                -- Обновляем текст следующего апгрейда или скрываем кнопку
                if currentPickaxeLevel < #PickaxeUpgrades then
                    UpgradePickaxeText:setText("UPGRADE PICKAXE\nCOST: " .. PickaxeUpgrades[currentPickaxeLevel + 1].cost)
                else
                    UpgradePickaxeText:setText("PICKAXE MAXED!")
                    UpgradePickaxe:setVisibility(false)
                end
                saveGameData()
            end
        end
    end

    if isInZone(BuyZone) then
        BuyZoneText:setVisibility(false)
        PickaxeUI:setVisibility(true)
        BackPackUI:setVisibility(true)
        UpgradePickaxeText:setVisibility(true)
        UpgradeBackPackText:setVisibility(true)
        UpgradeBackPack:setVisibility(true)
        UpgradePickaxe:setVisibility(true)
        arrow3D:setVisibility(true)
        arrow3D_1:setVisibility(true)
    else
        BuyZoneText:setVisibility(true)
        PickaxeUI:setVisibility(false)
        BackPackUI:setVisibility(false)
        UpgradePickaxeText:setVisibility(false)
        UpgradeBackPackText:setVisibility(false)
        UpgradeBackPack:setVisibility(false)
        UpgradePickaxe:setVisibility(false)
        arrow3D:setVisibility(false)
        arrow3D_1:setVisibility(false)
    end
end
