--// Dongphan Script with Rayfield UI & PvP Tab

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local FramEnabled = false
local SpinEnabled = false
local AutoAttack = false
local SpinSpeed = 5
local SpinRadius = 10
local PvPSpin = false
local PvPSilentHit = false
local PvPVisuals = false

local CurrentTarget = nil

local function getClosestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= LocalPlayer.Character then
			if v.Name:lower():find("citynpc") or v.Name:lower():find("boss") then
				local mag = (v.HumanoidRootPart.Position - root.Position).Magnitude
				if mag < dist then
					dist = mag
					closest = v
				end
			end
		end
	end
	return closest
end

local function attack(target)
	if not target then return end
	local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		firetouchinterest(tool.Handle, target.HumanoidRootPart, 0)
		firetouchinterest(tool.Handle, target.HumanoidRootPart, 1)
	end
end

local function drawHitbox(target)
	if target and not target:FindFirstChild("PvPBox") then
		local part = Instance.new("BoxHandleAdornment")
		part.Name = "PvPBox"
		part.Adornee = target:FindFirstChild("HumanoidRootPart")
		part.Size = Vector3.new(6,6,6)
		part.Color3 = Color3.new(1,0,0)
		part.Transparency = 0.5
		part.ZIndex = 5
		part.AlwaysOnTop = true
		part.Parent = target
	end
end

local function drawLineToTarget(target)
	if not target then return end
	if workspace:FindFirstChild("LineToTarget") then workspace.LineToTarget:Destroy() end
	local beam = Instance.new("Beam", workspace)
	beam.Name = "LineToTarget"
	local a0 = Instance.new("Attachment", root)
	local a1 = Instance.new("Attachment", target.HumanoidRootPart)
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Width0 = 0.1
	beam.Color = ColorSequence.new(Color3.new(1, 1, 0))
end

RunService.Heartbeat:Connect(function()
	if FramEnabled or PvPSilentHit then
		CurrentTarget = getClosestTarget()
	end
	if FramEnabled and CurrentTarget then
		if (root.Position - CurrentTarget.HumanoidRootPart.Position).Magnitude > SpinRadius then
			local tween = TweenService:Create(root, TweenInfo.new(0.2), {CFrame = CFrame.new(CurrentTarget.HumanoidRootPart.Position + Vector3.new(SpinRadius, 0, 0))})
			tween:Play()
		else
			if SpinEnabled then
				local angle = tick() * SpinSpeed
				local x = math.cos(angle) * SpinRadius
				local z = math.sin(angle) * SpinRadius
				root.CFrame = CFrame.new(CurrentTarget.HumanoidRootPart.Position + Vector3.new(x, 0, z)) * CFrame.Angles(0, -angle, 0)
			end
			if AutoAttack then attack(CurrentTarget) end
		end
	end
	if PvPSpin then
		root.CFrame *= CFrame.Angles(0, math.rad(SpinSpeed*10), 0)
	end
	if PvPSilentHit and CurrentTarget then
		attack(CurrentTarget)
	end
	if PvPVisuals and CurrentTarget then
		drawHitbox(CurrentTarget)
		drawLineToTarget(CurrentTarget)
	end
end)

Rayfield:LoadConfiguration()

local MainWindow = Rayfield:CreateWindow({
	Name = "TT:dongphandzs1",
	LoadingTitle = "dongphandzs1 menu",
	LoadingSubtitle = "by you",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil,
		FileName = "dongphandzs1"
	},
	Discord = {
		Enabled = false
	},
	KeySystem = false
})

local Tab1 = MainWindow:CreateTab("Fram NPC")

Tab1:CreateToggle({Name = "Bật Fram", CurrentValue = false, Callback = function(v) FramEnabled = v end})
Tab1:CreateToggle({Name = "Chạy Vòng", CurrentValue = false, Callback = function(v) SpinEnabled = v end})
Tab1:CreateToggle({Name = "Tự Đánh", CurrentValue = false, Callback = function(v) AutoAttack = v end})
Tab1:CreateSlider({Name = "Bán kính", Range = {5, 30}, Increment = 1, CurrentValue = 10, Callback = function(v) SpinRadius = v end})
Tab1:CreateSlider({Name = "Tốc độ", Range = {1, 20}, Increment = 1, CurrentValue = 5, Callback = function(v) SpinSpeed = v end})

local Tab2 = MainWindow:CreateTab("PvP")

Tab2:CreateToggle({Name = "Xoay nhân vật (Spin PvP)", CurrentValue = false, Callback = function(v) PvPSpin = v end})
Tab2:CreateToggle({Name = "Hiện line + hitbox mục tiêu", CurrentValue = false, Callback = function(v) PvPVisuals = v end})
Tab2:CreateToggle({Name = "Slient hit mục tiêu gần nhất", CurrentValue = false, Callback = function(v) PvPSilentHit = v end})