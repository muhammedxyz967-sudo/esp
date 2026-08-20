-- ============================================================
-- DIAGNOSTIC FLING + TELEPORT  •  Executor LocalScript
-- Hardened fling (Heartbeat spam + max force)
-- ============================================================

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("FlingDiagnosticGui") then
	PlayerGui.FlingDiagnosticGui:Destroy()
end

----------------------------------------------------------------
-- GUI (unchanged)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingDiagnosticGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 300, 0, 440)
Main.Position = UDim2.new(0.5, -150, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(50, 50, 60)
stroke.Thickness = 1.2

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 14)
TitleFix.Position = UDim2.new(0, 0, 1, -14)
TitleFix.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -44, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FLING  •  EXECUTOR"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(230, 230, 240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(190, 190, 200)
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local dragging, dragStart, startPos = false, nil, nil
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

local ListHeader = Instance.new("TextLabel")
ListHeader.Size = UDim2.new(1, -28, 0, 20)
ListHeader.Position = UDim2.new(0, 14, 0, 46)
ListHeader.BackgroundTransparency = 1
ListHeader.Text = "PLAYERS"
ListHeader.Font = Enum.Font.GothamMedium
ListHeader.TextSize = 11
ListHeader.TextColor3 = Color3.fromRGB(130, 130, 145)
ListHeader.TextXAlignment = Enum.TextXAlignment.Left
ListHeader.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "PlayerList"
Scroll.Size = UDim2.new(1, -28, 0, 250)
Scroll.Position = UDim2.new(0, 14, 0, 70)
Scroll.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 8)

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Padding = UDim.new(0, 5)
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
	for _, b in pairs(playerButtons) do b:Destroy() end
	playerButtons = {}
end

local function updateList()
	clearList()
	local y = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Name = plr.Name
			btn.Size = UDim2.new(1, -4, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
			btn.Text = "  " .. plr.DisplayName .. "  (@" .. plr.Name .. ")"
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.TextColor3 = Color3.fromRGB(210, 210, 220)
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.BorderSizePixel = 0
			btn.Parent = Scroll
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

			btn.MouseButton1Click:Connect(function()
				for _, b in pairs(playerButtons) do
					b.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
				end
				btn.BackgroundColor3 = Color3.fromRGB(55, 95, 170)
				selectedPlayer = plr
				Status.Text = "Selected → " .. plr.DisplayName
			end)

			table.insert(playerButtons, btn)
			y = y + 35
		end
	end
	Scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(y + 10, 0))
end

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -28, 0, 18)
Status.Position = UDim2.new(0, 14, 1, -108)
Status.BackgroundTransparency = 1
Status.Text = "Select a player"
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextColor3 = Color3.fromRGB(140, 140, 155)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local FlingBtn = Instance.new("TextButton")
FlingBtn.Size = UDim2.new(0.48, -8, 0, 42)
FlingBtn.Position = UDim2.new(0, 14, 1, -82)
FlingBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 55)
FlingBtn.Text = "FLING"
FlingBtn.Font = Enum.Font.GothamBold
FlingBtn.TextSize = 14
FlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBtn.BorderSizePixel = 0
FlingBtn.Parent = Main
Instance.new("UICorner", FlingBtn).CornerRadius = UDim.new(0, 8)

local TPBtn = Instance.new("TextButton")
TPBtn.Size = UDim2.new(0.48, -8, 0, 42)
TPBtn.Position = UDim2.new(0.52, 0, 1, -82)
TPBtn.BackgroundColor3 = Color3.fromRGB(35, 115, 190)
TPBtn.Text = "TELEPORT"
TPBtn.Font = Enum.Font.GothamBold
TPBtn.TextSize = 14
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TPBtn.BorderSizePixel = 0
TPBtn.Parent = Main
Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 8)

----------------------------------------------------------------
-- HARDENED FLING
----------------------------------------------------------------
local flingConnection = nil

local function stopFling()
	if flingConnection then
		flingConnection:Disconnect()
		flingConnection = nil
	end
end

local function flingTarget(target)
	stopFling()
	if not target or not target.Character then return false end

	local root = target.Character:FindFirstChild("HumanoidRootPart")
	local hum  = target.Character:FindFirstChildOfClass("Humanoid")
	if not root then return false end

	-- Kill states that fight the launch
	if hum then
		pcall(function()
			hum.PlatformStand = true
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end)
	end

	-- Create force objects
	local bv = Instance.new("BodyVelocity")
	bv.Name = "DiagFling"
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.P = 99999
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.Parent = root

	local bav = Instance.new("BodyAngularVelocity")
	bav.Name = "DiagSpin"
	bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bav.P = 99999
	bav.AngularVelocity = Vector3.new(0, 0, 0)
	bav.Parent = root

	local start = tick()
	local duration = 0.65   -- keep forcing for this long

	flingConnection = RunService.Heartbeat:Connect(function()
		if not root or not root.Parent or tick() - start > duration then
			stopFling()
			if bv and bv.Parent then bv:Destroy() end
			if bav and bav.Parent then bav:Destroy() end
			if hum then
				pcall(function() hum.PlatformStand = false end)
			end
			return
		end

		-- Extreme random velocity every frame
		local power = 180000 + math.random(0, 90000)
		local vx = (math.random() - 0.5) * power
		local vy = math.random(90000, 220000)
		local vz = (math.random() - 0.5) * power

		bv.Velocity = Vector3.new(vx, vy, vz)
		bav.AngularVelocity = Vector3.new(
			math.random(-90, 90),
			math.random(-120, 120),
			math.random(-90, 90)
		)

		-- Direct assembly write (most important)
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.new(vx, vy, vz)
			root.AssemblyAngularVelocity = bav.AngularVelocity
			root.Velocity = Vector3.new(vx, vy, vz) -- legacy fallback
		end)
	end)

	return true
end

----------------------------------------------------------------
-- TELEPORT
----------------------------------------------------------------
local function teleportTo(target)
	if not target or not target.Character then return false end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local myChar = LocalPlayer.Character
	if not targetRoot or not myChar then return false end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return false end
	myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
	return true
end

----------------------------------------------------------------
-- Buttons
----------------------------------------------------------------
FlingBtn.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		Status.Text = "No player selected"
		return
	end
	local ok = flingTarget(selectedPlayer)
	Status.Text = ok and ("Fling active → " .. selectedPlayer.DisplayName) or "Target invalid"
	local orig = FlingBtn.BackgroundColor3
	FlingBtn.BackgroundColor3 = Color3.fromRGB(230, 70, 80)
	task.wait(0.12)
	FlingBtn.BackgroundColor3 = orig
end)

TPBtn.MouseButton1Click:Connect(function()
	if not selectedPlayer then
		Status.Text = "No player selected"
		return
	end
	local ok = teleportTo(selectedPlayer)
	Status.Text = ok and ("TP → " .. selectedPlayer.DisplayName) or "Target invalid"
	local orig = TPBtn.BackgroundColor3
	TPBtn.BackgroundColor3 = Color3.fromRGB(55, 145, 220)
	task.wait(0.12)
	TPBtn.BackgroundColor3 = orig
end)

----------------------------------------------------------------
-- List
----------------------------------------------------------------
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

task.spawn(function()
	while ScreenGui.Parent do
		task.wait(1.8)
		updateList()
	end
end)
