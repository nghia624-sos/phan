-- Menu Fram NPC - Gộp tính năng đầy đủ
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FramNPC"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 240)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local uilist = Instance.new("UIListLayout", frame)
uilist.FillDirection = Enum.FillDirection.Vertical
uilist.SortOrder = Enum.SortOrder.LayoutOrder
uilist.Padding = UDim.new(0, 5)

-- UI creation functions
local function createButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 18
	btn.Parent = frame
	return btn
end

local function createInput(labelText)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 35)
	container.BackgroundTransparency = 1
	container.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = labelText
	label.Font = Enum.Font.SourceSans
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(0.6, 0, 1, 0)
	input.Position = UDim2.new(0.4, 0, 0, 0)
	input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	input.TextColor3 = Color3.new(1, 1, 1)
	input.Text = "10"
	input.Font = Enum.Font.SourceSans
	input.TextSize = 18
	input.ClearTextOnFocus = false
	input.Parent = container

	return input
end

-- Variables
local running, autoCircle, noclip = false, false, false
local distanceBox = createInput("Bán kính đánh:")
local speedBox = createInput("Tốc độ quay:")

-- Buttons
local startBtn = createButton("Bật/Tắt Script")
startBtn.MouseButton1Click:Connect(function()
	running = not running
	startBtn.Text = running and "Đang chạy..." or "Bật/Tắt Script"
end)

local autoCircleBtn = createButton("Chạy vòng + Đánh")
autoCircleBtn.MouseButton1Click:Connect(function()
	autoCircle = not autoCircle
	autoCircleBtn.Text = autoCircle and "Tắt vòng + đánh" or "Chạy vòng + Đánh"
end)

local noclipBtn = createButton("Bật/Tắt Noclip")
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
end)

-- Noclip xử lý
game:GetService("RunService").Stepped:Connect(function()
	if noclip then
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

-- Tìm NPC gần nhất chứa tên "citynpc"
local function getNearestEnemy()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("citynpc") then
			local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist then
				dist = d
				closest = v
			end
		end
	end
	return closest
end

-- Di chuyển bộ tự nhiên đến mục tiêu
local pathService = game:GetService("PathfindingService")
spawn(function()
	while task.wait(0.5) do
		if running and not autoCircle then
			local target = getNearestEnemy()
			if target then
				local path = pathService:CreatePath()
				path:ComputeAsync(hrp.Position, target.HumanoidRootPart.Position)
				if path.Status == Enum.PathStatus.Complete then
					for _, waypoint in ipairs(path:GetWaypoints()) do
						if not running then break end
						humanoid:MoveTo(waypoint.Position)
						humanoid.MoveToFinished:Wait()
					end
				end
			end
		end
	end
end)

-- Chạy vòng quanh mục tiêu + auto đánh
local TweenService = game:GetService("TweenService")
spawn(function()
	while task.wait(0.03) do
		if autoCircle then
			local dist = tonumber(distanceBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 2
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
				local goalPos = target.HumanoidRootPart.Position + offset
				goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
				local cf = CFrame.new(goalPos, target.HumanoidRootPart.Position)
				TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = cf}):Play()

				-- Auto attack nếu có tool
				local tool = char:FindFirstChildOfClass("Tool")
				if tool then pcall(function() tool:Activate() end) end
			end
		end
	end
end)