local input = PlayerInput

-- Заполняем массив объектов
local ForestObj = {
    GameObject.findGameObject("VerticalWall_1"),
    GameObject.findGameObject("VerticalWall_2"),
    GameObject.findGameObject("SoundPostForest"),
    GameObject.findGameObject("Ladder"),
    GameObject.findGameObject("CampfireGroup"),
    GameObject.findGameObject("PicnicTable"),
    GameObject.findGameObject("Slide"),
    GameObject.findGameObject("LampPost_2"),
    GameObject.findGameObject("ConcreteSlab"),
    GameObject.findGameObject("RoofGazibo"),
    GameObject.findGameObject("RoofSupports"),
    GameObject.findGameObject("Blocker_10"),
    GameObject.findGameObject("Blocker_11"),
    GameObject.findGameObject("Blocker_12"),
    GameObject.findGameObject("Blocker_13"),
    GameObject.findGameObject("LadderWood"),
    GameObject.findGameObject("ScoreBoard"),
    GameObject.findGameObject("FlatPlatform"),
    GameObject.findGameObject("StumpGroup"),
    GameObject.findGameObject("TreeHouse"),
    GameObject.findGameObject("LampPost_3"),
    GameObject.findGameObject("LampPost_1"),
    GameObject.findGameObject("RampGroup_1"),
    GameObject.findGameObject("TreePlatform_9"),
    GameObject.findGameObject("RampGroup_2"),
    GameObject.findGameObject("TreeHouseLadder"),
    GameObject.findGameObject("Bridge"),
    GameObject.findGameObject("TreePlatform_1"),
    GameObject.findGameObject("TreePlatform_2"),
    GameObject.findGameObject("TreePlatform_8"),
    GameObject.findGameObject("TreePlatform_6"),
    GameObject.findGameObject("TreePlatform_5"),
    GameObject.findGameObject("TreePlatform_3"),
    GameObject.findGameObject("TreePlatform_4"),
    GameObject.findGameObject("TreePlatform_7"),
    GameObject.findGameObject("Tree6"),
    GameObject.findGameObject("Tree9"),
    GameObject.findGameObject("Tree1"),
    GameObject.findGameObject("Tree2"),
    GameObject.findGameObject("SmallTreeHouse_Tree"),
    GameObject.findGameObject("Tree5"),
    GameObject.findGameObject("Tree17"),
    GameObject.findGameObject("Tree10"),
    GameObject.findGameObject("Tree13"),
    GameObject.findGameObject("Tree4"),
    GameObject.findGameObject("Tree8"),
    GameObject.findGameObject("Tree16"),
    GameObject.findGameObject("Tree3"),
    GameObject.findGameObject("Tree19"),
    GameObject.findGameObject("Tree14"),
    GameObject.findGameObject("Tree18"),
    GameObject.findGameObject("Tree11"),
    GameObject.findGameObject("Tree15"),
    GameObject.findGameObject("Tree7"),
    GameObject.findGameObject("Tree12")
}

local isStarted = false
local grabbedObjects = {}

function findPlayerByID(id)
    if not Players then return nil end
    for _, plr in pairs(Players) do
        if plr and plr.playerID == id then
            return plr
        end
    end
    return nil
end


-- Переменные для хранения захваченных объектов
local rightHandHeldObject = nil
local leftHandHeldObject = nil

-- Переменные для определения начала захвата
local isRightGripPressed = false
local isLeftGripPressed = false

function isTouchingItemWithHand(gameObject, handPosition)
    local objScale = gameObject.scale
    local objPos = gameObject.position
    
    -- Рассчитываем границы
    local minBounds = objPos - (objScale * 0.6)
    local maxBounds = objPos + (objScale * 0.6)
    
    return handPosition.x >= minBounds.x
        and handPosition.x <= maxBounds.x
        and handPosition.y >= minBounds.y
        and handPosition.y <= maxBounds.y
        and handPosition.z >= minBounds.z
        and handPosition.z <= maxBounds.z
end

function sendGrabEvent(handType, objectIndex)
    emitEvent("grabEvent", {LocalPlayer.playerID, handType, objectIndex})
    onEvent("grabEvent", {LocalPlayer.playerID, handType, objectIndex})
end

