local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SPTS MODDED",
   LoadingTitle = "SPTS MODDED",
   LoadingSubtitle = "by Your Name",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "SPTSConfig",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

-- Таблица для хранения всех потоков фарма
local farmingThreads = {}

-- Переменные для ESP
local espEnabled = false
local espObjects = {}
local espLoop = nil

-- Переменные для респавна
local autoRespawnEnabled = false
local autoRespawnV2Enabled = false
local deathConnection = nil
local respawnV2Thread = nil
local shouldRespawnV2 = false

-- Переменная для оптимизации уведомлений
local lastNotificationTime = 0

-- Создаем таблицу для хранения всех кнопок и их параметров
local buttonConfigs = {
    FARM = {
        BT = {
            {"100", "+BT2"},
            {"10k", "+BT3"},
            {"100k", "+BT4"},
            {"1M", "+BT5"},
            {"10M", "+BT6"},
            {"1B", "+BT7"},
            {"100B", "+BT8"},
            {"10T", "+BT9"},
            {"5Qi", "+BT10"},
            {"1Qa", "+BT11"},
            {"50Qa", "+BT12"},
            {"450Qi", "+BT13"},
            {"40Sx", "+BT14"},
            {"3Sp", "+BT15"},
            {"250Sp", "+BT16"},
            {"20Oc", "+BT17"},
            {"2No", "+BT18"},
            {"200No", "+BT19"},
            {"15Dc", "+BT20"},
            {"1Ud", "+BT21"},
            {"250Ud", "+BT22"},
            {"10Dd", "+BT23"},
            {"1Td", "+BT24"},
            {"100Td", "+BT25"},
            {"15Qad", "+BT26"},
            {"2Qid", "+BT27"},
            {"250Qid", "+BT28"},
            {"30Sxd", "+BT29"},
            {"10Spd", "+BT30"},
            {"3Ocd", "+BT31"},
            {"1Nod", "+BT32"}
        },
        FS = {
            {"Rock", "+FS2"},
            {"Crystal", "+FS3"},
            {"1B", "+FS4"},
            {"100B", "+FS5"},
            {"10T", "+FS6"},
            {"1Qa", "+FS7"},
            {"150Qa", "+FS8"},
            {"15Qi", "+FS9"},
            {"2.55Sx", "+FS10"},
            {"1Sp", "+FS11"},
            {"500Sp", "+FS12"},
            {"250Oc", "+FS13"},
            {"150No", "+FS14"},
            {"55.5Dc", "+FS15"},
            {"30Ud", "+FS16"},
            {"11Dd", "+FS17"},
            {"4Td", "+FS18"},
            {"3Qad", "+FS19"},
            {"1.8Qid", "+FS20"},
            {"560Qid", "+FS21"},
            {"280Sxd", "+FS22"},
            {"154Spd", "+FS23"},
            {"90Ocd", "+FS24"}
        },
        PP = {
            {"1M", "+PP3"},
            {"1B", "+PP4"},
            {"1T", "+PP5"},
            {"1Qa", "+PP6"},
            {"333Qa", "+PP7"},
            {"111Qi", "+PP8"},
            {"33.3Sx", "+PP9"},
            {"11.1Sp", "+PP10"},
            {"3.36Oc", "+PP11"},
            {"1.11No", "+PP12"},
            {"444No", "+PP13"},
            {"111Dc", "+PP14"},
            {"55.5Ud", "+PP15"},
            {"22.2Dd", "+PP16"},
            {"7.7Td", "+PP17"},
            {"3.3Qad", "+PP18"},
            {"1.1Qid", "+PP19"},
            {"444Qid", "+PP20"},
            {"249.9Sxd", "+PP21"},
            {"133.3Spd", "+PP22"},
            {"88.8Ocd", "+PP23"}
        }
    },
    FARM2 = {
        ["JF and MS"] = {
            {"10Qi", {"+JF16", "+MS16"}},
            {"1sx", {"+JF17", "+MS17"}},
            {"100Sx", {"+JF18", "+MS18"}},
            {"10Sp", {"+JF19", "+MS19"}},
            {"10Oc", {"+JF20", "+MS20"}},
            {"10No", {"+JF21", "+MS21"}},
            {"10Dc", {"+JF22", "+MS22"}},
            {"10Td", {"+JF23", "+MS23"}},
            {"10Qad", {"+JF24", "+MS24"}},
            {"10Qid", {"+JF25", "+MS25"}},
            {"10Spd", {"+JF26", "+MS26"}},
            {"10Nod", {"+JF27", "+MS27"}}
        }
    }
}

