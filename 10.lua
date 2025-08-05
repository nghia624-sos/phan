local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local target = nil
local framEnabled = false
local circleEnabled = false
local autoAttackEnabled = false
local radius = 10
local speed = 2

-- GUI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "NghiaMinhMenu"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 220)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local uilist = Instance.new("UIListLayout", frame)
uilist.FillDirection = Enum.FillDirection.Vertical
uilist.SortOrder = Enum.SortOrder.LayoutOrder

local function createToggle(name, callback)
	local button = Instance.new("TextButton", frame)
	button.Size = UDim2.new(1, -10, 0, 30)
	button.Position = UDim2.new(0, 5, 0, 0)
	button.Text = "❌ " .. name
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.new(1, 1, 1)
	
	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = (state and "✅ " or "❌ ") .. name
		callback(state)
	end)
end

local function createInput(name, default, callback)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -10, 0, 25)
	label.Text = name
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)

	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(1, -10, 0, 30)
	box.Text = tostring(default)
	box.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	box.TextColor3 = Color3.new(1, 1, 1)

	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then callback(num) end
	end)
end

-- INPUTS
createInput("Khoảng cách đánh (bán kính)", radius, function(v) radius = v end)
createInput("Tốc độ quay vòng", speed, function(v) speed = v end)

-- TOGGLES
createToggle("Bật Fram (Tele đến mục tiêu)", function(state)
	framEnabled = state
	if framEnabled then
		-- Tìm mục tiêu gần nhất
		local closest, dist = nil, math.huge
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("citynpc") then
				local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					closest = v
					dist = d
				end
			end
		end
		target = closest
		if target and target:FindFirstChild("HumanoidRootPart") then
			local direction = (target.HumanoidRootPart.Position - hrp.Position).Unit
			local telePos = target.HumanoidRootPart.Position - direction * radius
			hrp.CFrame = CFrame.new(telePos)
		end
	end
end)

createToggle("Chạy vòng tròn quanh mục tiêu", function(state)
	circleEnabled = state
end)

createToggle("Auto Attack", function(state)
	autoAttackEnabled = state
end)

-- CHẠY VÒNG TRÒN
RunService.RenderStepped:Connect(function(dt)
	if framEnabled and circleEnabled and target and target:FindFirstChild("HumanoidRootPart") then
		local tPos = target.HumanoidRootPart.Position
		local angle = tick() * speed
		local newX = tPos.X + math.cos(angle) * radius
		local newZ = tPos.Z + math.sin(angle) * radius
		local newPos = Vector3.new(newX, hrp.Position.Y, newZ)

		hum:MoveTo(newPos)

		-- Quay về hướng mục tiêu
		local faceDir = (tPos - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(faceDir.X, 0, faceDir.Z))
	end

	-- Auto Attack
	if autoAttackEnabled and target and target:FindFirstChild("Humanoid") then
		local humTarget = target:FindFirstChild("Humanoid")
		if humTarget.Health > 0 then
			mouse1click()
		end
	end
end)