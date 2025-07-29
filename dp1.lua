-- Gui Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 100, 0, 30)
OpenButton.Position = UDim2.new(0, 10, 0, 10)
OpenButton.Text = "Mở Menu"
OpenButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
OpenButton.TextColor3 = Color3.new(1, 1, 1)

local MenuFrame = Instance.new("Frame", ScreenGui)
MenuFrame.Size = UDim2.new(0, 200, 0, 200)
MenuFrame.Position = UDim2.new(0, 10, 0, 50)
MenuFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MenuFrame.Visible = false

-- Toggle Menu
OpenButton.MouseButton1Click:Connect(function()
	MenuFrame.Visible = not MenuFrame.Visible
end)

-- Variables
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local autoFarm = false
local radius = 10
local speed = 3
local currentTarget

-- UI Elements
local ToggleFarm = Instance.new("TextButton", MenuFrame)
ToggleFarm.Size = UDim2.new(1, -10, 0, 30)
ToggleFarm.Position = UDim2.new(0, 5, 0, 5)
ToggleFarm.Text = "Auto Vòng"
ToggleFarm.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
ToggleFarm.TextColor3 = Color3.new(1, 1, 1)

local RadiusBox = Instance.new("TextBox", MenuFrame)
RadiusBox.Size = UDim2.new(1, -10, 0, 30)
RadiusBox.Position = UDim2.new(0, 5, 0, 40)
RadiusBox.Text = "Bán kính: 10"
RadiusBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
RadiusBox.TextColor3 = Color3.new(1, 1, 1)

local SpeedBox = Instance.new("TextBox", MenuFrame)
SpeedBox.Size = UDim2.new(1, -10, 0, 30)
SpeedBox.Position = UDim2.new(0, 5, 0, 75)
SpeedBox.Text = "Tốc độ: 3"
SpeedBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)

local HPLabel = Instance.new("TextLabel", MenuFrame)
HPLabel.Size = UDim2.new(1, -10, 0, 30)
HPLabel.Position = UDim2.new(0, 5, 0, 110)
HPLabel.Text = "Máu: ???"
HPLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
HPLabel.TextColor3 = Color3.new(1, 0, 0)

-- Function tìm NPC chứa CityNPC
local function getCityNPC()
	local closest, dist = nil, math.huge
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc.Name:lower():find("citynpc") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
			local d = (npc.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
			if d < dist then
				dist = d
				closest = npc
			end
		end
	end
	return closest
end

-- Toggle Farm
ToggleFarm.MouseButton1Click:Connect(function()
	autoFarm = not autoFarm
	ToggleFarm.Text = autoFarm and "Đang Vòng" or "Auto Vòng"
	if autoFarm then
		currentTarget = getCityNPC()
	end
end)

-- Nhập thông số
RadiusBox.FocusLost:Connect(function()
	local val = tonumber(string.match(RadiusBox.Text, "%d+"))
	if val then
		radius = val
	end
end)

SpeedBox.FocusLost:Connect(function()
	local val = tonumber(string.match(SpeedBox.Text, "%d+"))
	if val then
		speed = val
	end
end)

-- Vòng tròn + Hiển thị máu + Ngắt khi mục tiêu chết
local angle = 0
RunService.RenderStepped:Connect(function(dt)
	if autoFarm then
		if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
			autoFarm = false
			ToggleFarm.Text = "Auto Vòng"
			currentTarget = nil
			HPLabel.Text = "Máu: ???"
			return
		end

		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			-- Di chuyển vòng quanh
			angle += dt * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local targetPos = currentTarget.HumanoidRootPart.Position + offset
			HumanoidRootPart.CFrame = CFrame.new(targetPos, currentTarget.HumanoidRootPart.Position)

			-- Cập nhật máu
			if currentTarget:FindFirstChild("Humanoid") then
				HPLabel.Text = "Máu: " .. math.floor(currentTarget.Humanoid.Health)
			else
				HPLabel.Text = "Máu: ???"
			end
		end
	end
end)
