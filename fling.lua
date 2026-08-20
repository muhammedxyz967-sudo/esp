-- Roblox LocalScript (executor context)
-- Draggable diagnostic panel + live player list + fling test

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up any previous instance
if PlayerGui:FindFirstChild("FlingDiagnosticGui") then
    PlayerGui.FlingDiagnosticGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingDiagnosticGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 280, 0, 380)
Main.Position = UDim2.new(0.5, -140, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 55)
UIStroke.Thickness = 1
UIStroke.Parent = Main

-- Title Bar (drag handle)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DIAGNOSTIC • FLING"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextColor3 = Color3.fromRGB(220, 220, 230)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Drag logic
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Player List Header
local ListHeader = Instance.new("TextLabel")
ListHeader.Size = UDim2.new(1, -24, 0, 22)
ListHeader.Position = UDim2.new(0, 12, 0, 44)
ListHeader.BackgroundTransparency = 1
ListHeader.Text = "PLAYERS IN SERVER"
ListHeader.Font = Enum.Font.GothamMedium
ListHeader.TextSize = 11
ListHeader.TextColor3 = Color3.fromRGB(140, 140, 155)
ListHeader.TextXAlignment = Enum.TextXAlignment.Left
ListHeader.Parent = Main

-- ScrollingFrame for players
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "PlayerList"
Scroll.Size = UDim2.new(1, -24, 0, 240)
Scroll.Position = UDim2.new(0, 12, 0, 68)
Scroll.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = Scroll

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Padding = UDim.new(0, 4)
ListLayout.Parent = Scroll

local ListPad = Instance.new("UIPadding")
ListPad.PaddingTop = UDim.new(0, 6)
ListPad.PaddingBottom = UDim.new(0, 6)
ListPad.PaddingLeft = UDim.new(0, 6)
ListPad.PaddingRight = UDim.new(0, 6)
ListPad.Parent = Scroll

local selectedPlayer = nil
local playerButtons = {}

local function clearList()
    for _, btn in pairs(playerButtons) do
        btn:Destroy()
    end
    playerButtons = {}
end

local function updateList()
    clearList()
    local y = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Name = plr.Name
            btn.Size = UDim2.new(1, -4, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
            btn.Text = "  " .. plr.DisplayName .. "  (@" .. plr.Name .. ")"
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            btn.Parent = Scroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 5)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                for _, b in pairs(playerButtons) do
                    b.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
                end
                btn.BackgroundColor3 = Color3.fromRGB(55, 90, 160)
                selectedPlayer = plr
            end)

            table.insert(playerButtons, btn)
            y = y + 32
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(y + 12, 0))
end

-- Fling Button
local FlingBtn = Instance.new("TextButton")
FlingBtn.Name = "FlingButton"
FlingBtn.Size = UDim2.new(1, -24, 0, 40)
FlingBtn.Position = UDim2.new(0, 12, 1, -56)
FlingBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
FlingBtn.Text = "FLING SELECTED"
FlingBtn.Font = Enum.Font.GothamBold
FlingBtn.TextSize = 14
FlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBtn.BorderSizePixel = 0
FlingBtn.Parent = Main

local FlingCorner = Instance.new("UICorner")
FlingCorner.CornerRadius = UDim.new(0, 6)
FlingCorner.Parent = FlingBtn

local function flingTarget(target)
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- High-force BodyVelocity (test fling)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "DiagnosticFling"
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(
        math.random(-120, 120),
        math.random(80, 160),
        math.random(-120, 120)
    )
    bv.Parent = root

    task.delay(0.35, function()
        if bv and bv.Parent then
            bv:Destroy()
        end
    end)
end

FlingBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        flingTarget(selectedPlayer)
        -- brief visual feedback
        local original = FlingBtn.BackgroundColor3
        FlingBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 90)
        task.wait(0.15)
        FlingBtn.BackgroundColor3 = original
    end
end)

-- Live refresh
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(2)
        updateList()
    end
end)
