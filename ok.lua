--// GUI Đơn Giản
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BossFramGUI"
gui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 140, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.Text = "Bật Fram Boss"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

--// Biến Điều Khiển
local running = false
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()

--// Tùy Chỉnh
local speed = 2      -- Tốc độ xoay quanh
local radius = 10    -- Bán kính xoay

--// Tìm Boss Gần Nhất
local function getNearestBoss()
    local closest, distance = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if string.find(v.Name:lower(), "boss") and v.Humanoid.Health > 0 then
                local dist = (v.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist < distance then
                    closest = v
                    distance = dist
                end
            end
        end
    end
    return closest
end

--// Hiển Thị Máu Mục Tiêu
local healthLabel = Instance.new("TextLabel", gui)
healthLabel.Size = UDim2.new(0, 200, 0, 30)
healthLabel.Position = UDim2.new(0, 20, 0, 60)
healthLabel.Text = "Máu Boss: 0"
healthLabel.BackgroundTransparency = 1
healthLabel.TextColor3 = Color3.new(1, 0, 0)
healthLabel.TextScaled = true

--// Hàm Fram Boss
local angle = 0
RunService.RenderStepped:Connect(function(dt)
    if running then
        local target = getNearestBoss()
        if target and char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            angle = angle + dt * speed
            local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
            local targetPos = target.HumanoidRootPart.Position + offset
            root.CFrame = CFrame.new(targetPos, target.HumanoidRootPart.Position)

            -- Cập nhật hiển thị máu
            healthLabel.Text = "Máu Boss: " .. math.floor(target.Humanoid.Health)
        end
    end
end)

--// Bật/Tắt Script
toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    toggleBtn.Text = running and "Tắt Fram Boss" or "Bật Fram Boss"
    healthLabel.Visible = running
end)