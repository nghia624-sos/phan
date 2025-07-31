-- Fram NPC Script - Tương thích KRNL Mobile
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local TweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPC"
gui.ResetOnSpawn = false

-- Tạo khung menu chính
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 240)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
frame.Parent = gui

-- Tiêu đề
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.Text = "Fram NPC"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Tabs
local tab1Btn = Instance.new("TextButton", frame)
tab1Btn.Text = "Tab 1: Chạy bộ đến NPC"
tab1Btn.Size = UDim2.new(1, 0, 0, 30)
tab1Btn.Position = UDim2.new(0, 0, 0, 40)

local tab2Btn = Instance.new("TextButton", frame)
tab2Btn.Text = "Tab 2: Vòng quanh + Đánh"
tab2Btn.Size = UDim2.new(1, 0, 0, 30)
tab2Btn.Position = UDim2.new(0, 0, 0, 80)

local tab3Btn = Instance.new("TextButton", frame)
tab3Btn.Text = "Tab 3: Tự vòng quanh"
tab3Btn.Size = UDim2.new(1, 0, 0, 30)
tab3Btn.Position = UDim2.new(0, 0, 0, 120)

-- Input tùy chỉnh khoảng cách + tốc độ
local distanceBox = Instance.new("TextBox", frame)
distanceBox.PlaceholderText = "Khoảng cách (vd: 10)"
distanceBox.Size = UDim2.new(1, -10, 0, 30)
distanceBox.Position = UDim2.new(0, 5, 0, 160)
distanceBox.Text = "10"

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ (vd: 2)"
speedBox.Size = UDim2.new(1, -10, 0, 30)
speedBox.Position = UDim2.new(0, 5, 0, 200)
speedBox.Text = "2"

-- Toggle script chính
local toggle = false
local runAround = false
local autoRunCircle = false

-- Nút bật/tắt
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Text = "Bật Script"
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.Position = UDim2.new(0, 0, 1, -30)

toggleBtn.MouseButton1Click:Connect(function()
	toggle = not toggle
	toggleBtn.Text = toggle and "Tắt Script" or "Bật Script"
end)

-- Gán nút tab
tab1Btn.MouseButton1Click:Connect(function()
	runAround = false
	autoRunCircle = false
end)

tab2Btn.MouseButton1Click:Connect(function()
	runAround = true
	autoRunCircle = false
end)

tab3Btn.MouseButton1Click:Connect(function()
	runAround = false
	autoRunCircle = true
end)

-- Tìm NPC gần nhất
function getNearestNPC()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("citynpc") then
			local root = v:FindFirstChild("HumanoidRootPart")
			if root then
				local d = (root.Position - hrp.Position).Magnitude
				if d < dist then
					closest = v
					dist = d
				end
			end
		end
	end
	return closest
end

-- Auto Fram vòng lặp chính
task.spawn(function()
	while true do task.wait(0.1)
		if toggle then
			local target = getNearestNPC()
			if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
				local enemyHRP = target.HumanoidRootPart
				local enemyHum = target.Humanoid

				-- Di chuyển đến mục tiêu
				if (enemyHRP.Position - hrp.Position).Magnitude > 8 then
					humanoid:MoveTo(enemyHRP.Position)
					humanoid.MoveToFinished:Wait()
				end

				-- Tự chạy vòng tròn quanh mục tiêu
				if autoRunCircle then
					task.spawn(function()
						while toggle and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
							local dist = tonumber(distanceBox.Text) or 10
							local speed = tonumber(speedBox.Text) or 2
							local angle = tick() * speed
							local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
							local goalPos = enemyHRP.Position + offset
							goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
							local goalCF = CFrame.new(goalPos, enemyHRP.Position)
							TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()
							task.wait(0.03)
						end
					end)
				end

				-- Auto đánh + xoay mặt
				if runAround then
					task.spawn(function()
						while toggle and target and target.Humanoid.Health > 0 do
							char:SetPrimaryPartCFrame(CFrame.new(hrp.Position, enemyHRP.Position))
							mouse1press()
							task.wait(0.1)
							mouse1release()
							task.wait(0.1)
						end
					end)
				end

				repeat task.wait() until target.Humanoid.Health <= 0 or not toggle
			end
		end
	end
end)