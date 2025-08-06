--// DỊCH VỤ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// BIẾN
local running = false
local radius = 10
local speed = 3
local currentTarget = nil
local framConnection = nil

--// TÌM NPC
local function findTarget()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChildOfClass("Humanoid") then
			if string.lower(v.Name):find("citynpc") then
				return v
			end
		end
	end
	return nil
end

--// TẠO PATH TRÁNH RÀO CẢN
local function walkTo(position)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true,
	})
	path:ComputeAsync(hrp.Position, position)
	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in pairs(path:GetWaypoints()) do
			if not running then break end
			hum:MoveTo(waypoint.Position)
			hum.MoveToFinished:Wait()
		end
	end
end

--// BẮT ĐẦU FARM
local function startFram()
	if framConnection then framConnection:Disconnect() end

	framConnection = RunService.Heartbeat:Connect(function()
		if not running then return end

		if not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") then
			currentTarget = findTarget()
			return
		end

		local targetHRP = currentTarget:FindFirstChild("HumanoidRootPart")
		if not targetHRP then return end

		local dist = (hrp.Position - targetHRP.Position).Magnitude

		if dist > radius + 2 then
			walkTo(targetHRP.Position)
		else
			local t = tick()
			local x = math.cos(t * speed) * radius
			local z = math.sin(t * speed) * radius
			local movePos = targetHRP.Position + Vector3.new(x, 0, z)
			hum:MoveTo(movePos)

			local dir = (targetHRP.Position - hrp.Position).Unit
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))

			pcall(function()
				mouse1click()
			end)
		end
	end)
end

local function stopFram()
	running = false
	if framConnection then
		framConnection:Disconnect()
		framConnection = nil
	end
	hum:Move(Vector3.new(0, 0, 0))
end

--// GUI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "TT_dongphandzs1"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -20, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.Text = "Bật Fram"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14

local radiusInput = Instance.new("TextBox", frame)
radiusInput.Size = UDim2.new(1, -20, 0, 30)
radiusInput.Position = UDim2.new(0, 10, 0, 80)
radiusInput.PlaceholderText = "Bán kính (Hiện tại: "..radius..")"
radiusInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
radiusInput.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusInput.Font = Enum.Font.Gotham
radiusInput.TextSize = 14
radiusInput.ClearTextOnFocus = true

local speedInput = Instance.new("TextBox", frame)
speedInput.Size = UDim2.new(1, -20, 0, 30)
speedInput.Position = UDim2.new(0, 10, 0, 120)
speedInput.PlaceholderText = "Tốc độ (Hiện tại: "..speed..")"
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 14
speedInput.ClearTextOnFocus = true

--// NÚT
toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "Tắt Fram" or "Bật Fram"
	if running then
		startFram()
	else
		stopFram()
	end
end)

radiusInput.FocusLost:Connect(function()
	local val = tonumber(radiusInput.Text)
	if val then
		radius = val
		radiusInput.PlaceholderText = "Bán kính (Hiện tại: "..radius..")"
	end
end)

speedInput.FocusLost:Connect(function()
	local val = tonumber(speedInput.Text)
	if val then
		speed = val
		speedInput.PlaceholderText = "Tốc độ (Hiện tại: "..speed..")"
	end
end)