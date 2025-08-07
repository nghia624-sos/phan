local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TT:dongphandzs1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local framButton = Instance.new("TextButton", frame)
framButton.Size = UDim2.new(1, -20, 0, 50)
framButton.Position = UDim2.new(0, 10, 0, 10)
framButton.Text = "Bật Fram"
framButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
framButton.TextColor3 = Color3.new(1, 1, 1)
framButton.Font = Enum.Font.SourceSansBold
framButton.TextSize = 24

local radiusLabel = Instance.new("TextLabel", frame)
radiusLabel.Position = UDim2.new(0, 10, 0, 70)
radiusLabel.Size = UDim2.new(0, 100, 0, 30)
radiusLabel.Text = "Bán kính:"
radiusLabel.TextColor3 = Color3.new(1, 1, 1)
radiusLabel.BackgroundTransparency = 1

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Position = UDim2.new(0, 120, 0, 70)
radiusBox.Size = UDim2.new(0, 100, 0, 30)
radiusBox.Text = "10"

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Position = UDim2.new(0, 10, 0, 110)
speedLabel.Size = UDim2.new(0, 100, 0, 30)
speedLabel.Text = "Tốc độ:"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1

local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 120, 0, 110)
speedBox.Size = UDim2.new(0, 100, 0, 30)
speedBox.Text = "3"

-- Biến toàn cục
local framActive = false
local currentTarget = nil

-- Hàm tìm NPC gần nhất
function getNearestCityNPC()
	local nearest = nil
	local shortest = math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < shortest then
					shortest = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

-- Hàm quay mặt
function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
		HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
	end
end

-- Dùng pathfinding để né vật cản
function moveToPositionSmart(destination)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true
	})
	path:ComputeAsync(HRP.Position, destination)

	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			if not framActive then return end
			hum:MoveTo(waypoint.Position)
			local reached = hum.MoveToFinished:Wait()
			if not reached then break end
		end
	else
		warn("Không tìm được đường tới mục tiêu.")
	end
end

-- Tự đánh
function autoAttack()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	task.wait(0.1)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Chạy vòng quanh mục tiêu có né vật cản
function runAround(target, radius, speed)
	local angle = 0
	while framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local targetPos = target.HumanoidRootPart.Position
		angle += speed * RunService.Heartbeat:Wait()
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goal = targetPos + offset

		-- Né vật cản khi chạy quanh
		local ray = workspace:Raycast(HRP.Position, (goal - HRP.Position).Unit * radius, RaycastParams.new())
		if ray and ray.Instance then
			moveToPositionSmart(goal)
		else
			local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal)})
			tween:Play()
		end

		faceTarget(target)
	end
end

-- Bắt đầu fram
function startFram()
	while framActive do
		currentTarget = getNearestCityNPC()
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			moveToPositionSmart(currentTarget.HumanoidRootPart.Position)

			-- Đợi tiếp cận gần
			repeat task.wait() until
				(HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15 or not framActive

			local radius = tonumber(radiusBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 3

			task.spawn(function()
				while framActive and currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 do
					autoAttack()
					task.wait(0.3)
				end
			end)

			runAround(currentTarget, radius, speed)
		else
			task.wait(1)
		end
	end
end

-- Nút bật tắt
framButton.MouseButton1Click:Connect(function()
	framActive = not framActive
	framButton.Text = framActive and "Tắt Fram" or "Bật Fram"
	if framActive then
		task.spawn(startFram)
	end
end)