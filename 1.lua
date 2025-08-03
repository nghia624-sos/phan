-- GUI Fram quanh mục tiêu hiện tại, có auto đánh, quay mặt và hiển thị máu
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Tạo GUI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "TT_dongphandzs1"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 220)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Toggle
local enabled = false
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Text = "Bật: Chạy vòng + Đánh + Aim"
toggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 16

-- Khoảng cách
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0.45, -5, 0, 30)
radiusBox.Position = UDim2.new(0.05, 0, 0, 80)
radiusBox.PlaceholderText = "Khoảng cách"
radiusBox.Text = "10"
radiusBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.TextSize = 14

-- Tốc độ
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0.45, -5, 0, 30)
speedBox.Position = UDim2.new(0.5, 5, 0, 80)
speedBox.PlaceholderText = "Tốc độ"
speedBox.Text = "2"
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 14

-- Label hiển thị máu mục tiêu
local healthLabel = Instance.new("TextLabel", frame)
healthLabel.Size = UDim2.new(1, -20, 0, 30)
healthLabel.Position = UDim2.new(0, 10, 0, 120)
healthLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
healthLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
healthLabel.Font = Enum.Font.SourceSansBold
healthLabel.TextSize = 16
healthLabel.Text = "Máu: --"

-- Target người dùng set thủ công
local currentTarget = nil
-- Bạn tự set bằng lệnh như:
-- currentTarget = workspace:FindFirstChild("Tên NPC") hoặc gán bằng code bên ngoài

-- Hàm quay vòng
local function rotateAroundTarget(target, radius, speed)
    local angle = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not enabled or not target or not target:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
            healthLabel.Text = "Máu: --"
            return
        end
        angle += dt * speed
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
        local newPos = target.HumanoidRootPart.Position + offset
        hrp.CFrame = CFrame.new(newPos, target.HumanoidRootPart.Position)

        -- Auto aim + đánh
        local tool = lp.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            pcall(function()
                tool:Activate()
            end)
        end

        -- Hiển thị máu mục tiêu
        local hum = target:FindFirstChildOfClass("Humanoid")
        if hum then
            healthLabel.Text = "Máu: " .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
        end
    end)
end

-- Bật nút
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "Đã BẬT" or "Bật: Chạy vòng + Đánh + Aim"

    if enabled then
        if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
            local radius = tonumber(radiusBox.Text) or 10
            local speed = tonumber(speedBox.Text) or 2
            rotateAroundTarget(currentTarget, radius, speed)
        else
            toggle.Text = "Lỗi: Chưa có mục tiêu"
            enabled = false
        end
    end
end)

-- Gợi ý cho bạn test:
-- Gán thủ công mục tiêu bạn muốn fram:
task.wait(3)
currentTarget = workspace:FindFirstChild("CityNPC1") -- đổi tên đúng với NPC bạn muốn fram