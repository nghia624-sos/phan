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
frame.Size = UDim2.new(0, 300, 0, 280)
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

-- Nút thu nh/phóng to
local toggleGUIButton = Instance.new("TextButton", frame)
toggleGUIButton.Text = ""
toggleGUIButton.Size = UDim2.new(0, 30, 0, 30)
toggleGUIButton.Position = UDim2.new(1, -35, 0, 5)
toggleGUIButton.AnchorPoint = Vector2.new(1, 0)
toggleGUIButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleGUIButton.TextColor3 = Color3.new(1, 1, 1)
toggleGUIButton.Font = Enum.Font.SourceSansBold
toggleGUIButton.TextSize = 20
toggleGUIButton.ZIndex = 2

local contentFrame = Instance.new("Frame", frame)
contentFrame.BackgroundTransparency = 1
contentFrame.Size = UDim2.new(1, -20, 1, -50)
contentFrame.Position = UDim2.new(0, 10, 0, 40)
contentFrame.Name = "Content"

local contentLayout = Instance.new("UIListLayout", contentFrame)
contentLayout.Padding = UDim.new(0, 8)
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper function: Toggle UI rows
local function createLabelToggle(text)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1

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
	container.Size = UDim2.new(1, 0, 0, 30)
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

-- GUI Content
local framRow, framToggle = createLabelToggle("Bt Fram")
framRow.Parent = contentFrame

local spinRow, spinToggle = createLabelToggle("Bt Spin")
spinRow.Parent = contentFrame

local radiusRow, radiusBox = createLabelBox("Bán kính", "10")
radiusRow.Parent = contentFrame

local speedRow, speedBox = createLabelBox("Tc ", "3")
speedRow.Parent = contentFrame

local nameLabel = Instance.new("TextLabel", contentFrame)
nameLabel.Size = UDim2.new(1, 0, 0, 30)
nameLabel.Text = "TT:dongphandzs1"
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.Font = Enum.Font.SourceSansBold
nameLabel.TextSize = 20
nameLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Toggle GUI logic
local isMinimized = false
toggleGUIButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	contentFrame.Visible = not isMinimized
	toggleGUIButton.Text = isMinimized and "" or ""
	frame.Size = isMinimized and UDim2.new(0, 150, 0, 50) or UDim2.new(0, 300, 0, 280)
end)

-- Logic
local framActive = false
local spinActive = false
local currentTarget = nil

function autoAttack()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	task.wait(0.1)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

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
			HRP.CFrame *= CFrame.Angles(0, math.rad(1000), 0)
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