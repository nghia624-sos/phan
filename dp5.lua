-- GUI menu
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "tt_dongphandzs1"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "tt:dongphandzs1"
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

local StartBtn = Instance.new("TextButton", Frame)
StartBtn.Position = UDim2.new(0, 10, 0, 50)
StartBtn.Size = UDim2.new(1, -20, 0, 40)
StartBtn.Text = "Bắt đầu Fram"
StartBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextScaled = true

-- Logic
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer

local running = false

local function getCharacter()
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	return char, hum, hrp
end

-- ✅ Tìm model chứa "CityNPC" hoặc "NPCity" (không phân biệt hoa/thường)
local function findValidNPC()
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

-- ✅ Di chuyển tới NPC bằng pathfinding
local function walkToTarget(target)
	local char, humanoid, rootPart = getCharacter()
	if not target or not target:FindFirstChild("HumanoidRootPart") then
		warn("❌ Không tìm thấy HumanoidRootPart của mục tiêu.")
		return
	end

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 10,
		AgentCanClimb = true
	})

	path:ComputeAsync(rootPart.Position, target.HumanoidRootPart.Position)

	if path.Status ~= Enum.PathStatus.Complete then
		warn("❌ Không thể tìm đường tới mục tiêu:", target.Name)
		return
	end

	for _, waypoint in pairs(path:GetWaypoints()) do
		if not running then break end

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		humanoid:MoveTo(waypoint.Position)
		local reached = false

		local connection
		connection = humanoid.MoveToFinished:Connect(function(success)
			reached = true
		end)

		local timeout = 3
		local timer = 0
		while not reached and timer < timeout do
			wait(0.1)
			timer = timer + 0.1
		end

		connection:Disconnect()
	end
end

-- Nút bắt đầu
StartBtn.MouseButton1Click:Connect(function()
	running = not running
	StartBtn.Text = running and "Đang Fram..." or "Bắt đầu Fram"
	StartBtn.BackgroundColor3 = running and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 150, 50)

	if running then
		task.spawn(function()
			while running do
				local npc = findValidNPC()
				if npc then
					walkToTarget(npc)
				else
					warn("❌ Không tìm thấy NPC chứa tên 'CityNPC' hoặc 'NPCity'")
				end
				wait(1)
			end
		end)
	end
end)