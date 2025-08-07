local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- GUI setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TT:dongphandzs1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout", frame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createLabelToggle(text)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -20, 0, 30)
	container.BackgroundTransparency = 1
	container.LayoutOrder = 1

	local label = Instance.new("TextLabel", container)
	label.Text = text
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("TextButton", container)
	toggle.Size = UDim2.new(0.4, 0, 1, 0)
	toggle.Position = UDim2.new(0.6, 0, 0, 0)
	toggle.Text = "OFF"
	toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggle.TextColor3 = Color3.new(1, 1, 1)
	toggle.Font = Enum.Font.SourceSansBold
	toggle.TextSize = 18

	return container, toggle
end

local function createLabelBox(labelText, defaultText)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -20, 0, 30)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Text = labelText
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left

	local textbox = Instance.new("TextBox", container)
	textbox.Text = defaultText
	textbox.Size = UDim2.new(0.4, 0, 1, 0)
	textbox.Position = UDim2.new(0.6, 0, 0, 0)
	textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	textbox.TextColor3 = Color3.new(1, 1, 1)
	textbox.Font = Enum.Font.SourceSans
	textbox.TextSize = 18

	return container, textbox
end

-- Create GUI elements
local framRow, framToggle = createLabelToggle("Bật Fram")
framRow.Parent = frame

local spinRow, spinToggle = createLabelToggle("Bật Spin")
spinRow.Parent = frame

local radiusRow, radiusBox = createLabelBox("Bán kính", "10")
radiusRow.Parent = frame

local speedRow, speedBox = createLabelBox("Tốc độ", "3")
speedRow.Parent = frame

-- Logic variables
local framActive = false
local spinActive = false
local currentTarget = nil

-- Auto attack
function autoAttack()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	task.wait(0.1)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Get nearest NPC
function getNearestCityNPC()
	local nearest, shortest = nil, math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < shortest then
					shortest, nearest = dist, v
				end
			end
		end
	end
	return nearest
end

function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
		HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
	end
end

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

function collectItemsAround(pos, radius)
	for _, item in ipairs(workspace:GetDescendants()) do
		if item:IsA("Tool") or item:IsA("Part") then
			if (item.Position - pos).Magnitude < radius then
				hum:MoveTo(item.Position)
				task.wait(0.4)
			end
		end
	end
end

task.spawn(function()
	while true do
		if spinActive and HRP then
			HRP.CFrame *= CFrame.Angles(0, math.rad(15), 0)
		end
		task.wait()
	end
end)

function startFram()
	while framActive do
		currentTarget = getNearestCityNPC()
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			hum:MoveTo(currentTarget.HumanoidRootPart.Position)
			repeat task.wait()
			until not framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15

			local radius = tonumber(radiusBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 3

			task.spawn(function()
				while framActive and currentTarget and currentTarget.Humanoid.Health > 0 do
					autoAttack()
					task.wait(0.3)
				end
			end)

			runAround(currentTarget, radius, speed)

			if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and currentTarget.Humanoid.Health <= 0 then
				collectItemsAround(currentTarget.HumanoidRootPart.Position, 20)
			end
		else
			task.wait(1)
		end
	end
end

framToggle.MouseButton1Click:Connect(function()
	framActive = not framActive
	framToggle.Text = framActive and "ON" or "OFF"
	framToggle.BackgroundColor3 = framActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
	if framActive then
		task.spawn(startFram)
	end
end)

spinToggle.MouseButton1Click:Connect(function()
	spinActive = not spinActive
	spinToggle.Text = spinActive and "ON" or "OFF"
	spinToggle.BackgroundColor3 = spinActive and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(60, 60, 60)
end)