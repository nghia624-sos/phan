--// Fram NPC2 - GUI Đơn Giản + MoveTo Mượt //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local running = false
local radius = 10
local speed = 2
local currentTarget = nil

-- Tìm NPC2
local function findNPC2()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
			if string.find(npc.Name:lower(), "npc2") then
				return npc
			end
		end
	end
	return nil
end

-- Auto đánh
local function attack()
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		tool:Activate()
	end
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 160)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fram NPC2"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.BorderSizePixel = 0

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 30)
toggle.Position = UDim2.new(0, 0, 0, 40)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggle.TextColor3 = Color3.new(1,1,1)

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, 0, 0, 30)
radiusBox.Position = UDim2.new(0, 0, 0, 80)
radiusBox.PlaceholderText = "Bán kính"
radiusBox.Text = tostring(radius)
radiusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
radiusBox.TextColor3 = Color3.new(1,1,1)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, 0, 0, 30)
speedBox.Position = UDim2.new(0, 0, 0, 120)
speedBox.PlaceholderText = "Tốc độ"
speedBox.Text = tostring(speed)
speedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBox.TextColor3 = Color3.new(1,1,1)

-- Nút bật/tắt
toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then
		currentTarget = findNPC2()
		toggle.Text = "Tắt Fram"
	else
		toggle.Text = "Bật Fram"
	end
end)

-- Chỉnh bán kính/tốc độ
radiusBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(radiusBox.Text)
		if val then radius = val end
	end
end)

speedBox.FocusLost:Connect(function(enter)
	if enter then
		local val = tonumber(speedBox.Text)
		if val then speed = val end
	end
end)

-- Loop chính
RunService.Heartbeat:Connect(function()
	if running then
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and currentTarget.Humanoid.Health > 0 then
			local distance = (hrp.Position - currentTarget.HumanoidRootPart.Position).Magnitude
			if distance > radius + 3 then
				-- Tiếp cận
				hum:MoveTo(currentTarget.HumanoidRootPart.Position)
			else
				-- Chạy vòng quanh + đánh
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
				local goalPos = currentTarget.HumanoidRootPart.Position + offset
				hum:MoveTo(goalPos)
				hrp.CFrame = CFrame.new(hrp.Position, currentTarget.HumanoidRootPart.Position)
				attack()
			end
		else
			-- NPC chết hoặc mất → tìm lại
			currentTarget = findNPC2()
		end
	end
end)