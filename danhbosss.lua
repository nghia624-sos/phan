local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoFarmMenu"
gui.ResetOnSpawn = false

-- Toggle Button (Mở Menu)
local toggleMenuBtn = Instance.new("TextButton", gui)
toggleMenuBtn.Size = UDim2.new(0, 100, 0, 30)
toggleMenuBtn.Position = UDim2.new(0, 10, 0, 10)
toggleMenuBtn.Text = "Mở Menu"
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

-- Menu Frame
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 200, 0, 200)
menuFrame.Position = UDim2.new(0, 10, 0, 50)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.Visible = false

-- Tắt/Mở Script
local toggleScriptBtn = Instance.new("TextButton", menuFrame)
toggleScriptBtn.Size = UDim2.new(0, 180, 0, 30)
toggleScriptBtn.Position = UDim2.new(0, 10, 0, 10)
toggleScriptBtn.Text = "Bật Script"
toggleScriptBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

-- Tốc độ xoay
local speedBox = Instance.new("TextBox", menuFrame)
speedBox.Size = UDim2.new(0, 180, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 50)
speedBox.PlaceholderText = "Tốc độ xoay (mặc định 3)"
speedBox.Text = ""

-- Tầm đánh
local rangeBox = Instance.new("TextBox", menuFrame)
rangeBox.Size = UDim2.new(0, 180, 0, 30)
rangeBox.Position = UDim2.new(0, 10, 0, 90)
rangeBox.PlaceholderText = "Tầm đánh (mặc định 24)"
rangeBox.Text = ""

-- Hiển thị máu mục tiêu
local healthLabel = Instance.new("TextLabel", menuFrame)
healthLabel.Size = UDim2.new(0, 180, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 130)
healthLabel.Text = "Máu mục tiêu: N/A"
healthLabel.TextColor3 = Color3.new(1, 1, 1)
healthLabel.BackgroundTransparency = 1

-- Logic
local scriptRunning = false

toggleMenuBtn.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
	toggleMenuBtn.Text = menuFrame.Visible and "Đóng Menu" or "Mở Menu"
end)

toggleScriptBtn.MouseButton1Click:Connect(function()
	scriptRunning = not scriptRunning
	toggleScriptBtn.Text = scriptRunning and "Tắt Script" or "Bật Script"
end)

RunService.RenderStepped:Connect(function()
	if scriptRunning and char and char:FindFirstChild("HumanoidRootPart") then
		local target, minDist = nil, math.huge
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v ~= char and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
				local dist = (char.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
				if dist < minDist then
					minDist = dist
					target = v
				end
			end
		end

		if target then
			local hrp = char.HumanoidRootPart
			local tHrp = target:FindFirstChild("HumanoidRootPart")
			local radius = tonumber(rangeBox.Text) or 24
			local speed = tonumber(speedBox.Text) or 3
			local angle = tick() * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local movePos = tHrp.Position + offset

			-- Di chuyển và xoay mặt
			char.Humanoid:MoveTo(movePos)
			local dir = (tHrp.Position - hrp.Position).Unit
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)

			-- Auto đánh
			if char:FindFirstChildOfClass("Tool") then
				local tool = char:FindFirstChildOfClass("Tool")
				pcall(function()
					tool:Activate()
				end)
			end

			-- Hiển thị máu
			local hp = math.floor(target.Humanoid.Health)
			local maxHp = math.floor(target.Humanoid.MaxHealth)
			healthLabel.Text = "Máu mục tiêu: " .. hp .. "/" .. maxHp
		else
			healthLabel.Text = "Máu mục tiêu: Không tìm thấy"
		end
	end
end)