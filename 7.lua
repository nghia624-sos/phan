local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNPC"
gui.ResetOnSpawn = false

-- Menu frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 220)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "Fram NPC"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- Toggle
local enable = false
local circleMode = false

function createButton(text, pos, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, pos)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 18
	btn.MouseButton1Click:Connect(callback)
	return btn
end

createButton("Bật/Tắt Script", 35, function()
	enable = not enable
end)

createButton("Chạy vòng tròn + Đánh", 70, function()
	circleMode = not circleMode
end)

local distanceBox = Instance.new("TextBox", frame)
distanceBox.PlaceholderText = "Bán kính vòng (vd: 10)"
distanceBox.Size = UDim2.new(1, -20, 0, 30)
distanceBox.Position = UDim2.new(0, 10, 0, 110)
distanceBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
distanceBox.TextColor3 = Color3.new(1, 1, 1)
distanceBox.Font = Enum.Font.SourceSans
distanceBox.TextSize = 18

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ vòng (vd: 3)"
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 150)
speedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 18

-- Tìm NPC gần nhất
function getNearestEnemy()
	local nearest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
				local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if d < dist then
					dist = d
					nearest = v
				end
			end
		end
	end
	return nearest
end

-- Chạy bộ tự nhiên
function walkToTarget(pos)
	humanoid:MoveTo(pos)
	local reached = false
	local conn
	conn = humanoid.MoveToFinished:Connect(function(success)
		reached = true
	end)
	while not reached and (hrp.Position - pos).Magnitude > 3 do
		task.wait(0.1)
	end
	if conn then conn:Disconnect() end
end

-- Auto Fram Loop
task.spawn(function()
	local TweenService = game:GetService("TweenService")
	while true do task.wait(0.03)
		if enable then
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local targetHRP = target.HumanoidRootPart
				local dist = (hrp.Position - targetHRP.Position).Magnitude

				if dist > 10 then
					walkToTarget(targetHRP.Position)
				end

				while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and enable do
					if circleMode then
						local distV = tonumber(distanceBox.Text) or 10
						local spd = tonumber(speedBox.Text) or 3
						local angle = tick() * spd
						local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * distV
						local goalPos = targetHRP.Position + offset
						local goalCF = CFrame.new(goalPos, targetHRP.Position)
						TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()
						-- Đánh
						for _, tool in ipairs(char:GetChildren()) do
							if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
								pcall(function() tool:Activate() end)
							end
						end
					else
						humanoid:MoveTo(targetHRP.Position)
					end
					task.wait(0.1)
				end
			end
		end
	end
end)