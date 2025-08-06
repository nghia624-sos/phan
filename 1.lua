-- GUI Menu: TT:dongphandzs1
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- GUI tạo bằng Instance (mobile friendly, kéo được)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TT_dongphandzs1"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "TT:dongphandzs1"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

-- Bật Fram
local FramToggle = Instance.new("TextButton", Frame)
FramToggle.Position = UDim2.new(0, 10, 0, 40)
FramToggle.Size = UDim2.new(0, 120, 0, 30)
FramToggle.Text = "Bật Fram: OFF"
FramToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
FramToggle.TextColor3 = Color3.new(1,1,1)
FramToggle.Font = Enum.Font.SourceSans
FramToggle.TextSize = 16

-- Bán kính và tốc độ
local RadiusBox = Instance.new("TextBox", Frame)
RadiusBox.PlaceholderText = "Bán kính (mặc định: 10)"
RadiusBox.Position = UDim2.new(0, 10, 0, 80)
RadiusBox.Size = UDim2.new(0, 120, 0, 30)
RadiusBox.Text = ""
RadiusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
RadiusBox.TextColor3 = Color3.new(1,1,1)
RadiusBox.Font = Enum.Font.SourceSans
RadiusBox.TextSize = 14

local SpeedBox = Instance.new("TextBox", Frame)
SpeedBox.PlaceholderText = "Tốc độ (mặc định: 2)"
SpeedBox.Position = UDim2.new(0, 150, 0, 80)
SpeedBox.Size = UDim2.new(0, 120, 0, 30)
SpeedBox.Text = ""
SpeedBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedBox.TextColor3 = Color3.new(1,1,1)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 14

-- Hiển thị máu Boss
local BossHp = Instance.new("TextLabel", Frame)
BossHp.Position = UDim2.new(0, 10, 0, 120)
BossHp.Size = UDim2.new(0, 260, 0, 30)
BossHp.Text = "Máu Boss: Không có"
BossHp.BackgroundTransparency = 1
BossHp.TextColor3 = Color3.new(1,0,0)
BossHp.Font = Enum.Font.SourceSansBold
BossHp.TextSize = 16

-- Tìm Boss gần nhất
local function getNearestBoss()
    local nearest, dist = nil, math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            local name = npc.Name:lower()
            if string.find(name, "boss") then
                local d = (npc.HumanoidRootPart.Position - HRP.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = npc
                end
            end
        end
    end
    return nearest
end

-- Chạy vòng quanh + auto aim + đánh
local FramRunning = false
FramToggle.MouseButton1Click:Connect(function()
    FramRunning = not FramRunning
    FramToggle.Text = FramRunning and "Bật Fram: ON" or "Bật Fram: OFF"

    while FramRunning and task.wait() do
        local boss = getNearestBoss()
        if boss and boss:FindFirstChild("Humanoid") and boss:FindFirstChild("HumanoidRootPart") then
            local radius = tonumber(RadiusBox.Text) or 10
            local speed = tonumber(SpeedBox.Text) or 2
            local angle = tick() * speed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
            local targetPos = boss.HumanoidRootPart.Position + offset

            -- Tween chạy mượt
            local tween = TweenService:Create(HRP, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
            tween:Play()

            -- Quay mặt về boss
            HRP.CFrame = CFrame.new(HRP.Position, boss.HumanoidRootPart.Position)

            -- Auto đánh (nếu có công cụ)
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Activate") then
                pcall(function()
                    tool:Activate()
                end)
            end

            -- Cập nhật máu boss
            local hp = math.floor(boss.Humanoid.Health)
            BossHp.Text = "Máu Boss: " .. hp
        else
            BossHp.Text = "Máu Boss: Không có"
        end
    end
end)