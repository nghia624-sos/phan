-- Fram NPC Full Fix (MoveTo + Auto Vòng + Đánh + Aim + Menu kéo)
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramMenuMobile"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 250)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 4)
uilist.FillDirection = Enum.FillDirection.Vertical
uilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
uilist.VerticalAlignment = Enum.VerticalAlignment.Top

function createLabel(text)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = UDim2.new(1, -10, 0, 25)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 18
	return label
end

function createButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Text = text
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 18
	btn.MouseButton1Click:Connect(callback)
	return btn
end

function createBox(placeholder)
	local box = Instance.new("TextBox")
	box.PlaceholderText = placeholder
	box.Size = UDim2.new(1, -10, 0, 30)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.SourceSans
	box.TextSize = 18
	return box
end

-- UI Elements
frame:AddChild(createLabel("Fram NPC - Nghia Minh"))
local toggleScriptBtn = createButton("[BẬT] Tự Fram NPC", function() running = not running toggleScriptBtn.Text = running and "[TẮT] Tự Fram NPC" or "[BẬT] Tự Fram NPC" end)
frame:AddChild(toggleScriptBtn)

local toggleRunCircleBtn = createButton("[BẬT] Chạy vòng + Đánh", function() runningCircle = not runningCircle toggleRunCircleBtn.Text = runningCircle and "[TẮT] Chạy vòng + Đánh" or "[BẬT] Chạy vòng + Đánh" end)
frame:AddChild(toggleRunCircleBtn)

local distanceBox = createBox("Bán kính đánh")
distanceBox.Text = "10"
frame:AddChild(distanceBox)

local speedBox = createBox("Tốc độ chạy vòng")
speedBox.Text = "2"
frame:AddChild(speedBox)

-- Tìm NPC gần nhất
function getNearestEnemy()
	local minDist, target = math.huge, nil
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and string.lower(v.Name):find("citynpc") then
			local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
			if dist < minDist then
				minDist = dist
				target = v
			end
		end
	end
	return target
end

-- Tự động đánh
function attack()
	pcall(function()
		mouse1click()
	end)
end

-- Di chuyển tự nhiên đến mục tiêu
function moveToTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		humanoid:MoveTo(target.HumanoidRootPart.Position)
	end
end

-- Chạy vòng quanh mục tiêu
RunService.Heartbeat:Connect(function()
	task.spawn(function()
		if running then
			local target = getNearestEnemy()
			if target and target:FindFirstChild("HumanoidRootPart") then
				local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
				if dist > 10 then
					moveToTarget(target)
				elseif runningCircle then
					local radius = tonumber(distanceBox.Text) or 10
					local speed = tonumber(speedBox.Text) or 2
					local angle = tick() * speed
					local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
					local goalPos = target.HumanoidRootPart.Position + offset
					humanoid:MoveTo(goalPos)
					-- Quay mặt
					local lookAt = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
					hr... = CFrame.new(hrp.Position) * CFrame.Angles(0, math.atan2(lookAt.LookVector.X, lookAt.LookVector.Z), 0)
					attack()
				end
			end
		end
	end)
end)

-- Tự động tìm NPC khác sau khi tiêu diệt
workspace.ChildRemoved:Connect(function(child)
	if child:IsA("Model") and child:FindFirstChild("Humanoid") and string.lower(child.Name):find("citynpc") then
		task.wait(0.5)
		local nextTarget = getNearestEnemy()
		if nextTarget then
			moveToTarget(nextTarget)
		end
	end
end)