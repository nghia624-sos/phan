local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNpcMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Size = UDim2.new(0, 250, 0, 280)
frame.Position = UDim2.new(0.2, 0, 0.2, 0)
frame.Active = true
frame.Draggable = true

local function createLabel(text, posY)
	local label = Instance.new("TextLabel", frame)
	label.Text = text
	label.Size = UDim2.new(1, 0, 0, 25)
	label.Position = UDim2.new(0, 0, 0, posY)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 20
	return label
end

local function createToggle(name, posY, callback)
	local button = Instance.new("TextButton", frame)
	button.Size = UDim2.new(1, 0, 0, 30)
	button.Position = UDim2.new(0, 0, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 18
	button.Text = name .. ": OFF"
	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = name .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
	return button
end

local function createInput(name, posY, default, callback)
	local textBox = Instance.new("TextBox", frame)
	textBox.Size = UDim2.new(1, 0, 0, 30)
	textBox.Position = UDim2.new(0, 0, 0, posY)
	textBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	textBox.PlaceholderText = name .. ": " .. tostring(default)
	textBox.TextColor3 = Color3.new(1, 1, 1)
	textBox.Font = Enum.Font.SourceSans
	textBox.TextSize = 18
	textBox.Text = ""
	textBox.FocusLost:Connect(function()
		local val = tonumber(textBox.Text)
		if val then
			callback(val)
		end
	end)
end

-- Variables
local runService = game:GetService("RunService")
local target = nil
local running = true
local autoFarm = false
local autoCircle = false
local radius = 10
local speed = 3

-- Functions
function findNearestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
			if string.lower(v.Name):find("citynpc") then
				local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					closest = v
					dist = d
				end
			end
		end
	end
	return closest
end

function moveTo(pos)
	humanoid:MoveTo(pos)
end

function aimAtTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
	end
end

function attack()
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		tool:Activate()
	end
end

-- Loops
task.spawn(function()
	while running do
		if autoFarm then
			if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
				target = findNearestTarget()
			end
			if target then
				local dist = (target.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist > 15 then
					moveTo(target.HumanoidRootPart.Position)
				end
			end
		end
		task.wait(0.2)
	end
end)

task.spawn(function()
	while running do
		if autoCircle and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
			local tPos = target.HumanoidRootPart.Position
			local angle = tick() * speed
			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			local newPos = tPos + Vector3.new(x, 0, z)
			moveTo(newPos)
			aimAtTarget(target)
			attack()
		end
		task.wait(0.1)
	end
end)

-- GUI controls
createLabel("Fram NPC Menu", 0)
createToggle("Bật tìm mục tiêu", 30, function(state) autoFarm = state end)
createToggle("Chạy vòng quanh + Đánh", 70, function(state) autoCircle = state end)
createInput("Bán kính chạy vòng", 110, radius, function(val) radius = val end)
createInput("Tốc độ vòng", 150, speed, function(val) speed = val end)