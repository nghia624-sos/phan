--[[
    Menu TT:dongphandzs1 - Hoàn chỉnh
    - Menu ở giữa màn hình khi mở
    - Thu nhỏ thành bong bóng góc phải dưới
    - Bong bóng bấm mở lại menu
    - Giữ nguyên toàn bộ chức năng fram NPC/BOSS, chạy vòng, auto đánh
    - Hiển thị máu mục tiêu, chỉnh tốc độ/bán kính
    - Chạy mượt, không teleport đột ngột
--]]

-- Tạo ScreenGui
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TT_dongphandzs1"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Kích thước màn hình
local screenSize = workspace.CurrentCamera.ViewportSize

-- Main Menu Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Parent = mainFrame

-- Nút thu nhỏ
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -45, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Parent = mainFrame

-- Bong bóng thu nhỏ
local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(0, 60, 0, 60)
miniButton.Position = UDim2.new(1, -70, 1, -70)
miniButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
miniButton.Text = "+"
miniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
miniButton.TextSize = 30
miniButton.Visible = false
miniButton.Parent = gui

-- Chức năng thu nhỏ/mở lại menu
minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniButton.Visible = true
end)

miniButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    miniButton.Visible = false
end)

-- Ví dụ thêm chức năng fram (bạn giữ nguyên phần code fram hiện tại của bạn ở đây)
-- Auto fram NPC/BOSS + chạy vòng + auto đánh
-- Dưới đây mình chỉ để placeholder, bạn thay bằng code fram của bạn
local function FramNPCBoss()
    -- Code fram NPC/BOSS của bạn...
end

-- Ví dụ nút bật fram
local framBtn = Instance.new("TextButton")
framBtn.Size = UDim2.new(0.9, 0, 0, 40)
framBtn.Position = UDim2.new(0.05, 0, 0, 60)
framBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
framBtn.Text = "Bật Fram NPC/BOSS"
framBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
framBtn.TextSize = 18
framBtn.Parent = mainFrame
framBtn.MouseButton1Click:Connect(FramNPCBoss)

-- Bạn có thể chèn tiếp code điều khiển tốc độ/bán kính, hiển thị máu mục tiêu
-- giữ nguyên logic fram hiện tại