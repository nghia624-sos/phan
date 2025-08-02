local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "TT_dongphandzs1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 150)
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

local running = false
local radius = 10
local speed = 4
local currentTarget = nil

-- Tìm NPC chứa tên "CityNPC" hoặc "NPCity" (không phân biệt hoa thường)
local function findTarget()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
			local name = string.lower(v.Name)
			if string.find(name, "citynpc") or string.find(name, "npcity") then
				return v
			end
		end
	end
	return nil
end

-- Quay mặt về mục tiêu
local function faceTarget(target)
	if target and hrp then
		local look = (target.Position - hrp.Position).Unit
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(look.X, 0, look.Z))
	end
end

-- Tự chạy vòng quanh mục tiêu + quay mặt
local function runAroundTarget(target)
	coroutine.wrap(function()
		while running and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
			local angle = tick() * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local destination = target.HumanoidRootPart.Position + offset
			hum:MoveTo(destination)
			faceTarget(target.HumanoidRootPart)
			wait(0.1)
		end
	end)()
end

-- Tự đánh
local function autoAttack(target)
	coroutine.wrap(function()
		while running and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
			local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				tool:Activate()
			end
			wait(0.4)
		end
	end)()
end

-- Tự chạy đến + xử lý hành vi
local function startFram()
	coroutine.wrap(function()
		while running do
			chr = lp.Character or lp.CharacterAdded:Wait()
			hum = chr:FindFirstChild("Humanoid")
			hrp = chr:FindFirstChild("HumanoidRootPart")

			currentTarget = findTarget()

			if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
				-- 1. Tự chạy bộ theo mục tiêu
				while running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and (hrp.Position - currentTarget.HumanoidRootPart.Position).Magnitude > radius + 2 do
					local followPos = currentTarget.HumanoidRootPart.Position
					hum:MoveTo(followPos)
					faceTarget(currentTarget.HumanoidRootPart)
					wait(0.2)
				end

				-- 2. Khi đã gần thì chạy vòng + đánh
				if running and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 then
					runAroundTarget(currentTarget)
					autoAttack(currentTarget)

					while running and currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 do
						wait(0.5)
					end
				end
			end

			wait(0.5)
		end
	end)()
end

-- Nút Toggle Fram
toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "✅ Đang Fram" or "🔁 Bật Fram"
	toggleBtn.BackgroundColor3 = running and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(0, 170, 0)
	if running then
		startFram()
	end
end)