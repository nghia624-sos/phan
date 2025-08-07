local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TT:dongphandzs1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 240)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local framButton = Instance.new("TextButton", frame)
framButton.Size = UDim2.new(1, -20, 0, 50)
framButton.Position = UDim2.new(0, 10, 0, 10)
framButton.Text = "Bật Fram"
framButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
framButton.TextColor3 = Color3.new(1, 1, 1)
framButton.Font = Enum.Font.SourceSansBold
framButton.TextSize = 24

local radiusLabel = Instance.new("TextLabel", frame)
radiusLabel.Position = UDim2.new(0, 10, 0, 70)
radiusLabel.Size = UDim2.new(0, 100, 0, 30)
radiusLabel.Text = "Bán kính:"
radiusLabel.TextColor3 = Color3.new(1, 1, 1)
radiusLabel.BackgroundTransparency = 1

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Position = UDim2.new(0, 120, 0, 70)
radiusBox.Size = UDim2.new(0, 100, 0, 30)
radiusBox.Text = "10"

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Position = UDim2.new(0, 10, 0, 110)
speedLabel.Size = UDim2.new(0, 100, 0, 30)
speedLabel.Text = "Tốc độ:"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1

local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 120, 0, 110)
speedBox.Size = UDim2.new(0, 100, 0, 30)
speedBox.Text = "3"

-- Thêm nút Spin
local spinButton = Instance.new("TextButton", frame)
spinButton.Size = UDim2.new(1, -20, 0, 30)
spinButton.Position = UDim2.new(0, 10, 0, 150)
spinButton.Text = "Bật Spin"
spinButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
spinButton.TextColor3 = Color3.new(1, 1, 1)
spinButton.Font = Enum.Font.SourceSansBold
spinButton.TextSize = 20

-- Biến
local framActive = false
local spinActive = false
local currentTarget = nil

-- Hàm tìm NPC
function getNearestCityNPC()
	local nearest = nil
	local shortest = math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < shortest then
					shortest = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

-- Aim
function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
		HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
	end
end

-- Vòng quanh
function runAround(target, radius, speed)
	local angle = 0
	while framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local targetPos = target.HumanoidRootPart.Position
		angle += speed * RunService.Heartbeat:Wait()
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goal = targetPos + offset
		local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal)})
		tween:Play()
		faceTarget(target)
	end
end

-- Tự đánh
function autoAttack()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	task.wait(0.1)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Tự nhặt
function collectItemsAround(position, radius)
	for _, item in ipairs(workspace:GetDescendants()) do
		if item:IsA("Tool") or item:IsA("Part") then
			if (item.Position - position).Magnitude < radius then
				hum:MoveTo(item.Position)
				task.wait(0.4)
			end
		end
	end
end

-- Tính năng quay spin
task.spawn(function()
	while true do
		if spinActive and HRP then
			HRP.CFrame *= CFrame.Angles(0, math.rad(15), 0)
		end
		task.wait()
	end
end)

-- Hàm chính
function startFram()
	while framActive do
		currentTarget = getNearestCityNPC()
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			hum:MoveTo(currentTarget.HumanoidRootPart.Position)
			repeat task.wait()
			until not framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15

			local radius = tonumber(radiusBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 3

			-- Tự đánh
			task.spawn(function()
				while framActive and currentTarget and currentTarget.Humanoid.Health > 0 do
					autoAttack()
					task.wait(0.3)
				end
			end)

			-- Vòng quanh
			runAround(currentTarget, radius, speed)

			-- NPC chết, nhặt đồ
			if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and currentTarget.Humanoid.Health <= 0 then
				collectItemsAround(currentTarget.HumanoidRootPart.Position, 20)
			end
		else
			task.wait(1)
		end
	end
end

-- Nút bật/tắt Fram
framButton.MouseButton1Click:Connect(function()
	framActive = not framActive
	framButton.Text = framActive and "Tắt Fram" or "Bật Fram"
	if framActive then
		task.spawn(startFram)
	end
end)

-- Nút bật/tắt Spin
spinButton.MouseButton1Click:Connect(function()
	spinActive = not spinActive
	spinButton.Text = spinActive and "Tắt Spin" or "Bật Spin"
end)