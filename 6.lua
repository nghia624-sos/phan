local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")
local mouse = lp:GetMouse()

-- Giao diện
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MenuTT"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.5, -150, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT: dongphandzs1"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 30)
toggle.Position = UDim2.new(0, 0, 0, 35)
toggle.Text = "BẬT: Đánh Boss"
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0.5, -10, 0, 30)
radiusBox.Position = UDim2.new(0, 5, 0, 75)
radiusBox.Text = "23"
radiusBox.PlaceholderText = "Khoảng cách"
radiusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
radiusBox.TextColor3 = Color3.new(1, 1, 1)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0.5, -10, 0, 30)
speedBox.Position = UDim2.new(0.5, 5, 0, 75)
speedBox.Text = "2"
speedBox.PlaceholderText = "Tốc độ quay"
speedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBox.TextColor3 = Color3.new(1, 1, 1)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -10, 0, 30)
hpLabel.Position = UDim2.new(0, 5, 0, 115)
hpLabel.Text = "Máu mục tiêu: N/A"
hpLabel.TextColor3 = Color3.new(1, 0.2, 0.2)
hpLabel.BackgroundTransparency = 1
hpLabel.Font = Enum.Font.SourceSans
hpLabel.TextSize = 16

-- Biến
local running = false
local currentTarget = nil

-- Hàm tìm NPC gần nhất
local function getNearestTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if v ~= chr and v.Humanoid.Health > 0 then
				return v
			end
		end
	end
end

-- Hàm đánh và aim
local function attackAndAim()
	local tool = chr:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		local remote = tool:FindFirstChildWhichIsA("RemoteEvent", true)
		if remote then
			pcall(function()
				remote:FireServer()
			end)
		end
	end
	if currentTarget then
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(
			currentTarget.HumanoidRootPart.Position.X,
			hrp.Position.Y,
			currentTarget.HumanoidRootPart.Position.Z
		))
	end
end

-- Vòng chạy
task.spawn(function()
	while true do task.wait()
		if running then
			currentTarget = getNearestTarget()
			if currentTarget and currentTarget:FindFirstChild("Humanoid") then
				local r = tonumber(radiusBox.Text) or 20
				local s = tonumber(speedBox.Text) or 2
				local t = tick()
				local angle = t * s
				local x = math.cos(angle) * r
				local z = math.sin(angle) * r
				local goal = currentTarget.HumanoidRootPart.Position + Vector3.new(x, 0, z)
				local tween = TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal)})
				tween:Play()

				-- Aim + Auto đánh
				attackAndAim()

				-- Hiển thị máu mục tiêu
				hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
			else
				hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
			end
		end
	end
end)

-- Nút bật
toggle.MouseButton1Click:Connect(function()
	running = not running
	toggle.Text = (running and "TẮT: Đánh Boss" or "BẬT: Đánh Boss")
end)