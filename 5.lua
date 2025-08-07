-- Gộp script GUI cũ + Kavo UI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TTNHAT/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("TT:dongphandzs1", "Ocean")

-- Biến
getgenv().framActive = false
getgenv().spinActive = false
local currentTarget = nil

-- Tìm NPC
function getNearestCityNPC()
	local nearest = nil
	local shortest = math.huge
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
				if dist < shortest then
					shortest = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

-- Aim
function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
		HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
	end
end

-- Vòng quanh
function runAround(target, radius, speed)
	local angle = 0
	while getgenv().framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local targetPos = target.HumanoidRootPart.Position
		angle += speed * RunService.Heartbeat:Wait()
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		hum:MoveTo(targetPos + offset)
		faceTarget(target)
	end
end

-- Tự đánh
function autoAttack()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	task.wait(0.1)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Nhặt đồ
function collectItemsAround(position, radius)
	for _, item in ipairs(workspace:GetDescendants()) do
		if item:IsA("Tool") or item:IsA("Part") then
			if (item.Position - position).Magnitude < radius then
				hum:MoveTo(item.Position)
				task.wait(0.4)
			end
		end
	end
end

-- Quay spin
task.spawn(function()
	while true do
		if getgenv().spinActive and HRP then
			HRP.CFrame *= CFrame.Angles(0, math.rad(15), 0)
		end
		task.wait()
	end
end)

-- Main fram
function startFram(radius, speed)
	while getgenv().framActive do
		currentTarget = getNearestCityNPC()
		if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
			hum:MoveTo(currentTarget.HumanoidRootPart.Position)
			repeat task.wait() until not getgenv().framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15

			task.spawn(function()
				while getgenv().framActive and currentTarget and currentTarget.Humanoid.Health > 0 do
					autoAttack()
					task.wait(0.3)
				end
			end)

			runAround(currentTarget, radius, speed)

			if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and currentTarget.Humanoid.Health <= 0 then
				collectItemsAround(currentTarget.HumanoidRootPart.Position, 20)
			end
		else
			task.wait(1)
		end
	end
end

-- GUI: Tab Fram NPC
local framTab = Window:NewTab("Fram NPC")
local framSection = framTab:NewSection("Auto Fram")

local radius = 10
local speed = 3

framSection:NewTextbox("Bán kính", "Nhập bán kính", function(txt)
	radius = tonumber(txt) or 10
end)

framSection:NewTextbox("Tốc độ", "Nhập tốc độ", function(txt)
	speed = tonumber(txt) or 3
end)

framSection:NewToggle("Bật Fram", "Tự động tìm và fram NPC", function(state)
	getgenv().framActive = state
	if state then
		task.spawn(function()
			startFram(radius, speed)
		end)
	end
end)

-- GUI: Tab Spin
local spinTab = Window:NewTab("Spin")
local spinSection = spinTab:NewSection("Quay quanh NPC")

spinSection:NewToggle("Bật Spin", "Nhân vật quay tự xoay", function(state)
	getgenv().spinActive = state
end)