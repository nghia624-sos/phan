-- Dịch vụ Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến điều khiển
local fram = false
local radius = 23
local speed = 2
local target = nil

-- Hàm tìm mục tiêu gần nhất
local function getNearest()
	local nearest, minDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= chr and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
			local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = v
			end
		end
	end
	return nearest
end

-- Hàm tự xoay mặt về mục tiêu
local function faceTarget()
	if target and target:FindFirstChild("HumanoidRootPart") then
		local look = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
	end
end

-- Hàm tự đánh bằng Tool:Activate()
local function autoAttack()
	local tool = lp.Character:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function()
			tool:Activate()
		end)
	end
end

-- Di chuyển vòng quanh mục tiêu
RunService.Heartbeat:Connect(function()
	if fram and target and target:FindFirstChild("HumanoidRootPart") then
		local tPos = target.HumanoidRootPart.Position
		local tickTime = tick() * speed
		local x = math.cos(tickTime) * radius
		local z = math.sin(tickTime) * radius
		local pos = tPos + Vector3.new(x, 0, z)

		hum:MoveTo(pos)
		faceTarget()
		autoAttack()
	end
end)

-- Cập nhật mục tiêu mỗi giây
task.spawn(function()
	while true do
		if fram then
			target = getNearest()
		end
		wait(1)
	end
end)

-- GUI - TT:dongphandzs1
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TT_dongphandzs1"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 250, 0, 200)
main.Position = UDim2.new(0, 100, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local framBtn = Instance.new("TextButton", main)
framBtn.Position = UDim2.new(0, 10, 0, 40)
framBtn.Size = UDim2.new(0, 230, 0, 30)
framBtn.Text = "Bật Fram"
framBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
framBtn.TextColor3 = Color3.new(1, 1, 1)
framBtn.Font = Enum.Font.SourceSans
framBtn.TextSize = 16

framBtn.MouseButton1Click:Connect(function()
	fram = not fram
	framBtn.Text = fram and "Tắt Fram" or "Bật Fram"
end)

local radiusBox = Instance.new("TextBox", main)
radiusBox.Position = UDim2.new(0, 10, 0, 80)
radiusBox.Size = UDim2.new(0, 230, 0, 30)
radiusBox.Text = tostring(radius)
radiusBox.PlaceholderText = "Bán kính (VD: 23)"
radiusBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
radiusBox.TextColor3 = Color3.new(1, 1, 1)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 16

radiusBox.FocusLost:Connect(function()
	local val = tonumber(radiusBox.Text)
	if val then radius = val end
end)

local speedBox = Instance.new("TextBox", main)
speedBox.Position = UDim2.new(0, 10, 0, 120)
speedBox.Size = UDim2.new(0, 230, 0, 30)
speedBox.Text = tostring(speed)
speedBox.PlaceholderText = "Tốc độ (VD: 2)"
speedBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 16

speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text)
	if val then speed = val end
end)

-- Nút ẩn GUI
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Ẩn GUI"
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16

local visible = true
toggleBtn.MouseButton1Click:Connect(function()
	visible = not visible
	main.Visible = visible
	toggleBtn.Text = visible and "Ẩn GUI" or "Hiện GUI"
end)