local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI
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
	createLabel(name, parent)
	local input = Instance.new("TextBox", parent)
	input.Size = UDim2.new(1, 0, 0, 30)
	input.BackgroundColor3 = Color3.fromRGB(80,80,80)
	input.TextColor3 = Color3.new(1,1,1)
	input.Text = tostring(defaultValue)
	input.Font = Enum.Font.SourceSans
	input.TextSize = 20
	input.ClearTextOnFocus = false
	input.FocusLost:Connect(function()
		local val = tonumber(input.Text)
		if val then callback(val) end
	end)
end

-- Cấu hình
local framOn, circleRun = false, false
local radius, speed, attackRange = 8, 2, 10
local currentTarget = nil

-- Tìm NPC gần nhất
function findClosestNPC()
	local closest, dist = nil, math.huge
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChildOfClass("Humanoid") then
			if string.lower(npc.Name):find("citynpc") and npc:FindFirstChildOfClass("Humanoid").Health > 0 then
				local d = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					closest = npc
					dist = d
				end
			end
		end
	end
	return closest
end

-- Di chuyển bộ tự nhiên
function moveToTarget(target)
	local pfs = game:GetService("PathfindingService")
	local path = pfs:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true, AgentCanClimb=true})
	path:ComputeAsync(hrp.Position, target.HumanoidRootPart.Position)
	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			if not framOn then return end
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	else
		humanoid:MoveTo(target.HumanoidRootPart.Position)
	end
end

-- Auto đánh
function attack(target)
	if not target then return end
	local h = target:FindFirstChildOfClass("Humanoid")
	if h and h.Health > 0 then
		local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
		if dist <= attackRange then
			mouse1click()
		end
	end
end

-- Quay mặt về phía mục tiêu
function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
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
		angle += math.rad(20)
	end
end

-- Luồng chính
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

-- Giao diện điều khiển
createToggleButton("Bắt đầu", frame, function(state) framOn = state end)
createToggleButton("Chạy Vòng", frame, function(state) circleRun = state end)
createInput("Bán kính", frame, radius, function(v) radius = v end)
createInput("Tốc độ quay", frame, speed, function(v) speed = v end)
createInput("Tầm đánh", frame, attackRange, function(v) attackRange = v end)