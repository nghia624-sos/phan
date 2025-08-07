-- GUI Menu "TT:dongphandzs1" - Tách tab Fram NPC và Spin
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Biến điều khiển
local autoFram = false
local spinToggle = false
local radius = 10
local speed = 2
local spinSpeed = math.pi -- rad/s

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TT_dongphandzs1"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 400, 0, 280)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Tabs = Instance.new("Folder", Frame)
Tabs.Name = "Tabs"

-- Tab buttons
local tabButtons = {}
local currentTab = nil

function createTab(name)
	local tabBtn = Instance.new("TextButton", Frame)
	tabBtn.Text = name
	tabBtn.Size = UDim2.new(0, 120, 0, 30)
	tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 14
	tabBtn.Position = UDim2.new(0, #tabButtons * 120, 0, 0)

	local tabFrame = Instance.new("Frame", Tabs)
	tabFrame.Name = name
	tabFrame.Visible = false
	tabFrame.Size = UDim2.new(1, 0, 1, -30)
	tabFrame.Position = UDim2.new(0, 0, 0, 30)
	tabFrame.BackgroundTransparency = 1

	tabBtn.MouseButton1Click:Connect(function()
		if currentTab then currentTab.Visible = false end
		tabFrame.Visible = true
		currentTab = tabFrame
	end)

	table.insert(tabButtons, tabBtn)
	if not currentTab then
		currentTab = tabFrame
		tabFrame.Visible = true
	end
	return tabFrame
end

-- TAB Fram NPC
local tabFram = createTab("Fram NPC")

local framToggle = Instance.new("TextButton", tabFram)
framToggle.Size = UDim2.new(0, 200, 0, 40)
framToggle.Position = UDim2.new(0, 20, 0, 20)
framToggle.Text = "🔁 Bật Fram NPC: OFF"
framToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
framToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
framToggle.MouseButton1Click:Connect(function()
	autoFram = not autoFram
	framToggle.Text = autoFram and "🔁 Bật Fram NPC: ON" or "🔁 Bật Fram NPC: OFF"
end)

local radiusBox = Instance.new("TextBox", tabFram)
radiusBox.Size = UDim2.new(0, 200, 0, 30)
radiusBox.Position = UDim2.new(0, 20, 0, 70)
radiusBox.PlaceholderText = "Bán kính vòng tròn (vd: 10)"
radiusBox.Text = ""

radiusBox.FocusLost:Connect(function()
	local val = tonumber(radiusBox.Text)
	if val then radius = val end
end)

local speedBox = Instance.new("TextBox", tabFram)
speedBox.Size = UDim2.new(0, 200, 0, 30)
speedBox.Position = UDim2.new(0, 20, 0, 110)
speedBox.PlaceholderText = "Tốc độ chạy vòng (vd: 2)"
speedBox.Text = ""

speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text)
	if val then speed = val end
end)

-- TAB Spin
local tabSpin = createTab("Spin")

local spinSlider = Instance.new("TextBox", tabSpin)
spinSlider.Size = UDim2.new(0, 200, 0, 30)
spinSlider.Position = UDim2.new(0, 20, 0, 20)
spinSlider.PlaceholderText = "Tốc độ quay radian/s"
spinSlider.Text = ""

spinSlider.FocusLost:Connect(function()
	local val = tonumber(spinSlider.Text)
	if val then spinSpeed = val end
end)

local spinButton = Instance.new("TextButton", tabSpin)
spinButton.Size = UDim2.new(0, 200, 0, 40)
spinButton.Position = UDim2.new(0, 20, 0, 60)
spinButton.Text = "⏱️ Quay người: OFF"
spinButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
spinButton.TextColor3 = Color3.fromRGB(255, 255, 255)

spinButton.MouseButton1Click:Connect(function()
	spinToggle = not spinToggle
	spinButton.Text = spinToggle and "⏱️ Quay người: ON" or "⏱️ Quay người: OFF"
end)

-- Tìm NPC
function getTarget()
	local lowestDist, chosen = math.huge, nil
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			local name = v.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < lowestDist then
					lowestDist = dist
					chosen = v
				end
			end
		end
	end
	return chosen
end

-- Move tự nhiên
function moveToTarget(target)
	local hum = Character:FindFirstChild("Humanoid")
	if hum then
		hum:MoveTo(target.HumanoidRootPart.Position)
		hum.MoveToFinished:Wait()
	end
end

-- Quay mặt
function faceTarget(target)
	if not target or not HRP then return end
	local look = (target.HumanoidRootPart.Position - HRP.Position).Unit
	HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + look)
end

-- Vòng quanh + đánh
function circleTarget(target)
	spawn(function()
		while autoFram and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
			local tPos = target.HumanoidRootPart.Position
			local angle = tick() * speed
			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			local goalPos = tPos + Vector3.new(x, 0, z)
			local tween = TweenService:Create(HRP, TweenInfo.new(0.2), {CFrame = CFrame.new(goalPos, tPos)})
			tween:Play()
			wait(0.2)
		end
	end)
end

-- Auto đánh
function autoAttack(target)
	spawn(function()
		while autoFram and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
			local tool = Character:FindFirstChildOfClass("Tool")
			if tool then
				local attack = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("RemoteFunction")
				if attack then
					pcall(function()
						attack:FireServer()
					end)
				end
			end
			wait(0.4)
		end
	end)
end

-- Main Loop
spawn(function()
	while wait(0.5) do
		if autoFram then
			local target = getTarget()
			if target then
				moveToTarget(target)
				faceTarget(target)
				wait(0.2)
				circleTarget(target)
				autoAttack(target)
				while autoFram and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
					wait()
				end
			end
		end
	end
end)

-- Spin nhân vật
spawn(function()
	while wait() do
		if spinToggle and HRP then
			HRP.CFrame *= CFrame.Angles(0, spinSpeed * wait(), 0)
		end
	end
end)