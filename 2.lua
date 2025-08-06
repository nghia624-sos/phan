-- GUI menu: TT:dongphandzs1 (KRNL Mobile)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- GUI setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TT_dongphandzs1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Size = UDim2.new(0, 120, 0, 30)
toggle.Text = "Bật Fram: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Position = UDim2.new(0, 10, 0, 80)
radiusBox.Size = UDim2.new(0, 120, 0, 30)
radiusBox.PlaceholderText = "Bán kính (mặc định: 10)"
radiusBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
radiusBox.TextColor3 = Color3.new(1,1,1)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 14

local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 150, 0, 80)
speedBox.Size = UDim2.new(0, 120, 0, 30)
speedBox.PlaceholderText = "Tốc độ (mặc định: 2)"
speedBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.new(0, 10, 0, 130)
status.Size = UDim2.new(1, -20, 0, 30)
status.Text = "Mục tiêu: Không có"
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 0)
status.Font = Enum.Font.SourceSansBold
status.TextSize = 16

-- Tìm object gần nhất (bất kỳ đối tượng nào trong workspace)
local function getNearestTarget()
    local nearest = nil
    local shortestDist = math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:IsDescendantOf(workspace) and obj ~= HRP then
            local dist = (obj.Position - HRP.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = obj
            end
        end
    end
    return nearest
end

-- Vòng fram
local isRunning = false
toggle.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    toggle.Text = isRunning and "Bật Fram: ON" or "Bật Fram: OFF"

    while isRunning and task.wait() do
        local target = getNearestTarget()
        if target then
            status.Text = "Mục tiêu: " .. target.Name
            local radius = tonumber(radiusBox.Text) or 10
            local speed = tonumber(speedBox.Text) or 2
            local angle = tick() * speed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
            local dest = target.Position + offset

            -- Tween chạy mượt
            local tween = TweenService:Create(HRP, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(dest)})
            tween:Play()

            -- Quay mặt về mục tiêu
            HRP.CFrame = CFrame.new(HRP.Position, target.Position)

            -- Auto đánh nếu có tool
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Activate") then
                pcall(function() tool:Activate() end)
            end
        else
            status.Text = "Không tìm thấy mục tiêu!"
        end
    end
end)