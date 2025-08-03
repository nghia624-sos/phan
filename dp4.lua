-- ROBLOX SCRIPT: Nghia Minh Fram NPC + Chạy vòng quanh + Tăng Hitbox
-- Tương thích KRNL Mobile, giữ nguyên mọi tính năng

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")
local mouse = lp:GetMouse()

local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "NghiaMinh"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 540) -- Chiều cao menu dài hơn
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

function createLabel(txt)
    local lbl = Instance.new("TextLabel")
    lbl.Text = txt
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 16
    lbl.Parent = frame
end

function createToggle(txt, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.Text = txt .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(function()
        local on = btn.Text:find("OFF") ~= nil
        btn.Text = txt .. ": " .. (on and "ON" or "OFF")
        callback(not on)
    end)
    btn.Parent = frame
end

function createInput(txt, default, callback)
    createLabel(txt)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 25)
    box.Text = tostring(default)
    box.BackgroundColor3 = Color3.fromRGB(60,60,60)
    box.TextColor3 = Color3.new(1,1,1)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.SourceSans
    box.TextSize = 16
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) end
    end)
    box.Parent = frame
end

-- Các biến chính
local run = false
local spin = false
local radius = 10
local speed = 5
local hitX, hitY, hitZ = 4, 4, 4
local showHitbox = false
local target

-- Tìm mục tiêu gần nhất
function getTarget()
    local near, dist = nil, math.huge
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") then
            local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                near = v
            end
        end
    end
    return near
end

-- Vòng quanh + auto đánh
RunService.Heartbeat:Connect(function()
    if run then
        if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then
            target = getTarget()
        end
        if target then
            local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
            if dist > radius+2 then
                hum:MoveTo(target.HumanoidRootPart.Position)
            elseif spin then
                local t = tick()
                local offset = Vector3.new(math.cos(t*speed)*radius, 0, math.sin(t*speed)*radius)
                local pos = target.HumanoidRootPart.Position + offset
                hum:MoveTo(pos)
                hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
            end
            -- auto attack
            mouse1press()
            wait(0.1)
            mouse1release()
        end
    end
end)

-- Hitbox handle
RunService.RenderStepped:Connect(function()
    if showHitbox then
        for _,v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("Part") and v.Name == "Handle" then
                if not v:FindFirstChild("HITBOX") then
                    local box = Instance.new("BoxHandleAdornment", v)
                    box.Name = "HITBOX"
                    box.Size = Vector3.new(hitX, hitY, hitZ)
                    box.Adornee = v
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Transparency = 0.5
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                else
                    v.HITBOX.Size = Vector3.new(hitX, hitY, hitZ)
                end
            end
        end
    else
        for _,v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("Part") and v:FindFirstChild("HITBOX") then
                v.HITBOX:Destroy()
            end
        end
    end
end)

-- GUI
createLabel("TT: dongphandzs1")
createToggle("Bật Fram", function(on) run = on end)
createToggle("Chạy vòng quanh + auto đánh", function(on) spin = on end)
createToggle("Hiện vùng sát thương (Hitbox)", function(on) showHitbox = on end)
createInput("Khoảng cách chạy vòng", radius, function(v) radius = v end)
createInput("Tốc độ quay vòng", speed, function(v) speed = v end)
createInput("Hitbox X", hitX, function(v) hitX = v end)
createInput("Hitbox Y", hitY, function(v) hitY = v end)
createInput("Hitbox Z", hitZ, function(v) hitZ = v end)