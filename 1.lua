--// DỊCH VỤ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// BIẾN
local running = false
local radius = 10
local speed = 3
local target = nil

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

--// CHẠY TỚI NPC
local function moveToTarget(tar)
	local path = (tar.HumanoidRootPart.Position - hrp.Position).Magnitude
	if path > radius then
		hum:MoveTo(tar.HumanoidRootPart.Position)
		hum.MoveToFinished:Wait()
	end
end

--// CHẠY VÒNG VÀ ĐÁNH
local function runAround()
	local angle = 0
	local attacking = false

	RunService:BindToRenderStep("FramNPC", Enum.RenderPriority.Character.Value, function()
		if target and target:FindFirstChild("HumanoidRootPart") and running then
			-- Tính vị trí chạy vòng
			angle = angle + speed * 0.03
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local runPos = target.HumanoidRootPart.Position + offset
			hum:MoveTo(runPos)

			-- Quay mặt về mục tiêu
			local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(dir.X, 0, dir.Z))

			-- Đánh
			if not attacking then
				attacking = true
				pcall(function()
					-- Mô phỏng đánh (tùy game có thể thay bằng firetouch hoặc RemoteEvent)
					mouse1click()
				end)
				wait(0.5)
				attacking = false
			end
		end
	end)
end

--// BẬT FRAM
local function startFram()
	target = findTarget()
	if target then
		moveToTarget(target)
		runAround()
	end
end

local function stopFram()
	RunService:UnbindFromRenderStep("FramNPC")
	hum:Move(Vector3.new(0,0,0))
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

--// HÀNH ĐỘNG NÚT
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