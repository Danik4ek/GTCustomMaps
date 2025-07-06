-- Меню-кнопки
local Red = GameObject.findGameObject("Red")
local Blue = GameObject.findGameObject("Blue")
local Green = GameObject.findGameObject("Green")
local Yellow = GameObject.findGameObject("Yellow")
local White = GameObject.findGameObject("White")
local Black = GameObject.findGameObject("Black")
local SPTimer = GameObject.findGameObject("SPTimer")
local SPStart = GameObject.findGameObject("SPStart")
local SPStage = GameObject.findGameObject("SPStage")

-- Цветовые индикаторы
local ChoosenColorRed = GameObject.findGameObject("ChoosenColorRed")
local ChoosenColorBlue = GameObject.findGameObject("ChoosenColorBlue")
local ChoosenColorGreen = GameObject.findGameObject("ChoosenColorGreen")
local ChoosenColorYellow = GameObject.findGameObject("ChoosenColorYellow")
local ChoosenColorWhite = GameObject.findGameObject("ChoosenColorWhite")
local ChoosenColorBlack = GameObject.findGameObject("ChoosenColorBlack")

-- Состояния
local WhatColorChoosen = "white"
local gridSize = 5
local gameStarted = false
local startTime = 0
local timeElapsed = 0
local completedCount = 0
local waitingForNextStage = false
local stageDelayStart = 0

-- Таблицы
local pixelGrid = {}
local playerGrid = {}
local paintGrid = {}
local currentPattern = nil
local remainingPatterns = {}
local leaderboard = {}
local maxLeaders = 10

-- УЗОРЫ
local patterns = {
    {
        ["1,1"]="red",["1,2"]="white",["1,3"]="blue",["1,4"]="white",["1,5"]="black",
        ["2,1"]="white",["2,2"]="blue",["2,3"]="blue",["2,4"]="white",["2,5"]="red",
        ["3,1"]="green",["3,2"]="white",["3,3"]="black",["3,4"]="white",["3,5"]="green",
        ["4,1"]="white",["4,2"]="blue",["4,3"]="blue",["4,4"]="white",["4,5"]="yellow",
        ["5,1"]="red",["5,2"]="white",["5,3"]="blue",["5,4"]="white",["5,5"]="red"
    },
    {
        ["1,1"]="green",["1,2"]="green",["1,3"]="green",["1,4"]="green",["1,5"]="green",
        ["2,1"]="white",["2,2"]="white",["2,3"]="white",["2,4"]="white",["2,5"]="white",
        ["3,1"]="blue",["3,2"]="blue",["3,3"]="blue",["3,4"]="blue",["3,5"]="blue",
        ["4,1"]="white",["4,2"]="white",["4,3"]="white",["4,4"]="white",["4,5"]="white",
        ["5,1"]="red",["5,2"]="red",["5,3"]="red",["5,4"]="red",["5,5"]="red"
    },
    {
        ["1,1"]="black",["1,2"]="black",["1,3"]="black",["1,4"]="black",["1,5"]="black",
        ["2,1"]="black",["2,2"]="white",["2,3"]="white",["2,4"]="white",["2,5"]="black",
        ["3,1"]="black",["3,2"]="white",["3,3"]="yellow",["3,4"]="white",["3,5"]="black",
        ["4,1"]="black",["4,2"]="white",["4,3"]="white",["4,4"]="white",["4,5"]="black",
        ["5,1"]="black",["5,2"]="black",["5,3"]="black",["5,4"]="black",["5,5"]="black"
    },
    {
        ["1,1"]="white",["1,2"]="white",["1,3"]="red",["1,4"]="white",["1,5"]="white",
        ["2,1"]="white",["2,2"]="red",["2,3"]="red",["2,4"]="red",["2,5"]="white",
        ["3,1"]="red",["3,2"]="red",["3,3"]="red",["3,4"]="red",["3,5"]="red",
        ["4,1"]="white",["4,2"]="red",["4,3"]="red",["4,4"]="red",["4,5"]="white",
        ["5,1"]="white",["5,2"]="white",["5,3"]="red",["5,4"]="white",["5,5"]="white"
    },
    {
        ["1,1"]="blue",["1,2"]="blue",["1,3"]="white",["1,4"]="blue",["1,5"]="blue",
        ["2,1"]="blue",["2,2"]="white",["2,3"]="white",["2,4"]="white",["2,5"]="blue",
        ["3,1"]="white",["3,2"]="white",["3,3"]="yellow",["3,4"]="white",["3,5"]="white",
        ["4,1"]="blue",["4,2"]="white",["4,3"]="white",["4,4"]="white",["4,5"]="blue",
        ["5,1"]="blue",["5,2"]="blue",["5,3"]="white",["5,4"]="blue",["5,5"]="blue"
    }
}

