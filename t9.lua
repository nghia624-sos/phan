-- GUI Đơn Giản Fram NPC | KRNL Mobile
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local framOn = false
local target = nil
local radius = 10
local speed = 4

-- Tạo GUI nút bật/tắt
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Btn = Instance.new("TextButton", ScreenGui)
Btn.Size = UDim2.new(0, 150, 0, 50)
Btn.Position = UDim2.new(0.5, -75, 0.8, 0)
Btn.Text = "Bật Fram"
Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 24
Btn.Active = true
Btn.Draggable = true

-- Hàm tìm NPC
local function getTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("npc") then
			return v
		end
	end
	return nil
end

-- Hàm chạy tới mục tiêu
local function moveToTarget(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		hum:MoveTo(target.HumanoidRootPart.Position)
	end
end

-- Hàm chạy vòng quanh mục tiêu
local function runCircle(target)
	if target and target:FindFirstChild("HumanoidRootPart") then
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local pos = target.HumanoidRootPart.Position + offset
		hum:MoveTo(pos)
	end
end

-- Bắt đầu Fram
RunService.Heartbeat:Connect(function()
	if framOn then
		if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
			target = getTarget()
		end
		if target then
			local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
			if dist > radius + 5 then
				moveToTarget(target)
			else
				runCircle(target)
				-- Auto đánh
				local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
				if tool then
					tool:Activate()
				end
			end
		end
	end
end)

-- Khi bấm nút
Btn.MouseButton1Click:Connect(function()
	framOn = not framOn
	if framOn then
		Btn.Text = "Tắt Fram"
		Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	else
		Btn.Text = "Bật Fram"
		Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	end
end)