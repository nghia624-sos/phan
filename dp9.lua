local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

-- Biến điều chỉnh
local running = false
local radius = 10
local speed = 5

-- Tìm mục tiêu gần nhất
local function getClosestNPC()
    local nearest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            local name = v.Name:lower()
            if string.find(name, "citynpc") or string.find(name, "npcity") then
                local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- Chạy vòng tròn quanh mục tiêu
local function orbitTarget(target)
    local angle = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not running or not target or not target:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
            return
        end

        angle = angle + dt * speed
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local targetPos = target.HumanoidRootPart.Position + Vector3.new(x, 0, z)

        -- Tween di chuyển
        local tween = TweenService:Create(hrp, TweenInfo.new(0.2), {CFrame = CFrame.new(targetPos)})
        tween:Play()

        -- Quay mặt về mục tiêu
        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HumanoidRootPart.Position.X, hrp.Position.Y, target.HumanoidRootPart.Position.Z))

        -- Giả lập đánh
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Bắt đầu tự động chạy vòng + đánh
local function startFram()
    running = true
    while running do
        local npc = getClosestNPC()
        if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            orbitTarget(npc)
            repeat
                task.wait(0.2)
            until not running or npc.Humanoid.Health <= 0
        else
            task.wait(0.5)
        end
    end
end

-- Giao diện GUI (dùng Simple GUI cho KRNL Mobile)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.Size = UDim2.new(0, 200, 0, 180)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

-- Input radius
local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.PlaceholderText = "Bán kính (mặc định 10)"
RadiusBox.Size = UDim2.new(1, 0, 0, 30)
RadiusBox.Position = UDim2.new(0, 0, 0, 0)
RadiusBox.Text = tostring(radius)
RadiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RadiusBox.TextColor3 = Color3.new(1, 1, 1)

-- Input speed
local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.PlaceholderText = "Tốc độ (mặc định 5)"
SpeedBox.Size = UDim2.new(1, 0, 0, 30)
SpeedBox.Position = UDim2.new(0, 0, 0, 35)
SpeedBox.Text = tostring(speed)
SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)

-- Nút bật Fram
local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, 0, 0, 40)
ToggleButton.Position = UDim2.new(0, 0, 0, 70)
ToggleButton.Text = "BẬT Fram"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

ToggleButton.MouseButton1Click:Connect(function()
    if not running then
        radius = tonumber(RadiusBox.Text) or 10
        speed = tonumber(SpeedBox.Text) or 5
        running = true
        ToggleButton.Text = "TẮT Fram"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        startFram()
    else
        running = false
        ToggleButton.Text = "BẬT Fram"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end)