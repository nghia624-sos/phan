local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI Setup (Fix cho KRNL Mobile)
local gui = Instance.new("ScreenGui")
gui.Name = "FramNpcMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 200)
frame.Position = UDim2.new(0, 20, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fram Npc"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Size = UDim2.new(0, 100, 0, 30)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

local radiusLabel = Instance.new("TextLabel", frame)
radiusLabel.Position = UDim2.new(0, 10, 0, 80)
radiusLabel.Size = UDim2.new(0, 100, 0, 20)
radiusLabel.Text = "Bán kính:"
radiusLabel.TextColor3 = Color3.new(1,1,1)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Font = Enum.Font.SourceSans
radiusLabel.TextSize = 14

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Position = UDim2.new(0, 110, 0, 80)
radiusBox.Size = UDim2.new(0, 50, 0, 20)
radiusBox.Text = "8"
radiusBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
radiusBox.TextColor3 = Color3.new(0,0,0)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 14

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Position = UDim2.new(0, 10, 0, 110)
speedLabel.Size = UDim2.new(0, 100, 0, 20)
speedLabel.Text = "Tốc độ quay:"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14

local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 110, 0, 110)
speedBox.Size = UDim2.new(0, 50, 0, 20)
speedBox.Text = "1"
speedBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
speedBox.TextColor3 = Color3.new(0,0,0)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14

-- Logic
local farming = false

-- Tìm mục tiêu có chứa 'CityNPC'
local function findTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") then
				return v
			end
		end
	end
	return nil
end

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

		-- Tính vị trí
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local dest = target.HumanoidRootPart.Position + offset

		-- Hướng về mục tiêu
		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)

		-- Di chuyển
		humanoid:MoveTo(dest)

		-- Tăng tốc đánh
		humanoid.WalkSpeed = 20
		humanoid.JumpPower = 0

		-- Tự đánh
		for _, tool in pairs(char:GetChildren()) do
			if tool:IsA("Tool") then
				tool:Activate()
			end
		end

		-- Tự hồi máu
		if humanoid.Health < humanoid.MaxHealth * 0.6 then
			humanoid.Health = humanoid.Health + 1
		end

		angle += tonumber(speed)
		task.wait(0.1)
	end
end

toggle.MouseButton1Click:Connect(function()
	farming = not farming
	toggle.Text = farming and "Tắt Fram" or "Bật Fram"
	toggle.BackgroundColor3 = farming and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 170, 0)

	if farming then
		spawn(function()
			while farming do
				local target = findTarget()
				if target then
					repeat
						humanoid:MoveTo(target.HumanoidRootPart.Position)
						task.wait(0.2)
					until not farming or (hrp.Position - target.HumanoidRootPart.Position).Magnitude <= tonumber(radiusBox.Text) + 2

					circleTarget(target, tonumber(radiusBox.Text), tonumber(speedBox.Text) * 0.1)
				end
				task.wait(0.5)
			end
		end)
	else
		humanoid.WalkSpeed = 16
	end
end)