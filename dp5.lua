-- MENU TỰ ĐỘNG CHẠY VÒNG + AUTO ĐÁNH (GIỮ TẤT CẢ TÍNH NĂNG CŨ)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- TÌM NPC GẦN NHẤT THEO TÊN CHỨA 'CityNPC' hoặc 'NPCity'
local function getClosestNPC()
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local name = v.Name:lower()
            if name:find("citynpc") or name:find("npcity") then
                local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v
                end
            end
        end
    end
    return closest
end

-- GUI MENU
local ScreenGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ScreenGui.Name = "NghiaMinh"
local Frame = Instance.new("Frame", ScreenGui)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Size = UDim2.new(0, 260, 0, 400)
Frame.Position = UDim2.new(0, 20, 0.2, 0)
Frame.Active = true
Frame.Draggable = true

local function createLabel(text, pos)
    local lbl = Instance.new("TextLabel", Frame)
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Position = UDim2.new(0, 0, 0, pos)
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    return lbl
end

local function createToggle(text, pos, default, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
    return btn
end

local function createBox(text, pos, default, callback)
    createLabel(text, pos - 25)
    local box = Instance.new("TextBox", Frame)
    box.Size = UDim2.new(1, 0, 0, 30)
    box.Position = UDim2.new(0, 0, 0, pos)
    box.BackgroundColor3 = Color3.fromRGB(60,60,60)
    box.TextColor3 = Color3.new(1,1,1)
    box.Text = tostring(default)
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) end
    end)
    return box
end

-- CÁC BIẾN
local autoRunCircle = false
local radius, speed = 15, 30
local hitboxX, hitboxY, hitboxZ = 10, 10, 10
local showHitbox = false

-- TỰ ĐỘNG CHẠY VÒNG QUANH NPC
local currentTarget, connection
local function runCircle()
    if connection then connection:Disconnect() end
    connection = RunService.Heartbeat:Connect(function()
        if not autoRunCircle then return end
        currentTarget = getClosestNPC()
        if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
            local targetPos = currentTarget.HumanoidRootPart.Position
            local angle = tick() * (speed/10)
            local offset = Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
            local nextPos = targetPos + offset
            local moveTween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(nextPos, targetPos)})
            moveTween:Play()
            hum:MoveTo(nextPos)
        end
    end)
end

-- VÙNG GÂY SÁT THƯƠNG (HITBOX HANDLE)
local hitboxPart
local function updateHitbox()
    if not showHitbox then
        if hitboxPart then hitboxPart:Destroy() hitboxPart = nil end
        return
    end
    local tool = chr:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        local handle = tool.Handle
        if not hitboxPart then
            hitboxPart = Instance.new("Part")
            hitboxPart.Anchored = false
            hitboxPart.CanCollide = false
            hitboxPart.Transparency = 0.4
            hitboxPart.Color = Color3.new(1,0,0)
            hitboxPart.Material = Enum.Material.Neon
            hitboxPart.Name = "HitboxDisplay"
            hitboxPart.Parent = handle
        end
        hitboxPart.Size = Vector3.new(hitboxX, hitboxY, hitboxZ)
        hitboxPart.CFrame = handle.CFrame
    end
end

RunService.RenderStepped:Connect(updateHitbox)

-- TẠO MENU
createToggle("Chạy vòng quanh + auto đánh", 10, false, function(state)
    autoRunCircle = state
    if state then
        runCircle()
    end
end)

createToggle("Hiện vùng sát thương (Hitbox)", 45, false, function(state)
    showHitbox = state
end)

createBox("Khoảng cách chạy vòng", 105, radius, function(v) radius = v end)
createBox("Tốc độ quay vòng", 160, speed, function(v) speed = v end)
createBox("Hitbox X", 215, hitboxX, function(v) hitboxX = v end)
createBox("Hitbox Y", 270, hitboxY, function(v) hitboxY = v end)
createBox("Hitbox Z", 325, hitboxZ, function(v) hitboxZ = v end)

-- TỰ ĐỘNG HƯỚNG MẶT VỀ MỤC TIÊU
RunService.Heartbeat:Connect(function()
    if autoRunCircle and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
        local lookPos = currentTarget.HumanoidRootPart.Position
        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(lookPos.X, hrp.Position.Y, lookPos.Z))
    end
end)