-- Tạo GUI
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PHAN:FRAM NPC"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function createLabel(text, parent)
	local label = Instance.new("TextLabel", parent)
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 20
	return label
end

local function createToggleButton(text, parent, callback)
	local button = Instance.new("TextButton", parent)
	button.Size = UDim2.new(1, 0, 0, 30)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1,1,1)
	button.Text = text.." OFF"
	button.Font = Enum.Font.SourceSans
	button.TextSize = 20
	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = text.." "..(state and "ON" or "OFF")
		callback(state)
	end)
	return button
end

local function createInput(name, parent, defaultValue, callback)
	local label = createLabel(name, parent)
	local input = Instance.new("TextBox", parent)
	input.Size = UDim2.new(1, 0, 0, 30)
	input.BackgroundColor3 = Color3.fromRGB(80,80,80)
	input.TextColor3 = Color3.new(1,1,1)
	input.Text = tostring(defaultValue)
	input.Font = Enum.Font.SourceSans
	input.TextSize = 20
	input.FocusLost:Connect(function()
		local val = tonumber(input.Text)
		if val then callback(val) end
	end)
end

-- Cấu hình
local framOn = false
local circleRun = false
local radius = 8
local speed = 2
local attackRange = 10
local currentTarget = nil

-- Tìm NPC gần nhất
function findClosestNPC()
	local closest, distance = nil, math.huge
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChildOfClass("Humanoid") then
			if string.lower(npc.Name):find("citynpc") and npc:FindFirstChildOfClass("Humanoid").Health > 0 then
				local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < distance then
					closest = npc
					distance = dist
				end
			end
		end
	end
	return closest
end

-- Di chuyển bộ tự nhiên bằng Pathfinding
function moveToTarget(target)
	local pathfinding = game:GetService("PathfindingService")
	local path = pathfinding:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true
	})
	path:ComputeAsync(hrp.Position, target.HumanoidRootPart.Position)
	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	else
		humanoid:MoveTo(target.HumanoidRootPart.Position)
	end
end

-- Auto đánh
function attack(target)
	if not target or not target:FindFirstChildOfClass("Humanoid") then return end
	local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
	if dist <= attackRange then
		mouse1click()
	end
end

-- Quay mặt về phía mục tiêu
function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local look = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
	end
end

-- Chạy vòng quanh mục tiêu
function circleAround(target)
	local angle = 0
	while framOn and circleRun and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChildOfClass("Humanoid").Health > 0 do
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local pos = target.HumanoidRootPart.Position + offset
		humanoid:MoveTo(pos)
		faceTarget(target)
		attack(target)
		wait(speed)
		angle = angle + math.rad(20)
	end
end

-- Luồng chính Fram
spawn(function()
	while true do wait(0.5)
		if framOn then
			if not currentTarget or currentTarget:FindFirstChildOfClass("Humanoid").Health <= 0 then
				currentTarget = findClosestNPC()
			end
			if currentTarget then
				moveToTarget(currentTarget)
				if circleRun then
					circleAround(currentTarget)
				end
			end
		end
	end
end)

-- Giao diện
createToggleButton("Bắt đầu", frame, function(state) framOn = state end)
createToggleButton("Chạy Vòng", frame, function(state) circleRun = state end)
createInput("Bán kính", frame, radius, function(val) radius = val end)
createInput("Tốc độ quay", frame, speed, function(val) speed = val end)
createInput("Tầm đánh", frame, attackRange, function(val) attackRange = val end)