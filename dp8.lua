local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến
local fram = false
local circle = false
local autoHit = false
local target = nil
local radius = 10
local speed = 5
local targetName = "CityNPC"
local sizeX, sizeY, sizeZ = 5, 5, 5
local hitboxEnabled = false
local hitboxPart = nil

-- GUI
local screengui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
screengui.Name = "FramMenu"
screengui.ResetOnSpawn = false

local frame = Instance.new("Frame", screengui)
frame.Size = UDim2.new(0, 320, 0, 360)
frame.Position = UDim2.new(0.5, -160, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Nghia Minh Menu"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Hàm tìm NPC
function getNPC()
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find(targetName:lower()) then
			return v
		end
	end
end

-- Auto hit
RunService.RenderStepped:Connect(function()
	if autoHit and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
		mouse1press()
		wait()
		mouse1release()
	end
end)

-- Hitbox function
function updateHitbox()
	if hitboxPart then hitboxPart:Destroy() end
	local tool = chr:FindFirstChildOfClass("Tool")
	if tool and tool:FindFirstChild("Handle") then
		local handle = tool.Handle
		hitboxPart = Instance.new("Part", handle)
		hitboxPart.Size = Vector3.new(sizeX, sizeY, sizeZ)
		hitboxPart.Material = Enum.Material.Neon
		hitboxPart.Color = Color3.new(1,0,0)
		hitboxPart.Transparency = 0.3
		hitboxPart.CanCollide = false
		local weld = Instance.new("WeldConstraint", hitboxPart)
		weld.Part0 = handle
		weld.Part1 = hitboxPart
	end
end

-- Chạy vòng quanh NPC
function runCircle()
	local angle = 0
	RunService:BindToRenderStep("RunCircle", Enum.RenderPriority.Character.Value, function(dt)
		if not circle or not target or not target:FindFirstChild("HumanoidRootPart") then
			RunService:UnbindFromRenderStep("RunCircle")
			return
		end
		angle += dt * speed
		local pos = target.HumanoidRootPart.Position + Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
		hum:MoveTo(pos)
		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
	end)
end

-- Fram NPC
spawn(function()
	while true do
		wait(0.5)
		if fram then
			target = getNPC()
			if target and target:FindFirstChild("HumanoidRootPart") then
				repeat
					hum:MoveTo(target.HumanoidRootPart.Position)
					wait(0.5)
				until not fram or target.Humanoid.Health <= 0
			end
		end
	end
end)

-- Nút bấm
function addButton(text, y, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 300, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.Text = text
	btn.MouseButton1Click:Connect(callback)
end

-- Ô nhập số
function addInput(text, y, defaultValue, onChange)
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(0, 100, 0, 25)
	label.Position = UDim2.new(0, 10, 0, y)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Text = text

	local input = Instance.new("TextBox", frame)
	input.Size = UDim2.new(0, 200, 0, 25)
	input.Position = UDim2.new(0, 110, 0, y)
	input.BackgroundColor3 = Color3.fromRGB(60,60,60)
	input.TextColor3 = Color3.new(1,1,1)
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.Text = tostring(defaultValue)
	input.FocusLost:Connect(function()
		onChange(tonumber(input.Text))
	end)
end

-- Các nút chức năng
addButton("🟢 Bật/Tắt Fram", 40, function() fram = not fram end)
addButton("🔄 Bật/Tắt Chạy Vòng", 80, function() circle = not circle; if circle then runCircle() end end)
addButton("⚔️ Bật/Tắt Auto Đánh", 120, function() autoHit = not autoHit end)
addButton("🔴 Bật/Tắt Hiển thị Hitbox", 160, function()
	hitboxEnabled = not hitboxEnabled
	if hitboxEnabled then updateHitbox() else if hitboxPart then hitboxPart:Destroy() end end
end)

-- Các input chỉnh thông số
addInput("Bán kính chạy vòng", 200, radius, function(val) radius = val or 10 end)
addInput("Tốc độ vòng", 230, speed, function(val) speed = val or 5 end)
addInput("Tên mục tiêu", 260, targetName, function(val) targetName = tostring(val or "CityNPC") end)
addInput("Kích thước X", 290, sizeX, function(val) sizeX = val or 5; if hitboxEnabled then updateHitbox() end end)
addInput("Kích thước Y", 320, sizeY, function(val) sizeY = val or 5; if hitboxEnabled then updateHitbox() end end)
addInput("Kích thước Z", 350, sizeZ, function(val) sizeZ = val or 5; if hitboxEnabled then updateHitbox() end end)