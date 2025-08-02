-- Cập nhật chính xác logic chạy vòng tròn và auto đánh

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

local running = false
local radius = 10
local speed = 5
local currentTarget = nil
local noclip = false

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0.01, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fram NPC (Auto)"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

function createButton(text, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.9, 0, 0, 30)
	btn.Position = UDim2.new(0.05, 0, 0, #frame:GetChildren() * 35)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 16
	btn.MouseButton1Click:Connect(callback)
end

function createInput(text, default, onChange)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(0.9, 0, 0, 20)
	label.Position = UDim2.new(0.05, 0, 0, #frame:GetChildren() * 35)
	label.Text = text
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14

	local box = Instance.new("TextBox", frame)
	box.Size = UDim2.new(0.9, 0, 0, 30)
	box.Position = UDim2.new(0.05, 0, 0, #frame:GetChildren() * 35)
	box.Text = tostring(default)
	box.BackgroundColor3 = Color3.fromRGB(60,60,60)
	box.TextColor3 = Color3.new(1,1,1)
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.SourceSans
	box.TextSize = 16
	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then onChange(num) end
	end)
end

createButton("Bật Fram", function() running = true end)
createButton("Tắt Fram", function() running = false end)
createInput("Bán kính", radius, function(val) radius = val end)
createInput("Tốc độ vòng", speed, function(val) speed = val end)

-- Noclip
RunService.Stepped:Connect(function()
	if noclip and chr then
		for _,v in pairs(chr:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)

-- Tìm NPC gần nhất chứa "CityNPC" hoặc "NPCity"
function getNearestTarget()
	local minDist = math.huge
	local target = nil
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			local name = v.Name:lower()
			if (name:find("citynpc") or name:find("npcity")) and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < minDist then
					minDist = dist
					target = v
				end
			end
		end
	end
	return target
end

-- Auto Fram logic
RunService.Heartbeat:Connect(function()
	if not running then return end

	if not chr or not hum or not hrp then return end
	if not currentTarget or currentTarget:FindFirstChild("Humanoid").Health <= 0 then
		currentTarget = getNearestTarget()
	end

	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
		local targetHRP = currentTarget.HumanoidRootPart
		local dist = (hrp.Position - targetHRP.Position).Magnitude

		if dist > radius + 1 then
			hum:MoveTo(targetHRP.Position)
		else
			-- Chạy vòng tròn
			local t = tick()
			local angle = t * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local movePos = targetHRP.Position + offset
			hum:MoveTo(movePos)

			-- Quay mặt về NPC
			chr:SetPrimaryPartCFrame(CFrame.new(hrp.Position, targetHRP.Position))

			-- Auto đánh
			local tool = chr:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Activate") then
				pcall(function() tool:Activate() end)
			elseif tool and tool:FindFirstChild("ClickDetector") then
				fireclickdetector(tool.ClickDetector)
			end
		end
	end
end)