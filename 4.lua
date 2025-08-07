-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0.1, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Frame.Active = true
Frame.Draggable = true

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, 0, 0, 50)
ToggleButton.Text = "Bật Fram"
ToggleButton.BackgroundColor3 = Color3.new(1, 0, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 24

local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.PlaceholderText = "Bán kính"
RadiusBox.Text = "10"
RadiusBox.Position = UDim2.new(0, 10, 0, 60)
RadiusBox.Size = UDim2.new(0, 200, 0, 30)

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.PlaceholderText = "Tốc độ"
SpeedBox.Text = "3"
SpeedBox.Position = UDim2.new(0, 10, 0, 100)
SpeedBox.Size = UDim2.new(0, 200, 0, 30)

local FramActive = false

-- Logic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Tìm NPC gần nhất
local function getClosestNPC()
	local closest
	local shortest = math.huge
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
			if npc.Name:lower():find("citynpc") or npc.Name:lower():find("npcity") then
				local dist = (npc.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < shortest and npc.Humanoid.Health > 0 then
					shortest = dist
					closest = npc
				end
			end
		end
	end
	return closest
end

-- Tự động nhặt item gần
local function pickupItems()
	for _, item in pairs(workspace:GetDescendants()) do
		if item:IsA("ProximityPrompt") and item.ActionText == "Lụm" then
			fireproximityprompt(item)
		end
	end
end

-- Tự fram
local currentTarget
RunService.Heartbeat:Connect(function()
	if FramActive then
		if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
			currentTarget = getClosestNPC()
		end
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			local radius = tonumber(RadiusBox.Text) or 10
			local speed = tonumber(SpeedBox.Text) or 3
			local time = tick()
			local angle = time * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local targetPos = currentTarget.HumanoidRootPart.Position + offset

			-- Di chuyển
			HRP.CFrame = HRP.CFrame:Lerp(CFrame.new(targetPos, currentTarget.HumanoidRootPart.Position), 0.2)

			-- Auto attack
			local tool = Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				for _, v in pairs(tool:GetDescendants()) do
					if v:IsA("TouchTransmitter") then
						firetouchinterest(tool.Handle, currentTarget.HumanoidRootPart, 0)
						firetouchinterest(tool.Handle, currentTarget.HumanoidRootPart, 1)
					end
				end
			end

			pickupItems()
		end
	end
end)

-- Toggle
ToggleButton.MouseButton1Click:Connect(function()
	FramActive = not FramActive
	ToggleButton.Text = FramActive and "Tắt Fram" or "Bật Fram"
	ToggleButton.BackgroundColor3 = FramActive and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)