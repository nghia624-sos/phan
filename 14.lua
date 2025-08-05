--// DỊCH VỤ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// BIẾN
local radius = 15
local speed = 3
local running = false
local target = nil
local fram = false
local autoAttack = true
local autoAim = true

--// TÌM MỤC TIÊU
local function getTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
			local name = v.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				return v
			end
		end
	end
	return nil
end

--// AUTO AIM
RunService.RenderStepped:Connect(function()
	if autoAim and target and target:FindFirstChild("HumanoidRootPart") then
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
	end
end)

--// AUTO ĐÁNH
local function attack()
	if autoAttack then
		pcall(function()
			mouse1click()
		end)
	end
end

--// CHẠY VÒNG QUANH MỤC TIÊU
local function runCircle()
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	running = true
	local angle = 0

	RunService:UnbindFromRenderStep("RunCircle")
	RunService:BindToRenderStep("RunCircle", Enum.RenderPriority.Character.Value, function(dt)
		if not running or not target or target.Humanoid.Health <= 0 then
			RunService:UnbindFromRenderStep("RunCircle")
			running = false
			return
		end

		angle += dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = target.HumanoidRootPart.Position + offset

		hum:MoveTo(goalPos)
		attack()
	end)
end

--// KHI BẬT FRAM
task.spawn(function()
	while true do task.wait(0.5)
		if fram and not running then
			target = getTarget()
			if target then
				-- Teleport đến mục tiêu cách một khoảng
				local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
				local teleportPos = target.HumanoidRootPart.Position - dir * radius
				hrp.CFrame = CFrame.new(teleportPos)

				-- Đợi load xong rồi bắt đầu chạy vòng
				task.wait(0.2)
				runCircle()
			end
		end
	end
end)

--// GUI MENU ĐƠN GIẢN
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.Size = UDim2.new(0, 200, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

-- Fram Toggle
local FramBtn = Instance.new("TextButton", Frame)
FramBtn.Text = "Bật Fram"
FramBtn.Size = UDim2.new(1, 0, 0, 40)
FramBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FramBtn.TextColor3 = Color3.new(1, 1, 1)
FramBtn.MouseButton1Click:Connect(function()
	fram = not fram
	FramBtn.Text = fram and "Tắt Fram" or "Bật Fram"
end)

-- Tốc độ
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.PlaceholderText = "Tốc độ chạy vòng"
SpeedBox.Position = UDim2.new(0, 0, 0, 50)
SpeedBox.Size = UDim2.new(1, 0, 0, 30)
SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBox.TextColor3 = Color3.new(1,1,1)
SpeedBox.Text = tostring(speed)
SpeedBox.FocusLost:Connect(function()
	local val = tonumber(SpeedBox.Text)
	if val then speed = val end
end)

-- Bán kính
local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.PlaceholderText = "Bán kính vòng"
RadiusBox.Position = UDim2.new(0, 0, 0, 90)
RadiusBox.Size = UDim2.new(1, 0, 0, 30)
RadiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RadiusBox.TextColor3 = Color3.new(1,1,1)
RadiusBox.Text = tostring(radius)
RadiusBox.FocusLost:Connect(function()
	local val = tonumber(RadiusBox.Text)
	if val then radius = val end
end)

-- Tự Aim
local AimBtn = Instance.new("TextButton", Frame)
AimBtn.Text = "Tự Aim: Bật"
AimBtn.Position = UDim2.new(0, 0, 0, 130)
AimBtn.Size = UDim2.new(1, 0, 0, 30)
AimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimBtn.TextColor3 = Color3.new(1,1,1)
AimBtn.MouseButton1Click:Connect(function()
	autoAim = not autoAim
	AimBtn.Text = "Tự Aim: " .. (autoAim and "Bật" or "Tắt")
end)

-- Tự đánh
local AttackBtn = Instance.new("TextButton", Frame)
AttackBtn.Text = "Auto Đánh: Bật"
AttackBtn.Position = UDim2.new(0, 0, 0, 170)
AttackBtn.Size = UDim2.new(1, 0, 0, 30)
AttackBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AttackBtn.TextColor3 = Color3.new(1,1,1)
AttackBtn.MouseButton1Click:Connect(function()
	autoAttack = not autoAttack
	AttackBtn.Text = "Auto Đánh: " .. (autoAttack and "Bật" or "Tắt")
end)