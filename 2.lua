-- GUI Rayfield - TT:dongphandzs1 by đông phan

loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local target = nil
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

FramTab:CreateInput({
	Name = "📏 Bán kính chạy vòng (5–30)",
	PlaceholderText = "Ví dụ: 10",
	RemoveTextAfterFocusLost = false,
	Callback = function(Value)
		local num = tonumber(Value)
		if num and num >= 5 and num <= 30 then
			framRadius = num
		end
	end,
})

FramTab:CreateInput({
	Name = "⚡ Tốc độ quay vòng (1–10)",
	PlaceholderText = "Ví dụ: 3",
	RemoveTextAfterFocusLost = false,
	Callback = function(Value)
		local speed = tonumber(Value)
		if speed and speed >= 1 and speed <= 10 then
			framSpeed = speed
		end
	end,
})

FramTab:CreateToggle({
	Name = "🔁 Bật Fram NPC (MoveTo + vòng + đánh)",
	Default = false,
	Callback = function(Value)
		framEnabled = Value
		if Value then
			spawn(function()
				while framEnabled do
					target = nil
					for _, v in pairs(workspace:GetDescendants()) do
						if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
							if string.lower(v.Name):find("citynpc") then
								target = v
								break
							end
						end
					end

					if target then
						local tHRP = target:FindFirstChild("HumanoidRootPart")
						if tHRP then
							Humanoid:MoveTo(tHRP.Position)
							repeat wait() until (HRP.Position - tHRP.Position).Magnitude < framRadius + 2 or not framEnabled

							while framEnabled and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
								local angle = tick() * framSpeed
								local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * framRadius
								local position = tHRP.Position + offset
								local tween = TweenService:Create(HRP, TweenInfo.new(0.1), {CFrame = CFrame.new(position, tHRP.Position)})
								tween:Play()

								-- Quay mặt + tấn công
								HRP.CFrame = CFrame.new(HRP.Position, tHRP.Position)
								mouse1click()
								wait(0.1)
							end
						end
					end
					wait(0.5)
				end
			end)
		end
	end,
})

------------ TAB 2: PvP ------------

local PvPTab = Window:CreateTab("PVP", 4483345998)

PvPTab:CreateToggle({
	Name = "🔄 Spin (Xoay chong chóng)",
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
	Name = "🎯 Silent Aim (Tự tìm mục tiêu gần)",
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
					wait(0.2)
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