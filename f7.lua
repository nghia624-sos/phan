-- TT:dongphandzs1 - Fram Boss (KRNL Mobile UI)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến tuỳ chỉnh
local radius = 20
local speed = 2
local autoFram = false
local currentTarget = nil

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TT_dongphandzs1"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 240)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Text = "TT:dongphandzs1 - Đánh BOSS"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Nút bật tắt Fram
local framBtn = Instance.new("TextButton", Frame)
framBtn.Size = UDim2.new(1, -20, 0, 30)
framBtn.Position = UDim2.new(0, 10, 0, 40)
framBtn.Text = "Bật Fram Boss"
framBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
framBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
framBtn.Font = Enum.Font.SourceSans
framBtn.TextSize = 16

-- Ô nhập bán kính
local radiusBox = Instance.new("TextBox", Frame)
radiusBox.PlaceholderText = "Bán kính quay (mặc định: 20)"
radiusBox.Text = tostring(radius)
radiusBox.Size = UDim2.new(1, -20, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 80)
radiusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 14

-- Ô nhập tốc độ
local speedBox = Instance.new("TextBox", Frame)
speedBox.PlaceholderText = "Tốc độ quay (mặc định: 2)"
speedBox.Text = tostring(speed)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 120)
speedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14

-- Hiển thị máu
local healthLabel = Instance.new("TextLabel", Frame)
healthLabel.Text = "Máu mục tiêu: N/A"
healthLabel.Size = UDim2.new(1, -20, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 160)
healthLabel.BackgroundTransparency = 1
healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
healthLabel.Font = Enum.Font.SourceSansBold
healthLabel.TextSize = 16

-- Nút thu nhỏ
local minimizeBtn = Instance.new("TextButton", Frame)
minimizeBtn.Text = "-"
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Bong bóng khi thu nhỏ
local bubble = Instance.new("TextButton", ScreenGui)
bubble.Text = "TT"
bubble.Size = UDim2.new(0, 60, 0, 30)
bubble.Position = UDim2.new(0, 10, 0, 10)
bubble.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
bubble.Visible = false
bubble.Active = true
bubble.Draggable = true

-- Tìm boss gần nhất
function getBoss()
	local nearest, distance = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
			if string.lower(v.Name):find("boss") and v ~= chr then
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

-- Chạy vòng quanh mục tiêu
RunService.Heartbeat:Connect(function(dt)
	if autoFram and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local destination = currentTarget.HumanoidRootPart.Position + offset
		hum:MoveTo(destination)

		-- Xoay mặt về boss
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(currentTarget.HumanoidRootPart.Position.X, hrp.Position.Y, currentTarget.HumanoidRootPart.Position.Z))

		-- Hiển thị máu
		if currentTarget:FindFirstChildOfClass("Humanoid") then
			local hp = currentTarget:FindFirstChildOfClass("Humanoid")
			healthLabel.Text = "Máu mục tiêu: " .. math.floor(hp.Health) .. " / " .. math.floor(hp.MaxHealth)
			if hp.Health <= 0 then
				autoFram = false
				framBtn.Text = "Bật Fram Boss"
			end
		end
	end
end)

-- Sự kiện nút
framBtn.MouseButton1Click:Connect(function()
	radius = tonumber(radiusBox.Text) or 20
	speed = tonumber(speedBox.Text) or 2
	if not autoFram then
		currentTarget = getBoss()
		if currentTarget then
			autoFram = true
			framBtn.Text = "Đang Fram..."
		end
	else
		autoFram = false
		framBtn.Text = "Bật Fram Boss"
	end
end)

-- Thu nhỏ và mở lại
minimizeBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
	bubble.Visible = true
end)

bubble.MouseButton1Click:Connect(function()
	Frame.Visible = true
	bubble.Visible = false
end)