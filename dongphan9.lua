-- Script HOÀN CHỈNH với các tính năng:
-- - Auto đánh, aim, chạy vòng mục tiêu
-- - Noclip, GUI menu bật/tắt
-- - Hiển thị máu mục tiêu
-- - Hiển thị vùng sát thương (khối đỏ) với nút bật/tắt và ô chỉnh kích thước

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NghiaMinh"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 500)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundTransparency = 0.3
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0

local function createButton(text, y)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    return btn
end

local function createInput(labelText, default, y)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, y)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(1, -10, 0, 25)
    input.Position = UDim2.new(0, 5, 0, y+20)
    input.Text = default
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.ClearTextOnFocus = false
    return input
end

local follow = false
local attack = false
local autoaim = false
local noclip = false
local showhp = true
local clicking = false
local bigHitbox = false

local speedBox = createInput("Tốc độ chạy vòng", "6", 5)
local distanceBox = createInput("Khoảng cách với mục tiêu", "10", 60)

local followBtn = createButton("Chạy Vòng [OFF]", 110)
followBtn.MouseButton1Click:Connect(function()
    follow = not follow
    followBtn.Text = "Chạy Vòng [" .. (follow and "ON" or "OFF") .. "]"
end)

local attackBtn = createButton("Auto Đánh [OFF]", 150)
attackBtn.MouseButton1Click:Connect(function()
    clicking = not clicking
    attackBtn.Text = "Auto Đánh [" .. (clicking and "ON" or "OFF") .. "]"
end)

local aimBtn = createButton("Auto Aim [OFF]", 190)
aimBtn.MouseButton1Click:Connect(function()
    autoaim = not autoaim
    aimBtn.Text = "Auto Aim [" .. (autoaim and "ON" or "OFF") .. "]"
end)

local noclipBtn = createButton("Noclip [OFF]", 230)
noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = "Noclip [" .. (noclip and "ON" or "OFF") .. "]"
end)

local bigHitboxBtn = createButton("Vùng Sát Thương Lớn [OFF]", 270)
bigHitboxBtn.MouseButton1Click:Connect(function()
    bigHitbox = not bigHitbox
    bigHitboxBtn.Text = "Vùng Sát Thương Lớn [" .. (bigHitbox and "ON" or "OFF") .. "]"
end)

local hitboxScaleBox = createInput("Kích Thước Vùng Đánh", "3", 310)

-- Auto Attack (fix cảm ứng)
spawn(function()
    while true do
        task.wait(0.15)
        if clicking then
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end)

-- Auto Aim
spawn(function()
    while true do
        task.wait(0.1)
        if autoaim then
            local nearest = nil
            local dist = math.huge
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= char then
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if root and v.Humanoid.Health > 0 then
                        local d = (root.Position - hrp.Position).Magnitude
                        if d < dist then
                            dist = d
                            nearest = root
                        end
                    end
                end
            end
            if nearest then
                hrp.CFrame = CFrame.new(hrp.Position, nearest.Position)
            end
        end
    end
end)

-- Noclip
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- Di chuyển vòng quanh mục tiêu
spawn(function()
    while true do
        task.wait()
        if follow then
            local nearest = nil
            local dist = math.huge
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= char then
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if root and v.Humanoid.Health > 0 then
                        local d = (root.Position - hrp.Position).Magnitude
                        if d < dist then
                            dist = d
                            nearest = root
                        end
                    end
                end
            end
            if nearest then
                local speed = tonumber(speedBox.Text) or 6
                local radius = tonumber(distanceBox.Text) or 10
                local t = tick() * speed
                local offset = Vector3.new(math.cos(t), 0, math.sin(t)) * radius
                local targetPos = nearest.Position + offset
                humanoid:MoveTo(targetPos)
            end
        end
    end
end)

-- Hiển thị máu mục tiêu
local hpText = Instance.new("TextLabel", frame)
hpText.Size = UDim2.new(1, -10, 0, 25)
hpText.Position = UDim2.new(0, 5, 0, 450)
hpText.Text = "Máu: N/A"
hpText.TextColor3 = Color3.new(1,1,1)
hpText.BackgroundTransparency = 1

spawn(function()
    while true do
        task.wait(0.2)
        if showhp then
            local nearest = nil
            local dist = math.huge
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= char then
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if root and v.Humanoid.Health > 0 then
                        local d = (root.Position - hrp.Position).Magnitude
                        if d < dist then
                            dist = d
                            nearest = v
                        end
                    end
                end
            end
            if nearest then
                hpText.Text = "Máu: " .. math.floor(nearest:FindFirstChild("Humanoid").Health)
            else
                hpText.Text = "Máu: N/A"
            end
        end
    end
end)

-- Hiển thị vùng sát thương
spawn(function()
    while true do
        task.wait(1)
        local scale = tonumber(hitboxScaleBox.Text) or 3
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                local handle = v.Handle
                local existing = handle:FindFirstChild("BoxAdornment")
                if bigHitbox then
                    if not existing then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "BoxAdornment"
                        box.Adornee = handle
                        box.Size = handle.Size * scale
                        box.Color3 = Color3.new(1, 0, 0)
                        box.Transparency = 0.5
                        box.AlwaysOnTop = true
                        box.ZIndex = 5
                        box.Parent = handle
                    else
                        existing.Size = handle.Size * scale
                    end
                else
                    if existing then existing:Destroy() end
                end
            end
        end
    end
end)