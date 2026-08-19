-- // Gelişmiş ESP Sistemi + Tracer (Test Amaçlı) // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local espEnabled = false
local tracerEnabled = false
local maxDistance = 700

local espContainer = Instance.new("Folder")
espContainer.Name = "ESP_Container"
espContainer.Parent = CoreGui

local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "TracerGui"
tracerGui.Parent = CoreGui
tracerGui.Enabled = true

local function isTarget(player)
    if player == localPlayer then return false end
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end
    if humanoid.Health <= 0 then return false end
    
    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    local distance = (rootPart.Position - localRoot.Position).Magnitude
    return distance <= maxDistance
end

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

-- // Tracer çizgisi oluştur // --
local function createTracer(character, player)
    local frame = Instance.new("Frame")
    frame.Name = "Tracer_" .. player.Name
    frame.Size = UDim2.new(0, 1, 0, 1)
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0, 0.5)
    frame.Parent = tracerGui
    
    -- Yanlış anlaşılmayı önlemek için ekstra kontrol
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not tracerEnabled or not espEnabled then
            frame.Visible = false
            connection:Disconnect()
            frame:Destroy()
            return
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart or not localRoot then
            frame.Visible = false
            return
        end
        
        local distance = (rootPart.Position - localRoot.Position).Magnitude
        if distance > maxDistance then
            frame.Visible = false
            return
        end
        
        -- Ekran koordinatlarına çevir
        local screenPoint, onScreen = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
        
        if onScreen then
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local screenX = screenPoint.X
            local screenY = screenPoint.Y
            local centerX = viewportSize.X / 2
            local centerY = viewportSize.Y / 2
            
            local deltaX = screenX - centerX
            local deltaY = screenY - centerY
            local length = math.sqrt(deltaX * deltaX + deltaY * deltaY)
            local angle = math.deg(math.atan2(deltaY, deltaX))
            
            frame.Visible = true
            frame.Position = UDim2.new(0, centerX, 0, centerY)
            frame.Rotation = angle
            frame.Size = UDim2.new(0, length, 0, 1)
        else
            frame.Visible = false
        end
    end)
    
    return frame
end

local function clearESP()
    for _, v in pairs(espContainer:GetChildren()) do
        if v:IsA("Highlight") or v:IsA("BillboardGui") then
            v:Destroy()
        end
    end
end

local function clearTracers()
    for _, v in pairs(tracerGui:GetChildren()) do
        if v:IsA("Frame") then
            v:Destroy()
        end
    end
end

local function updateESP()
    clearESP()
    clearTracers()

    if not espEnabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if isTarget(player) then
            createBox(player.Character)
            createNameTag(player.Character, player)
            if tracerEnabled then
                createTracer(player.Character, player)
            end
        end
    end
end

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        espEnabled = not espEnabled
        if not espEnabled then
            tracerEnabled = false
        end
        updateESP()
        print("[ESP] Sistem durumu: " .. (espEnabled and "AÇIK" or "KAPALI"))
    end
    
    if input.KeyCode == Enum.KeyCode.T then
        if espEnabled then
            tracerEnabled = not tracerEnabled
            updateESP()
            print("[Tracer] Sistem durumu: " .. (tracerEnabled and "AÇIK" or "KAPALI"))
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not espEnabled then return end
    
    for _, v in pairs(espContainer:GetChildren()) do
        if v:IsA("BillboardGui") and v.Adornee and v.Adornee.Parent then
            local character = v.Adornee.Parent
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local label = v:FindFirstChildOfClass("TextLabel")
                if label then
                    local player = Players:GetPlayerFromCharacter(character)
                    if player then
                        label.Text = player.Name .. " | " .. math.floor(humanoid.Health) .. " HP"
                    end
                end
            end
        end
    end
end)

print("[ESP] Test aracı yüklendi.")
print("[ESP] E tuşu: ESP aç/kapat")
print("[Tracer] T tuşu: Tracer aç/kapat")
print("[ESP] Maksimum mesafe: " .. maxDistance .. " studs")