-- Получаем сервисы один раз
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RemoteEvent = ReplicatedStorage.RemoteEvent
local player = Players.LocalPlayer

-- Оптимизированная функция уведомлений
local function optimizedNotify(title, content)
    local currentTime = time()
    if currentTime - lastNotificationTime >= 1 then
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = 2,
            Image = 4483362458,
        })
        lastNotificationTime = currentTime
    end
end

-- Функция очистки памяти
local function cleanupMemory()
    collectgarbage("collect")
    task.wait(0.5)
    collectgarbage("collect")
    print("🔄 Очистка памяти выполнена")
end

-- Автоматическая очистка памяти каждые 30 минут
task.spawn(function()
    while true do
        task.wait(1800)
        cleanupMemory()
    end
end)

-- Мониторинг памяти
local function monitorMemory()
    task.spawn(function()
        while true do
            task.wait(300)
            local memory = collectgarbage("count")
            if memory > 50000 then
                cleanupMemory()
            end
        end
    end)
end

monitorMemory()

-- Функции для ESP
local function createESP(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = character:WaitForChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESP_Text"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = character.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard
    
    espObjects[character] = {highlight, billboard}
end

local function removeESP(character)
    if espObjects[character] then
        for _, object in ipairs(espObjects[character]) do
            if object and object.Parent then
                object:Destroy()
            end
        end
        espObjects[character] = nil
    end
end

local function updateESP()
    local players = Players:GetPlayers()
    local count = 0
    
    for _, player in ipairs(players) do
        if player ~= Players.LocalPlayer and player.Character then
            if not espObjects[player.Character] then
                createESP(player.Character)
            end
            count += 1
            if count > 20 then break end
        end
    end
    
    for character, _ in pairs(espObjects) do
        if not character:IsDescendantOf(game) then
            removeESP(character)
        end
    end
end

local function startESP()
    if espLoop then return end
    
    espLoop = task.spawn(function()
        while espEnabled do
            updateESP()
            task.wait(2) -- Реже обновляем ESP
        end
    end)
end

local function stopESP()
    espEnabled = false
    if espLoop then
        task.cancel(espLoop)
        espLoop = nil
    end
    
    for character, _ in pairs(espObjects) do
        removeESP(character)
    end
    espObjects = {}
end

-- Функция для остановки всех потоков фарма
local function stopAllFarming()
    for buttonName, thread in pairs(farmingThreads) do
        if thread then
            task.cancel(thread)
            farmingThreads[buttonName] = nil
        end
    end
    stopRespawnV2()
    stopESP()
    cleanupMemory()
    optimizedNotify("Фарм остановлен", "Все процессы остановлены + очистка памяти")
end

-- Функция для остановки RespawnV2
local function stopRespawnV2()
    shouldRespawnV2 = false
    if respawnV2Thread then
        task.cancel(respawnV2Thread)
        respawnV2Thread = nil
    end
    autoRespawnV2Enabled = false
end

-- Функция для респавна
local function respawnPlayer()
    RemoteEvent:FireServer({"Respawn"})
end

-- Оптимизированная функция быстрого респавна
local function startFastRespawn()
    stopRespawnV2()
    
    shouldRespawnV2 = true
    autoRespawnV2Enabled = true
    
    respawnV2Thread = task.spawn(function()
        while shouldRespawnV2 do
            respawnPlayer()
            
            local startTime = time()
            while shouldRespawnV2 and time() - startTime < 10 do
                RunService.Heartbeat:Wait()
            end
        end
    end)
end

-- Оптимизированная функция запуска фарма
local function startFarming(buttonName, eventName)
    if farmingThreads[buttonName] then
        task.cancel(farmingThreads[buttonName])
        farmingThreads[buttonName] = nil
        optimizedNotify("Фарм остановлен", buttonName .. " остановлен")
        return
    end
    
    local thread = task.spawn(function()
        local lastFire = time()
        
        while farmingThreads[buttonName] do
            local currentTime = time()
            
            if currentTime - lastFire >= 0.1 then
                RemoteEvent:FireServer({eventName})
                lastFire = currentTime
            end
            
            RunService.Heartbeat:Wait()
        end
    end)
    
    farmingThreads[buttonName] = thread
    optimizedNotify("Фарм запущен", buttonName .. " активирован")
end

-- Функция для запуска фарма JF and MS
local function startJFFarming(buttonName, eventNames)
    if farmingThreads[buttonName] then
        task.cancel(farmingThreads[buttonName])
        farmingThreads[buttonName] = nil
        optimizedNotify("Фарм остановлен", buttonName .. " остановлен")
        return
    end
    
    local thread = task.spawn(function()
        local lastFire = time()
        
        while farmingThreads[buttonName] do
            local currentTime = time()
            
            if currentTime - lastFire >= 0.1 then
                for _, eventName in ipairs(eventNames) do
                    RemoteEvent:FireServer({eventName})
                end
                lastFire = currentTime
            end
            
            RunService.Heartbeat:Wait()
        end
    end)
    
    farmingThreads[buttonName] = thread
    optimizedNotify("Фарм запущен", buttonName .. " активирован")
end

-- Создаем вкладки
local FarmTab = Window:CreateTab("FARM", 4483362458)
local Farm2Tab = Window:CreateTab("FARM2", 4483362458)
local RespawnTab = Window:CreateTab("Respawn", 4483362458)
local RespawnV2Tab = Window:CreateTab("RespawnV2", 4483362458)
local UtilitiesTab = Window:CreateTab("Utilities", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)

-- Вкладка ESP
local ESPSection = ESPTab:CreateSection("Player ESP")

local ESPToggle = ESPTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        if state then
            startESP()
            optimizedNotify("ESP", "ESP включен")
        else
            stopESP()
            optimizedNotify("ESP", "ESP выключен")
        end
    end,
})

