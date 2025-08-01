--// SCRIPT FRAM NPC FULL FIX WITH AUTO TARGET SWITCH \--

-- Biến toàn cục
_G.FramRunning = false
_G.AutoCircle = false
_G.Radius = 10
_G.Speed = 2

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local TweenService = game:GetService("TweenService")

-- Hàm tìm mục tiêu gần nhất chứa tên 'citynpc'
local function getNearestEnemy()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Name:lower():find("citynpc") then
            local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                closest = v
            end
        end
    end
    return closest
end

-- Di chuyển tự nhiên đến mục tiêu
spawn(function()
    while task.wait(0.3) do
        if _G.FramRunning and not _G.AutoCircle then
            local target = getNearestEnemy()
            if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid").Health > 0 then
                humanoid:MoveTo(target.HumanoidRootPart.Position)
            else
                humanoid:MoveTo(hrp.Position)
            end
        end
    end
end)

-- Tự động chạy vòng quanh và đánh
spawn(function()
    while task.wait(0.03) do
        if _G.AutoCircle then
            local dist = tonumber(_G.Radius or 10)
            local speed = tonumber(_G.Speed or 2)
            local target = getNearestEnemy()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local angle = tick() * speed
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
                local goalPos = target.HumanoidRootPart.Position + offset
                goalPos = Vector3.new(goalPos.X, hrp.Position.Y, goalPos.Z)
                local goalCF = CFrame.new(goalPos, target.HumanoidRootPart.Position)
                TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = goalCF}):Play()

                -- Đánh mục tiêu
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end
    end
end)

-- Tự động chuyển mục tiêu sau khi tiêu diệt mục tiêu cũ
spawn(function()
    while task.wait(1) do
        if _G.FramRunning then
            local target = getNearestEnemy()
            if target then
                -- Kiểm tra xem mục tiêu có bị tiêu diệt chưa
                if target:FindFirstChild("Humanoid") and target.Humanoid.Health <= 0 then
                    -- Nếu mục tiêu chết, tìm mục tiêu mới và di chuyển
                    humanoid:MoveTo(hrp.Position)
                    task.wait(1) -- Chờ 1 giây trước khi tìm mục tiêu mới
                    _G.FramRunning = true -- Tiếp tục chạy
                end
            end
        end
    end
end)

-- GUI MENU
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramMenuMobile"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 200)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fram NPC"
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(1, -10, 0, 30)
startBtn.Position = UDim2.new(0, 5, 0, 40)
startBtn.Text = "Bật/Tắt Fram NPC"
startBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
startBtn.TextColor3 = Color3.new(1,1,1)

local autoCircleBtn = Instance.new("TextButton", frame)
autoCircleBtn.Size = UDim2.new(1, -10, 0, 30)
autoCircleBtn.Position = UDim2.new(0, 5, 0, 80)
autoCircleBtn.Text = "Bật/Tắt Vòng Quanh + Đánh"
autoCircleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
autoCircleBtn.TextColor3 = Color3.new(1,1,1)

local distanceBox = Instance.new("TextBox", frame)
distanceBox.Size = UDim2.new(1, -10, 0, 30)
distanceBox.Position = UDim2.new(0, 5, 0, 120)
distanceBox.PlaceholderText = "Bán kính vòng (default 10)"
distanceBox.Text = ""
distanceBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
distanceBox.TextColor3 = Color3.new(1,1,1)

distanceBox.FocusLost:Connect(function()
    _G.Radius = tonumber(distanceBox.Text) or 10
end)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -10, 0, 30)
speedBox.Position = UDim2.new(0, 5, 0, 160)
speedBox.PlaceholderText = "Tốc độ vòng (default 2)"
speedBox.Text = ""
speedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedBox.TextColor3 = Color3.new(1,1,1)

speedBox.FocusLost:Connect(function()
    _G.Speed = tonumber(speedBox.Text) or 2
end)

startBtn.MouseButton1Click:Connect(function()
    _G.FramRunning = not _G.FramRunning
    startBtn.Text = _G.FramRunning and "Đã bật Fram" or "Bật Fram NPC"
end)

autoCircleBtn.MouseButton1Click:Connect(function()
    _G.AutoCircle = not _G.AutoCircle
    autoCircleBtn.Text = _G.AutoCircle and "Đã bật Vòng Quanh" or "Bật Vòng Quanh + Đánh"
end)