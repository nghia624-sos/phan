--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SimpleMenu"
gui.ResetOnSpawn = false

-- Toggle GUI Button
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Mở Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false

-- Toggle menu visibility
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Tab buttons
local tabs = {}
local function createTab(name, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 80, 0, 25)
    btn.Position = UDim2.new(0, 10 + (#tabs * 85), 0, 10)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    table.insert(tabs, btn)
    return btn
end

local radius = 10
local speed = 2
local running = false
local autoAim = false
local target = nil

-- Find Closest Target
local function getClosestTarget()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local shortestDist = math.huge
    local closest = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("Humanoid") and obj ~= char then
            local dist = (char.HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closest = obj
            end
        end
    end
    return closest
end

-- Move Around Target
local function moveAroundTarget()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local angle = 0

    while running and target and target:FindFirstChild("HumanoidRootPart") and humanoid do
        angle = angle + speed * 0.05
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local movePos = target.HumanoidRootPart.Position + offset
        humanoid:MoveTo(movePos)
        
        if autoAim then
            local dir = (target.HumanoidRootPart.Position - hrp.Position).Unit
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir)
        end

        wait(0.05)
    end
end

-- Tab 1: Tìm mục tiêu gần nhất
local tab1 = createTab("Tìm Mục Tiêu")
tab1.MouseButton1Click:Connect(function()
    target = getClosestTarget()
    if target then
        print("Đã chọn mục tiêu:", target.Name)
    else
        print("Không tìm thấy mục tiêu.")
    end
end)

-- Tab 2: Chạy vòng + đánh
local tab2 = createTab("Vòng + Đánh")
tab2.MouseButton1Click:Connect(function()
    if target then
        running = true
        coroutine.wrap(moveAroundTarget)()
    else
        print("Hãy chọn mục tiêu trước.")
    end
end)

-- Tab 3: Auto Aim
local tab3 = createTab("Auto Aim")
tab3.MouseButton1Click:Connect(function()
    autoAim = not autoAim
    tab3.Text = autoAim and "Aim: Bật" or "Aim: Tắt"
end)

-- Bán kính chỉnh
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0, 60, 0, 25)
radiusBox.Position = UDim2.new(0, 10, 0, 160)
radiusBox.PlaceholderText = "Bán kính"
radiusBox.Text = tostring(radius)
radiusBox.FocusLost:Connect(function()
    radius = tonumber(radiusBox.Text) or 10
end)

-- Tốc độ chỉnh
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 60, 0, 25)
speedBox.Position = UDim2.new(0, 80, 0, 160)
speedBox.PlaceholderText = "Tốc độ"
speedBox.Text = tostring(speed)
speedBox.FocusLost:Connect(function()
    speed = tonumber(speedBox.Text) or 2
end)

-- Nút Tắt Script
local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(0, 80, 0, 25)
stopBtn.Position = UDim2.new(0, 150, 0, 160)
stopBtn.Text = "Tắt Script"
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
stopBtn.MouseButton1Click:Connect(function()
    running = false
    autoAim = false
    print("Đã dừng script.")
end)