-- GUI cơ bản
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CityNPCFramGUI"

-- Menu toggle
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 100)
toggleButton.Text = "Bật Menu"
toggleButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8)
toggleButton.TextColor3 = Color3.new(1, 1, 1)

-- Frame menu chính
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, 200, 0, 230)
menu.Position = UDim2.new(0, 20, 0, 150)
menu.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
menu.Visible = false

-- Tùy chọn tốc độ và bán kính
local speedBox = Instance.new("TextBox", menu)
speedBox.Size = UDim2.new(0, 180, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 10)
speedBox.PlaceholderText = "Tốc độ xoay (default 10)"
speedBox.Text = ""

local radiusBox = Instance.new("TextBox", menu)
radiusBox.Size = UDim2.new(0, 180, 0, 30)
radiusBox.Position = UDim2.new(0, 10, 0, 50)
radiusBox.PlaceholderText = "Bán kính (default 10)"
radiusBox.Text = ""

-- Nút chọn mục tiêu CityNPC
local targetButton = Instance.new("TextButton", menu)
targetButton.Size = UDim2.new(0, 180, 0, 30)
targetButton.Position = UDim2.new(0, 10, 0, 90)
targetButton.Text = "Chọn mục tiêu CityNPC"

-- Label hiển thị máu
local healthLabel = Instance.new("TextLabel", menu)
healthLabel.Size = UDim2.new(0, 180, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 130)
healthLabel.Text = "Máu mục tiêu: N/A"
healthLabel.TextColor3 = Color3.new(1,1,1)
healthLabel.BackgroundTransparency = 1

-- Bật tắt chạy vòng tròn
local startButton = Instance.new("TextButton", menu)
startButton.Size = UDim2.new(0, 180, 0, 30)
startButton.Position = UDim2.new(0, 10, 0, 170)
startButton.Text = "Bắt đầu vòng tròn"
startButton.BackgroundColor3 = Color3.new(0.3, 0.8, 0.3)

-- Logic
local running = false
local target = nil
local angle = 0
local RS = game:GetService("RunService")

function findCityNPCs()
	local list = {}
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and string.find(v.Name, "CityNPC") then
			table.insert(list, v)
		end
	end
	return list
end

targetButton.MouseButton1Click:Connect(function()
	local npcs