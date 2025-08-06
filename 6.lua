--// Dịch vụ
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--// Biến
local radius = 10
local speed = 2
local isFramming = false
local framTarget = nil
local guiEnabled = true

--// Tạo GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TT_dongphandzs1"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 320)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Nút tiêu đề
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "TT:dongphandzs1"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

-- Nút bật/tắt Fram
local FramToggle = Instance.new("TextButton", Frame)
FramToggle.Size = UDim2.new(1, 0, 0, 30)
FramToggle.Text = "Bật Fram BOSS"
FramToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FramToggle.TextColor3 = Color3.new(1, 1, 1)
FramToggle.Font = Enum.Font.SourceSans
FramToggle.TextSize = 18

-- Hiển thị máu mục tiêu
local HPLabel = Instance.new("TextLabel", Frame)
HPLabel.Size = UDim2.new(1, 0, 0, 25)
HPLabel.Text = "Máu mục tiêu: N/A"
HPLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HPLabel.TextColor3 = Color3.new(1, 1, 1)
HPLabel.Font = Enum.Font.SourceSans
HPLabel.TextSize = 16

-- Nhập bán kính
local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.Size = UDim2.new(1, 0, 0, 30)
RadiusBox.PlaceholderText = "Bán kính chạy vòng (mặc định 10)"
RadiusBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RadiusBox.TextColor3 = Color3.new(1, 1, 1)
RadiusBox.Font = Enum.Font.SourceSans
RadiusBox.TextSize = 16

-- Nhập tốc độ
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(1, 0, 0, 30)
SpeedBox.PlaceholderText = "Tốc độ chạy vòng (mặc định 2)"
SpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 16

-- Thu nhỏ menu
local HideBtn = Instance.new("TextButton", Frame)
HideBtn.Size = UDim2.new(1, 0, 0, 25)
HideBtn.Text = "Ẩn Menu"
HideBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.Font = Enum.Font.SourceSansBold
HideBtn.TextSize = 16

--// Chức năng tìm boss
function FindBoss()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if v.Name:lower():find("boss") then
				return v
			end
		end
	end
	return nil
end

--// Hàm chạy vòng quanh boss
function StartFram()
	coroutine.wrap(function()
		while isFramming and framTarget and framTarget:FindFirstChild("HumanoidRootPart") and framTarget:FindFirstChild("Humanoid") and framTarget.Humanoid.Health > 0 do
			local angle = tick() * speed
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
			local goal = framTarget.HumanoidRootPart.Position + offset
			local tween = TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal, framTarget.HumanoidRootPart.Position)})
			tween:Play()
			RunService.RenderStepped:Wait()
			HPLabel.Text = "Máu mục tiêu: " .. math.floor(framTarget.Humanoid.Health)
		end
	end)()
end

--// Sự kiện nút Bật/Tắt Fram
FramToggle.MouseButton1Click:Connect(function()
	isFramming = not isFramming
	if isFramming then
		FramToggle.Text = "Tắt Fram BOSS"
		radius = tonumber(RadiusBox.Text) or 10
		speed = tonumber(SpeedBox.Text) or 2
		framTarget = FindBoss()
		if framTarget then
			local root = framTarget:FindFirstChild("HumanoidRootPart")
			if root then
				hrp.CFrame = CFrame.new(root.Position + Vector3.new(0, 3, 0))
				wait(0.2)
				StartFram()
			end
		else
			FramToggle.Text = "Không tìm thấy Boss"
			isFramming = false
		end
	else
		FramToggle.Text = "Bật Fram BOSS"
		framTarget = nil
		HPLabel.Text = "Máu mục tiêu: N/A"
	end
end)

--// Nút thu nhỏ menu
HideBtn.MouseButton1Click:Connect(function()
	guiEnabled = not guiEnabled
	Frame.Visible = guiEnabled
end)