-- Dịch vụ Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến
local fram = false
local radius = 23
local speed = 2
local target = nil
local teleported = false

-- Tìm mục tiêu gần nhất
local function getNearest()
	local minDist = math.huge
	local nearest = nil
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v ~= chr and v.Humanoid.Health > 0 then
			local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = v
			end
		end
	end
	return nearest
end

-- Xoay mặt về mục tiêu
local function faceTarget()
	if target and target:FindFirstChild("HumanoidRootPart") then
		local look = (target.HumanoidRootPart.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
	end
end

-- Auto đánh (dành cho mobile)
local function autoAttack()
	local tool = chr:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function()
			tool:Activate()
		end)
	end
end

-- Chạy vòng quanh mục tiêu sau khi đã teleport
RunService.Heartbeat:Connect(function()
	if fram and target and target:FindFirstChild("HumanoidRootPart") then
		if not teleported then
			local tPos = target.HumanoidRootPart.Position
			local offset = Vector3.new(math.random(-radius, radius), 0, math.random(-radius, radius))
			hrp.CFrame = CFrame.new(tPos + offset + Vector3.new(0, 3, 0)) -- Tele lên đầu mục tiêu
			teleported = true
		else
			local tPos = target.HumanoidRootPart.Position
			local time = tick() * speed
			local x = math.cos(time) * radius
			local z = math.sin(time) * radius
			local newPos = tPos + Vector3.new(x, 0, z)

			hum:MoveTo(newPos)
			faceTarget()
			autoAttack()
		end
	end
end)

-- Cập nhật mục tiêu
task.spawn(function()
	while true do
		if fram then
			local newTarget = getNearest()
			if newTarget ~= target then
				target = newTarget
				teleported = false -- Cho phép teleport lại
			end
		end
		wait(1)
	end
end)

-- GUI
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
	teleported = false
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