local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Giá trị mặc định
local radius = 10
local speed = 2
local running = false
local target = nil

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Text = "TT:dongphandzs1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.Size = UDim2.new(0.5, -5, 0, 25)
RadiusBox.Position = UDim2.new(0, 5, 0, 35)
RadiusBox.PlaceholderText = "Bán kính"
RadiusBox.Text = tostring(radius)
RadiusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
RadiusBox.TextColor3 = Color3.new(1, 1, 1)

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.Size = UDim2.new(0.5, -5, 0, 25)
SpeedBox.Position = UDim2.new(0.5, 0, 0, 35)
SpeedBox.PlaceholderText = "Tốc độ"
SpeedBox.Text = tostring(speed)
SpeedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, -10, 0, 30)
ToggleButton.Position = UDim2.new(0, 5, 0, 65)
ToggleButton.Text = "Bật Fram"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

local HPLabel = Instance.new("TextLabel", Frame)
HPLabel.Size = UDim2.new(1, -10, 0, 25)
HPLabel.Position = UDim2.new(0, 5, 0, 100)
HPLabel.BackgroundTransparency = 1
HPLabel.TextColor3 = Color3.new(1, 0, 0)
HPLabel.Text = "Máu: N/A"

-- Hàm tìm mục tiêu gần nhất (ví dụ chứa "NPC")
local function getNearestTarget()
    local nearest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v ~= char and v:FindFirstChild("HumanoidRootPart") then
            if string.find(string.lower(v.Name), "npc") then
                local mag = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if mag < dist then
                    nearest = v
                    dist = mag
                end
            end
        end
    end
    return nearest
end

-- Auto đánh
local function autoAttack()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

-- Chạy vòng quanh mục tiêu
RunService.Heartbeat:Connect(function()
    if running and target and target:FindFirstChild("HumanoidRootPart") then
        -- Cập nhật bán kính & tốc độ
        radius = tonumber(RadiusBox.Text) or radius
        speed = tonumber(SpeedBox.Text) or speed

        -- Hiển thị máu
        HPLabel.Text = "Máu: " .. math.floor(target.Humanoid.Health) .. "/" .. math.floor(target.Humanoid.MaxHealth)

        -- Tạo vị trí vòng tròn
        local angle = tick() * speed
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local targetPos = target.HumanoidRootPart.Position + offset

        hum:MoveTo(targetPos)
        hrp.CFrame = CFrame.lookAt(hrp.Position, target.HumanoidRootPart.Position)

        -- Đánh
        autoAttack()
    end
end)

-- Nút bật/tắt
ToggleButton.MouseButton1Click:Connect(function()
    running = not running
    if running then
        ToggleButton.Text = "Tắt Fram"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        target = getNearestTarget()
    else
        ToggleButton.Text = "Bật Fram"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        target = nil
        HPLabel.Text = "Máu: N/A"
    end
end)