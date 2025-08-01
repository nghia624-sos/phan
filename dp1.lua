-- Menu Fram CityNPC - by Nghia Minh
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 120)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Text = "Fram CityNPC"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, -20, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 18
ToggleButton.Text = "Bật Fram"

-- Logic fram
local running = false

function findNearestCityNPC()
	local nearest = nil
	local shortest = math.huge
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and string.find(npc.Name, "CityNPC") then
			local dist = (HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
			if dist < shortest then
				shortest = dist
				nearest = npc
			end
		end
	end
	return nearest
end

function moveToNPC(npc)
	if not npc or not npc:FindFirstChild("HumanoidRootPart") then return end

	local path = PathfindingService:CreatePath()
	path:ComputeAsync(HumanoidRootPart.Position, npc.HumanoidRootPart.Position)

	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in pairs(path:GetWaypoints()) do
			if not running then return end
			Humanoid:MoveTo(waypoint.Position)
			Humanoid.MoveToFinished:Wait()
		end
	end
end

-- Loop khi bật fram
task.spawn(function()
	while true do
		task.wait(1)
		if running then
			local npc = findNearestCityNPC()
			if npc then
				moveToNPC(npc)
			end
		end
	end
end)

-- Nút bật tắt
ToggleButton.MouseButton1Click:Connect(function()
	running = not running
	ToggleButton.Text = running and "Tắt Fram" or "Bật Fram"
end)