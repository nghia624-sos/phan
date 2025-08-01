-- // GUI TT:dongphandzs1 // --
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TT_dongphandzs1"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- Radius input
local radiusBox = Instance.new("TextBox", frame)
radiusBox.PlaceholderText = "Bán kính (mặc định 10)"
radiusBox.Size = UDim2.new(1, -20, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 40)

-- Speed input
local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ (mặc định 5)"
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 80)

-- Toggle button
local toggle = Instance.new("TextButton", frame)
toggle.Text = "BẬT Fram"
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 120)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggle.TextColor3 = Color3.new(1,1,1)

-- Vars
local runFram = false

-- Functions
function findNearestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(game.Workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= character then
			local mag = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
			if mag < dist then
				dist = mag
				closest = v
			end
		end
	end
	return closest
end

function faceTarget(target)
	local lookVector = (target.Position - hrp.Position).Unit
	hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
end

-- Loop
task.spawn(function()
	while true do
		task.wait()
		if runFram and character and hrp then
			local target = findNearestTarget()
			if target then
				local r = tonumber(radiusBox.Text) or 10
				local speed = tonumber(speedBox.Text) or 5
				local angle = tick() * speed
				local offset = Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
				local desiredPos = target.HumanoidRootPart.Position + offset

				-- Di chuyển bằng MoveTo để tránh bị kick
				local hum = character:FindFirstChildOfClass("Humanoid")
				if hum then
					hum:MoveTo(desiredPos)
				end

				-- Quay mặt về mục tiêu
				faceTarget(target.HumanoidRootPart)

				-- Auto đánh
				for _, tool in ipairs(character:GetChildren()) do
					if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
						pcall(function()
							tool:Activate()
						end)
					end
				end
			end
		end
	end
end)

-- Toggle Script
toggle.MouseButton1Click:Connect(function()
	runFram = not runFram
	toggle.Text = runFram and "TẮT Fram" or "BẬT Fram"
	toggle.BackgroundColor3 = runFram and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
end)