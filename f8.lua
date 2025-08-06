-- ROBLOX KRNL MOBILE - MENU TT:dongphandzs1 (Fix không chạy tới mục tiêu)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến điều khiển
local fram = false
local circle = false
local speed = 2
local radius = 15
local currentTarget = nil

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FramMenu"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 280, 0, 230)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1 - Đánh BOSS"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

-- Nút Fram
local btnFram = Instance.new("TextButton", Frame)
btnFram.Size = UDim2.new(0.9, 0, 0, 30)
btnFram.Position = UDim2.new(0.05, 0, 0, 40)
btnFram.Text = "Bật Fram"
btnFram.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
btnFram.TextColor3 = Color3.new(1,1,1)
btnFram.Font = Enum.Font.SourceSansBold
btnFram.TextScaled = true

-- Bán kính và tốc độ
local radiusBox = Instance.new("TextBox", Frame)
radiusBox.Size = UDim2.new(0.4, 0, 0, 25)
radiusBox.Position = UDim2.new(0.05, 0, 0, 80)
radiusBox.Text = tostring(radius)
radiusBox.PlaceholderText = "Bán kính"
radiusBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
radiusBox.TextColor3 = Color3.new(1,1,1)

local speedBox = Instance.new("TextBox", Frame)
speedBox.Size = UDim2.new(0.4, 0, 0, 25)
speedBox.Position = UDim2.new(0.55, 0, 0, 80)
speedBox.Text = tostring(speed)
speedBox.PlaceholderText = "Tốc độ"
speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedBox.TextColor3 = Color3.new(1,1,1)

-- Hiện máu mục tiêu
local healthLabel = Instance.new("TextLabel", Frame)
healthLabel.Size = UDim2.new(0.9, 0, 0, 25)
healthLabel.Position = UDim2.new(0.05, 0, 0, 110)
healthLabel.BackgroundTransparency = 1
healthLabel.TextColor3 = Color3.new(1, 0.5, 0.5)
healthLabel.TextScaled = true
healthLabel.Font = Enum.Font.SourceSans
healthLabel.Text = "Máu: Không có mục tiêu"

-- Thu gọn menu
local toggleBtn = Instance.new("TextButton", Frame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 25)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 140)
toggleBtn.Text = "Thu gọn menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.SourceSans
toggleBtn.TextScaled = true

local minimized = false
toggleBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _, v in pairs(Frame:GetChildren()) do
		if v ~= title and v ~= toggleBtn then
			v.Visible = not minimized
		end
	end
	toggleBtn.Text = minimized and "Mở rộng menu" or "Thu gọn menu"
end)

-- Tìm boss
local function getBoss()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
			if string.lower(v.Name):find("boss") then
				return v
			end
		end
	end
	return nil
end

-- Di chuyển tới mục tiêu (Pathfinding không xuyên tường)
local function moveToTarget(target)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	local path = PathfindingService:CreatePath()
	path:ComputeAsync(hrp.Position, target.HumanoidRootPart.Position)
	local waypoints = path:GetWaypoints()
	for _, point in ipairs(waypoints) do
		if not fram then return end
		hum:MoveTo(point.Position)
		hum.MoveToFinished:Wait()
	end
end

-- Di chuyển vòng quanh
local function circleAround()
	local angle = 0
	RunService:UnbindFromRenderStep("Circle")
	RunService:BindToRenderStep("Circle", Enum.RenderPriority.Character.Value, function()
		if not fram or not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") then return end
		local pos = currentTarget.HumanoidRootPart.Position
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local movePos = pos + offset
		hum:MoveTo(movePos)
		hrp.CFrame = CFrame.new(hrp.Position, pos)
		angle += speed * RunService.Heartbeat:Wait()
	end)
end

-- Kiểm tra mục tiêu
task.spawn(function()
	while task.wait(1) do
		if fram then
			if currentTarget == nil or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
				currentTarget = nil
				healthLabel.Text = "Máu: Không có mục tiêu"
				fram = false
				RunService:UnbindFromRenderStep("Circle")
			end
		end
	end
end)

-- Khi nhấn Fram
btnFram.MouseButton1Click:Connect(function()
	fram = not fram
	btnFram.Text = fram and "Tắt Fram" or "Bật Fram"
	radius = tonumber(radiusBox.Text) or 15
	speed = tonumber(speedBox.Text) or 2

	if fram then
		currentTarget = getBoss()
		if currentTarget then
			moveToTarget(currentTarget)
			circleAround()
		else
			btnFram.Text = "Không tìm thấy boss"
			fram = false
		end
	end
end)

-- Cập nhật máu mục tiêu
RunService.RenderStepped:Connect(function()
	if currentTarget and currentTarget:FindFirstChildOfClass("Humanoid") then
		local hp = math.floor(currentTarget:FindFirstChildOfClass("Humanoid").Health)
		healthLabel.Text = "Máu: " .. hp
	end
end)