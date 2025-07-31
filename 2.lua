-- Dịch vụ & nhân vật
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")

-- Menu gọn
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPCMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0, 50, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "Fram CityNPC"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Nút bật/tắt script
local running = false
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9, 0, 0, 30)
toggle.Position = UDim2.new(0.05, 0, 0, 30)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextScaled = true

-- Bán kính và tốc độ
local radiusBox = Instance.new("TextBox", frame)
radiusBox.PlaceholderText = "Bán kính (vd: 10)"
radiusBox.Position = UDim2.new(0.05, 0, 0, 70)
radiusBox.Size = UDim2.new(0.9, 0, 0, 25)
radiusBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBox.TextColor3 = Color3.new(1, 1, 1)
radiusBox.TextScaled = true
radiusBox.Font = Enum.Font.SourceSans

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ vòng (vd: 2)"
speedBox.Position = UDim2.new(0.05, 0, 0, 105)
speedBox.Size = UDim2.new(0.9, 0, 0, 25)
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.TextScaled = true
speedBox.Font = Enum.Font.SourceSans

-- Debug mục tiêu
local label = Instance.new("TextLabel", frame)
label.Position = UDim2.new(0.05, 0, 0, 140)
label.Size = UDim2.new(0.9, 0, 0, 25)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSans
label.TextScaled = true
label.Text = "Đang chờ bật..."

-- Tìm NPC gần nhất
local function getNearestCityNPC()
	local nearest, minDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
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

-- Chạy bộ đến mục tiêu
local function moveTo(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		hum:MoveTo(target.HumanoidRootPart.Position)
		hum.MoveToFinished:Wait()
	end
end

-- Chạy vòng quanh mục tiêu
local function orbitTarget(target, radius, speed)
	local angle = 0
	local orbitLoop
	orbitLoop = RunService.Heartbeat:Connect(function(dt)
		if not running or not target or target.Humanoid.Health <= 0 then
			orbitLoop:Disconnect()
			return
		end
		angle = angle + dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local newPos = target.HumanoidRootPart.Position + offset
		hum:MoveTo(newPos)
		-- Quay mặt
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
	end)
end

-- Vòng lặp chính
task.spawn(function()
	while true do
		wait(0.3)
		if running then
			local target = getNearestCityNPC()
			if target then
				label.Text = "Tới: " .. target.Name
				moveTo(target)
				local r = tonumber(radiusBox.Text) or 10
				local s = tonumber(speedBox.Text) or 2
				orbitTarget(target, r, s)
				repeat wait(0.3) until not running or target.Humanoid.Health <= 0
			else
				label.Text = "Không tìm thấy NPC CityNPC"
			end
		end
	end
end)

-- Nút toggle
toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = running and "Tắt Fram" or "Bật Fram"
	toggle.BackgroundColor3 = running and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(70, 130, 180)
	label.Text = running and "Đang tìm mục tiêu..." or "Đã tắt"
end)