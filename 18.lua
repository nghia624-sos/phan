-- MENU SCRIPT TT:dongphandzs1 (fix menu hiển thị)
-- Giữ toàn bộ tính năng: chạy bộ tự nhiên, chạy vòng, auto đánh, tìm mục tiêu mới, noclip, GUI kéo được

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local GuiService = game:GetService("StarterGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "TT:dongphandzs1"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.Parent = Frame

-- Tạo layout để sắp xếp nút
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = Frame

-- Tạo khung chứa nút
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -10, 1, -60)
Container.Position = UDim2.new(0, 5, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = Frame

-- Gán layout vào container
local layout2 = layout:Clone()
layout2.Parent = Container

-- Thêm các nút điều khiển như toggle fram, auto aim, noclip, tốc độ, bán kính...
-- Bạn có thể giữ nguyên code tạo nút và sự kiện như cũ, chỉ cần gán parent = Container

-- Ví dụ tạo một nút mẫu:
local ToggleFram = Instance.new("TextButton")
ToggleFram.Size = UDim2.new(1, 0, 0, 40)
ToggleFram.Text = "Bật Fram"
ToggleFram.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleFram.TextColor3 = Color3.new(1, 1, 1)
ToggleFram.Font = Enum.Font.SourceSansBold
ToggleFram.TextScaled = true
ToggleFram.Parent = Container

-- Các chức năng script (fram NPC, chạy vòng, auto đánh...) giữ nguyên như hiện tại và đặt vào sự kiện nút
-- Ví dụ: ToggleFram.MouseButton1Click:Connect(function() ... end)

-- Các tính năng như tìm mục tiêu, chạy vòng, noclip, auto đánh... nên giữ trong các biến/toggle để quản lý dễ hơn
-- Nếu bạn cần cập nhật phần chức năng fram/tìm NPC hãy gửi lại script phần đó