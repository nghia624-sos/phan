local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
	Name = "TT:dongphandzs1 by đông phan",
	LoadingTitle = "Đang tải menu...",
	LoadingSubtitle = "by Nghia Minh",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "TT_dongphandzs1",
		FileName = "FramCityNPC"
	},
	KeySystem = false
})

local FramTab = Window:CreateTab("🤖 Fram NPC", 4483362458)

local radius = 10
local speed = 3
local running = false
local currentTarget

FramTab:CreateSlider({
	Name = "Bán kính vòng quanh mục tiêu",
	Range = {5, 30},
	Increment = 1,
	Default = 10,
	Callback = function(Value)
		radius = Value
	end,
})

FramTab:CreateSlider({
	Name = "Tốc độ chạy vòng",
	Range = {1, 10},
	Increment = 1,
	Default = 3,
	Callback = function(Value)
		speed = Value
	end,
})

local function findCityNPC()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
			if string.lower(npc.Name):find("citynpc") then
				if npc.Humanoid.Health > 0 then
					return npc
				end
			end
		end
	end
	return nil
end

local function moveToTarget(target)
	local humanoid = Character:FindFirstChildOfClass("Humanoid")
	if humanoid and target then
		humanoid:MoveTo(target.HumanoidRootPart.Position)
	end
end

local function isCloseEnough(pos1, pos2, dist)
	return (pos1 - pos2).Magnitude <= dist
end

local function rotateAroundTarget(target)
	local angle = 0
	while running and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		angle = angle + speed * RunService.Heartbeat:Wait()
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		local goalPos = target.HumanoidRootPart.Position + Vector3.new(x, 0, z)
		
		local tween = TweenService:Create(HRP, TweenInfo.new(0.2), {CFrame = CFrame.new(goalPos, target.HumanoidRootPart.Position)})
		tween:Play()
		tween.Completed:Wait()

		-- Auto attack
		local tool = Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			mouse1click()
		end
	end
end

FramTab:CreateToggle({
	Name = "Bật Fram NPC",
	CurrentValue = false,
	Callback = function(state)
		running = state
		if state then
			task.spawn(function()
				while running do
					currentTarget = findCityNPC()
					if currentTarget then
						moveToTarget(currentTarget)
						repeat
							RunService.Heartbeat:Wait()
						until not running or isCloseEnough(HRP.Position, currentTarget.HumanoidRootPart.Position, radius + 3)

						if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
							rotateAroundTarget(currentTarget)
						end
					else
						wait(1) -- Không tìm thấy thì đợi tí
					end
				end
			end)
		end
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