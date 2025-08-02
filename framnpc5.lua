local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Hàm chờ character và các thành phần chính sẵn sàng
local function waitForCharacter()
	local chr = lp.Character or lp.CharacterAdded:Wait()
	local hum = chr:WaitForChild("Humanoid")
	local hrp = chr:WaitForChild("HumanoidRootPart")
	return chr, hum, hrp
end

-- GUI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "TT_dongphandzs1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 230, 0, 150)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.Text = "🔁 Bật Fram"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18

-- Biến điều khiển
local running = false
local framLoopRunning = false -- Ngăn việc chạy nhiều vòng lặp cùng lúc
local radius = 10
local speed = 4

-- Tìm mục tiêu chứa CityNPC hoặc NPCity
local function findTarget()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			local name = string.lower(v.Name)
			if name:find("citynpc") or name:find("npcity") then
				return v
			end
		end
	end
	return nil
end

-- Xoay mặt nhân vật về phía mục tiêu
local function faceTarget(hrp, targetHRP)
	local dir = (targetHRP.Position - hrp.Position).Unit
	hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))
end

-- Auto đánh
local function autoAttack(target)
	task.spawn(function()
		while running and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
			local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				tool:Activate()
			end
			task.wait(0.5)
		end
	end)
end

-- Chạy vòng quanh mục tiêu
local function runAround(chr, hum, hrp, target)
	task.spawn(function()
		while running and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
			local angle = tick() * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local destination = target.HumanoidRootPart.Position + offset
			hum:MoveTo(destination)
			faceTarget(hrp, target.HumanoidRootPart)
			task.wait(0.1)
		end
	end)
end

-- Fram tổng hợp
local function startFram()
	if framLoopRunning then return end
	framLoopRunning = true

	task.spawn(function()
		repeat task.wait() until lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character:FindFirstChild("HumanoidRootPart")

		while running do
			local chr, hum, hrp = waitForCharacter()
			local target = findTarget()

			if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") then
				while running and (hrp.Position - target.HumanoidRootPart.Position).Magnitude > radius + 2 and target.Humanoid.Health > 0 do
					hum:MoveTo(target.HumanoidRootPart.Position)
					faceTarget(hrp, target.HumanoidRootPart)
					task.wait(0.3)
				end

				if running and target.Humanoid.Health > 0 then
					runAround(chr, hum, hrp, target)
					autoAttack(target)
					while running and target.Humanoid.Health > 0 do
						task.wait(0.3)
					end
				end
			else
				task.wait(0.5)
			end
		end

		framLoopRunning = false
	end)
end

-- Nút bật/tắt
toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "✅ Đang Fram" or "🔁 Bật Fram"
	toggleBtn.BackgroundColor3 = running and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(0, 170, 0)

	if running then
		startFram()
	end
end)