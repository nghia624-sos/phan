local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Menu GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPCMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 260)
frame.Position = UDim2.new(0, 50, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Active = true
frame.Draggable = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 10)

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "Fram NPC"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

-- Toggle script
local enableScript = false
local toggleButton = Instance.new("TextButton", frame)
toggleButton.Size = UDim2.new(0.9, 0, 0, 30)
toggleButton.Position = UDim2.new(0.05, 0, 0, 35)
toggleButton.Text = "Bật Script"
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextScaled = true

-- Tabs
local tab1, tab2 = false, false

local btnTab1 = Instance.new("TextButton", frame)
btnTab1.Size = UDim2.new(0.44, 0, 0, 30)
btnTab1.Position = UDim2.new(0.05, 0, 0, 75)
btnTab1.Text = "Đến NPC"
btnTab1.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnTab1.TextColor3 = Color3.new(1, 1, 1)
btnTab1.Font = Enum.Font.SourceSans
btnTab1.TextScaled = true

local btnTab2 = Instance.new("TextButton", frame)
btnTab2.Size = UDim2.new(0.44, 0, 0, 30)
btnTab2.Position = UDim2.new(0.51, 0, 0, 75)
btnTab2.Text = "Vòng + Đánh"
btnTab2.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnTab2.TextColor3 = Color3.new(1, 1, 1)
btnTab2.Font = Enum.Font.SourceSans
btnTab2.TextScaled = true

-- Bán kính & tốc độ
local radiusBox = Instance.new("TextBox", frame)
radiusBox.PlaceholderText = "Bán kính (vd: 10)"
radiusBox.Size = UDim2.new(0.9, 0, 0, 30)
radiusBox.Position = UDim2.new(0.05, 0, 0, 115)
radiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusBox.TextColor3 = Color3.new(1, 1, 1)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextScaled = true

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ (vd: 2)"
speedBox.Size = UDim2.new(0.9, 0, 0, 30)
speedBox.Position = UDim2.new(0.05, 0, 0, 155)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextScaled = true

-- Tìm NPC gần nhất chứa "CityNPC"
local function findNearestCityNPC()
	local nearest, distance = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.find(string.lower(v.Name), "citynpc") and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < distance then
					distance = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

-- Chạy bộ tự nhiên
local function moveTo(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		hum:MoveTo(target.HumanoidRootPart.Position)
	end
end

-- Chạy vòng quanh + đánh
local function orbitAndAttack(target, radius, speed)
	local angle = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not target or target.Humanoid.Health <= 0 or not enableScript or not tab2 then
			connection:Disconnect()
			return
		end
		angle = angle + dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = target.HumanoidRootPart.Position + offset
		hum:MoveTo(goalPos)
		-- Auto quay mặt
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
		-- Auto đánh (giả lập chuột trái)
		mouse1click()
	end)
end

-- Vòng lặp chính
task.spawn(function()
	while true do
		task.wait(0.5)
		if enableScript then
			local npc = findNearestCityNPC()
			if npc then
				if tab1 then moveTo(npc) end
				if tab2 then
					local radius = tonumber(radiusBox.Text) or 10
					local speed = tonumber(speedBox.Text) or 2
					orbitAndAttack(npc, radius, speed)
					repeat task.wait() until npc.Humanoid.Health <= 0 or not enableScript
				end
			end
		end
	end
end)

-- Nút bật tắt script
toggleButton.MouseButton1Click:Connect(function()
	enableScript = not enableScript
	toggleButton.Text = enableScript and "Tắt Script" or "Bật Script"
	toggleButton.BackgroundColor3 = enableScript and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(70, 130, 180)
end)

-- Tab lựa chọn
btnTab1.MouseButton1Click:Connect(function()
	tab1 = not tab1
	btnTab1.BackgroundColor3 = tab1 and Color3.fromRGB(60, 180, 75) or Color3.fromRGB(100, 100, 100)
end)

btnTab2.MouseButton1Click:Connect(function()
	tab2 = not tab2
	btnTab2.BackgroundColor3 = tab2 and Color3.fromRGB(60, 180, 75) or Color3.fromRGB(100, 100, 100)
end)