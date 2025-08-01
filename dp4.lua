-- GUI menu
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "tt_dongphandzs1"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 150)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
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

-- Main fram logic
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local running = false

local function getCharacter()
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")
	return char, hrp, hum
end

-- 🆕 LẤY MỘT NPC BẤT KỲ có tên chứa "CityNPC" (KHÔNG GIỚI HẠN KHOẢNG CÁCH)
local function findAnyCityNPC()
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
			if string.find(model.Name, "CityNPC") then
				return model -- ✔️ Lấy mục tiêu đầu tiên thỏa mãn
			end
		end
	end
	return nil
end

local function walkTo(target)
	local _, hrp, hum = getCharacter()
	local targetHRP = target:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return end

	local path = PathfindingService:CreatePath()
	path:ComputeAsync(hrp.Position, targetHRP.Position)

	if path.Status == Enum.PathStatus.Complete then
		for _, point in ipairs(path:GetWaypoints()) do
			if not running then return end
			if point.Action == Enum.PathWaypointAction.Jump then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			hum:MoveTo(point.Position)
			hum.MoveToFinished:Wait(2)
		end
	end
end

StartBtn.MouseButton1Click:Connect(function()
	running = not running
	StartBtn.Text = running and "Đang Fram..." or "Bắt đầu Fram"
	StartBtn.BackgroundColor3 = running and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 150, 50)

	if running then
		task.spawn(function()
			while running do
				local npc = findAnyCityNPC() -- 🔄 đổi thành tìm bất kỳ mục tiêu CityNPC
				if npc then
					walkTo(npc)
				end
				wait(1)
			end
		end)
	end
end)