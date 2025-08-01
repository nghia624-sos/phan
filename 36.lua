local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local pathfindingService = game:GetService("PathfindingService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

-- GUI MENU
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "PhanFramNPC"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 150)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "Phan:FramNPC"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local function createLabel(text, pos)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 20)
	label.Position = UDim2.new(0, 10, 0, pos)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.Parent = frame
	return label
end

local function createInput(default, pos)
	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, -20, 0, 25)
	input.Position = UDim2.new(0, 10, 0, pos)
	input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	input.TextColor3 = Color3.new(1, 1, 1)
	input.Text = tostring(default)
	input.Font = Enum.Font.SourceSans
	input.TextSize = 16
	input.ClearTextOnFocus = false
	input.Parent = frame
	return input
end

local function createButton(text, pos, func)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 30)
	button.Position = UDim2.new(0, 10, 0, pos)
	button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.MouseButton1Click:Connect(func)
	button.Parent = frame
	return button
end

createLabel("Bán kính:", 40)
local radiusBox = createInput("10", 60)

createLabel("Tốc độ:", 95)
local speedBox = createInput("2", 115)

local toggle = false
createButton("BẬT / TẮT Fram", 150, function()
	toggle = not toggle
end)

-- TÌM NPC
function findNearestNPC()
	local nearest, dist = nil, math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			local name = v.Name:lower()
			if name:find("npccity") then
				local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					nearest, dist = v, d
				end
			end
		end
	end
	return nearest
end

-- DI CHUYỂN CÓ PATHFIND
function moveToTarget(targetPos)
	local path = pathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true
	})
	path:ComputeAsync(hrp.Position, targetPos)
	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	end
end

-- CHẠY VÒNG + ĐÁNH
function circleTarget(npc)
	local radius = tonumber(radiusBox.Text) or 10
	local speed = tonumber(speedBox.Text) or 2
	while toggle and npc and npc.Parent and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid").Health > 0 do
		local t = tick()
		local angle = t * speed
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		local offset = Vector3.new(x, 0, z)
		local targetPos = npc.HumanoidRootPart.Position + offset
		humanoid:MoveTo(targetPos)

		-- quay mặt về mục tiêu
		local lookVec = (npc.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVec.X, 0, lookVec.Z))

		-- auto đánh (nếu game dùng tool thì kiểm tra tool và active)
		local tool = player.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			pcall(function() tool:Activate() end)
		end

		wait()
	end
end

-- VÒNG LẶP CHÍNH
task.spawn(function()
	while true do
		if toggle then
			local npc = findNearestNPC()
			if npc and npc:FindFirstChild("HumanoidRootPart") then
				moveToTarget(npc.HumanoidRootPart.Position)
				circleTarget(npc)
			end
		end
		wait(0.5)
	end
end)