-- Dịch vụ & nhân vật
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPCMenu"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 220)
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

-- Nút bật/tắt fram
local running = false
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9, 0, 0, 28)
toggle.Position = UDim2.new(0.05, 0, 0, 30)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextScaled = true

-- Tab: Tự vòng quanh
local autoOrbit = false
local orbitToggle = Instance.new("TextButton", frame)
orbitToggle.Size = UDim2.new(0.9, 0, 0, 25)
orbitToggle.Position = UDim2.new(0.05, 0, 0, 65)
orbitToggle.Text = "Tự vòng quanh: TẮT"
orbitToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
orbitToggle.TextColor3 = Color3.new(1, 1, 1)
orbitToggle.Font = Enum.Font.SourceSans
orbitToggle.TextScaled = true

-- Input bán kính và tốc độ
local radiusBox = Instance.new("TextBox", frame)
radiusBox.PlaceholderText = "Bán kính (vd: 10)"
radiusBox.Position = UDim2.new(0.05, 0, 0, 100)
radiusBox.Size = UDim2.new(0.9, 0, 0, 25)
radiusBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBox.TextColor3 = Color3.new(1, 1, 1)
radiusBox.TextScaled = true
radiusBox.Font = Enum.Font.SourceSans

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ vòng (vd: 2)"
speedBox.Position = UDim2.new(0.05, 0, 0, 135)
speedBox.Size = UDim2.new(0.9, 0, 0, 25)
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.TextScaled = true
speedBox.Font = Enum.Font.SourceSans

-- Label thông báo
local label = Instance.new("TextLabel", frame)
label.Position = UDim2.new(0.05, 0, 0, 170)
label.Size = UDim2.new(0.9, 0, 0, 30)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSans
label.TextScaled = true
label.Text = "Đang chờ bật..."

-- Tìm NPC gần nhất chứa "CityNPC"
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

-- Di chuyển tự nhiên
local function moveTo(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		hum:MoveTo(target.HumanoidRootPart.Position)
		hum.MoveToFinished:Wait()
	end
end

-- Tự động chạy vòng quanh
local function orbitTarget(target, radius, speed)
	local angle = 0
	local loop
	loop = RunService.Heartbeat:Connect(function(dt)
		if not running or not autoOrbit or not target or target.Humanoid.Health <= 0 then
			loop:Disconnect()
			return
		end
		angle = angle + dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local newPos = target.HumanoidRootPart.Position + offset
		hum:MoveTo(newPos)
		-- Quay mặt về mục tiêu
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
	end)
end

-- Vòng lặp fram
task.spawn(function()
	while true do
		wait(0.3)
		if running then
			local target = getNearestCityNPC()
			if target then
				label.Text = "Tới: " .. target.Name
				moveTo(target)
				if autoOrbit then
					local r = tonumber(radiusBox.Text) or 10
					local s = tonumber(speedBox.Text) or 2
					orbitTarget(target, r, s)
					repeat wait(0.3) until not running or target.Humanoid.Health <= 0
				end
			else
				label.Text = "Không tìm thấy CityNPC"
			end
		end
	end
end)

-- Nút bật/tắt script
toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = running and "Tắt Fram" or "Bật Fram"
	toggle.BackgroundColor3 = running and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(70, 130, 180)
	label.Text = running and "Đang tìm mục tiêu..." or "Đã tắt"
end)

-- Nút bật/tắt tự vòng quanh
orbitToggle.MouseButton1Click:Connect(function()
	autoOrbit = not autoOrbit
	orbitToggle.Text = "Tự vòng quanh: " .. (autoOrbit and "BẬT" or "TẮT")
	orbitToggle.BackgroundColor3 = autoOrbit and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
end)