-- Цветовой индикатор
function updateColorIndicator()
    ChoosenColorRed:setVisibility(WhatColorChoosen == "red")
    ChoosenColorBlue:setVisibility(WhatColorChoosen == "blue")
    ChoosenColorGreen:setVisibility(WhatColorChoosen == "green")
    ChoosenColorYellow:setVisibility(WhatColorChoosen == "yellow")
    ChoosenColorWhite:setVisibility(WhatColorChoosen == "white")
    ChoosenColorBlack:setVisibility(WhatColorChoosen == "black")
end

function isButtonPressed(obj)
    local lh, rh = LocalPlayer.leftHandPosition, LocalPlayer.rightHandPosition
    local minB = obj.position - (obj.scale * 0.5)
    local maxB = obj.position + (obj.scale * 0.5)
    local function inBox(p)
        return p.x >= minB.x and p.x <= maxB.x and p.y >= minB.y and p.y <= maxB.y and p.z >= minB.z and p.z <= maxB.z
    end
    return inBox(lh) or inBox(rh)
end

for x = 1, gridSize do
    pixelGrid[x] = {}
    paintGrid[x] = {}
    playerGrid[x] = {}
    for y = 1, gridSize do
        local px = "Pixel_"..x.."_"..y
        local pt = "Paint_"..x.."_"..y
        pixelGrid[x][y] = {
            Red = GameObject.findGameObject(px.."_Red"),
            Blue = GameObject.findGameObject(px.."_Blue"),
            Green = GameObject.findGameObject(px.."_Green"),
            Yellow = GameObject.findGameObject(px.."_Yellow"),
            White = GameObject.findGameObject(px.."_White"),
            Black = GameObject.findGameObject(px.."_Black"),
            Base = GameObject.findGameObject(px)
        }
        paintGrid[x][y] = {
            Red = GameObject.findGameObject(pt.."_Red"),
            Blue = GameObject.findGameObject(pt.."_Blue"),
            Green = GameObject.findGameObject(pt.."_Green"),
            Yellow = GameObject.findGameObject(pt.."_Yellow"),
            White = GameObject.findGameObject(pt.."_White"),
            Black = GameObject.findGameObject(pt.."_Black")
        }
        for _, obj in pairs(paintGrid[x][y]) do obj:setVisibility(false) end
        paintGrid[x][y].White:setVisibility(true)
        for color, obj in pairs(pixelGrid[x][y]) do
            if color ~= "White" and color ~= "Base" then obj:setVisibility(false) end
        end
        pixelGrid[x][y].White:setVisibility(true)
        playerGrid[x][y] = "white"
    end
end

-- Покраска пикселя
function paintPixel(x, y)
    for color, obj in pairs(pixelGrid[x][y]) do
        if color ~= "Base" then obj:setVisibility(false) end
    end
    local col = string.gsub(WhatColorChoosen, "^%l", string.upper)
    pixelGrid[x][y][col]:setVisibility(true)
    playerGrid[x][y] = WhatColorChoosen
    checkPattern()
end

