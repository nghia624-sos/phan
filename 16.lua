local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPCMenu"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 250)
frame.Position = UDim2.new(0, 30, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fram NPC"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local toggleScript = false
local modeRun, modeCircle = false, false

-- Toggle
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9, 0, 0, 30)
toggle.Position = UDim2.new(0.05, 0, 0, 35)
toggle.Text = "Bật Script"
toggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextScaled = true
toggle.Font = Enum.Font.SourceSans

-- Tabs
local btnRun = Instance.new("TextButton", frame)
btnRun.Size = UDim2.new(0.44, 0, 0, 30)
btnRun.Position = UDim2.new(0.05, 0, 0, 75)
btnRun.Text = "Tới NPC"
btnRun.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnRun.TextColor3 = Color3.new(1, 1, 1)
btnRun.TextScaled = true

local btnCircle = Instance.new("TextButton", frame)
btnCircle.Size = UDim2.new(0.44, 0, 0, 30)
btnCircle.Position = UDim2.new(0.51, 0, 0, 75)
btnCircle.Text = "Vòng + Đánh"
btnCircle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnCircle.TextColor3 = Color3.new(1, 1, 1)
btnCircle.TextScaled = true

-- Inputs
local radiusInput = Instance.new("TextBox", frame)
radiusInput.PlaceholderText = "Bán kính (vd: 10)"
radiusInput.Size = UDim2.new(0.9, 0, 0, 30)
radiusInput.Position = UDim2.new(0.05, 0, 0, 115)
radiusInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusInput.TextColor3 = Color3.new(1, 1, 1)
radiusInput.TextScaled = true

local speedInput = Instance.new("TextBox", frame)
speedInput.PlaceholderText = "Tốc độ (vd: 2)"
speedInput.Size = UDim2.new(0.9, 0, 0, 30)
speedInput.Position = UDim2.new(0.05, 0, 0, 155)
speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.TextScaled = true

-- Hàm tìm NPC gần nhất chứa tên CityNPC (không phân biệt hoa thường)
local function getNearestCityNPC()
	local nearest = nil
	local minDist = math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			local name = string.lower(v.Name)
			if name:find("citynpc") and v.Humanoid.Health > 0 then
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

-- Di chuyển bộ tự nhiên
local function walkToTarget(target)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	hum:MoveTo(target.HumanoidRootPart.Position)
	hum.MoveToFinished:Wait()
end

-- Chạy vòng quanh và đánh
local function orbitAndAttack(target, radius, speed)
	local angle = 0
	local run
	run = RunService.Heartbeat:Connect(function(dt)
		if not toggleScript or not target or target.Humanoid.Health <= 0 then
			run:Disconnect()
			return
		end
		angle = angle + dt * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local newPos = target.HumanoidRootPart.Position + offset
		hum:MoveTo(newPos)
		-- Quay mặt
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
		-- Auto click (chuột trái)
		pcall(mouse1click)
	end)
end

-- Vòng lặp chính
task.spawn(function()
	while true do
		task.wait(0.3)
		if toggleScript then
			local target = getNearestCityNPC()
			if target then
				if modeRun then
					walkToTarget(target)
				end
				if modeCircle then
					local radius = tonumber(radiusInput.Text) or 10
					local speed = tonumber(speedInput.Text) or 2
					orbitAndAttack(target, radius, speed)
					repeat task.wait(0.2) until not toggleScript or target.Humanoid.Health <= 0
				end
			end
		end
	end
end)

-- Nút bật/tắt script
toggle.MouseButton1Click:Connect(function()
	toggleScript = not toggleScript
	toggle.Text = toggleScript and "Tắt Script" or "Bật Script"
	toggle.BackgroundColor3 = toggleScript and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(70, 130, 180)
end)

btnRun.MouseButton1Click:Connect(function()
	modeRun = not modeRun
	btnRun.BackgroundColor3 = modeRun and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
end)

btnCircle.MouseButton1Click:Connect(function()
	modeCircle = not modeCircle
	btnCircle.BackgroundColor3 = modeCircle and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
end)