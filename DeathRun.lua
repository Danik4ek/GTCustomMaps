local DeathRunButton1 = GameObject.findGameObject("DeathRunButton1")
local DeathRunButton2 = GameObject.findGameObject("DeathRunButton2")
local DeathRunButton3 = GameObject.findGameObject("DeathRunButton3")
local DeathRunButton4 = GameObject.findGameObject("DeathRunButton4")
local DeathRunButton5 = GameObject.findGameObject("DeathRunButton5")
local DeathRunButton6 = GameObject.findGameObject("DeathRunButton6")
local DeathRunButton7 = GameObject.findGameObject("DeathRunButton7")
local DeathRunButton8 = GameObject.findGameObject("DeathRunButton8")
local DeathRunButton9Red = GameObject.findGameObject("DeathRunButton91")
local DeathRunButton9Green = GameObject.findGameObject("DeathRunButton92")
local DeathRunGlass = GameObject.findGameObject("DeathRunGlass")
local is1ButtonActivate = false
local is2ButtonActivate = false
local is3ButtonActivate = false
local is4ButtonActivate = false
local is5ButtonActivate = false
local is6ButtonActivate = false
local is7ButtonActivate = false
local is8ButtonActivate = false
local is9ButtonActivate = false


-- Ловушки
local DeathRunTrap1 = GameObject.findGameObject("DeathRunTrap1")
local DeathRunTrap2 = GameObject.findGameObject("DeathRunTrap2")
local DeathRunTrap21 = GameObject.findGameObject("DeathRunTrap21")
DeathRunTrap21:setCollision(false)
local initialX = DeathRunTrap2.rotation:euler().x
local DeathRunTrap31 = GameObject.findGameObject("DeathRunTrap31")
local DeathRunTrap32 = GameObject.findGameObject("DeathRunTrap32")
local DeathRunTrap33 = GameObject.findGameObject("DeathRunTrap33")
local DeathRunTrap41 = GameObject.findGameObject("DeathRunTrap41")
local DeathRunTrap42 = GameObject.findGameObject("DeathRunTrap42")
DeathRunTrap41:setCollision(false)
DeathRunTrap42:setCollision(false)
DeathRunTrap41:setVisibility(false)
DeathRunTrap42:setVisibility(false)
local DeathRunTrap5 = GameObject.findGameObject("DeathRunTrap5")
local DeathRunTrap6 = GameObject.findGameObject("DeathRunTrap6")
DeathRunTrap6:setCollision(false)
local WindTunnelRibbons = GameObject.findGameObject("WindTunnelRibbons")
WindTunnelRibbons:setVisibility(false)
local DeathRunTrap7 = GameObject.findGameObject("DeathRunTrap7")
local DeathRunTrap8 = GameObject.findGameObject("DeathRunTrap8")
DeathRunTrap8:setCollision(false)
DeathRunTrap8:setVisibility(false)
local DeathRunTrapRed = GameObject.findGameObject("RedDoor")
local DeathRunTrapGreen = GameObject.findGameObject("GreenDoor")

-- Остальные объекты
local DeathRunTeleporter = GameObject.findGameObject("DeathRunTeleporter")
DeathRunTeleporter:setCollision(false)
local FinishGame = GameObject.findGameObject("FinishGame")
local Teleport = GameObject.findGameObject("Teleporter")
Teleport:setCollision(false)
local KillZone = GameObject.findGameObject("lava")
local isGreenActive = false
local isRedActive = false
local StartTrap7 = false
local StartTrap2 = false
local HowManyPlayersDied = 0
local isDeathTeleported = false
local targetID = 11
local deathTeleportFirstTime = false
isDeathRunTeleporterTeleported = true

-- Таблица для хранения отложенных функций
local DelayedFunctions = {}

-- Функция для создания таймера
function setTimeout(delay, func)
    local timeout = {
        endTime = os.clock() + delay,
        callback = func
    }
    table.insert(DelayedFunctions, timeout)
