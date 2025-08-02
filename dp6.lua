-- TT:dongphandzs1 Fram Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

local radius = 10
local speed = 5
local fram = false
local guiVisible = true
local currentTarget = nil

-- GUI
local screengui = Instance.new("ScreenGui", game.CoreGui)
screengui.Name = "FramMenu"
local frame = Instance.new("Frame", screengui)
frame.Size = UDim2.new(0, 260, 0, 220)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "TT:dongphandzs1"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- Fram Toggle
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Text = "Bật Fram"
toggle.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 18

-- Khoảng cách
local radiusLabel = Instance.new("TextLabel", frame)
radiusLabel.Position = UDim2.new(0, 10, 0, 80)
radiusLabel.Size = UDim2.new(0, 120, 0, 25)
radiusLabel.Text = "Khoảng cách:"

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Position = UDim2.new(0, 130, 0, 80)
radiusBox.Size = UDim2.new(0, 100, 0, 25)
radiusBox.Text = tostring(radius)

-- Tốc độ
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Position = UDim2.new(0, 10, 0, 110)
speedLabel.Size = UDim2.new(0, 120, 0, 25)
speedLabel.Text = "Tốc độ quay:"

local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 130, 0, 110)
speedBox.Size = UDim2.new(0, 100, 0, 25)
speedBox.Text = tostring(speed)

-- Toggle GUI
local toggleGUI = Instance.new("TextButton", frame)
toggleGUI.Size = UDim2.new(1, -20, 0, 25)
toggleGUI.Position = UDim2.new(0, 10, 0, 180)
toggleGUI.Text = "Ẩn/Hiện Menu"
toggleGUI.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleGUI.TextColor3 = Color3.new(1, 1, 1)

-- Hiển thị máu mục tiêu
local healthLabel = Instance.new("TextLabel", frame)
healthLabel.Position = UDim2.new(0, 10, 0, 150)
healthLabel.Size = UDim2.new(1, -20, 0, 25)
healthLabel.Text = "Máu mục tiêu: ..."
healthLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
healthLabel.Font = Enum.Font.SourceSansBold
healthLabel.TextScaled = true

-- Tìm NPC gần nhất (mọi tên)
local function getClosestNPC()
    local closest
    local shortest = math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            local dist = (hrp.Position - v.HumanoidRootPart.Position).Magnitude
            if dist < shortest and v:FindFirstChildOfClass("Humanoid").Health > 0 then
                shortest = dist
                closest = v
            end
        end
    end
    return closest
end

-- Auto Fram
spawn(function()
    while true do
        task.wait()
        if fram then
            radius = tonumber(radiusBox.Text) or 10
            speed = tonumber(speedBox.Text) or 5

            currentTarget = getClosestNPC()
            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                local angle = 0
                repeat
                    task.wait()
                    if not fram or not currentTarget or not currentTarget:FindFirstChild("HumanoidRootPart") then break end
                    local pos = currentTarget.HumanoidRootPart.Position
                    angle += math.rad(speed)
                    local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                    local targetPos = pos + offset
                    hrp.CFrame = CFrame.new(targetPos, pos)

                    -- Auto attack (nếu có công cụ cận chiến)
                    local tool = lp.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        tool:Activate()
                    end

                    -- Cập nhật máu
                    if currentTarget:FindFirstChild("Humanoid") then
                        local hp = math.floor(currentTarget.Humanoid.Health)
                        local max = math.floor(currentTarget.Humanoid.MaxHealth)
                        healthLabel.Text = "Máu mục tiêu: " .. hp .. "/" .. max
                    end
                until currentTarget.Humanoid.Health <= 0 or not fram
            end
        end
    end
end)

-- Nút bật/tắt fram
toggle.MouseButton1Click:Connect(function()
    fram = not fram
    toggle.Text = fram and "Tắt Fram" or "Bật Fram"
end)

-- Nút bật/tắt hiển thị menu
toggleGUI.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    for _, v in pairs(frame:GetChildren()) do
        if v ~= title and v ~= toggleGUI then
            v.Visible = guiVisible
        end
    end
end)