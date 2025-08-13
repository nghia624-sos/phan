--// Menu Đánh Boss - Bản MoveTo Mượt //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local running = false
local autoAttack = false
local currentTarget = nil
local radius = 10
local speed = 2

--// GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(0.2, 0, 0.2, 0)
frame.Size = UDim2.new(0, 250, 0, 250)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 30)
toggle.Text = "BẬT: Đánh Boss"

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, 0, 0, 30)
autoBtn.Position = UDim2.new(0, 0, 0, 40)
autoBtn.Text = "BẬT: Auto Đánh (Riêng)"

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.Position = UDim2.new(0, 0, 0, 80)
radiusBox.PlaceholderText = "Bán kính"
radiusBox.Text = tostring(radius)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, 0, 0, 30)
speedBox.Position = UDim2.new(0, 0, 0, 120)
speedBox.PlaceholderText = "Tốc độ"
speedBox.Text = tostring(speed)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, 0, 0, 30)
hpLabel.Position = UDim2.new(0, 0, 0, 160)
hpLabel.Text = "Máu mục tiêu: 0"
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

--// Hàm Tìm Boss
local function findBoss()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
			local name = npc.Name:lower()
			if string.find(name, "boss") then
				return npc
			end
		end
	end
	return nil
end

--// Hàm Đánh
local function attack()
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		tool:Activate()
	end
end

--// Nút bật Fram Boss
toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then
		currentTarget = findBoss()
		toggle.Text = "TẮT: Đánh Boss"
	else
		toggle.Text = "BẬT: Đánh Boss"
	end
end)

--// Nút Auto Đánh Riêng
autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	if autoAttack then
		autoBtn.Text = "TẮT: Auto Đánh (Riêng)"
	else
		autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
	end
end)

--// Chỉnh bán kính & tốc độ
radiusBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(radiusBox.Text)
		if val then radius = val end
	end
end)

speedBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(speedBox.Text)
		if val then speed = val end
	end
end)

--// Loop chính
RunService.Heartbeat:Connect(function()
	if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		if currentTarget.Humanoid.Health <= 0 then
			running = false
			autoAttack = false
			currentTarget = nil
			toggle.Text = "BẬT: Đánh Boss"
			autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
			hpLabel.Text = "Máu mục tiêu: Đã chết"
			return
		end

		-- Tính vị trí quay vòng
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = currentTarget.HumanoidRootPart.Position + offset

		-- Di chuyển bằng MoveTo
		hum:MoveTo(goalPos)

		-- Xoay mặt về boss
		hrp.CFrame = CFrame.new(hrp.Position, currentTarget.HumanoidRootPart.Position)

		-- Auto đánh
		if autoAttack then attack() end

		-- Hiển thị máu
		hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
	elseif running then
		-- Nếu không tìm thấy boss thì dừng
		currentTarget = findBoss()
		if not currentTarget then
			running = false
			autoAttack = false
			toggle.Text = "BẬT: Đánh Boss"
			autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
			hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
		end
	end
end)