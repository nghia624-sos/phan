-- Khởi tạo GUI
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NghiaMinhMenu"
gui.ResetOnSpawn = false

-- Frame chính
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

-- Tiêu đề
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "NghiaMinh Auto Fram"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(60,60,60)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Hiển thị tên mục tiêu
local targetLabel = Instance.new("TextLabel", frame)
targetLabel.Position = UDim2.new(0, 10, 0, 35)
targetLabel.Size = UDim2.new(1, -20, 0, 25)
targetLabel.BackgroundTransparency = 1
targetLabel.TextColor3 = Color3.new(1,1,1)
targetLabel.Font = Enum.Font.SourceSans
targetLabel.TextSize = 16
targetLabel.Text = "Mục tiêu: none"

-- Bán kính và tốc độ
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Position = UDim2.new(0, 10, 0, 65)
radiusBox.Size = UDim2.new(0, 110, 0, 25)
radiusBox.PlaceholderText = "Bán kính (mặc định 10)"
radiusBox.Text = ""
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 14
radiusBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
radiusBox.TextColor3 = Color3.new(1,1,1)

local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 140, 0, 65)
speedBox.Size = UDim2.new(0, 110, 0, 25)
speedBox.PlaceholderText = "Tốc độ vòng (mặc định 3)"
speedBox.Text = ""
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14
speedBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
speedBox.TextColor3 = Color3.new(1,1,1)

-- Nút bật auto fram
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Position = UDim2.new(0, 10, 0, 100)
toggleBtn.Size = UDim2.new(1, -20, 0, 30)
toggleBtn.Text = "Bật Auto Fram"
toggleBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18

-- Tự động fram logic
local running = false
local target = nil

function findNearestTarget()
	local closest, dist = nil, math.huge
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= char then
			local root = obj:FindFirstChild("HumanoidRootPart")
			if root and obj.Humanoid.Health > 0 then
				local d = (hrp.Position - root.Position).Magnitude
				if d < dist then
					dist = d
					closest = obj
				end
			end
		end
	end
	return closest
end

function rotateToTarget(target)
	local root = target:FindFirstChild("HumanoidRootPart")
	if root then
		local dir = (root.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))
	end
end

function moveInCircle(target, radius, speed)
	local angle = 0
	local root = target:FindFirstChild("HumanoidRootPart")
	while running and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local pos = root.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		humanoid:MoveTo(pos)
		rotateToTarget(target)
		angle = angle + math.rad(speed)
		task.wait(0.1)
	end
end

function attack()
	local tool = char:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		tool:Activate()
	end
end

toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "Tắt Auto Fram" or "Bật Auto Fram"

	if running then
		task.spawn(function()
			while running do
				target = findNearestTarget()
				if target then
					targetLabel.Text = "Mục tiêu: "..target.Name
					humanoid:MoveTo(target.HumanoidRootPart.Position)
					repeat
						task.wait(0.2)
					until not running or (hrp.Position - target.HumanoidRootPart.Position).Magnitude < 12

					local r = tonumber(radiusBox.Text) or 10
					local s = tonumber(speedBox.Text) or 3
					
					task.spawn(function()
						while running and target and target.Humanoid.Health > 0 do
							attack()
							task.wait(0.4)
						end
					end)
					
					moveInCircle(target, r, s)
				else
					targetLabel.Text = "Mục tiêu: không tìm thấy"
				end
				task.wait(1)
			end
		end)
	end
end)