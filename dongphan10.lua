local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FramMenuMobile"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Tên menu
local title = Instance.new("TextLabel", gui)
title.Size = UDim2.new(0, 180, 0, 30)
title.Position = UDim2.new(0, 60, 0.3, -30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "Nghia Minh"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 520)
frame.Position = UDim2.new(0, 50, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function createInput(labelText, defaultValue, posY)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(0, 220, 0, 20)
	label.Position = UDim2.new(0, 10, 0, posY)
	label.Text = labelText .. ": " .. defaultValue
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.TextSize = 14

	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(0, 220, 0, 30)
	box.Position = UDim2.new(0, 10, 0, posY + 20)
	box.Text = tostring(defaultValue)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.Font = Enum.Font.SourceSans
	box.TextSize = 16
	box.BorderSizePixel = 0
	return box
end

local function createButton(text, posY)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 220, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text .. " [OFF]"
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	return btn
end

-- Nhãn máu
local healthLabel = Instance.new("TextLabel", gui)
healthLabel.Size = UDim2.new(0, 200, 0, 30)
healthLabel.Position = UDim2.new(1, -210, 0.05, 0)
healthLabel.BackgroundTransparency = 0.2
healthLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
healthLabel.TextColor3 = Color3.new(1, 0, 0)
healthLabel.TextSize = 18
healthLabel.Text = "Máu mục tiêu: Không có"

-- Trạng thái
local running, aiming, clicking, noclip, visible, showHitbox = false, false, false, false, true, false

-- Nút
local framBtn = createButton("Chạy Vòng", 10)
local aimBtn = createButton("Auto Aim", 50)
local clickBtn = createButton("Auto Đánh", 90)
local noclipBtn = createButton("Noclip", 130)
local toggleGUI = createButton("Ẩn/Hiện Menu", 170)
local toggleHitbox = createButton("Hiện Vùng Sát Thương", 210)

-- Input
local distanceBox = createInput("Khoảng cách", 10, 250)
local speedBox = createInput("Tốc độ", 2, 300)
local widthBox = createInput("Hitbox Width", 6, 350)
local heightBox = createInput("Hitbox Height", 6, 400)
local depthBox = createInput("Hitbox Depth", 6, 450)

-- Sự kiện nút
framBtn.MouseButton1Click:Connect(function()
	running = not running
	framBtn.Text = "Chạy Vòng [" .. (running and "ON" or "OFF") .. "]"
end)
aimBtn.MouseButton1Click:Connect(function()
	aiming = not aiming
	aimBtn.Text = "Auto Aim [" .. (aiming and "ON" or "OFF") .. "]"
end)
clickBtn.MouseButton1Click:Connect(function()
	clicking = not clicking
	clickBtn.Text = "Auto Đánh [" .. (clicking and "ON" or "OFF") .. "]"
end)
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip [" .. (noclip and "ON" or "OFF") .. "]"
end)
toggleGUI.MouseButton1Click:Connect(function()
	visible = not visible
	frame.Visible = visible
end)
toggleHitbox.MouseButton1Click:Connect(function()
	showHitbox = not showHitbox
	toggleHitbox.Text = "Hiện Vùng Sát Thương [" .. (showHitbox and "ON" or "OFF") .. "]"
end)

-- Tìm mục tiêu gần nhất
local function getNearestEnemy()
	local nearest, minDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char and v.Humanoid.Health > 0 then
			local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < minDist then
				nearest = v
				minDist = dist
			end
		end
	end
	return nearest
end

-- Theo dõi máu
task.spawn(function()
	while true do task.wait(0.2)
		local target = getNearestEnemy()
		if target and target:FindFirstChild("Humanoid") then
			healthLabel.Text = "Máu mục tiêu: " .. math.floor(target.Humanoid.Health)
		else
			healthLabel.Text = "Máu mục tiêu: Không có"
		end
	end
end)

-- Auto click
local VirtualInputManager = game:GetService("VirtualInputManager")
task.spawn(function()
	while true do task.wait(0.15)
		if clicking then
			pcall(function()
				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
				task.wait(0.05)
				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
			end)
		end
	end
end)

-- Noclip
game:GetService("RunService").Stepped:Connect(function()
	if noclip then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

-- Auto aim
task.spawn(function()
	while true do task.wait()
		if aiming then
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
			end
		end
	end
end)

-- Chạy vòng quanh
local TweenService = game:GetService("TweenService")
task.spawn(function()
	while true do task.wait(0.03)
		if running then
			local dist = tonumber(distanceBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 2
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
				local goalPos = target.HumanoidRootPart.Position + offset
				goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
				local goalCF = CFrame.new(goalPos, target.HumanoidRootPart.Position)
				TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()
			end
		end
	end
end)

-- Hiển thị hitbox thật theo vũ khí
local hitboxPart = Instance.new("Part")
hitboxPart.Anchored = true
hitboxPart.CanCollide = false
hitboxPart.Transparency = 1
hitboxPart.Color = Color3.fromRGB(255, 0, 0)
hitboxPart.Material = Enum.Material.ForceField
hitboxPart.Parent = workspace

task.spawn(function()
	while true do task.wait(0.1)
		hitboxPart.Transparency = showHitbox and 0.3 or 1
		if showHitbox then
			local tool = char:FindFirstChildOfClass("Tool")
			local handle = tool and tool:FindFirstChild("Handle")
			if handle then
				local size = Vector3.new(
					tonumber(widthBox.Text) or 6,
					tonumber(heightBox.Text) or 6,
					tonumber(depthBox.Text) or 6
				)
				hitboxPart.Size = size
				hitboxPart.CFrame = handle.CFrame
			end
		end
	end
end)