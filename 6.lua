--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// BIẾN
local radius = 15
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil

--// GUI KÉO ĐƯỢC
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TT_dongphandzs1"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 260)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

-- BUTTONS & INPUTS
local function CreateButton(txt, parent, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, 40 + #parent:GetChildren() * 35)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSans
	btn.Text = txt
	btn.TextScaled = true
	local corner = Instance.new("UICorner", btn)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function CreateInput(txt, parent, defaultVal, onChange)
	local box = Instance.new("TextBox", parent)
	box.Size = UDim2.new(1, -20, 0, 30)
	box.Position = UDim2.new(0, 10, 0, 40 + #parent:GetChildren() * 35)
	box.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.SourceSans
	box.PlaceholderText = txt
	box.Text = tostring(defaultVal)
	box.TextScaled = true
	local corner = Instance.new("UICorner", box)
	box.FocusLost:Connect(function()
		local val = tonumber(box.Text)
		if val then onChange(val) end
	end)
	return box
end

local hpLabel = Instance.new("TextLabel", Frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 220)
hpLabel.BackgroundTransparency = 1
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLabel.Font = Enum.Font.SourceSans
hpLabel.TextScaled = true
hpLabel.Text = "Máu mục tiêu: Không có"

-- Tạo nút
CreateButton("Bật Fram", Frame, function()
	running = not running
end)

CreateButton("Bật Auto Đánh", Frame, function()
	autoAttack = not autoAttack
end)

CreateInput("Bán kính quay", Frame, radius, function(val)
	radius = val
end)

CreateInput("Tốc độ quay", Frame, speed, function(val)
	speed = val
end)

-- HÀM TÌM MỤC TIÊU
function getNearestTarget()
	local nearest, shortest = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= chr then
			local mag = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if mag < shortest then
				shortest = mag
				nearest = v
			end
		end
	end
	return nearest
end

-- VÒNG LẶP
RunService.Heartbeat:Connect(function()
	if not running then return end

	if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
		currentTarget = getNearestTarget()
	end

	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local hp = math.floor(currentTarget.Humanoid.Health)
		hpLabel.Text = "Máu mục tiêu: " .. hp

		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = currentTarget.HumanoidRootPart.Position + offset
		local direction = (targetPos - hrp.Position)
		if direction.Magnitude > 1 then
			local moveStep = direction.Unit * math.min(direction.Magnitude, 0.4)
			hrp.CFrame = CFrame.new(hrp.Position + moveStep, currentTarget.HumanoidRootPart.Position)
		end

		if autoAttack then
			local dist = (hrp.Position - currentTarget.HumanoidRootPart.Position).Magnitude
			if dist <= radius + 2 then
				for _, tool in pairs(lp.Backpack:GetChildren()) do
					if tool:IsA("Tool") then
						tool.Parent = chr
						tool:Activate()
					end
				end
				for _, tool in pairs(chr:GetChildren()) do
					if tool:IsA("Tool") then
						tool:Activate()
					end
				end
			end
		end
	end
end)