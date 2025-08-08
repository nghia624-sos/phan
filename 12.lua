local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
	Name = "TT:dongphandzs1",
	LoadingTitle = "Fram NPC Module",
	LoadingSubtitle = "by Đông Phan",
	KeySystem = false
})

local tab = Window:CreateTab("Fram NPC", 4483362458)

-- Biến
local framEnabled = false
local orbitEnabled = false
local orbitRadius = 10
local orbitSpeed = 3
local currentTarget = nil
local orbitTween = nil

-- Tìm mục tiêu mới
local function getNearestNPC()
	local nearest = nil
	local shortestDistance = math.huge

	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
			local name = string.lower(npc.Name)
			if (string.find(name, "citynpc") or string.find(name, "npcity")) and npc.Humanoid.Health > 0 then
				local distance = (npc.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					nearest = npc
				end
			end
		end
	end
	return nearest
end

-- Hàm chạy bộ đến mục tiêu
local function moveToTarget(target)
	local humanoid = Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:MoveTo(target.HumanoidRootPart.Position)
	end
end

-- Hàm chạy vòng quanh mục tiêu
local function orbitTarget(target)
	if orbitTween then orbitTween:Cancel() end

	local angle = 0
	local function tweenStep()
		if not orbitEnabled or not target or not target:FindFirstChild("HumanoidRootPart") then return end
		angle += orbitSpeed * 0.05
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * orbitRadius
		local goalPos = target.HumanoidRootPart.Position + offset
		local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(0.1), {Position = goalPos})
		tween:Play()
		orbitTween = tween
	end
	RunService:UnbindFromRenderStep("OrbitLoop")
	RunService:BindToRenderStep("OrbitLoop", 201, tweenStep)
end

-- Auto attack
local function attack()
	local tool = Character:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function()
			tool:Activate()
		end)
	end
end

-- Fram loop
task.spawn(function()
	while true do
		task.wait(0.3)
		if framEnabled then
			if not currentTarget or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
				currentTarget = getNearestNPC()
			end

			if currentTarget then
				local distance = (currentTarget.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude

				if distance > orbitRadius + 3 then
					moveToTarget(currentTarget)
				else
					if orbitEnabled then
						orbitTarget(currentTarget)
					end
					attack()
				end
			end
		else
			RunService:UnbindFromRenderStep("OrbitLoop")
		end
	end
end)

-- Giao diện nút bật/tắt và tuỳ chỉnh
tab:CreateToggle({
	Name = "Bật Fram NPC",
	CurrentValue = false,
	Callback = function(Value)
		framEnabled = Value
	end
})

tab:CreateToggle({
	Name = "Chạy vòng quanh mục tiêu",
	CurrentValue = false,
	Callback = function(Value)
		orbitEnabled = Value
	end
})

tab:CreateSlider({
	Name = "Bán kính chạy vòng",
	Range = {5, 30},
	Increment = 1,
	CurrentValue = 10,
	Callback = function(Value)
		orbitRadius = Value
	end
})

tab:CreateSlider({
	Name = "Tốc độ chạy vòng",
	Range = {1, 10},
	Increment = 1,
	CurrentValue = 3,
	Callback = function(Value)
		orbitSpeed = Value
	end
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