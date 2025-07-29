-- GUI Đơn Giản
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false
gui.Name = "CityNPCMenu"

-- Bật/Tắt Menu
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 100, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "Mở Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
openBtn.TextColor3 = Color3.new(1, 1, 1)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false

-- Nút bật/tắt script
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 180, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "BẬT Script"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

-- Nhập bán kính
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0, 180, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 50)
radiusBox.PlaceholderText = "Bán kính vòng (m)"
radiusBox.Text = "10"

-- Nhập tốc độ
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 180, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 90)
speedBox.PlaceholderText = "Tốc độ chạy vòng"
speedBox.Text = "3"

-- Trạng thái hoạt động
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(0, 180, 0, 30)
status.Position = UDim2.new(0, 10, 0, 130)
status.Text = "Trạng thái: Tắt"
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1

-- Mở menu
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Script hoạt động
local active = false
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HRP = nil

toggleBtn.MouseButton1Click:Connect(function()
	active = not active
	toggleBtn.Text = active and "TẮT Script" or "BẬT Script"
	toggleBtn.BackgroundColor3 = active and Color3.fromRGB(200,0,0) or Color3.fromRGB(0,200,0)
	status.Text = "Trạng thái: " .. (active and "Đang chạy" or "Tắt")
end)

-- Hàm tìm NPC chứa "CityNPC"
function getCityNPC()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("citynpc") then
			return v
		end
	end
	return nil
end

-- Chạy vòng quanh
RunService.Heartbeat:Connect(function(dt)
	if not active then return end
	if not HRP then HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
	if not HRP then return end

	local target = getCityNPC()
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end

	local radius = tonumber(radiusBox.Text) or 10
	local speed = tonumber(speedBox.Text) or 3

	local tPos = target.HumanoidRootPart.Position
	local angle = tick() * speed
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local newPos = tPos + offset

	HRP.CFrame = CFrame.new(newPos, tPos)
end)