-- ROBLOX SCRIPT MENU: TT:dongphandzs1
-- Menu Fram NPC với tùy chỉnh bán kính và tốc độ bằng ô nhập số

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hrp = chr:WaitForChild("HumanoidRootPart")
local hum = chr:WaitForChild("Humanoid")

local running = false
local noclip = false
local radius = 10
local speed = 5
local framLoop = false
local currentTarget = nil
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "FramGui"
ui.ResetOnSpawn = false

-- Draggable frame
local frame = Instance.new("Frame", ui)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Position = UDim2.new(0.02, 0, 0.2, 0)
frame.Size = UDim2.new(0, 200, 0, 320)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "TT:dongphandzs1"
title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- BUTTON FUNCTION CREATOR
local function createButton(text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(callback)
end

local function createInput(text, default, parent, onChanged)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14

    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -10, 0, 30)
    box.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    box.Text = tostring(default)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    box.TextColor3 = Color3.new(1,1,1)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.SourceSans
    box.TextSize = 16
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            onChanged(num)
        end
    end)
end

createButton("Bật Fram", frame, function()
    running = true
    framLoop = true
end)

createButton("Tắt Fram", frame, function()
    running = false
    framLoop = false
end)

createButton("Noclip ON/OFF", frame, function()
    noclip = not noclip
end)

createInput("Bán kính vòng (radius)", radius, frame, function(val)
    radius = val
end)

createInput("Tốc độ vòng (speed)", speed, frame, function(val)
    speed = val
end)

-- Noclip
game:GetService("RunService").Stepped:Connect(function()
    if noclip and chr and hum then
        for _, v in pairs(chr:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- Tìm NPC gần nhất
local function getNearestNPC()
    local minDist = math.huge
    local target = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr then
            local name = v.Name:lower()
            if name:find("citynpc") or name:find("npcity") then
                local root = v:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - hrp.Position).magnitude
                    if dist < minDist then
                        minDist = dist
                        target = v
                    end
                end
            end
        end
    end
    return target
end

-- Di chuyển tự nhiên
local function moveToTarget(pos)
    hum:MoveTo(pos)
    hum.MoveToFinished:Wait()
end

-- Auto aim và đánh
local function faceAndAttack(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
        local tool = chr:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            pcall(function()
                tool:Activate()
            end)
        end
    end
end

-- Chạy vòng quanh mục tiêu
local function runAround(target)
    local angle = 0
    while running and target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
        angle += speed * 0.03
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
        local targetPos = target.HumanoidRootPart.Position + offset + Vector3.new(0, 1, 0)
        hum:MoveTo(targetPos)
        faceAndAttack(target)
        task.wait(0.03)
    end
end

-- Fram vòng lặp
spawn(function()
    while true do
        task.wait(0.5)
        if running then
            currentTarget = getNearestNPC()
            if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                local root = currentTarget.HumanoidRootPart
                local distance = (hrp.Position - root.Position).Magnitude
                if distance > radius + 2 then
                    moveToTarget(root.Position)
                end
                if running and currentTarget:FindFirstChild("Humanoid") then
                    runAround(currentTarget)
                end
            end
        end
    end
end)