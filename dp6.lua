-- MENU tt:dongphandzs1 - Tự tìm NPC chứa 'CityNPC' hoặc 'NPCity' và di chuyển tự nhiên
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer

-- GUI MENU
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "tt_dongphandzs1"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(0, 50, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "tt:dongphandzs1"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

local button = Instance.new("TextButton", frame)
button.Position = UDim2.new(0, 10, 0, 40)
button.Size = UDim2.new(1, -20, 0, 40)
button.Text = "Bắt đầu Fram"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextScaled = true

-- TÌM NPC chứa "CityNPC" hoặc "NPCity"
local function findNPC()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
			local name = string.lower(obj.Name)
			if name:find("citynpc") or name:find("npcity") then
				return obj
			end
		end
	end
	return nil
end

-- DI CHUYỂN TỰ NHIÊN bằng Pathfinding
local function moveToTarget(target)
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hrp or not hum then return end
	local dest = target:FindFirstChild("HumanoidRootPart")
	if not dest then return end

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentCanClimb = true,
	})
	path:ComputeAsync(hrp.Position, dest.Position)

	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in pairs(path:GetWaypoints()) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			hum:MoveTo(waypoint.Position)
			hum.MoveToFinished:Wait(2)
		end
	else
		-- Nếu không tìm được đường thì dùng MoveTo cơ bản
		hum:MoveTo(dest.Position)
	end
end

-- KHỞI ĐỘNG CHẠY
local running = false
button.MouseButton1Click:Connect(function()
	running = not running
	button.Text = running and "Đang Fram..." or "Bắt đầu Fram"
	button.BackgroundColor3 = running and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)

	if running then
		task.spawn(function()
			while running do
				local npc = findNPC()
				if npc then
					moveToTarget(npc)
				end
				wait(1)
			end
		end)
	end
end)