local ESPColorPicker = ESPTab:CreateColorPicker({
    Name = "Цвет ESP",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        for character, objects in pairs(espObjects) do
            if objects[1] then
                objects[1].FillColor = color
            end
        end
    end
})

local ESPTransparency = ESPTab:CreateSlider({
    Name = "Прозрачность ESP",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "%",
    CurrentValue = 0.8,
    Flag = "ESPTransparency",
    Callback = function(value)
        for character, objects in pairs(espObjects) do
            if objects[1] then
                objects[1].FillTransparency = value
            end
        end
    end
})

-- Вкладка FARM - BT
local BTSection = FarmTab:CreateSection("BT Farming")
for _, buttonConfig in ipairs(buttonConfigs.FARM.BT) do
    local Button = FarmTab:CreateButton({
        Name = buttonConfig[1],
        Callback = function()
            startFarming(buttonConfig[1], buttonConfig[2])
        end,
    })
end

-- Вкладка FARM - FS
local FSSection = FarmTab:CreateSection("FS Farming")
for _, buttonConfig in ipairs(buttonConfigs.FARM.FS) do
    local Button = FarmTab:CreateButton({
        Name = buttonConfig[1],
        Callback = function()
            startFarming(buttonConfig[1], buttonConfig[2])
        end,
    })
end

-- Вкладка FARM - PP
local PPSection = FarmTab:CreateSection("PP Farming")
for _, buttonConfig in ipairs(buttonConfigs.FARM.PP) do
    local Button = FarmTab:CreateButton({
        Name = buttonConfig[1],
        Callback = function()
            startFarming(buttonConfig[1], buttonConfig[2])
        end,
    })
end

-- Вкладка FARM2 - JF and MS
local JFSection = Farm2Tab:CreateSection("JF and MS Farming")
for _, buttonConfig in ipairs(buttonConfigs.FARM2["JF and MS"]) do
    local Button = Farm2Tab:CreateButton({
        Name = buttonConfig[1],
        Callback = function()
            startJFFarming(buttonConfig[1], buttonConfig[2])
        end,
    })
