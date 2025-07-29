-- GUI tạo menu đơn giản
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

-- Nút mở menu
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "Mở Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Khung menu
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 230)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Visible = false

-- Toggle mở menu
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Biến
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local autoFarm = false
local radius = 10
local speed = 3
local target = nil
local angle = 0

-- Hàm tìm NPC chứa CityNPC
local function getCityNPC()
	local nearest, dist = nil, math.huge
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name:lower():find("citynpc") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
			local d = (obj.HumanoidRootPart.Position - HRP.Position).Magnitude
			if d < dist and obj.Humanoid.Health > 0 then
				dist = d
				nearest = obj
			end
		end
	end
	return nearest
end

-- Nút bật vòng
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -20, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Auto Vòng: TẮT"
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

toggleBtn.MouseButton1Click:Connect(function()
	autoFarm = not autoFarm
	toggleBtn.Text = "Auto Vòng: " .. (autoFarm and "BẬT" or "TẮT")
	if autoFarm then
		target = getCityNPC()
	end
end)

-- Ô nhập bán kính
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, -20, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 50)
radiusBox.Text = "Bán kính: 10"
radiusBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBox.TextColor3 = Color3.new(1, 1, 1)

radiusBox.FocusLost:Connect(function()
	local val = tonumber(radiusBox.Text:match("%d+"))
	if val then radius = val end
end)

-- Ô nhập tốc độ
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 90)
speedBox.Text = "Tốc độ: 3"
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.TextColor3 = Color3.new(1, 1, 1)

speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text:match("%d+"))
	if val then speed = val end
end)

-- Label hiển thị máu
local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu: ???"
hpLabel.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
hpLabel.TextColor3 = Color3.new(1, 1, 1)

-- Vòng tròn fram mục tiêu + tự ngắt khi mục tiêu chết
RunService.RenderStepped:Connect(function(dt)
	if autoFarm then
		if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
			hpLabel.Text = "Máu: ???"
			autoFarm = false
			toggleBtn.Text = "Auto Vòng: TẮT"
			target = nil
			return
		end

		angle = angle + dt * speed
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
		local targetPos = target.HumanoidRootPart.Position + offset
		HRP.CFrame = CFrame.new(targetPos, target.HumanoidRootPart.Position)

		-- Update máu
		hpLabel.Text = "Máu: " .. math.floor(target.Humanoid.Health)
	end
end)