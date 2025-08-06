--// DỊCH VỤ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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

--// FRAM CHÍNH
local function startFram()
	if framConnection then framConnection:Disconnect() end

	framConnection = RunService.RenderStepped:Connect(function()
		if not running then return end
		if not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") then
			currentTarget = findTarget()
			return
		end

		local dist = (hrp.Position - currentTarget.HumanoidRootPart.Position).Magnitude

		if dist > radius + 2 then
			-- Di chuyển tự nhiên tới mục tiêu
			hum:MoveTo(currentTarget.HumanoidRootPart.Position)
		else
			-- Chạy vòng quanh mục tiêu
			local t = tick()
			local x = math.cos(t * speed) * radius
			local z = math.sin(t * speed) * radius
			local movePos = currentTarget.HumanoidRootPart.Position + Vector3.new(x, 0, z)
			hum:MoveTo(movePos)

			-- Quay mặt về mục tiêu
			local dir = (currentTarget.HumanoidRootPart.Position - hrp.Position).Unit
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))

			-- Tấn công
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
local screengui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
screengui.Name = "TT_dongphandzs1"
screengui.ResetOnSpawn = false

local frame = Instance.new("Frame", screengui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local toggleFram = Instance.new("TextButton", frame)
toggleFram.Size = UDim2.new(1, -20, 0, 30)
toggleFram.Position = UDim2.new(0, 10, 0, 40)
toggleFram.Text = "Bật Fram"
toggleFram.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
toggleFram.TextColor3 = Color3.new(1,1,1)
toggleFram.Font = Enum.Font.Gotham
toggleFram.TextSize = 14

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, -20, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 80)
radiusBox.PlaceholderText = "Bán kính (hiện tại: "..radius..")"
radiusBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.Font = Enum.Font.Gotham
radiusBox.TextSize = 14
radiusBox.ClearTextOnFocus = false

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 120)
speedBox.PlaceholderText = "Tốc độ quay (hiện tại: "..speed..")"
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false

--// NÚT
toggleFram.MouseButton1Click:Connect(function()
	running = not running
	toggleFram.Text = running and "Tắt Fram" or "Bật Fram"
	if running then
		startFram()
	else
		stopFram()
	end
end)

radiusBox.FocusLost:Connect(function()
	local val = tonumber(radiusBox.Text)
	if val then
		radius = val
		radiusBox.PlaceholderText = "Bán kính (hiện tại: "..radius..")"
	end
end)

speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text)
	if val then
		speed = val
		speedBox.PlaceholderText = "Tốc độ quay (hiện tại: "..speed..")"
	end
end)