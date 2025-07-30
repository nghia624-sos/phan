-- GUI đơn giản
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramBossGui"

local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = gui
toggleBtn.Size = UDim2.new(0, 140, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.Text = "Bật Fram Boss"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 20

local healthLabel = Instance.new("TextLabel", gui)
healthLabel.Size = UDim2.new(0, 200, 0, 30)
healthLabel.Position = UDim2.new(0, 20, 0, 60)
healthLabel.Text = "Máu Boss: 0"
healthLabel.BackgroundTransparency = 1
healthLabel.TextColor3 = Color3.new(1, 0, 0)
healthLabel.TextScaled = true
healthLabel.Visible = false

-- Biến điều khiển
local enabled = false
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Tùy chỉnh bán kính & tốc độ
local radius = 10
local speed = 2
local angle = 0

-- Tìm boss gần nhất
local function getNearestBoss()
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local nearest = nil
    local shortest = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if string.find(v.Name:lower(), "boss") and v.Humanoid.Health > 0 then
                local dist = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- Hàm xoay quanh boss
RunService.RenderStepped:Connect(function(dt)
    if enabled then
        local char = lp.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart

        local target = getNearestBoss()
        if target then
            angle += dt * speed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
            local movePos = target.HumanoidRootPart.Position + offset

            -- Di chuyển đến vị trí xoay quanh
            char:FindFirstChildOfClass("Humanoid"):MoveTo(movePos)

            -- Quay mặt về boss
            local look = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
            hrp.CFrame = CFrame.new(hrp.Position, look.Position)

            -- Hiển thị máu
            healthLabel.Visible = true
            healthLabel.Text = "Máu Boss: " .. math.floor(target.Humanoid.Health)
        else
            healthLabel.Text = "Không tìm thấy Boss"
        end
    end
end)

-- Nút bật tắt
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleBtn.Text = enabled and "Tắt Fram Boss" or "Bật Fram Boss"
    healthLabel.Visible = enabled
end)