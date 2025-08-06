-- GUI ĐƠN (Không bị trùng, không cần bật 2 lần)
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
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "TT_dongphandzs1_GUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(60,60,60)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Text = "Bật Fram: Tắt"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, -20, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 80)
radiusBox.Text = "Bán kính: 10"
radiusBox.TextColor3 = Color3.new(1,1,1)
radiusBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
radiusBox.ClearTextOnFocus = false

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 120)
speedBox.Text = "Tốc độ: 5"
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedBox.ClearTextOnFocus = false

local healthLabel = Instance.new("TextLabel", frame)
healthLabel.Size = UDim2.new(1, -20, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 160)
healthLabel.Text = "Máu mục tiêu: Không"
healthLabel.TextColor3 = Color3.new(1,1,1)
healthLabel.BackgroundTransparency = 1
healthLabel.Font = Enum.Font.SourceSans
healthLabel.TextSize = 14

-- Hàm tìm mục tiêu gần nhất
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

-- Auto attack
function AutoAttack()
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then tool:Activate() end
end

-- Nút bật fram
toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = "Bật Fram: " .. (running and "Bật" or "Tắt")
end)

-- Chỉ 1 vòng lặp duy nhất
RunService.RenderStepped:Connect(function()
	if not running then return end

	-- Cập nhật các thông số
	local suc1, _ = pcall(function()
		radius = tonumber(radiusBox.Text:match("%d+")) or 10
		speed = tonumber(speedBox.Text:match("%d+")) or 5
	end)

	currentTarget = GetNearestTarget()

	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local hp = currentTarget.Humanoid
		healthLabel.Text = "Máu mục tiêu: " .. math.floor(hp.Health) .. "/" .. math.floor(hp.MaxHealth)

		local tickTime = tick() * speed
		local angle = tickTime % (2 * math.pi)
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = currentTarget.HumanoidRootPart.Position + offset
		hum:MoveTo(targetPos)

		-- Quay mặt về phía mục tiêu
		hrp.CFrame = CFrame.new(hrp.Position, currentTarget.HumanoidRootPart.Position)

		-- Auto đánh
		AutoAttack()
	else
		healthLabel.Text = "Máu mục tiêu: Không"
	end
end)