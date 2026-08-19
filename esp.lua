-- // Gelişmiş ESP Sistemi (Test Amaçlı) // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local espEnabled = false
local espContainer = Instance.new("Folder")
espContainer.Name = "ESP_Container"
espContainer.Parent = CoreGui

-- // Ayarlar // --
local MAX_DISTANCE = 400 -- Maksimum algılama mesafesi (studs)

-- // Tespit edilecek hedef tipleri // --
local function isTarget(player)
    if player == localPlayer then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or humanoid.Health <= 0 then return false end
    
    -- Mesafe kontrolü
    local localCharacter = localPlayer.Character
    if not localCharacter then return false end
    
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    local distance = (rootPart.Position - localRoot.Position).Magnitude
    if distance > MAX_DISTANCE then return false end
    
    return true
end

-- // Kutu çizimi // --
local function createBox(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = espContainer
    highlight.Adornee = character
    return highlight
end

-- // İsim etiketi // --
local function createNameTag(character, player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_NameTag"
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    billboard.Parent = espContainer

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Text = player.Name .. " | " .. math.floor(character.Humanoid.Health) .. " HP"
    textLabel.Parent = billboard

    return billboard
end

-- // Tüm ESP'yi temizle // --
local function clearAllESP()
    for _, v in pairs(espContainer:GetChildren()) do
        if v:IsA("Highlight") or v:IsA("BillboardGui") then
            v:Destroy()
        end
    end
end

-- // ESP güncelleme döngüsü // --
local function updateESP()
    clearAllESP()

    if not espEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if isTarget(player) then
            createBox(player.Character)
            createNameTag(player.Character, player)
        end
    end
end

-- // Karakter değişimlerini izle // --
local function onCharacterAdded(character)
    if espEnabled then
        task.wait(0.5)
        updateESP()
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        player.CharacterAdded:Connect(onCharacterAdded)
        if player.Character then
            onCharacterAdded(player.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end)

Players.PlayerRemoving:Connect(function()
    if espEnabled then
        task.wait(0.1)
        updateESP()
    end
end)

-- // E tuşu ile aç/kapat // --
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- X tuşu ile her şeyi kapat
    if input.KeyCode == Enum.KeyCode.X then
        espEnabled = false
        clearAllESP()
        print("[ESP] Sistem tamamen kapatıldı!")
        return
    end
    
    -- E tuşu ile aç/kapat
    if input.KeyCode == Enum.KeyCode.E then
        espEnabled = not espEnabled
        updateESP()
        print("[ESP] Sistem durumu: " .. (espEnabled and "AÇIK" or "KAPALI"))
    end
end)

-- // Sağlık değerlerini ve mesafeyi sürekli güncelle // --
RunService.Heartbeat:Connect(function()
    if not espEnabled then return end
    
    -- Periyodik olarak mesafe kontrolü yap
    for _, v in pairs(espContainer:GetChildren()) do
        if v:IsA("BillboardGui") and v.Adornee and v.Adornee.Parent then
            local character = v.Adornee.Parent
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                -- Mesafe kontrolü
                local localCharacter = localPlayer.Character
                if localCharacter then
                    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
                    if localRoot then
                        local distance = (rootPart.Position - localRoot.Position).Magnitude
                        
                        -- 400 studs'tan uzaksa kaldır
                        if distance > MAX_DISTANCE then
                            v:Destroy()
                            -- Eşleşen highlight'ı da kaldır
                            for _, highlight in pairs(espContainer:GetChildren()) do
                                if highlight:IsA("Highlight") and highlight.Adornee == character then
                                    highlight:Destroy()
                                end
                            end
                        else
                            -- Mesafe bilgisini etikete ekle
                            local label = v:FindFirstChildOfClass("TextLabel")
                            if label then
                                local player = Players:GetPlayerFromCharacter(character)
                                if player then
                                    label.Text = player.Name .. " | " .. math.floor(humanoid.Health) .. " HP | " .. math.floor(distance) .. "m"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- // İlk açılış mesajı // --
print("[ESP] Test aracı yüklendi.")
print("[ESP] Kontroller:")
print("[ESP] E tuşu: Aç/Kapat")
print("[ESP] X tuşu: Tamamen kapat")
print("[ESP] Maksimum mesafe: " .. MAX_DISTANCE .. " studs")
