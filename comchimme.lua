--// Kavo UI Library loader
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("TT:dongphandzs1", "Midnight")

--// Tab và Section
local FramTab = Window:NewTab("Đánh NPC")
local FramSection = FramTab:NewSection("Auto Fram")

--// Service
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

--// Biến điều khiển
local framActive = false
local spinActive = false
local autoAttackActive = false
local currentTarget = nil
local radius = 10
local speed = 3

--// Auto Attack an toàn
function autoAttack()
	VirtualInputManager:SendMouseButtonEvent(100, 100, 0, true, game, 0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(100, 100, 0, false, game, 0)
end

--// Tìm NPC gần nhất
function getNearestCityNPC()
	local nearest, shortest = nil, math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < shortest then
					shortest, nearest = dist, v
				end
			end
		end
	end
	return nearest
end

--// Quay mặt về mục tiêu
function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
		HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
	end
end

--// Chạy vòng quanh mục tiêu
function runAround(target, radius, speed)
	local angle = 0
	while framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local targetPos = target.HumanoidRootPart.Position
		angle += speed * RunService.Heartbeat:Wait()
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local goal = targetPos + offset
		local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal)})
		tween:Play()
		faceTarget(target)
	end
end

--// Nhặt vật phẩm
function collectItemsAround(pos, radius)
	for _, item in ipairs(workspace:GetDescendants()) do
		if item:IsA("Tool") or item:IsA("Part") then
			if (item.Position - pos).Magnitude < radius then
				hum:MoveTo(item.Position)
				task.wait(0.4)
			end
		end
	end
end

--// Chế độ xoay spin
task.spawn(function()
	while true do
		if spinActive and HRP then
			HRP.CFrame *= CFrame.Angles(0, math.rad(1000), 0)
		end
		task.wait()
	end
end)

--// Chạy Fram
function startFram()
	while framActive do
		currentTarget = getNearestCityNPC()
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			hum:MoveTo(currentTarget.HumanoidRootPart.Position)
			repeat task.wait()
			until not framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15

			task.spawn(function()
				while framActive and currentTarget and currentTarget.Humanoid.Health > 0 do
					if autoAttackActive then autoAttack() end
					task.wait(0.3)
				end
			end)

			runAround(currentTarget, radius, speed)

			if currentTarget and currentTarget.Humanoid.Health <= 0 then
				collectItemsAround(currentTarget.HumanoidRootPart.Position, 20)
			end
		else
			task.wait(1)
		end
	end
end

--// GUI Option
FramSection:NewToggle("Bật Fram", "Tự động tìm và đánh CityNPC", function(state)
	framActive = state
	if framActive then
		task.spawn(startFram)
	end
end)

FramSection:NewToggle("Bật Spin", "Xoay nhân vật liên tục", function(state)
	spinActive = state
end)

FramSection:NewToggle("Tự Động Đánh", "Click chuột tự động", function(state)
	autoAttackActive = state
end)

FramSection:NewTextBox("Bán kính", "VD: 10", function(txt)
	radius = tonumber(txt) or 10
end)

FramSection:NewTextBox("Tốc độ quay", "VD: 3", function(txt)
	speed = tonumber(txt) or 3
end)