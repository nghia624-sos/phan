--// DỊCH VỤ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// BIẾN
local fram = false
local radius = 23
local speed = 2
local target = nil

--// HÀM TÌM NPC GẦN NHẤT
local function getNearestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= chr then
			local mag = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if mag < dist then
				closest = v
				dist = mag
			end
		end
	end
	return closest
end

--// HÀM XOAY VỀ PHÍA MỤC TIÊU
local function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local lookVector = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
	end
end

--// AUTO FRAM VÒNG TRÒN
RunService.Heartbeat:Connect(function(dt)
	if fram and target and target:FindFirstChild("HumanoidRootPart") and hum and hum.Health > 0 then
		local tPos = target.HumanoidRootPart.Position
		local time = tick() * speed
		local x = math.cos(time) * radius
		local z = math.sin(time) * radius
		local newPos = tPos + Vector3.new(x, 0, z)

		hum:MoveTo(newPos)
		faceTarget(target)
	end
end)

--// TÌM MỤC TIÊU LIÊN TỤC
task.spawn(function()
	while true do
		if fram or not target then
			target = getNearestTarget()
		end
		task.wait(1)
	end
end)

--// GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TT_dongphandzs1"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "TT:dongphandzs1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local FramToggle = Instance.new("TextButton", Frame)
FramToggle.Position = UDim2.new(0, 10, 0, 40)
FramToggle.Size = UDim2.new(0, 230, 0, 30)
FramToggle.Text = "Bật Fram"
FramToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FramToggle.TextColor3 = Color3.new(1, 1, 1)
FramToggle.Font = Enum.Font.SourceSans
FramToggle.TextSize = 16

FramToggle.MouseButton1Click:Connect(function()
	fram = not fram
	FramToggle.Text = fram and "Tắt Fram" or "Bật Fram"
end)

local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.Position = UDim2.new(0, 10, 0, 80)
RadiusBox.Size = UDim2.new(0, 230, 0, 30)
RadiusBox.Text = tostring(radius)
RadiusBox.PlaceholderText = "Bán kính đánh (VD: 23)"
RadiusBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
RadiusBox.TextColor3 = Color3.new(1, 1, 1)
RadiusBox.Font = Enum.Font.SourceSans
RadiusBox.TextSize = 16

RadiusBox.FocusLost:Connect(function()
	local val = tonumber(RadiusBox.Text)
	if val then
		radius = val
	end
end)

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Position = UDim2.new(0, 10, 0, 120)
SpeedBox.Size = UDim2.new(0, 230, 0, 30)
SpeedBox.Text = tostring(speed)
SpeedBox.PlaceholderText = "Tốc độ (VD: 2)"
SpeedBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 16

SpeedBox.FocusLost:Connect(function()
	local val = tonumber(SpeedBox.Text)
	if val then
		speed = val
	end
end)

local ToggleGUI = Instance.new("TextButton", ScreenGui)
ToggleGUI.Size = UDim2.new(0, 100, 0, 30)
ToggleGUI.Position = UDim2.new(0, 10, 0, 10)
ToggleGUI.Text = "Ẩn GUI"
ToggleGUI.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleGUI.TextColor3 = Color3.new(1, 1, 1)
ToggleGUI.Font = Enum.Font.SourceSansBold
ToggleGUI.TextSize = 16
ToggleGUI.ZIndex = 2

local isVisible = true
ToggleGUI.MouseButton1Click:Connect(function()
	isVisible = not isVisible
	Frame.Visible = isVisible
	ToggleGUI.Text = isVisible and "Ẩn GUI" or "Hiện GUI"
end)