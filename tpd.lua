local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local radius = 20
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil
local targetOffset = Vector3.new()
local orbitAngle = 0
local noclipEnabled = false
local healing = false

local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "Menu_TT"
gui.Enabled = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 270)
frame.Position = UDim2.new(0.5, -150, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "BẬT: Đánh Boss"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)

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

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.TextColor3 = Color3.new(1, 0, 0)
hpLabel.BackgroundTransparency = 1

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, 0, 0, 30)
autoBtn.Position = UDim2.new(0, 0, 0, 170)
autoBtn.Text = "BẬT: Auto Đánh"
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
autoBtn.TextColor3 = Color3.new(1,1,1)

local noclipBtn = Instance.new("TextButton", frame)
noclipBtn.Size = UDim2.new(1, 0, 0, 30)
noclipBtn.Position = UDim2.new(0, 0, 0, 200)
noclipBtn.Text = "BẬT: Noclip"
noclipBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
noclipBtn.TextColor3 = Color3.new(1,1,1)

local nameText = Instance.new("TextLabel", frame)
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 230)
nameText.Text = "TT:dongphandzs1"
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.BackgroundTransparency = 1
nameText.TextScaled = true

local function getTarget()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			if string.find(string.lower(v.Name), "boss") then
				return v
			end
		end
	end
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			return v
		end
	end
end

local function attack()
	local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
end

local function autoHeal()
	if healing then return end
	if hum.Health < 80 then
		healing = true
		local currentTool = chr:FindFirstChildOfClass("Tool")
		local bandage = lp.Backpack:FindFirstChild("Bandage") or lp.Backpack:FindFirstChild("băng gạc")
		if bandage then
			bandage.Parent = chr
			task.wait(0.2)
			pcall(function() bandage:Activate() end)
			task.wait(1)
		end
		if currentTool and currentTool.Parent == lp.Backpack then
			currentTool.Parent = chr
		end
		healing = false
	end
end

RunService.Stepped:Connect(function()
	if noclipEnabled then
		for _, part in pairs(chr:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = (noclipEnabled and "TẮT" or "BẬT") .. ": Noclip"
end)

RunService.Heartbeat:Connect(function(deltaTime)
	autoHeal()

	if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local targetHRP = currentTarget.HumanoidRootPart
		if currentTarget.Humanoid.Health <= 0 then
			running = false
			autoAttack = false
			currentTarget = nil
			targetOffset = Vector3.new()
			toggle.Text = "BẬT: Đánh Boss"
			autoBtn.Text = "BẬT: Auto Đánh"
			hpLabel.Text = "Máu mục tiêu: Đã chết"
			return
		end

		if targetOffset == Vector3.new() then
			local dir = (hrp.Position - targetHRP.Position)
			local horizDir = Vector3.new(dir.X, 0, dir.Z)
			local len = horizDir.Magnitude
			if len == 0 then len = 1 end
			targetOffset = horizDir.Unit * math.min(len, radius)
			orbitAngle = math.atan2(targetOffset.Z, targetOffset.X)
		end

		orbitAngle = orbitAngle + speed * deltaTime
		local offset = Vector3.new(math.cos(orbitAngle), 0, math.sin(orbitAngle)) * radius
		local goalPos = targetHRP.Position + offset

		local tween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(goalPos, targetHRP.Position)})
		tween:Play()

		hum.AutoRotate = false
		hrp.CFrame = CFrame.new(hrp.Position, targetHRP.Position)

		if autoAttack then attack() end

		hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
	elseif running then
		running = false
		autoAttack = false
		currentTarget = nil
		targetOffset = Vector3.new()
		toggle.Text = "BẬT: Đánh Boss"
		autoBtn.Text = "BẬT: Auto Đánh"
		hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
	end
end)

toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then
		currentTarget = getTarget()
		targetOffset = Vector3.new()
		toggle.Text = "TẮT: Đánh Boss"

		task.spawn(function()
			while running do
				task.wait(0.55)
				if running then
					running = false
					toggle.Text = "BẬT: Đánh Boss"
					task.wait(0.20)
					running = true
					currentTarget = getTarget()
					targetOffset = Vector3.new()
					toggle.Text = "TẮT: Đánh Boss"
				end
			end
		end)
	else
		toggle.Text = "BẬT: Đánh Boss"
	end
end)

autoBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh"
end)

disInput.FocusLost:Connect(function()
	radius = tonumber(disInput.Text) or radius
end)

spdInput.FocusLost:Connect(function()
	speed = tonumber(spdInput.Text) or speed
end)