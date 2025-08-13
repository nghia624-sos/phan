local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến
local radius = 20
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil
local targetOffset = Vector3.new()
local orbitAngle = 0
local noclipEnabled = false

-- GUI chính
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "Menu_TT"
gui.Enabled = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 270)
frame.Position = UDim2.new(0.5, -150, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- Button Đánh Boss
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "BẬT: Đánh Boss"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Khoảng cách
local disLabel = Instance.new("TextLabel", frame)
disLabel.Text = "Khoảng cách:"
disLabel.Size = UDim2.new(0, 150, 0, 30)
disLabel.Position = UDim2.new(0, 10, 0, 50)
disLabel.TextColor3 = Color3.new(1,1,1)
disLabel.BackgroundTransparency = 1

local disInput = Instance.new("TextBox", frame)
disInput.Size = UDim2.new(0, 100, 0, 30)
disInput.Position = UDim2.new(0, 160, 0, 50)
disInput.Text = tostring(radius)
disInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
disInput.TextColor3 = Color3.new(1,1,1)

-- Tốc độ
local spdLabel = Instance.new("TextLabel", frame)
spdLabel.Text = "Tốc độ quay:"
spdLabel.Size = UDim2.new(0, 150, 0, 30)
spdLabel.Position = UDim2.new(0, 10, 0, 90)
spdLabel.TextColor3 = Color3.new(1,1,1)
spdLabel.BackgroundTransparency = 1

local spdInput = Instance.new("TextBox", frame)
spdInput.Size = UDim2.new(0, 100, 0, 30)
spdInput.Position = UDim2.new(0, 160, 0, 90)
spdInput.Text = tostring(speed)
spdInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spdInput.TextColor3 = Color3.new(1,1,1)

-- HP label
local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.TextColor3 = Color3.new(1, 0, 0)
hpLabel.BackgroundTransparency = 1

-- Auto đánh
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, 0, 0, 30)
autoBtn.Position = UDim2.new(0, 0, 0, 170)
autoBtn.Text = "BẬT: Auto Đánh"
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
autoBtn.TextColor3 = Color3.new(1,1,1)

-- Noclip
local noclipBtn = Instance.new("TextButton", frame)
noclipBtn.Size = UDim2.new(1, 0, 0, 30)
noclipBtn.Position = UDim2.new(0, 0, 0, 200)
noclipBtn.Text = "BẬT: Noclip"
noclipBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
noclipBtn.TextColor3 = Color3.new(1,1,1)

-- Tên menu
local nameText = Instance.new("TextLabel", frame)
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 230)
nameText.Text = "TT:dongphandzs1"
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.BackgroundTransparency = 1
nameText.TextScaled = true

-- Giao diện mật khẩu
local passGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
passGui.Name = "PassCheck"

local passFrame = Instance.new("Frame", passGui)
passFrame.Size = UDim2.new(0, 250, 0, 130)
passFrame.Position = UDim2.new(0.5, -125, 0.5, -65)
passFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
passFrame.BorderSizePixel = 0

local title = Instance.new("TextLabel", passFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "Nhập Mật Khẩu"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local input = Instance.new("TextBox", passFrame)
input.Size = UDim2.new(0.9, 0, 0, 30)
input.Position = UDim2.new(0.05, 0, 0, 45)
input.PlaceholderText = "••••••••"
input.BackgroundColor3 = Color3.fromRGB(50,50,50)
input.TextColor3 = Color3.new(1,1,1)

local btn = Instance.new("TextButton", passFrame)
btn.Size = UDim2.new(0.5, 0, 0, 30)
btn.Position = UDim2.new(0.25, 0, 0, 85)
btn.Text = "Xác nhận"
btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()
	if input.Text == "dp2119" then
		gui.Enabled = true
		passGui:Destroy()
	end
end)

-- Tấn công
local function attack()
	local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
end

-- Tìm NPC2 mục tiêu
local function getNPC2Target()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			if string.find(string.lower(v.Name), "npc2") then
				return v
			end
		end
	end
end

-- MoveTo mượt tới mục tiêu
local function moveToTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local reached = false
		local connection
		connection = hrp:GetPropertyChangedSignal("Position"):Connect(function()
			if (hrp.Position - target.HumanoidRootPart.Position).Magnitude <= radius then
				reached = true
			end
		end)
		local waitTime = 0
		while not reached and waitTime < 10 do
			hrp:MoveTo(target.HumanoidRootPart.Position)
			wait(0.1)
			waitTime = waitTime + 0.1
		end
		if connection then connection:Disconnect() end
	end
end

-- Noclip
RunService.Stepped:Connect(function()
	if noclipEnabled then
		for _, part in pairs(chr:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = (noclipEnabled and "TẮT" or "BẬT") .. ": Noclip"
end)

-- Chạy vòng quanh mục tiêu
RunService.Heartbeat:Connect(function(deltaTime)
	if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local targetHRP = currentTarget.HumanoidRootPart
		if currentTarget.Humanoid.Health <= 0 then
			running = false
			autoAttack = false
			currentTarget = nil
			targetOffset = Vector3.new()
			toggle.Text = "BẬT: Đánh Boss"
			autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
			hpLabel.Text = "Máu mục tiêu: Đã chết"
			return
		end

		-- Nếu chưa ở gần target thì MoveTo
		if (hrp.Position - targetHRP.Position).Magnitude > radius then
			hrp:MoveTo(targetHRP.Position)
			return
		end

		-- Tạo offset lần đầu
		if targetOffset == Vector3.new() then
			local dir = (hrp.Position - targetHRP.Position)
			local horizDir = Vector3.new(dir.X, 0, dir.Z)
			local len = horizDir.Magnitude
			if len == 0 then len = 1 end
			targetOffset = horizDir.Unit * math.min(len, radius)
			orbitAngle = math.atan2(targetOffset.Z, targetOffset.X)
		end

		-- Tính vị trí mới
		orbitAngle = orbitAngle + speed * deltaTime
		local offset = Vector3.new(math.cos(orbitAngle), 0, math.sin(orbitAngle)) * radius
		local goalPos = targetHRP.Position + offset

		-- Tween mượt
		local tween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(goalPos, targetHRP.Position)})
		tween:Play()

		-- Quay mặt về hướng mục tiêu
		hum.AutoRotate = false
		hrp.CFrame = CFrame.new(hrp.Position, targetHRP.Position)

		-- Auto đánh
		if autoAttack then attack() end

		hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
	elseif running then
		-- Reset nếu không tìm thấy
		running = false
		autoAttack = false
		currentTarget = nil
		targetOffset = Vector3.new()
		toggle.Text = "BẬT: Đánh Boss"
		autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
		hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
	end
end)

-- Toggle Đánh Boss
toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then
		currentTarget = getNPC2Target()
		targetOffset = Vector3.new()
		if currentTarget then
			coroutine.wrap(function()
				moveToTarget(currentTarget)
			end)()
		end
	end
	toggle.Text = (running and "TẮT" or "BẬT") .. ": Đánh Boss"
end)

-- Auto đánh riêng
autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh (Riêng)"
end)

-- Cập nhật radius & speed
disInput.FocusLost:Connect(function()
	radius = tonumber(disInput.Text) or radius
end)
spdInput.FocusLost:Connect(function()
	speed = tonumber(spdInput.Text) or speed
end)