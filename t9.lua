local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local lp = Players.LocalPlayer

local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Biến điều khiển
local targetName = "Boss" -- đổi thành tên mục tiêu bạn muốn
local radius = 15
local speed = 6
local runningCircle = false

-- GUI đơn giản
local screenGui = Instance.new("ScreenGui", lp.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, 0, 0, 40)
toggleBtn.Text = "Bật/Tắt chạy vòng"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, 0, 0, 40)
radiusBox.Position = UDim2.new(0, 0, 0, 50)
radiusBox.PlaceholderText = "Bán kính"
radiusBox.Text = tostring(radius)

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, 0, 0, 40)
speedBox.Position = UDim2.new(0, 0, 0, 100)
speedBox.PlaceholderText = "Tốc độ"
speedBox.Text = tostring(speed)

-- Tìm mục tiêu gần nhất
local function getTarget()
    local nearest, dist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and string.find(string.lower(obj.Name), string.lower(targetName)) then
            local mag = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
            if mag < dist then
                dist = mag
                nearest = obj
            end
        end
    end
    return nearest
end

-- Auto đánh
local function autoAttack()
    VirtualUser:Button1Down(Vector2.new(0,0))
    wait(0.1)
    VirtualUser:Button1Up(Vector2.new(0,0))
end

-- Chạy vòng bằng MoveTo
local function runCircle()
    while runningCircle do
        local target = getTarget()
        if target and target:FindFirstChild("HumanoidRootPart") then
            local tPos = target.HumanoidRootPart.Position
            for i = 0, 360, speed do
                local angle = math.rad(i)
                local x = tPos.X + math.cos(angle) * radius
                local z = tPos.Z + math.sin(angle) * radius
                local y = tPos.Y
                hum:MoveTo(Vector3.new(x, y, z))
                hum.MoveToFinished:Wait()
                if (hrp.Position - tPos).Magnitude <= radius + 2 then
                    autoAttack()
                end
                if not runningCircle then break end
            end
        else
            wait(0.5)
        end
    end
end

-- Sự kiện nút bấm
toggleBtn.MouseButton1Click:Connect(function()
    runningCircle = not runningCircle
    radius = tonumber(radiusBox.Text) or radius
    speed = tonumber(speedBox.Text) or speed
    if runningCircle then
        runCircle()
    end
end)