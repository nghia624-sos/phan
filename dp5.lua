-- GUI: TT:dongphandzs1 - FIX nhân vật đứng yên, auto chạy đến mục tiêu chắc chắn
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
	character = char
	task.wait(0.5)
	hrp = character:WaitForChild("HumanoidRootPart")
end)

-- GUI
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

local radiusBox = Instance.new("TextBox", frame)
radiusBox.PlaceholderText = "Bán kính đánh (VD: 10)"
radiusBox.Size = UDim2.new(1, -20, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 40)

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Tốc độ vòng (VD: 5)"
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 80)

local toggle = Instance.new("TextButton", frame)
toggle.Text = "BẬT Fram"
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 120)
toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggle.TextColor3 = Color3.new(1,1,1)

-- Flag
local runFram = false

-- Tìm NPC có tên chứa "citynpc"
function findCityTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(game.Workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.find(v.Name:lower(), "citynpc") then
				local mag = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
				if mag < dist then
					dist = mag
					closest = v
				end
			end
		end
	end
	return closest
end

-- Quay mặt về mục tiêu
function faceTarget(target)
	if hrp and target then
		local look = (target.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + look)
	end
end

-- Main Fram Loop
task.spawn(function()
	while true do
		task.wait(0.1)
		if runFram then
			-- Luôn cập nhật nhân vật
			character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				hrp = character.HumanoidRootPart
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					local target = findCityTarget()
					if target and target:FindFirstChild("HumanoidRootPart") then
						local r = tonumber(radiusBox.Text) or 10
						local speed = tonumber(speedBox.Text) or 5
						local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude

						if dist > r + 2 then
							-- Chạy bộ đến mục tiêu
							humanoid:MoveTo(target.HumanoidRootPart.Position + Vector3.new(0, 0, -2))
						else
							-- Chạy vòng quanh mục tiêu
							local angle = tick() * speed
							local offset = Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
							local pos = target.HumanoidRootPart.Position + offset
							humanoid:MoveTo(pos)
						end

						-- Quay mặt
						faceTarget(target.HumanoidRootPart)

						-- Auto đánh
						for _, tool in ipairs(character:GetChildren()) do
							if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
								pcall(function() tool:Activate() end)
							end
						end
					end
				end
			end
		end
	end
end)

-- Nút bật/tắt
toggle.MouseButton1Click:Connect(function()
	runFram = not runFram
	toggle.Text = runFram and "TẮT Fram" or "BẬT Fram"
	toggle.BackgroundColor3 = runFram and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(0, 170, 0)
end)