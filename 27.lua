-- Fram NPC Full Fix with MoveTo and Auto Attack
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPCGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.5, -125, 0.5, -100)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Fram NPC"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local function createButton(name, pos, parent)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, pos)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 18
	btn.Text = name
	return btn
end

local function createBox(pos, placeholder, parent)
	local box = Instance.new("TextBox", parent)
	box.Size = UDim2.new(1, -10, 0, 25)
	box.Position = UDim2.new(0, 5, 0, pos)
	box.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.PlaceholderText = placeholder
	box.Font = Enum.Font.SourceSans
	box.TextSize = 18
	return box
end

local running = false
local autoCircle = false

local startBtn = createButton("Bật/Tắt Script", 35, frame)
local circleBtn = createButton("Chạy Vòng + Đánh", 70, frame)
local distanceBox = createBox(110, "Bán kính vòng (vd: 10)", frame)
local speedBox = createBox(140, "Tốc độ vòng (vd: 2)", frame)

distanceBox.Text = "10"
speedBox.Text = "2"

local function getNearestEnemy()
	local nearest, minDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("citynpc") then
			local h = v:FindFirstChild("Humanoid")
			local root = v:FindFirstChild("HumanoidRootPart")
			if h and h.Health > 0 and root then
				local dist = (hrp.Position - root.Position).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

startBtn.MouseButton1Click:Connect(function()
	running = not running
	startBtn.Text = running and "Đang chạy..." or "Bật/Tắt Script"
end)

circleBtn.MouseButton1Click:Connect(function()
	autoCircle = not autoCircle
	circleBtn.Text = autoCircle and "Tắt Chạy Vòng + Đánh" or "Chạy Vòng + Đánh"
end)

-- Di chuyển tự nhiên bằng MoveTo
spawn(function()
	while true do wait(0.5)
		if running then
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				humanoid:MoveTo(target.HumanoidRootPart.Position)
				humanoid.MoveToFinished:Wait()
			end
		end
	end
end)

-- Chạy vòng quanh mục tiêu + auto đánh
spawn(function()
	while true do wait(0.03)
		if autoCircle then
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local dist = tonumber(distanceBox.Text) or 10
				local speed = tonumber(speedBox.Text) or 2
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
				local goalPos = target.HumanoidRootPart.Position + offset
				goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
				local goalCF = CFrame.new(goalPos, target.HumanoidRootPart.Position)
				TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()

				-- Tự động đánh và aim
				local tool = char:FindFirstChildOfClass("Tool")
				if tool and tool:FindFirstChild("Handle") then
					tool:Activate()
				end
			end
		end
	end
end) 