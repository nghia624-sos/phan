-- Fram Npc Script cho Roblox KRNL Mobile - Hỗ trợ kéo menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Cài đặt
local radius = 10 -- bán kính vòng
local speed = 3 -- tốc độ quay
local attackRange = 20
local attackCooldown = 0.3
local autoFram = false
local autoAim = true

-- Giao diện GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNpcGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 50, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- ✅ Cho phép kéo
frame.Selectable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "Bật Fram CityNpc"
toggle.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 18
toggle.MouseButton1Click:Connect(function()
	autoFram = not autoFram
	toggle.Text = autoFram and "Tắt Fram CityNpc" or "Bật Fram CityNpc"
end)

-- Hàm tìm NPC có tên chứa 'CityNpc'
function findNearestCityNPC()
	local closest, shortest = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0 then
			if v.Name:lower():find("citynpc") then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < shortest then
					shortest = dist
					closest = v
				end
			end
		end
	end
	return closest
end

-- Auto Aim
function aimAt(target)
	if not target then return end
	local look = CFrame.lookAt(hrp.Position, target.HumanoidRootPart.Position)
	hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, look:ToEulerAnglesYXZ())
end

-- Auto Attack
function attack(target)
	if not target then return end
	local tool = character:FindFirstChildOfClass("Tool")
	if tool and (target.HumanoidRootPart.Position - hrp.Position).Magnitude <= attackRange then
		tool:Activate()
	end
end

-- Di chuyển xoay vòng quanh NPC
function runAround(target)
	if not target then return end
	local t = 0
	while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and autoFram do
		t += speed/100
		local offset = Vector3.new(math.cos(t)*radius, 0, math.sin(t)*radius)
		local goalPos = target.HumanoidRootPart.Position + offset
		humanoid:MoveTo(goalPos)
		if autoAim then aimAt(target) end
		attack(target)
		task.wait(attackCooldown)
	end
end

-- Luồng chính
task.spawn(function()
	while true do
		if autoFram then
			local target = findNearestCityNPC()
			if target then
				humanoid:MoveTo(target.HumanoidRootPart.Position)
				humanoid.MoveToFinished:Wait()
				runAround(target)
			end
		end
		task.wait(0.1)
	end
end)