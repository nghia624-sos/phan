local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local running = false
local circling = false

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPC"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fram NPC"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(1, -10, 0, 30)
startBtn.Position = UDim2.new(0, 5, 0, 40)
startBtn.Text = "Bật Fram"
startBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)

local circleBtn = Instance.new("TextButton", frame)
circleBtn.Size = UDim2.new(1, -10, 0, 30)
circleBtn.Position = UDim2.new(0, 5, 0, 80)
circleBtn.Text = "Chạy vòng + đánh"
circleBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 90)

local radiusBox = Instance.new("TextBox", frame)
radiusBox.PlaceholderText = "Bán kính (mặc định 10)"
radiusBox.Position = UDim2.new(0, 5, 0, 120)
radiusBox.Size = UDim2.new(1, -10, 0, 25)
radiusBox.Text = ""

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ vòng (mặc định 2)"
speedBox.Position = UDim2.new(0, 5, 0, 150)
speedBox.Size = UDim2.new(1, -10, 0, 25)
speedBox.Text = ""

-- Tìm NPC gần nhất
function getNearestCityNPC()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and tostring(v.Name):lower():find("citynpc") then
			local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist then
				closest = v
				dist = d
			end
		end
	end
	return closest
end

-- Di chuyển tự nhiên + né vật cản
function moveToTarget(pos)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true
	})
	path:ComputeAsync(hrp.Position, pos)

	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	end
end

-- Quay mặt về mục tiêu
function aimAtTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))
	end
end

-- Auto đánh
function autoAttack(target, range)
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		for _, part in pairs(target:GetDescendants()) do
			if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude <= range then
				firetouchinterest(tool.Handle, part, 0)
				firetouchinterest(tool.Handle, part, 1)
			end
		end
	end
end

-- Chạy vòng quanh + đánh
function circleTargetLoop()
	task.spawn(function()
		while circling do
			local target = getNearestCityNPC()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local dist = tonumber(radiusBox.Text) or 10
				local speed = tonumber(speedBox.Text) or 2
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
				local goalPos = target.HumanoidRootPart.Position + offset
				goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)

				aimAtTarget(target)
				humanoid:MoveTo(goalPos)
				autoAttack(target, dist + 3)
			end
			task.wait(0.2)
		end
	end)
end

-- Tự tìm mục tiêu mới và chạy tới
function startFramLoop()
	task.spawn(function()
		while running do
			local target = getNearestCityNPC()
			if target and target:FindFirstChild("HumanoidRootPart") then
				moveToTarget(target.HumanoidRootPart.Position)
				repeat
					task.wait()
				until not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0
			else
				task.wait(1)
			end
		end
	end)
end

-- Bật Fram
startBtn.MouseButton1Click:Connect(function()
	running = not running
	startBtn.Text = running and "Đang chạy..." or "Bật Fram"
	if running then
		startFramLoop()
	end
end)

-- Bật chạy vòng + đánh
circleBtn.MouseButton1Click:Connect(function()
	circling = not circling
	circleBtn.Text = circling and "Đang chạy vòng..." or "Chạy vòng + đánh"
	if circling then
		circleTargetLoop()
	end
end)