end

-- Функция для обработки таймеров
function shallowCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

-- Обновлённая функция handleTimeouts
function handleTimeouts()
    local currentTime = os.clock()
    for i = #DelayedFunctions, 1, -1 do
        local timeout = DelayedFunctions[i]
        if timeout and currentTime >= timeout.endTime then
            local success, err = pcall(timeout.callback)
            if not success then
                print("Ошибка в таймауте:", err)
            end
            table.remove(DelayedFunctions, i)
        end
    end
end


-- Функция проверки нажатия кнопки
function isButtonPressed(gameObject)
    local leftHand = LocalPlayer.leftHandPosition
    local rightHand = LocalPlayer.rightHandPosition
 
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
 
    return isWithinBounds(leftHand) or isWithinBounds(rightHand)
end

function isInTrap(gameObject)
    local leftHand = LocalPlayer.leftHandPosition
    local rightHand = LocalPlayer.rightHandPosition
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
 
    return isWithinBounds(leftHand) or isWithinBounds(rightHand) or isWithinBounds(body)
end

-- Обработчик событий
function onEvent(tag, data)

    if tag == "ActivateTrap1" then
        is1ButtonActivate = true
        DeathRunButton1:setVisibility(false)
        DeathRunTrap1:setVisibility(false)
        DeathRunTrap1:setCollision(false)
        setTimeout(5, function()
            DeathRunTrap1:setVisibility(true)
            DeathRunTrap1:setCollision(true)
        end)
    end

    if tag == "ActivateTrap2" then
        is2ButtonActivate = true
        DeathRunButton2:setVisibility(false)
        StartTrap2 = true
        DeathRunTrap21:setCollision(true)
        setTimeout(5, function()
            DeathRunTrap21:setCollision(false)
        end)
    end

    if tag == "ActivateTrap3" then
        is3ButtonActivate = true
        DeathRunButton3:setVisibility(false)
        DeathRunTrap31:setVisibility(false)
        DeathRunTrap31:setCollision(false)
        DeathRunTrap32:setVisibility(false)
        DeathRunTrap32:setCollision(false)
        DeathRunTrap33:setVisibility(false)
        DeathRunTrap33:setCollision(false)
        setTimeout(5, function()
            DeathRunTrap31:setVisibility(true)
            DeathRunTrap31:setCollision(true)
            DeathRunTrap32:setVisibility(true)
            DeathRunTrap32:setCollision(true)
            DeathRunTrap33:setVisibility(true)
            DeathRunTrap33:setCollision(true)
        end)
    end

    if tag == "ActivateTrap4" then
        is4ButtonActivate = true
        DeathRunButton4:setVisibility(false)
        DeathRunGlass:setVisibility(false)
        DeathRunGlass:setCollision(false)
        DeathRunTrap41:setVisibility(true)
        DeathRunTrap42:setVisibility(true)
        DeathRunTrap41:setCollision(true)
        DeathRunTrap42:setCollision(true)
        setTimeout(10, function()
            DeathRunGlass:setVisibility(true)
            DeathRunGlass:setCollision(true)
            DeathRunTrap41:setVisibility(false)
            DeathRunTrap42:setVisibility(false)
            DeathRunTrap41:setCollision(false)
            DeathRunTrap42:setCollision(false)
        end)
    end

    if tag == "ActivateTrap5" then
        is5ButtonActivate = true
        DeathRunButton5:setVisibility(false)
        DeathRunTrap5:setVisibility(false)
        DeathRunTrap5:setCollision(false)
        setTimeout(5, function()
            DeathRunTrap5:setVisibility(true)
            DeathRunTrap5:setCollision(true)
        end)
    end

    if tag == "ActivateTrap6" then
        is6ButtonActivate = true
        DeathRunButton6:setVisibility(false)
        DeathRunTrap6:setCollision(true)
        WindTunnelRibbons:setVisibility(true)
        setTimeout(5, function()
            DeathRunTrap6:setCollision(false)
            WindTunnelRibbons:setVisibility(false)
        end)
    end

    if tag == "ActivateTrap7" then
        is7ButtonActivate = true
        DeathRunButton7:setVisibility(false)
        StartTrap7 = true
    end

    if tag == "ActivateTrap8" then
        is8ButtonActivate = true
        DeathRunButton8:setVisibility(false)
        DeathRunTrap8:setCollision(true)
        DeathRunTrap8:setVisibility(true)
        setTimeout(5, function()
            DeathRunTrap8:setCollision(false)
            DeathRunTrap8:setVisibility(false)
        end)
    end

    if tag == "ActivateTrap9Red" then
        is9ButtonActivate = true
        DeathRunButton9Red:setVisibility(false)
        DeathRunButton9Green:setVisibility(false)
        isRedActive = true
    end

    if tag == "ActivateTrap9Green" then
        is9ButtonActivate = true
        DeathRunButton9Red:setVisibility(false)
        DeathRunButton9Green:setVisibility(false)
        isGreenActive = true
    end

    if tag == "SetDeathTeleport" then
        targetID = data[1]
        if LocalPlayer.playerID == targetID then
            DeathRunTeleporter:setCollision(true)
            setTimeout(3, function()
            DeathRunTeleporter:setCollision(false)
        end)
        end
    end

    if tag == "PlayerDied" then
        HowManyPlayersDied = HowManyPlayersDied + 1
    end

    if tag == "ResetGame" then
        -- Сброс счётчика
        HowManyPlayersDied = 0

        -- Сброс состояний кнопок
        is1ButtonActivate = false
        is2ButtonActivate = false
        is3ButtonActivate = false
        is4ButtonActivate = false
        is5ButtonActivate = false
        is6ButtonActivate = false
        is7ButtonActivate = false
        is8ButtonActivate = false
        is9ButtonActivate = false
        isGreenActive = false
        isRedActive = false

        -- Снова показать кнопки
        DeathRunButton1:setVisibility(true)
        DeathRunButton2:setVisibility(true)
        DeathRunButton3:setVisibility(true)
        DeathRunButton4:setVisibility(true)
        DeathRunButton5:setVisibility(true)
        DeathRunButton6:setVisibility(true)
        DeathRunButton7:setVisibility(true)
        DeathRunButton8:setVisibility(true)
        DeathRunButton9Red:setVisibility(true)
        DeathRunButton9Green:setVisibility(true)

        -- Включить телепорт
        Teleport:setCollision(true)
        setTimeout(5, function()
            Teleport:setCollision(false)
            isDeathTeleported = false
        end)
    end

