local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Biến điều khiển
local radius = 10
local speed = 5
local running = false
local currentTarget = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ScreenGui.Name = "TT_dongphandzs1_GUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "TT:dongphandzs1"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(60,60,60)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, -20, 0, 30)
Toggle.Position = UDim2.new(0, 10, 0, 40)
Toggle.Text = "Bật Fram: Tắt"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
Toggle.Font = Enum.Font.SourceSans
Toggle.TextSize = 16

local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.Size = UDim2.new(1, -20, 0, 30)
RadiusBox.Position = UDim2.new(0, 10, 0, 80)
RadiusBox.Text = "Bán kính: 10"
RadiusBox.TextColor3 = Color3.new(1,1,1)
RadiusBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
RadiusBox.ClearTextOnFocus = false

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 120)
SpeedBox.Text = "Tốc độ: 5"
SpeedBox.TextColor3 = Color3.new(1,1,1)
SpeedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
SpeedBox.ClearTextOnFocus = false

local HealthLabel = Instance.new("TextLabel", Frame)
HealthLabel.Size = UDim2.new(1, -20, 0, 30)
HealthLabel.Position = UDim2.new(0, 10, 0, 160)
HealthLabel.Text = "Máu mục tiêu: Không"
HealthLabel.TextColor3 = Color3.new(1,1,1)
HealthLabel.BackgroundTransparency = 1
HealthLabel.Font = Enum.Font.SourceSans
HealthLabel.TextSize = 14

-- Logic tìm mục tiêu gần
function GetNearestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= char then
			local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if d < dist and v.Humanoid.Health > 0 then
				closest = v
				dist = d
			end
		end
	end
	return closest
end

-- Auto Attack
function AutoAttack(target)
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		tool:Activate()
	end
end

-- Toggle bật tắt
Toggle.MouseButton1Click:Connect(function()
	running = not running
	Toggle.Text = "Bật Fram: " .. (running and "Bật" or "Tắt")
end)

-- Vòng lặp chạy quanh
RunService.RenderStepped:Connect(function()
	if running then
		local suc1, r1 = pcall(function()
			radius = tonumber(RadiusBox.Text:match("%d+")) or radius
			speed = tonumber(SpeedBox.Text:match("%d+")) or speed
		end)

		currentTarget = GetNearestTarget()
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			local hp = currentTarget.Humanoid
			HealthLabel.Text = "Máu mục tiêu: " .. math.floor(hp.Health) .. "/" .. math.floor(hp.MaxHealth)

			-- Di chuyển quanh
			local tickTime = tick() * speed
			local angle = tickTime % (2 * math.pi)
			local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local targetPos = currentTarget.HumanoidRootPart.Position + offset
			hum:MoveTo(targetPos)

			-- Quay mặt
			hrp.CFrame = CFrame.new(hrp.Position, currentTarget.HumanoidRootPart.Position)

			-- Đánh
			AutoAttack(currentTarget)
		else
			HealthLabel.Text = "Máu mục tiêu: Không"
		end
	end
end)