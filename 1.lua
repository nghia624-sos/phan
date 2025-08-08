--[[ GUI - Rayfield by Đông Phan | GUI: TT:dongphandzs1 ]]--

loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local target = nil
local framEnabled = false
local framRadius = 10
local framSpeed = 3

local spinEnabled = false
local silentEnabled = false
local hitboxEnabled = false

---------------------- GUI ----------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "TT:dongphandzs1 by đông phan",
	LoadingTitle = "TT:dongphandzs1",
	LoadingSubtitle = "by dongphandzs1",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "dongphandzs1Script",
		FileName = "fram_script"
	}
})

------------- TAB 1: Fram NPC -------------------

local FramTab = Window:CreateTab("Fram NPC", 4483362458)

FramTab:CreateSlider({
	Name = "Bán kính chạy vòng",
	Range = {5, 30},
	Increment = 1,
	Default = framRadius,
	Callback = function(Value)
		framRadius = Value
	end,
})

FramTab:CreateSlider({
	Name = "Tốc độ chạy vòng",
	Range = {1, 10},
	Increment = 1,
	Default = framSpeed,
	Callback = function(Value)
		framSpeed = Value
	end,
})

FramTab:CreateToggle({
	Name = "🔁 Bật Fram NPC",
	Default = false,
	Callback = function(Value)
		framEnabled = Value
		if Value then
			spawn(function()
				while framEnabled do
					target = nil
					for _, v in pairs(workspace:GetDescendants()) do
						if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
							if string.lower(v.Name):find("citynpc") then
								target = v
								break
							end
						end
					end

					if target and target:FindFirstChild("HumanoidRootPart") then
						local tHRP = target.HumanoidRootPart
						Humanoid:MoveTo(tHRP.Position)
						repeat
							wait(0.1)
						until (HRP.Position - tHRP.Position).Magnitude < framRadius + 2 or not framEnabled or not target

						while framEnabled and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
							local angle = tick() * framSpeed
							local offset = Vector3.new(math.cos(angle) * framRadius, 0, math.sin(angle) * framRadius)
							local goal = tHRP.Position + offset

							local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal, tHRP.Position)})
							tween:Play()

							-- Quay mặt + Đánh
							HRP.CFrame = CFrame.new(HRP.Position, tHRP.Position)
							mouse1click()
							wait(0.1)
						end
					end
					wait(0.5)
				end
			end)
		end
	end,
})

------------- TAB 2: PVP -------------------

local PvPTab = Window:CreateTab("PVP", 4483345998)

PvPTab:CreateToggle({
	Name = "🔄 Spin (Chong chóng)",
	Default = false,
	Callback = function(Value)
		spinEnabled = Value
		if Value then
			spawn(function()
				while spinEnabled do
					Character:SetPrimaryPartCFrame(HRP.CFrame * CFrame.Angles(0, math.rad(30), 0))
					wait(0.05)
				end
			end)
		end
	end,
})

PvPTab:CreateToggle({
	Name = "📏 Hitbox + Line",
	Default = false,
	Callback = function(Value)
		hitboxEnabled = Value
		if Value then
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local part = player.Character.HumanoidRootPart
					local highlight = Instance.new("BoxHandleAdornment", part)
					highlight.Size = part.Size + Vector3.new(2,2,2)
					highlight.Color3 = Color3.fromRGB(255, 0, 0)
					highlight.AlwaysOnTop = true
					highlight.ZIndex = 5
					highlight.Adornee = part
					highlight.Name = "HitHighlight"

					local line = Instance.new("Beam", part)
					line.Attachment0 = Instance.new("Attachment", HRP)
					line.Attachment1 = Instance.new("Attachment", part)
					line.Color = ColorSequence.new(Color3.new(1,0,0))
					line.FaceCamera = true
					line.Width0 = 0.1
					line.Width1 = 0.1
					line.Name = "TargetLine"
				end
			end
		else
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, v in pairs(player.Character:GetDescendants()) do
						if v.Name == "HitHighlight" or v.Name == "TargetLine" then
							v:Destroy()
						end
					end
				end
			end
		end
	end,
})

PvPTab:CreateToggle({
	Name = "🎯 Silent Aim (Đánh trúng tự động)",
	Default = false,
	Callback = function(Value)
		silentEnabled = Value
		if Value then
			spawn(function()
				while silentEnabled do
					local nearest = nil
					local shortest = math.huge
					for _, p in pairs(Players:GetPlayers()) do
						if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
							local dist = (HRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
							if dist < shortest then
								shortest = dist
								nearest = p.Character
							end
						end
					end
					if nearest then
						HRP.CFrame = CFrame.new(HRP.Position, nearest.HumanoidRootPart.Position)
						mouse1click()
					end
					wait(0.2)
				end
			end)
		end
	end,
})