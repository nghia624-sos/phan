-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BossFarmGui"
gui.ResetOnSpawn = false

-- Nút bật/tắt
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 140, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Bật Script"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Ô nhập bán kính
local radiusBox = Instance.new("TextBox", gui)
radiusBox.Size = UDim2.new(0, 140, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 50)
radiusBox.Text = "Bán kính: 10"
radiusBox.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
radiusBox.TextColor3 = Color3.fromRGB(0, 0, 0)

-- Ô nhập tốc độ
local speedBox = Instance.new("TextBox", gui)
speedBox.Size = UDim2.new(0, 140, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 90)
speedBox.Text = "Tốc độ: 2"
speedBox.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
speedBox.TextColor3 = Color3.fromRGB(0, 0, 0)

-- Hiển thị máu mục tiêu
local hpLabel = Instance.new("TextLabel", gui)
hpLabel.Size = UDim2.new(0, 200, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu mục tiêu: N/A"
hpLabel.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
hpLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
hpLabel.TextScaled = true

-- Biến điều khiển
local active = false
local radius = 10
local speed = 2
local target = nil
local lastAttack = 0
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tìm mục tiêu gần nhất
local function findNearestTarget()
	local nearest = nil
	local minDist = math.huge
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChildOfClass("Humanoid") then
			local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < minDist and obj ~= LocalPlayer.Character then
				minDist = dist
				nearest = obj
			end
		end
	end
	return nearest
end

-- Bật/Tắt script
toggleBtn.MouseButton1Click:Connect(function()
	active = not active
	toggleBtn.Text = active and "Tắt Script" or "Bật Script"
	if active then
		target = findNearestTarget()
	end
end)

-- Nhập bán kính
radiusBox.FocusLost:Connect(function()
	local val = tonumber(radiusBox.Text:match("%d+"))
	if val then
		radius = val
		radiusBox.Text = "Bán kính: " .. val
	end
end)

-- Nhập tốc độ
speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text:match("%d+"))
	if val then
		speed = val
		speedBox.Text = "Tốc độ: " .. val
	end
end)

-- Vòng lặp chính
spawn(function()
	while true do
		wait(0.1)
		if active then
			if not target or not target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildOfClass("Humanoid").Health <= 0 then
				target = findNearestTarget()
			end

			local char = LocalPlayer.Character
			if char and target then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if hrp and humanoid then
					-- ✅ Auto Aim bằng CFrame.lookAt
					local tPos = target.HumanoidRootPart.Position
					local lookAt = Vector3.new(tPos.X, hrp.Position.Y, tPos.Z)
					hrp.CFrame = CFrame.lookAt(hrp.Position, lookAt)

					-- ✅ Tính vị trí xoay vòng
					local t = tick() * speed
					local offset = Vector3.new(math.cos(t) * radius, 0, math.sin(t) * radius)
					local movePos = target.HumanoidRootPart.Position + offset

					-- ✅ Di chuyển xoay vòng
					humanoid:MoveTo(movePos)

					-- ✅ Tự động đánh
					local distance = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
					if distance <= 10 and tick() - lastAttack >= 0.5 then
						lastAttack = tick()
						pcall(function()
							local humanoidTarget = target:FindFirstChildOfClass("Humanoid")
							if humanoidTarget then
								humanoidTarget:TakeDamage(5)
							end
						end)
					end

					-- ✅ Hiển thị máu mục tiêu
					local hp = target:FindFirstChildOfClass("Humanoid")
					if hp then
						hpLabel.Text = string.format("Máu mục tiêu: %d", math.floor(hp.Health))
					else
						hpLabel.Text = "Máu mục tiêu: N/A"
					end
				end
			else
				hpLabel.Text = "Máu mục tiêu: N/A"
			end
		else
			hpLabel.Text = "Máu mục tiêu: N/A"
		end
	end
end)