-- Следующий узор
function pickNextPattern()
    if #remainingPatterns == 0 then return end
    local patternIndex = table.remove(remainingPatterns, 1)
    currentPattern = patterns[patternIndex]
    for x = 1, gridSize do
        for y = 1, gridSize do
            local key = x..","..y
            local col = string.gsub(currentPattern[key], "^%l", string.upper)
            for _, obj in pairs(paintGrid[x][y]) do obj:setVisibility(false) end
            paintGrid[x][y][col]:setVisibility(true)
            for color, obj in pairs(pixelGrid[x][y]) do
                if color ~= "White" and color ~= "Base" then obj:setVisibility(false) end
            end
            pixelGrid[x][y].White:setVisibility(true)
            playerGrid[x][y] = "white"
        end
    end
end

function checkPattern()
    for x = 1, gridSize do
        for y = 1, gridSize do
            if playerGrid[x][y] ~= currentPattern[x..","..y] then return end
        end
    end

    completedCount = completedCount + 1
    playSound(1, Vec3.new(0, 0, 0), 1)

    if completedCount == 5 then
        gameStarted = false
        SPStage:setText("Finish!")
        SPStart:setVisibility(true)
        local timeTaken = os.clock() - startTime
        emitEvent("gameFinished", { timeTaken, LocalPlayer })
        onEvent("gameFinished", { timeTaken, LocalPlayer })
        return
    end

    waitingForNextStage = true
    stageDelayStart = os.clock()
    SPStage:setText("Stage "..(completedCount + 1).."/5")
end

function onEvent(tag, data)
    if tag == "gameFinished" then
        local time = data[1]
        local player = data[2]
        local name = player.playerName
        for i = 1, #leaderboard do
            if leaderboard[i].name == name then return end
        end
        table.insert(leaderboard, { name = name, time = time })
        if #leaderboard > maxLeaders then table.remove(leaderboard) end

        for i = 1, #leaderboard do
            local nameObj = GameObject.findGameObject("Name"..i)
            local timeObj = GameObject.findGameObject("Time"..i)
            if nameObj then nameObj:setText(leaderboard[i].name) end
            if timeObj then timeObj:setText(string.format("%.2f", leaderboard[i].time)) end
        end
    end
end

function tick()
    if not gameStarted and isButtonPressed(SPStart) then
        gameStarted = true
        startTime = os.clock()
        timeElapsed = 0
        SPStart:setVisibility(false)
        completedCount = 0

        remainingPatterns = {}
        for i = 1, #patterns do table.insert(remainingPatterns, i) end
        math.randomseed(os.clock() * 1000)
        for i = #remainingPatterns, 2, -1 do
            local j = math.random(1, i)
            remainingPatterns[i], remainingPatterns[j] = remainingPatterns[j], remainingPatterns[i]
        end

        SPStage:setText("Stage 1/5")
        pickNextPattern()
    end

    if gameStarted then
        timeElapsed = os.clock() - startTime
        local m = math.floor(timeElapsed / 60)
        local s = math.floor(timeElapsed % 60)
        local ms = math.floor((timeElapsed % 1) * 100)
        SPTimer:setText(string.format("%02d:%02d.%02d", m, s, ms))

        if waitingForNextStage then
            if os.clock() - stageDelayStart >= 1 then
                waitingForNextStage = false
                pickNextPattern()
            end
            return
        end
    end

    -- Выбор цвета
    if isButtonPressed(Red) then WhatColorChoosen = "red"; updateColorIndicator()
    elseif isButtonPressed(Blue) then WhatColorChoosen = "blue"; updateColorIndicator()
    elseif isButtonPressed(Green) then WhatColorChoosen = "green"; updateColorIndicator()
    elseif isButtonPressed(Yellow) then WhatColorChoosen = "yellow"; updateColorIndicator()
    elseif isButtonPressed(White) then WhatColorChoosen = "white"; updateColorIndicator()
    elseif isButtonPressed(Black) then WhatColorChoosen = "black"; updateColorIndicator() end

    -- Рисование
    if gameStarted and not waitingForNextStage then
        for x = 1, gridSize do
            for y = 1, gridSize do
                if isButtonPressed(pixelGrid[x][y].Base) then
                    paintPixel(x, y)
                end
            end
        end
    end
end