function onEvent(tag, data)
    if tag == "grabEvent" then
        local playerID = data[1]
        local handType = data[2]  -- 0 = left, 1 = right
        local objectIndex = data[3]
        
        -- Инициализация состояния игрока, если нужно
        if not grabbedObjects[playerID] then
            grabbedObjects[playerID] = {right = -1, left = -1}
        end
        
        -- Сохраняем предыдущее состояние для руки
        local prevIndex
        if handType == 1 then
            prevIndex = grabbedObjects[playerID].right
            grabbedObjects[playerID].right = objectIndex
        else
            prevIndex = grabbedObjects[playerID].left
            grabbedObjects[playerID].left = objectIndex
        end
        
        -- Обработка коллизии для предыдущего объекта (который отпустили)
        if prevIndex ~= -1 then
            if prevIndex >= 1 and prevIndex <= #ForestObj then
                local obj = ForestObj[prevIndex]
                if obj then
                    -- Включаем коллизию для отпущенного объекта
                    obj:setCollision(true)
                end
            end
        end
        
        -- Обработка коллизии для нового объекта (который взяли)
        if objectIndex ~= -1 then
            if objectIndex >= 1 and objectIndex <= #ForestObj then
                local obj = ForestObj[objectIndex]
                if obj then
                    -- Выключаем коллизию для взятого объекта
                    obj:setCollision(false)
                end
            end
        end
    end
end

function findObjectIndex(obj)
    for i = 1, #ForestObj do
        if ForestObj[i] == obj then
            return i
        end
    end
    return -1
end

function tick()
    if not isStarted then
        isStarted = true
        grabbedObjects[LocalPlayer.playerID] = {right = -1, left = -1}
    end
    
    -- Обработка захвата правой рукой
    if input.rightGrip > 0.5 then
        if not isRightGripPressed then
            isRightGripPressed = true
            
            if not rightHandHeldObject then
                for i, obj in ipairs(ForestObj) do
                    -- Проверяем что объект свободен
                    local isFree = true
                    for _, state in pairs(grabbedObjects) do
                        if state.right == i or state.left == i then
                            isFree = false
                            break
                        end
                    end
                    
                    if obj and isFree and isTouchingItemWithHand(obj, LocalPlayer.rightHandPosition) then
                        rightHandHeldObject = obj
                        
                        -- Обновляем состояние
                        local index = findObjectIndex(obj)
                        grabbedObjects[LocalPlayer.playerID].right = index
                        
                        -- Отправляем событие
                        sendGrabEvent(1, index)
                        break
                    end
                end
            end
        end
        
        -- Удерживание объекта
        if rightHandHeldObject then
            rightHandHeldObject.position = LocalPlayer.rightHandPosition
            rightHandHeldObject.rotation = LocalPlayer.rightHandRotation
        end
    else
        if isRightGripPressed then
            isRightGripPressed = false
            
            if rightHandHeldObject then
                -- Обновляем состояние
                sendGrabEvent(1, -1)
                grabbedObjects[LocalPlayer.playerID].right = -1
                rightHandHeldObject = nil
            end
        end
    end

    -- Обработка захвата левой рукой
    if input.leftGrip > 0.5 then
        if not isLeftGripPressed then
            isLeftGripPressed = true
            
            if not leftHandHeldObject then
                for i, obj in ipairs(ForestObj) do
                    local isFree = true
                    for _, state in pairs(grabbedObjects) do
                        if state.right == i or state.left == i then
                            isFree = false
                            break
                        end
                    end
                    
                    if obj and isFree and isTouchingItemWithHand(obj, LocalPlayer.leftHandPosition) then
                        leftHandHeldObject = obj
                        
                        local index = findObjectIndex(obj)
                        grabbedObjects[LocalPlayer.playerID].left = index
                        sendGrabEvent(0, index)
                        break
                    end
                end
            end
        end
        
        if leftHandHeldObject then
            leftHandHeldObject.position = LocalPlayer.leftHandPosition
            leftHandHeldObject.rotation = LocalPlayer.leftHandRotation
        end
    else
        if isLeftGripPressed then
            isLeftGripPressed = false
            
            if leftHandHeldObject then
                sendGrabEvent(0, -1)
                grabbedObjects[LocalPlayer.playerID].left = -1
                leftHandHeldObject = nil
            end
        end
    end
    
    -- Обновляем объекты, которые держат другие игроки
    for playerID, grabState in pairs(grabbedObjects) do
        -- Пропускаем локального игрока
        if playerID ~= LocalPlayer.playerID then
            local player = findPlayerByID(playerID)
            if player then
                -- Правая рука
                if grabState.right and grabState.right >= 1 and grabState.right <= #ForestObj then
                    local obj = ForestObj[grabState.right]
                    if obj then
                        obj.position = player.rightHandPosition
                        obj.rotation = player.rightHandRotation
                    end
                end
                
                -- Левая рука
                if grabState.left and grabState.left >= 1 and grabState.left <= #ForestObj then
                    local obj = ForestObj[grabState.left]
                    if obj then
                        obj.position = player.leftHandPosition
                        obj.rotation = player.leftHandRotation
                    end
                end
            end
        end
    end
end
