local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNpcMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Text = "Fram NPC"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local function createLabel(text, pos)
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -20, 0, 20)
	lbl.Position = UDim2.new(0, 10, 0, pos)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.SourceSans
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	return lbl
end

local function createInput(pos, default)
	local input = Instance.new("TextBox", frame)
	input.Size = UDim2.new(1, -20, 0, 25)
	input.Position = UDim2.new(0, 10, 0, pos)
	input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	input.TextColor3 = Color3.new(1, 1, 1)
	input.Font = Enum.Font.SourceSans
	input.TextSize = 14
	input.Text = tostring(default)
	return input
end

local function createButton(text, pos, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, pos)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 16
	btn.Text = text
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Settings
local radiusInput = createInput(40, 10)
local speedInput = createInput(75, 6)
local runEnabled = false
local currentTarget

createLabel("Bán kính đánh:", 25)
createLabel("Tốc độ chạy vòng:", 60)

createButton("Bật/Tắt Fram", 110, function()
	runEnabled = not runEnabled
end)

-- Tìm NPC gần nhất
local function getNearestNPC()
	local nearest, dist = nil, math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():find("citynpc") then
			local h = obj:FindFirstChild("HumanoidRootPart")
			if h then
				local d = (h.Position - hrp.Position).Magnitude
				if d < dist then
					nearest = obj
					dist = d
				end
			end
		end
	end
	return nearest
end

-- Chạy bộ tự nhiên đến mục tiêu
local function walkTo(position)
	humanoid:MoveTo(position)
	humanoid.MoveToFinished:Wait()
end

-- Di chuyển theo vòng tròn quanh mục tiêu
local function moveInCircle(target, radius, speed)
	local angle = 0
	while runEnabled and target and target:FindFirstChild("HumanoidRootPart") do
		angle += speed / 100
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = target.HumanoidRootPart.Position + offset
		humanoid:MoveTo(targetPos)

		-- Tự xoay mặt về mục tiêu
		local lookAt = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookAt)

		-- Auto attack
		if target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
			for _, tool in ipairs(player.Character:GetChildren()) do
				if tool:IsA("Tool") then
					tool:Activate()
				end
			end
		end

		task.wait(0.1)
	end
end

-- Vòng lặp chính
task.spawn(function()
	while task.wait(1) do
		if runEnabled then
			currentTarget = getNearestNPC()
			if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
				walkTo(currentTarget.HumanoidRootPart.Position + Vector3.new(0, 0, 2)) -- đi đến gần
				moveInCircle(currentTarget, tonumber(radiusInput.Text), tonumber(speedInput.Text))
			end
		end
	end
end)