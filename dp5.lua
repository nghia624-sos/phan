-- ROBLOX SCRIPT MENU: TT:dongphandzs1
-- Bật "Fram" => chạy tới mục tiêu + tự chạy vòng quanh + auto đánh

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local running = false
local radius = 10
local speed = 5
local noclip = false
local currentTarget = nil

-- UI
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

-- Button
local function createButton(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, #frame:GetChildren() * 35)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 16
	btn.MouseButton1Click:Connect(callback)
end

-- Input
local function createInput(labelText, default, onChange)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -10, 0, 20)
	label.Position = UDim2.new(0, 5, 0, #frame:GetChildren() * 35)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14

	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(1, -10, 0, 30)
	box.Position = UDim2.new(0, 5, 0, #frame:GetChildren() * 35)
	box.Text = tostring(default)
	box.BackgroundColor3 = Color3.fromRGB(40,40,40)
	box.TextColor3 = Color3.new(1,1,1)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.SourceSans
	box.TextSize = 16
	box.FocusLost:Connect(function()
		local val = tonumber(box.Text)
		if val then
			onChange(val)
		end
	end)
end

-- UI Elements
createButton("Bật Fram", function() running = true end)
createButton("Tắt Fram", function() running = false end)
createButton("Noclip ON/OFF", function() noclip = not noclip end)
createInput("Bán kính vòng", radius, function(val) radius = val end)
createInput("Tốc độ vòng", speed, function(val) speed = val end)

-- Noclip
RunService.Stepped:Connect(function()
	if noclip and chr then
		for _, v in pairs(chr:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

-- Tìm NPC gần nhất (CityNPC hoặc NPCity)
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

-- Hành vi chính
RunService.Heartbeat:Connect(function()
	if running then
		if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
			currentTarget = getNearestNPC()
		end

		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			local targetPos = currentTarget.HumanoidRootPart.Position
			local dist = (hrp.Position - targetPos).Magnitude

			if dist > radius + 2 then
				-- Di chuyển tới mục tiêu
				hum:MoveTo(targetPos)
			else
				-- Tự động chạy vòng tròn quanh mục tiêu
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
				local circlePos = targetPos + offset
				hum:MoveTo(circlePos)

				-- Quay mặt về mục tiêu
				chr:SetPrimaryPartCFrame(CFrame.new(hrp.Position, targetPos))

				-- Auto đánh
				local tool = chr:FindFirstChildOfClass("Tool")
				if tool and tool:FindFirstChild("Activate") then
					tool:Activate()
				end
			end
		end
	end
end)