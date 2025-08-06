--// Dịch vụ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// Biến
local radius = 10
local speed = 2
local fram = false
local currentTarget = nil
local running = false

--// Tìm NPC có tên chứa "CityNPC"
function findTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.lower(v.Name):find("citynpc") then
				return v
			end
		end
	end
	return nil
end

--// Tự động đánh
function autoAttack(target)
	spawn(function()
		while fram and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
			local tool = lp.Character:FindFirstChildOfClass("Tool")
			if tool then
				tool:Activate()
			end
			wait(0.2)
		end
	end)
end

--// Chạy vòng quanh bằng MoveTo
function moveInCircle(target)
	if not target then return end
	running = true
	local angle = 0
	while fram and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goalPos = target.HumanoidRootPart.Position + offset
		-- MoveTo mượt, không xuyên
		hum:MoveTo(goalPos)
		angle = angle + speed * 0.05
		-- Quay mặt về mục tiêu
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))
		wait(0.05)
	end
	running = false
end

--// Bật Fram
function startFram()
	currentTarget = findTarget()
	if currentTarget then
		-- Tele đến gần mục tiêu
		local pos = currentTarget.HumanoidRootPart.Position + Vector3.new(0, 0, -radius)
		hrp.CFrame = CFrame.new(pos)
		wait(0.2)
		autoAttack(currentTarget)
		moveInCircle(currentTarget)
	end
end

--// Giao diện cơ bản KRNL Mobile
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "NghiaFramGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Frame.Active = true
Frame.Draggable = true

local FramToggle = Instance.new("TextButton", Frame)
FramToggle.Size = UDim2.new(1, 0, 0, 40)
FramToggle.Position = UDim2.new(0, 0, 0, 0)
FramToggle.Text = "Bật Fram"
FramToggle.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
FramToggle.TextColor3 = Color3.new(1, 1, 1)

FramToggle.MouseButton1Click:Connect(function()
	fram = not fram
	FramToggle.Text = fram and "Tắt Fram" or "Bật Fram"
	if fram and not running then
		startFram()
	end
end)

-- Bán kính
local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.Size = UDim2.new(1, 0, 0, 30)
RadiusBox.Position = UDim2.new(0, 0, 0, 50)
RadiusBox.PlaceholderText = "Bán kính (mặc định 10)"
RadiusBox.Text = ""
RadiusBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RadiusBox.TextColor3 = Color3.new(1, 1, 1)

RadiusBox.FocusLost:Connect(function()
	local val = tonumber(RadiusBox.Text)
	if val then radius = val end
end)

-- Tốc độ
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1, 0, 0, 30)
SpeedBox.Position = UDim2.new(0, 0, 0, 85)
SpeedBox.PlaceholderText = "Tốc độ (mặc định 2)"
SpeedBox.Text = ""
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)

SpeedBox.FocusLost:Connect(function()
	local val = tonumber(SpeedBox.Text)
	if val then speed = val end
end)