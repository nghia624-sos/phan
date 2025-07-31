local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FramNpcMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 260)
frame.Position = UDim2.new(0, 10, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2

local uiList = Instance.new("UIListLayout", frame)
uiList.Padding = UDim.new(0, 5)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top

-- Toggle Fram
local toggleFram = Instance.new("TextButton", frame)
toggleFram.Text = "Bật Fram"
toggleFram.Size = UDim2.new(0, 200, 0, 30)
toggleFram.BackgroundColor3 = Color3.fromRGB(60, 180, 60)

-- Toggle Vòng Tròn
local toggleCircle = Instance.new("TextButton", frame)
toggleCircle.Text = "Bật Vòng Tròn"
toggleCircle.Size = UDim2.new(0, 200, 0, 30)
toggleCircle.BackgroundColor3 = Color3.fromRGB(60, 60, 180)

-- Bán kính + tốc độ
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Text = "10"
radiusBox.PlaceholderText = "Bán kính quay"
radiusBox.Size = UDim2.new(0, 200, 0, 30)
radiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusBox.TextColor3 = Color3.new(1, 1, 1)

local speedBox = Instance.new("TextBox", frame)
speedBox.Text = "2"
speedBox.PlaceholderText = "Tốc độ quay"
speedBox.Size = UDim2.new(0, 200, 0, 30)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.new(1, 1, 1)

-- Biến điều khiển
local running = false
local circleOn = false
local currentTarget = nil

-- Tìm mục tiêu chứa "CityNpc"
local function findTarget()
	local nearest, minDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.lower(v.Name):find("citynpc") then
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

-- Di chuyển tự nhiên bằng pathfinding
local function moveToTarget(target)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	local destination = target.HumanoidRootPart.Position
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true,
	})
	
	path:ComputeAsync(hrp.Position, destination)
	if path.Status == Enum.PathStatus.Complete then
		local waypoints = path:GetWaypoints()
		for _, waypoint in ipairs(waypoints) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
			if not running then break end
		end
	else
		-- Nếu không tìm được đường, thử move trực tiếp
		humanoid:MoveTo(destination)
		humanoid.MoveToFinished:Wait()
	end
end

-- Auto attack + hướng mặt
task.spawn(function()
	while true do wait(0.1)
		if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			humanoid.WalkSpeed = 32
			hrp.CFrame = CFrame.new(hrp.Position, currentTarget.HumanoidRootPart.Position)
			mouse1click()
		end
	end
end)

-- Auto Heal
task.spawn(function()
	while true do wait(1)
		if running and humanoid.Health < humanoid.MaxHealth * 0.6 then
			for _, item in pairs(player.Backpack:GetChildren()) do
				if item:IsA("Tool") and string.lower(item.Name):find("heal") then
					item.Parent = char
					wait(0.2)
					item:Activate()
				end
			end
		end
	end
end)

-- Quay vòng quanh mục tiêu
task.spawn(function()
	while true do wait(0.03)
		if running and circleOn and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			local radius = tonumber(radiusBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 2
			local angle = tick() * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local goalPos = currentTarget.HumanoidRootPart.Position + offset
			goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
			local goalCF = CFrame.new(goalPos, currentTarget.HumanoidRootPart.Position)
			TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()
		end
	end
end)

-- Toggle Fram
toggleFram.MouseButton1Click:Connect(function()
	running = not running
	toggleFram.Text = running and "Tắt Fram" or "Bật Fram"
	toggleFram.BackgroundColor3 = running and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 180, 60)

	if running then
		task.spawn(function()
			while running do
				local target = findTarget()
				currentTarget = target
				if target then moveToTarget(target) end
				wait(0.5)
			end
		end)
	end
end)

-- Toggle vòng tròn
toggleCircle.MouseButton1Click:Connect(function()
	circleOn = not circleOn
	toggleCircle.Text = circleOn and "Tắt Vòng Tròn" or "Bật Vòng Tròn"
	toggleCircle.BackgroundColor3 = circleOn and Color3.fromRGB(200, 60, 200) or Color3.fromRGB(60, 60, 180)
end)