end

-- Основной цикл
function tick()
    -- Обрабатываем таймеры
    handleTimeouts()

    if isDeathRunTeleporterTeleported then
     isDeathRunTeleporterTeleported=false
     DeathRunTeleporter.position=Vec3.new(DeathRunTeleporter.position.x, DeathRunTeleporter.position.y-10, DeathRunTeleporter.position.z)
    end

    if #Players==1 and is1ButtonActivate and is2ButtonActivate and is3ButtonActivate and is4ButtonActivate and is5ButtonActivate and is6ButtonActivate and is7ButtonActivate and is8ButtonActivate and is9ButtonActivate and LocalPlayer.isMasterClient then
        emitEvent("ResetGame", { 1 })
        onEvent("ResetGame", { 1 })
    end

    if #Players>1 and LocalPlayer.isMasterClient and HowManyPlayersDied+1==#Players then
        emitEvent("ResetGame", { 1 })
        onEvent("ResetGame", { 1 })
    end

    if not isDeathTeleported and LocalPlayer.isMasterClient then
        isDeathTeleported = true
        local selectedPlayer = LocalPlayer  -- по умолчанию сам игрок
        if deathTeleportFirstTime then
            local allPlayers = {}
            for _, player in pairs(Players) do
                table.insert(allPlayers, player)
            end

            if #allPlayers > 0 then
                local randIndex = math.random(1, #allPlayers)
                selectedPlayer = allPlayers[randIndex]
            end
        else
            deathTeleportFirstTime = true
        end

        emitEvent("SetDeathTeleport", { selectedPlayer.playerID })
        onEvent("SetDeathTeleport", { selectedPlayer.playerID })
    end


    if StartTrap7 then
        StartTrap7=false
        for count7 = 1, 29 do
            setTimeout(count7/30, function()
                DeathRunTrap7.position = Vec3.new(DeathRunTrap7.position.x, DeathRunTrap7.position.y-0.2316, DeathRunTrap7.position.z)
            end)
        end
        setTimeout(7, function()
            DeathRunTrap7.position = Vec3.new(DeathRunTrap7.position.x, DeathRunTrap7.position.y+7, DeathRunTrap7.position.z)
        end)
    end

    if StartTrap2 then
        StartTrap2 = false
        for count2 = 1, 49 do
            setTimeout(count2/10, function()
                DeathRunTrap2.rotation = Quat.fromEuler(initialX + count2 * 5, -90, -90)
            end)
        end
    end

    -- Проверяем нажатие кнопки
    if isButtonPressed(DeathRunButton1) and not is1ButtonActivate then
        emitEvent("ActivateTrap1", {1})
        onEvent("ActivateTrap1", {1})
    end

    if isButtonPressed(DeathRunButton2) and not is2ButtonActivate then
        emitEvent("ActivateTrap2", {1})
        onEvent("ActivateTrap2", {1})
    end

    if isButtonPressed(DeathRunButton3) and not is3ButtonActivate then
        emitEvent("ActivateTrap3", {1})
        onEvent("ActivateTrap3", {1})
    end

    if isButtonPressed(DeathRunButton4) and not is4ButtonActivate then
        emitEvent("ActivateTrap4", {1})
        onEvent("ActivateTrap4", {1})
    end

    if isButtonPressed(DeathRunButton5) and not is5ButtonActivate then
        emitEvent("ActivateTrap5", {1})
        onEvent("ActivateTrap5", {1})
    end

    if isButtonPressed(DeathRunButton6) and not is6ButtonActivate then
        emitEvent("ActivateTrap6", {1})
        onEvent("ActivateTrap6", {1})
    end

    if isButtonPressed(DeathRunButton7) and not is7ButtonActivate then
        emitEvent("ActivateTrap7", {1})
        onEvent("ActivateTrap7", {1})
    end

    if isButtonPressed(DeathRunButton8) and not is8ButtonActivate then
        emitEvent("ActivateTrap8", {1})
        onEvent("ActivateTrap8", {1})
    end

    if isButtonPressed(DeathRunButton9Red) and not is9ButtonActivate then
        emitEvent("ActivateTrap9Red", {1})
        onEvent("ActivateTrap9Red", {1})
    end

    if isButtonPressed(DeathRunButton9Green) and not is9ButtonActivate then
        emitEvent("ActivateTrap9Green", {1})
        onEvent("ActivateTrap9Green", {1})
    end

    if isInTrap(DeathRunTrapRed) and isRedActive then
        Teleport:setCollision(true)
        emitEvent("PlayerDied", {1})
        onEvent("PlayerDied", {1})
    end

    if isInTrap(DeathRunTrapGreen) and isGreenActive then
        Teleport:setCollision(true)
        emitEvent("PlayerDied", {1})
        onEvent("PlayerDied", {1})
    end

    if isInTrap(KillZone) then
        Teleport:setCollision(true)
        emitEvent("PlayerDied", {1})
        onEvent("PlayerDied", {1})
    end

    if isInTrap(DeathRunTrap7) then
        Teleport:setCollision(true)
        emitEvent("PlayerDied", {1})
        onEvent("PlayerDied", {1})
    end

    if isInTrap(FinishGame) then
        emitEvent("ResetGame", { 1 })
        onEvent("ResetGame", { 1 })
    end
end