end

-- Вкладка Utilities
local ControlsSection = UtilitiesTab:CreateSection("Controls")

local StopButton = UtilitiesTab:CreateButton({
    Name = "Stop All Farming",
    Callback = function()
        stopAllFarming()
    end,
})

local CleanupButton = UtilitiesTab:CreateButton({
    Name = "Cleanup Memory",
    Callback = function()
        cleanupMemory()
        optimizedNotify("Очистка памяти", "Память успешно оптимизирована")
    end,
})

-- Вкладка Respawn
local RespawnSection = RespawnTab:CreateSection("Auto Respawn")

local function setupDeathTracking(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    if deathConnection then
        deathConnection:Disconnect()
        deathConnection = nil
    end
    
    deathConnection = humanoid.Died:Connect(function()
        if autoRespawnEnabled then
            task.wait(0.5)
            respawnPlayer()
        end
    end)
end

local RespawnToggle = RespawnTab:CreateToggle({
    Name = "Auto Respawn",
    CurrentValue = false,
    Flag = "AutoRespawnToggle",
    Callback = function(state)
        autoRespawnEnabled = state
        
        if state then
            stopRespawnV2()
            if player.Character then
                setupDeathTracking(player.Character)
            end
            optimizedNotify("Auto Respawn", "Автореспавн включен")
        else
            if deathConnection then
                deathConnection:Disconnect()
                deathConnection = nil
            end
            optimizedNotify("Auto Respawn", "Автореспавн выключен")
        end
    end,
})

local RespawnButton = RespawnTab:CreateButton({
    Name = "Respawn Now",
    Callback = function()
        respawnPlayer()
        optimizedNotify("Респавн", "Респавн выполнен")
    end,
})

-- Настраиваем отслеживание при добавлении персонажа
player.CharacterAdded:Connect(function(character)
    if autoRespawnEnabled then
        setupDeathTracking(character)
    end
end)

-- Вкладка RespawnV2
local RespawnV2Section = RespawnV2Tab:CreateSection("Fast Respawn (10s)")

local RespawnV2Toggle = RespawnV2Tab:CreateToggle({
    Name = "Auto Respawn V2 (10s)",
    CurrentValue = false,
    Flag = "AutoRespawnV2Toggle",
    Callback = function(state)
        if state then
            if autoRespawnEnabled then
                if deathConnection then
                    deathConnection:Disconnect()
                    deathConnection = nil
                end
                autoRespawnEnabled = false
            end
            startFastRespawn()
            optimizedNotify("RespawnV2", "Респавн каждые 10 секунд включен")
        else
            stopRespawnV2()
            optimizedNotify("RespawnV2", "Респавн каждые 10 секунд выключен")
        end
    end,
})

local RespawnV2Button = RespawnV2Tab:CreateButton({
    Name = "Respawn Now V2",
    Callback = function()
        respawnPlayer()
        optimizedNotify("Респавн", "Респавн выполнен")
    end,
})

local ForceStopButton = RespawnV2Tab:CreateButton({
    Name = "Force Stop RespawnV2",
    Callback = function()
        stopRespawnV2()
        optimizedNotify("RespawnV2", "Принудительно остановлен")
    end,
})

-- Настраиваем начальное состояние если персонаж уже есть
if player.Character then
    setupDeathTracking(player.Character)
end

-- Останавливаем все процессы при выходе из игры
game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        stopAllFarming()
    end
end)

-- Автоматически добавляем ESP для новых игроков
Players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function(character)
        if espEnabled then
            createESP(character)
        end
    end)
end)

-- Добавляем ESP для уже существующих игроков при включении
for _, otherPlayer in ipairs(Players:GetPlayers()) do
    if otherPlayer ~= player and otherPlayer.Character then
        if espEnabled then
            createESP(otherPlayer.Character)
        end
    end
end

optimizedNotify("SPTS MODDED", "GUI успешно загружен!")
Rayfield:LoadConfiguration()
