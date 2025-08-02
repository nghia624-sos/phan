-- ROBLOX SCRIPT MENU: TT:dongphandzs1 (v2 - tự động chạy vòng + đánh khi đủ gần)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

local running = false
local noclip = false
local radius = 10
local speed = 5
local currentTarget = nil

-- UI Setup
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "FramGui"
ui.ResetOnSpawn = false

local frame = Instance.new("Frame", ui)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Position = UDim2.new(0.02, 0, 0.2, 0)
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- UI Function Helpers
local function createButton(text, parent, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 16
	btn.MouseButton1Click:Connect(callback)
end

local function createInput(text, default, parent, onChanged)
	local label = Instance.new("TextLabel", parent)
	label.Size = UDim2.new(1, -10, 0, 20)
	label.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14

	local box = Instance.new("TextBox", parent)
	box.Size = UDim2.new(1, -10, 0, 30)
	box.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
	box.Text = tostring(default)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.SourceSans
	box.TextSize = 16
	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then
			onChanged(num)
		end
	end)
end

-- Buttons
createButton("Bật Fram", frame, function() running = true end)
createButton("Tắt Fram", frame, function() running = false end)
createButton("Noclip ON/OFF", frame, function() noclip = not noclip end)
createInput("Bán kính vòng (radius)", radius, frame, function(val) radius = val end)
createInput("Tốc độ vòng (speed)", speed, frame, function(val) speed = val end)

-- Noclip Handler
RunService.Stepped:Connect(function()
	if noclip and chr and hum then
		for _, v in pairs(chr:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)

-- Tìm NPC hợp lệ
local function getNearestNPC()
	local minDist = math.huge
	local target = nil
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr then
			local name = v.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				local root = v:FindFirstChild("HumanoidRootPart")
				if root then
					local dist = (root.Position - hrp.Position).Magnitude
					if dist < minDist then
						minDist = dist
						target = v
					end
				end
			end
		end
	end
	return target
end

-- Main Logic
RunService.Heartbeat:Connect(function()
	if running then
		if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
			currentTarget = getNearestNPC()
		end

		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			local targetHRP = currentTarget.HumanoidRootPart
			local dist = (hrp.Position - targetHRP.Position).Magnitude

			if dist > radius + 2 then
				hum:MoveTo(targetHRP.Position)
			else
				-- Tự động chạy vòng quanh + đánh + quay mặt
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
				local targetPos = targetHRP.Position + offset
				hum:MoveTo(targetPos)

				chr:SetPrimaryPartCFrame(CFrame.new(hrp.Position, targetHRP.Position))

				local tool = chr:FindFirstChildOfClass("Tool")
				if tool and tool:FindFirstChild("Activate") then
					tool:Activate()
				end
			end
		end
	end
end)