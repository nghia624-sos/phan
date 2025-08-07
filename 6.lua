-- Gộp script GUI cũ + Kavo UI + Fix lỗi kéo + Di chuyển + Nhặt item
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

-- Biến toàn cục
getgenv().framActive = false
getgenv().spinActive = false
local currentTarget = nil

-- Tìm NPC gần nhất chứa "citynpc"
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

-- Xoay mặt về phía mục tiêu
function faceTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
		local newCFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
		HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, newCFrame.LookVector:Angle(Vector3.new(0, 0, -1)), 0)
	end
end

-- Di chuyển vòng quanh mục tiêu
function runAround(target, radius, speed)
	local angle = 0
	while getgenv().framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local targetPos = target.HumanoidRootPart.Position
		angle += speed * RunService.Heartbeat:Wait()
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local destination = targetPos + offset
		hum:MoveTo(destination)
		faceTarget(target)
	end
end

-- Click đánh
function autoAttack()
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
	task.wait(0.1)
	VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Nhặt đồ gần mục tiêu
function collectItemsAround(position, radius)
	for _, item in ipairs(workspace:GetDescendants()) do
		if item:IsA("Tool") or item:IsA("Part") then
			if (item.Position - position).Magnitude < radius then
				hum:MoveTo(item.Position)
				task.wait(0.3)
			end
		end
	end
end

-- Vòng quay spin liên tục
task.spawn(function()
	while true do
		if getgenv().spinActive and HRP then
			HRP.CFrame *= CFrame.Angles(0, math.rad(15), 0)
		end
		task.wait()
	end
end)

-- Fram chính
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

-- 📁 GUI Tab Fram NPC
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

-- 📁 GUI Tab Spin
local spinTab = Window:NewTab("Spin")
local spinSection = spinTab:NewSection("Xoay nhân vật")

spinSection:NewToggle("Bật Spin", "Nhân vật xoay tại chỗ", function(state)
	getgenv().spinActive = state
end)