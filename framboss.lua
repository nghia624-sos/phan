-- Đông Phan Menu
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DongPhanMenu"

-- Frame chính
local frame = Instance.new("Frame", gui)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.Size = UDim2.new(0, 220, 0, 230)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Visible = true

-- Nút đóng/mở menu
local toggleMenu = Instance.new("TextButton", gui)
toggleMenu.Position = UDim2.new(0, 10, 0, 10)
toggleMenu.Size = UDim2.new(0, 120, 0, 30)
toggleMenu.Text = "Đóng/Mở Menu"
toggleMenu.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Nút bật/tắt script
local enabled = false
local toggleScript = Instance.new("TextButton", frame)
toggleScript.Position = UDim2.new(0, 10, 0, 10)
toggleScript.Size = UDim2.new(0, 200, 0, 30)
toggleScript.Text = "Bật Script"
toggleScript.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggleScript.Text = enabled and "Tắt Script" or "Bật Script"
end)

-- Label hiển thị máu
local healthLabel = Instance.new("TextLabel", frame)
healthLabel.Position = UDim2.new(0, 10, 0, 50)
healthLabel.Size = UDim2.new(0, 200, 0, 25)
healthLabel.Text = "Máu mục tiêu: ???"
healthLabel.TextColor3 = Color3.new(1,1,1)
healthLabel.BackgroundTransparency = 1

-- Bán kính quay
local radius = 10
local radiusBtn = Instance.new("TextButton", frame)
radiusBtn.Position = UDim2.new(0, 10, 0, 85)
radiusBtn.Size = UDim2.new(0, 200, 0, 30)
radiusBtn.Text = "Bán kính: 10"
radiusBtn.MouseButton1Click:Connect(function()
	radius = radius + 5
	if radius > 50 then radius = 5 end
	radiusBtn.Text = "Bán kính: " .. radius
end)

-- Tốc độ quay
local speed = 2
local speedBtn = Instance.new("TextButton", frame)
speedBtn.Position = UDim2.new(0, 10, 0, 125)
speedBtn.Size = UDim2.new(0, 200, 0, 30)
speedBtn.Text = "Tốc độ: 2"
speedBtn.MouseButton1Click:Connect(function()
	speed = speed + 1
	if speed > 10 then speed = 1 end
	speedBtn.Text = "Tốc độ: " .. speed
end)

-- Quay vòng quanh mục tiêu
local spinning = true
local spinBtn = Instance.new("TextButton", frame)
spinBtn.Position = UDim2.new(0, 10, 0, 165)
spinBtn.Size = UDim2.new(0, 200, 0, 30)
spinBtn.Text = "Quay vòng: ON"
spinBtn.MouseButton1Click:Connect(function()
	spinning = not spinning
	spinBtn.Text = "Quay vòng: " .. (spinning and "ON" or "OFF")
end)

-- Tìm mục tiêu gần nhất
local function getNearestTarget()
	local shortest = math.huge
	local nearest = nil
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char then
			local dist = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
			if dist < shortest then
				shortest = dist
				nearest = v
			end
		end
	end
	return nearest
end

-- Main loop
task.spawn(function()
	while true do
		task.wait(0.1)
		if enabled then
			local target = getNearestTarget()
			if target then
				local hp = math.floor(target.Humanoid.Health)
				healthLabel.Text = "Máu mục tiêu: " .. hp
				if spinning then
					local angle = tick() * speed
					local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
					local movePos = target.HumanoidRootPart.Position + offset
					humanoid:MoveTo(movePos)
				end
			else
				healthLabel.Text = "Không tìm thấy mục tiêu"
			end
		else
			healthLabel.Text = "Máu mục tiêu: ???"
		end
	end
end)