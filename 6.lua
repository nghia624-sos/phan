-- DỊCH VỤ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- BIẾN
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local radius = 20
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Menu_TT"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")
gui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 270)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -135)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Parent = gui
mainFrame.Active = true
mainFrame.Draggable = false -- dùng custom kéo

local frame = Instance.new("ScrollingFrame")
frame.Parent = mainFrame
frame.Size = UDim2.new(1, 0, 1, 0)
frame.CanvasSize = UDim2.new(0, 0, 0, 270)
frame.ScrollBarThickness = 6
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.ClipsDescendants = true

-- KÉO GUI
local dragging, dragInput, dragStart, startPos
local function updateInput(input)
	if not dragging then return end
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput then
		updateInput(input)
	end
end)

-- NÚT
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "BẬT: Đánh Boss"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)

local disLabel = Instance.new("TextLabel", frame)
disLabel.Text = "Khoảng cách:"
disLabel.Size = UDim2.new(0, 150, 0, 30)
disLabel.Position = UDim2.new(0, 10, 0, 50)
disLabel.TextColor3 = Color3.new(1,1,1)
disLabel.BackgroundTransparency = 1

local disInput = Instance.new("TextBox", frame)
disInput.Size = UDim2.new(0, 100, 0, 30)
disInput.Position = UDim2.new(0, 160, 0, 50)
disInput.Text = tostring(radius)
disInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
disInput.TextColor3 = Color3.new(1,1,1)

local spdLabel = Instance.new("TextLabel", frame)
spdLabel.Text = "Tốc độ quay:"
spdLabel.Size = UDim2.new(0, 150, 0, 30)
spdLabel.Position = UDim2.new(0, 10, 0, 90)
spdLabel.TextColor3 = Color3.new(1,1,1)
spdLabel.BackgroundTransparency = 1

local spdInput = Instance.new("TextBox", frame)
spdInput.Size = UDim2.new(0, 100, 0, 30)
spdInput.Position = UDim2.new(0, 160, 0, 90)
spdInput.Text = tostring(speed)
spdInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spdInput.TextColor3 = Color3.new(1,1,1)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.TextColor3 = Color3.new(1, 0, 0)
hpLabel.BackgroundTransparency = 1

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, 0, 0, 30)
autoBtn.Position = UDim2.new(0, 0, 0, 170)
autoBtn.Text = "BẬT: Auto Đánh"
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
autoBtn.TextColor3 = Color3.new(1,1,1)

local nameText = Instance.new("TextLabel", frame)
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 230)
nameText.Text = "TT:dongphandzs1"
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.BackgroundTransparency = 1
nameText.TextScaled = true

-- MẬT KHẨU
local passGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
passGui.Name = "PassCheck"

local passFrame = Instance.new("Frame", passGui)
passFrame.Size = UDim2.new(0, 250, 0, 130)
passFrame.Position = UDim2.new(0.5, -125, 0.5, -65)
passFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
passFrame.BorderSizePixel = 0

local title = Instance.new("TextLabel", passFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "Nhập Mật Khẩu"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local input = Instance.new("TextBox", passFrame)
input.Size = UDim2.new(0.9, 0, 0, 30)
input.Position = UDim2.new(0.05, 0, 0, 45)
input.PlaceholderText = "••••••••"
input.BackgroundColor3 = Color3.fromRGB(50,50,50)
input.TextColor3 = Color3.new(1,1,1)

local btn = Instance.new("TextButton", passFrame)
btn.Size = UDim2.new(0.5, 0, 0, 30)
btn.Position = UDim2.new(0.25, 0, 0, 85)
btn.Text = "Xác nhận"
btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()
	if input.Text == "dp2119" then
		gui.Enabled = true
		passGui:Destroy()
	end
end)

-- TÌM MỤC TIÊU
local function getTarget()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			return v
		end
	end
end

-- TẤN CÔNG
local function attack()
	local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function()
			tool:Activate()
		end)
	end
end

-- MAIN LOOP
RunService.Heartbeat:Connect(function()
	if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		if currentTarget.Humanoid.Health <= 0 then
			currentTarget = getTarget()
			if not currentTarget then
				running = false
				autoAttack = false
				toggle.Text = "BẬT: Đánh Boss"
				autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
				hpLabel.Text = "Máu mục tiêu: Không còn mục tiêu"
				return
			end
		end

		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		hum:MoveTo(currentTarget.HumanoidRootPart.Position + offset)
		if autoAttack then attack() end
		hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
	elseif running then
		running = false
		autoAttack = false
		currentTarget = nil
		toggle.Text = "BẬT: Đánh Boss"
		autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
		hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
	end
end)

-- SỰ KIỆN

toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then currentTarget = getTarget() end
	toggle.Text = (running and "TẮT" or "BẬT") .. ": Đánh Boss"
end)

disInput.FocusLost:Connect(function()
	radius = tonumber(disInput.Text) or radius
end)

spdInput.FocusLost:Connect(function()
	speed = tonumber(spdInput.Text) or speed
end)

autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh (Riêng)"
end)