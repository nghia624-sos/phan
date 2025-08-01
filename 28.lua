-- Fram NPC Full Fix Script (Mobile KRNL Compatible)
-- Tính năng: Di chuyển tự nhiên, chạy vòng quanh mục tiêu, auto đánh, tránh tele

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Biến điều khiển
local scriptEnabled = false
local circleEnabled = false
local autoAttack = false
local nearestTarget = nil

-- Tạo GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
frame.Active = true
frame.Draggable = true

local function createButton(name, posY)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Text = name
	return btn
end

local toggleScript = createButton("[Bật/Tắt] Fram NPC", 5)
local toggleCircle = createButton("[Bật/Tắt] Chạy Vòng + Đánh", 40)
local radiusLabel = Instance.new("TextLabel", frame)
radiusLabel.Size = UDim2.new(0.5, -10, 0, 25)
radiusLabel.Position = UDim2.new(0, 5, 0, 75)
radiusLabel.Text = "Bán kính"
radiusLabel.TextColor3 = Color3.new(1, 1, 1)
radiusLabel.BackgroundTransparency = 1

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0.5, -10, 0, 25)
radiusBox.Position = UDim2.new(0.5, 5, 0, 75)
radiusBox.Text = "10"
radiusBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
radiusBox.TextColor3 = Color3.new(1, 1, 1)

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(0.5, -10, 0, 25)
speedLabel.Position = UDim2.new(0, 5, 0, 105)
speedLabel.Text = "Tốc độ"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0.5, -10, 0, 25)
speedBox.Position = UDim2.new(0.5, 5, 0, 105)
speedBox.Text = "2"
speedBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
speedBox.TextColor3 = Color3.new(1, 1, 1)

-- Tìm NPC gần nhất
function getNearestNPC()
	local minDist = math.huge
	local target = nil
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name:lower():find("citynpc") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
			local dist = (HRP.Position - v.HumanoidRootPart.Position).Magnitude
			if dist < minDist then
				minDist = dist
				target = v
			end
		end
	end
	return target
end

-- Di chuyển tự nhiên tới mục tiêu
function moveToTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		Humanoid:MoveTo(target.HumanoidRootPart.Position + Vector3.new(2, 0, 2))
	end
end

-- Chạy vòng quanh mục tiêu
function runCircle()
	spawn(function()
		while circleEnabled and nearestTarget and nearestTarget:FindFirstChild("HumanoidRootPart") do
			local r = tonumber(radiusBox.Text) or 10
			local s = tonumber(speedBox.Text) or 2
			local t = nearestTarget.HumanoidRootPart.Position
			local angle = tick() * s
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * r
			local goalPos = t + offset
			local goalCF = CFrame.new(goalPos, t)
			TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = goalCF}):Play()
			task.wait(0.03)
		end
	end)
end

-- Auto Đánh
function autoAttackTarget()
	spawn(function()
		while circleEnabled and nearestTarget and nearestTarget:FindFirstChild("Humanoid") and nearestTarget.Humanoid.Health > 0 do
			pcall(function()
				local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
				if tool and tool:FindFirstChild("Handle") then
					firesignal(tool.Handle.Touched, nearestTarget:FindFirstChild("HumanoidRootPart"))
				end
			end)
			wait(0.2)
		end
	end)
end

-- Logic chính
spawn(function()
	while task.wait(0.5) do
		if scriptEnabled then
			nearestTarget = getNearestNPC()
			if nearestTarget then
				moveToTarget(nearestTarget)
				repeat wait(0.5) until not scriptEnabled or (nearestTarget and (HRP.Position - nearestTarget.HumanoidRootPart.Position).Magnitude <= 10)
				if circleEnabled then
					runCircle()
					autoAttackTarget()
				end
				repeat wait() until not nearestTarget or nearestTarget.Humanoid.Health <= 0
			end
		end
	end
end)

-- Nút bấm
local function toggleBool(var)
	return not var
end

toggleScript.MouseButton1Click:Connect(function()
	scriptEnabled = toggleBool(scriptEnabled)
	toggleScript.Text = scriptEnabled and "[ON] Fram NPC" or "[OFF] Fram NPC"
end)

toggleCircle.MouseButton1Click:Connect(function()
	circleEnabled = toggleBool(circleEnabled)
	toggleCircle.Text = circleEnabled and "[ON] Chạy Vòng + Đánh" or "[OFF] Chạy Vòng + Đánh"
end)