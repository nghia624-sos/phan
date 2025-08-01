local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

local running = false
local radius = 20
local speed = 5
local currentTarget = nil

-- GUI
local screengui = Instance.new("ScreenGui", game.CoreGui)
screengui.Name = "TT:dongphandzs1"

local frame = Instance.new("Frame", screengui)
frame.Size = UDim2.new(0, 250, 0, 180)
frame.Position = UDim2.new(0, 50, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 8)

local radiusBox = Instance.new("TextButton", frame)
radiusBox.PlaceholderText = "Bán kính đánh"
radiusBox.Text = tostring(radius)
radiusBox.Size = UDim2.new(1, -20, 0, 40)
radiusBox.Position = UDim2.new(0, 10, 0, 10)
radiusBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0, 6)

local speedBox = Instance.new("TextButton", frame)
speedBox.PlaceholderText = "Tốc độ vòng"
speedBox.Text = tostring(speed)
speedBox.Size = UDim2.new(1, -20, 0, 40)
speedBox.Position = UDim2.new(0, 10, 0, 60)
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

local toggle = Instance.new("TextButton", frame)
toggle.Text = "BẬT Fram"
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 110)
toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

-- Tìm NPC gần nhất
local function findTarget()
    local closest, minDist = nil, math.huge
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            local name = v.Name:lower()
            if name:find("citynpc") or name:find("npcity") then
                local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    closest = v
                    minDist = dist
                end
            end
        end
    end
    return closest
end

-- Auto Attack
local function attackLoop()
    while running and currentTarget and currentTarget:FindFirstChild("Humanoid") do
        pcall(function()
            currentTarget.Humanoid:TakeDamage(1) -- hoặc đổi thành click hoặc firetouch nếu muốn
        end)
        task.wait(0.5)
    end
end

-- Vòng tròn quanh mục tiêu
local function orbitTarget()
    spawn(function()
        attackLoop()
    end)
    local angle = 0
    while running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") do
        local pos = currentTarget.HumanoidRootPart.Position
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local targetPos = pos + offset
        hum:MoveTo(targetPos)
        hrp.CFrame = CFrame.new(hrp.Position, pos)
        angle = angle + speed * 0.03
        task.wait(0.03)
    end
end

-- Di chuyển đến mục tiêu trước khi chạy vòng
local function moveToTarget()
    if not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = currentTarget.HumanoidRootPart.Position
    hum:MoveTo(targetPos)
    repeat
        task.wait(0.2)
    until not running or (hrp.Position - targetPos).Magnitude < 10
end

-- Chạy chính
local function startFram()
    radius = tonumber(radiusBox.Text) or radius
    speed = tonumber(speedBox.Text) or speed
    while running do
        currentTarget = findTarget()
        if currentTarget then
            moveToTarget()
            if not running then break end
            orbitTarget()
        end
        task.wait(0.5)
    end
end

toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "TẮT Fram" or "BẬT Fram"
    if running then
        startFram()
    end
end)