local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local isFramming = false
local radius = 10
local speed = 5

-- Tìm NPC có tên chứa "CityNPC"
local function FindNearestCityNPC()
	local closest, closestDist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") and v ~= Character then
				local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < closestDist and v.Humanoid.Health > 0 then
					closest = v
					closestDist = dist
				end
			end
		end
	end
	return closest
end

-- Chạy quanh mục tiêu
local function SpinAroundTarget(target)
	local angle = 0
	local lastTween

	while isFramming and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		angle += speed * RunService.Heartbeat:Wait()
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local targetPos = target.HumanoidRootPart.Position + offset
		local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos, target.HumanoidRootPart.Position)})
		tween:Play()
		lastTween = tween

		-- Auto Attack nếu có Tool
		local tool = Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			tool:Activate()
		end
	end

	if lastTween then lastTween:Cancel() end
end

-- Fram NPC tổng hợp
local function FramNPC()
	while isFramming do
		local target = FindNearestCityNPC()
		if not target then
			wait(1)
			continue
		end

		local hum = Character:FindFirstChild("Humanoid")
		if hum then hum:MoveTo(target.HumanoidRootPart.Position) end

		repeat
			wait()
		until not isFramming or (target.HumanoidRootPart.Position - HRP.Position).Magnitude <= radius + 2 or target.Humanoid.Health <= 0

		if isFramming and target and target.Humanoid.Health > 0 then
			SpinAroundTarget(target)
		end
	end
end

-- Thêm vào Tab GUI
FramTab:CreateToggle({
	Name = "Bật Fram NPC",
	CurrentValue = false,
	Flag = "framnpc",
	Callback = function(Value)
		isFramming = Value
		if isFramming then
			task.spawn(FramNPC)
		end
	end,
})

FramTab:CreateSlider({
	Name = "Bán kính chạy vòng",
	Range = {5, 30},
	Increment = 1,
	CurrentValue = radius,
	Callback = function(Value)
		radius = Value
	end,
})

FramTab:CreateSlider({
	Name = "Tốc độ chạy vòng",
	Range = {1, 15},
	Increment = 0.5,
	CurrentValue = speed,
	Callback = function(Value)
		speed = Value
	end,
})

------------ TAB 2: PvP ------------
local PvPTab = Window:CreateTab("PVP", 4483345998)

PvPTab:CreateToggle({
	Name = "🔄 Spin",
	Default = false,
	Callback = function(Value)
		spinEnabled = Value
		if Value then
			spawn(function()
				while spinEnabled do
					if Character and HRP then
						HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(1000), 0)
					end
					wait(0.03)
				end
			end)
		end
	end,
})

PvPTab:CreateToggle({
	Name = "🎯 Silent Aim (Tự đánh mục tiêu gần)",
	Default = false,
	Callback = function(Value)
		silentEnabled = Value
		if Value then
			spawn(function()
				while silentEnabled do
					local nearest = nil
					local shortest = math.huge
					for _, p in pairs(Players:GetPlayers()) do
						if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
							local dist = (HRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
							if dist < shortest and p.Character.Humanoid.Health > 0 then
								shortest = dist
								nearest = p.Character
							end
						end
					end

					if nearest then
						HRP.CFrame = CFrame.new(HRP.Position, nearest.HumanoidRootPart.Position)
						mouse1click()
					end
					wait(0.25)
				end
			end)
		end
	end,
})

PvPTab:CreateToggle({
	Name = "📏 Hitbox + Line đến người chơi",
	Default = false,
	Callback = function(Value)
		hitboxEnabled = Value
		if Value then
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local part = player.Character.HumanoidRootPart
					
					local adorn = Instance.new("BoxHandleAdornment", part)
					adorn.Size = part.Size + Vector3.new(2,2,2)
					adorn.Color3 = Color3.new(1,0,0)
					adorn.Adornee = part
					adorn.AlwaysOnTop = true
					adorn.ZIndex = 10
					adorn.Name = "Hitbox"

					local beam = Instance.new("Beam", part)
					local a0 = Instance.new("Attachment", HRP)
					local a1 = Instance.new("Attachment", part)
					beam.Attachment0 = a0
					beam.Attachment1 = a1
					beam.Width0 = 0.1
					beam.Width1 = 0.1
					beam.Color = ColorSequence.new(Color3.new(1,0,0))
					beam.FaceCamera = true
					beam.Name = "TargetLine"
				end
			end
		else
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					for _, v in pairs(p.Character:GetDescendants()) do
						if v:IsA("BoxHandleAdornment") and v.Name == "Hitbox" then v:Destroy() end
						if v:IsA("Beam") and v.Name == "TargetLine" then v:Destroy() end
					end
				end
			end
		end
	end,
})