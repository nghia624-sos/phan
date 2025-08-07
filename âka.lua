if not game:IsLoaded() then game.Loaded:Wait() end

-- Thêm thư viện GUI Kavo
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/huynhdevpro123/Kavo-GUI/main/source.lua"))()

-- Đổi mật khẩu tại đây
local password = "dp212"
local input = tostring(game:GetService("Players").LocalPlayer.DisplayName)

if not string.find(input, password) then
    game.Players.LocalPlayer:Kick("Sai mật khẩu!")
    return
end

local Window = Library.CreateLib("TT:dongphandzs1", "Midnight")
local BossTab = Window:NewTab("Đánh BOSS")
local BossSection = BossTab:NewSection("Auto Fram Boss")

-- Biến lưu trạng thái
local autoFram = false
local framRadius = 10
local framSpeed = 5

-- Tìm boss gần nhất
local function findBoss()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if string.find(name, "boss") then
                local d = (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    closest = v
                    dist = d
                end
            end
        end
    end
    return closest
end

-- Hàm chạy vòng quanh boss
local RunService = game:GetService("RunService")
local CurrentBoss = nil

RunService.Heartbeat:Connect(function()
    if autoFram and CurrentBoss and CurrentBoss:FindFirstChild("HumanoidRootPart") then
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bossPos = CurrentBoss.HumanoidRootPart.Position
            local angle = tick() * framSpeed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * framRadius
            local targetPos = bossPos + offset
            hrp.CFrame = CFrame.new(targetPos, bossPos)
            -- Tự động đánh
            if char:FindFirstChildOfClass("Tool") then
                pcall(function()
                    char:FindFirstChildOfClass("Tool"):Activate()
                end)
            end
        end
    end
end)

-- Toggle Fram Boss
BossSection:NewToggle("Bật Fram Boss", "Tự động đánh boss gần nhất", function(t)
    autoFram = t
    if t then
        local found = findBoss()
        if found then
            CurrentBoss = found
            -- Teleport mượt
            local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
            local path = game:GetService("PathfindingService"):CreatePath()
            path:ComputeAsync(hrp.Position, found.HumanoidRootPart.Position)
            for _, wp in ipairs(path:GetWaypoints()) do
                hrp.CFrame = CFrame.new(wp.Position)
                task.wait(0.05)
            end
        end
    else
        CurrentBoss = nil
    end
end)

-- Tùy chỉnh bán kính và tốc độ quay
BossSection:NewSlider("Bán kính vòng", "Khoảng cách quay quanh boss", 50, 5, function(val)
    framRadius = val
end)

BossSection:NewSlider("Tốc độ quay", "Tốc độ quay quanh boss", 20, 1, function(val)
    framSpeed = val
end)

-- Hiển thị máu Boss
local BossHealthLabel = BossSection:NewLabel("Máu Boss: Không tìm thấy")
RunService.RenderStepped:Connect(function()
    if CurrentBoss and CurrentBoss:FindFirstChild("Humanoid") then
        local hp = math.floor(CurrentBoss.Humanoid.Health)
        local max = math.floor(CurrentBoss.Humanoid.MaxHealth)
        BossHealthLabel:UpdateLabel("Máu Boss: " .. hp .. "/" .. max)
    else
        BossHealthLabel:UpdateLabel("Máu Boss: Không tìm thấy")
    end
end)

-- Canh giữa GUI
task.spawn(function()
    local gui = game.CoreGui:FindFirstChild("TT:dongphandzs1")
    while not gui or not gui:FindFirstChild("Main") do
        gui = game.CoreGui:FindFirstChild("TT:dongphandzs1")
        task.wait()
    end
    local frame = gui.Main
    frame.Position = UDim2.new(0.5, -250, 0.5, -200) -- giữa màn hình
end)

-- Nút bong bóng và ẩn GUI
task.spawn(function()
    local gui = game.CoreGui:FindFirstChild("TT:dongphandzs1")
    while not gui or not gui:FindFirstChild("Main") do
        gui = game.CoreGui:FindFirstChild("TT:dongphandzs1")
        task.wait()
    end

    local main = gui.Main

    -- Tạo nút bong bóng
    local bubble = Instance.new("TextButton")
    bubble.Size = UDim2.new(0, 100, 0, 40)
    bubble.Position = UDim2.new(1, -110, 1, -50)
    bubble.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    bubble.Text = "Mở Menu"
    bubble.TextColor3 = Color3.new(1, 1, 1)
    bubble.Visible = false
    bubble.Parent = gui
    bubble.Active = true
    bubble.Draggable = true

    -- Nút ẩn GUI
    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 60, 0, 25)
    hideBtn.Position = UDim2.new(1, -70, 0, 10)
    hideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    hideBtn.Text = "Ẩn"
    hideBtn.TextColor3 = Color3.new(1, 1, 1)
    hideBtn.Parent = main

    hideBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        bubble.Visible = true
    end)

    bubble.MouseButton1Click:Connect(function()
        main.Visible = true
        bubble.Visible = false
    end)
end)