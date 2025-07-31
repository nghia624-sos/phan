local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FramNpcMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Parent = gui

local uiList = Instance.new("UIListLayout", frame)
uiList.Padding = UDim.new(0, 5)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top

-- Nút bật/tắt
local toggle = Instance.new("TextButton")
toggle.Text = "Bật Fram"
toggle.Size = UDim2.new(0, 200, 0, 30)
toggle.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
toggle.Parent = frame

-- Bán kính
local radiusBox = Instance.new("TextBox")
radiusBox.PlaceholderText = "Bán kính quay (VD: 10)"
radiusBox.Text = "10"
radiusBox.Size = UDim2.new(0, 200, 0, 30)
radiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusBox.TextColor3 = Color3.new(1,1,1)
radiusBox.Parent = frame

-- Tốc độ
local speedBox = Instance.new("TextBox")
speedBox.PlaceholderText = "Tốc độ quay (VD: 2)"
speedBox.Text = "2"
speedBox.Size = UDim2.new(0, 200, 0, 30)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Parent = frame

-- Biến điều khiển
local running = false

-- Tìm mục tiêu chứa tên "CityNpc"
local function findNearestTarget()
	local nearest, minDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

-- Auto Aim + Đánh
task.spawn(function()
	while true do wait(0.1)
		if running then
			local target = findNearestTarget()
			if target and target:FindFirstChild("Humanoid") then
				-- Tăng tốc đánh
				if humanoid and humanoid.WalkSpeed < 32 then
					humanoid.WalkSpeed = 32
				end
				-- Auto đánh
				mouse1click()
			end
		end
	end
end)

-- Auto Heal
task.spawn(function()
	while true do wait(1)
		if running and humanoid.Health < humanoid.MaxHealth * 0.6 then
			for _, item in pairs(player.Backpack:GetChildren()) do
				if item:IsA("Tool") and string.lower(item.Name):find("heal") then
					item.Parent = char
					wait(0.2)
					item:Activate()
				end
			end
		end
	end
end)

-- TweenService chạy vòng quanh mục tiêu
task.spawn(function()
	while true do wait(0.03)
		if running then
			local radius = tonumber(radiusBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 2
			local target = findNearestTarget()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
				local goalPos = target.HumanoidRootPart.Position + offset
				goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
				local goalCF = CFrame.new(goalPos, target.HumanoidRootPart.Position)
				TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()
			end
		end
	end
end)

-- Nút toggle Fram
toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = running and "Tắt Fram" or "Bật Fram"
	toggle.BackgroundColor3 = running and Color3.fromRGB(200,60,60) or Color3.fromRGB(60,180,60)
end)