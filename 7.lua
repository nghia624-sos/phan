loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function getChar()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local Character = getChar()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local framEnabled = false
local framRadius = 10
local framSpeed = 3

local spinEnabled = false
local silentEnabled = false
local hitboxEnabled = false

---------------- UI ------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "TT:dongphandzs1 by đông phan",
	LoadingTitle = "dongphandzs1",
	LoadingSubtitle = "Fram + PvP",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "dongphandzs1",
		FileName = "fram_settings"
	}
})

------------ TAB 1: Fram NPC ------------

local FramTab = Window:CreateTab("Fram NPC", 4483362458)

FramTab:CreateToggle({
	Name = "🔁 Chạy vòng",
	Default = false,
	Callback = function(Value)
		framEnabled = Value

		if Value then
			spawn(function()
				local rotating = false
				local currentTween
				local rotationConnection

				local function stopOrbit()
					rotating = false
					if rotationConnection then rotationConnection:Disconnect() end
					if currentTween then currentTween:Cancel() end
				end

				local function startOrbit(target)
					if not target or not target:FindFirstChild("HumanoidRootPart") then return end
					local center = target.HumanoidRootPart
					local angle = 0
					rotating = true

					rotationConnection = RunService.Heartbeat:Connect(function(dt)
						if not rotating or not center or target.Humanoid.Health <= 0 then return end
						angle = angle + dt * framSpeed
						local x = math.cos(angle) * framRadius
						local z = math.sin(angle) * framRadius

						local targetPos = center.Position + Vector3.new(x, 0, z)
						local cf = CFrame.new(targetPos, center.Position)

						if currentTween then currentTween:Cancel() end
						currentTween = TweenService:Create(HRP, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = cf})
						currentTween:Play()

						-- Tự xoay về phía mục tiêu
						HRP.CFrame = CFrame.new(HRP.Position, center.Position)

						-- Auto đánh nếu có tool
						local tool = Character:FindFirstChildOfClass("Tool")
						if tool then
							pcall(function()
								tool:Activate()
							end)
						end
					end)
				end

				while framEnabled do
					local target = nil

					-- Tìm NPC tên chứa "CityNPC"
					for _, v in pairs(workspace:GetDescendants()) do
						if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
							if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
								target = v
								break
							end
						end
					end

					if target then
						local tHRP = target:FindFirstChild("HumanoidRootPart")
						if tHRP then
							stopOrbit()

							-- Di chuyển tới gần mục tiêu
							while framEnabled and (HRP.Position - tHRP.Position).Magnitude > framRadius + 1 and target.Humanoid.Health > 0 do
								Humanoid:MoveTo(tHRP.Position)
								wait(0.1)
							end

							-- Nếu mục tiêu còn sống thì bắt đầu chạy vòng + đánh
							if framEnabled and target.Humanoid.Health > 0 then
								startOrbit(target)

								-- Chờ NPC chết
								while framEnabled and target.Humanoid.Health > 0 do
									wait(0.2)
								end

								stopOrbit()
							end
						end
					end

					wait(0.3) -- Tìm mục tiêu mới
				end
			end)
		end
	end,
})
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