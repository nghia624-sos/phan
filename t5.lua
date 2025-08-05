local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- Biến
local radius = 20
local speed = 2
local running = false
local autoAttack = false
local currentTarget = nil
local lowGraphics = false -- Biến để bật/tắt đồ họa thấp

-- GUI chính
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "Menu_TT"
gui.Enabled = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 270)
frame.Position = UDim2.new(0.5, -150, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- Tab 1: Điều khiển đánh Boss
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "BẬT: Đánh Boss"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)

local disLabel = Instance.new("TextLabel", frame)
disLabel.Text = "Khoảng cách:"
disLabel.Size = UDim2.new(0, 150, 0, 30)
disLabel.Position = UDim2.new(0, 10, 0, 50)
disLabel.TextColor3 = Color3.new(1,1,1)
disLabel.BackgroundTransparency = 1

local disInput = Instance.new("TextBox", frame)
disInput.Size = UDim2.new(0, 100, 0, 30)
disInput.Position = UDim2.new(0, 160, 0, 50)
disInput.Text = tostring(radius)
disInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
disInput.TextColor3 = Color3.new(1,1,1)

local spdLabel = Instance.new("TextLabel", frame)
spdLabel.Text = "Tốc độ quay:"
spdLabel.Size = UDim2.new(0, 150, 0, 30)
spdLabel.Position = UDim2.new(0, 10, 0, 90)
spdLabel.TextColor3 = Color3.new(1,1,1)
spdLabel.BackgroundTransparency = 1

local spdInput = Instance.new("TextBox", frame)
spdInput.Size = UDim2.new(0, 100, 0, 30)
spdInput.Position = UDim2.new(0, 160, 0, 90)
spdInput.Text = tostring(speed)
spdInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spdInput.TextColor3 = Color3.new(1,1,1)

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 130)
hpLabel.Text = "Máu mục tiêu: ..."
hpLabel.TextColor3 = Color3.new(1, 0, 0)
hpLabel.BackgroundTransparency = 1

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, 0, 0, 30)
autoBtn.Position = UDim2.new(0, 0, 0, 170)
autoBtn.Text = "BẬT: Auto Đánh"
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
autoBtn.TextColor3 = Color3.new(1,1,1)

local nameText = Instance.new("TextLabel", frame)
nameText.Size = UDim2.new(1, 0, 0, 30)
nameText.Position = UDim2.new(0, 0, 0, 230)
nameText.Text = "TT:dongphandzs1"
nameText.TextColor3 = Color3.fromRGB(100,255,100)
nameText.BackgroundTransparency = 1
nameText.TextScaled = true

-- Tab 2: Giảm Đồ Họa
local graphicsTab = Instance.new("Frame", gui)
graphicsTab.Size = UDim2.new(0, 300, 0, 200)
graphicsTab.Position = UDim2.new(0, 0, 0, 270)
graphicsTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
graphicsTab.Active = true
graphicsTab.Visible = false

local lowGraphicsBtn = Instance.new("TextButton", graphicsTab)
lowGraphicsBtn.Size = UDim2.new(1, 0, 0, 40)
lowGraphicsBtn.Position = UDim2.new(0, 0, 0, 0)
lowGraphicsBtn.Text = "BẬT: Giảm Đồ Họa"
lowGraphicsBtn.TextColor3 = Color3.new(1,1,1)
lowGraphicsBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Tăng giảm đồ họa
local function toggleLowGraphics()
    lowGraphics = not lowGraphics
    if lowGraphics then
        -- Giảm đồ họa
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1000000
        lighting.Brightness = 1
        lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0

        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v.Transparency = 0.5
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            elseif v:IsA("MeshPart") or v:IsA("Part") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            end
        end

        -- Tắt hiệu ứng nước
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 1
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0

        -- Giảm độ phân giải cây, cỏ, môi trường
        if workspace:FindFirstChild("Terrain") then
            workspace.Terrain.Decorations = false
        end

        -- Giảm chất lượng Render (Client)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        lowGraphicsBtn.Text = "TẮT: Giảm Đồ Họa"
    else
        -- Khôi phục đồ họa
        game:GetService("Lighting").GlobalShadows = true
        game:GetService("Lighting").Brightness = 2
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
        lowGraphicsBtn.Text = "BẬT: Giảm Đồ Họa"
    end
end

lowGraphicsBtn.MouseButton1Click:Connect(toggleLowGraphics)

-- Chức năng tìm mục tiêu và tấn công
local function getTarget()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= chr and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            return v
        end
    end
end

local function attack()
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
end

-- Vòng quay quanh mục tiêu
RunService.Heartbeat:Connect(function()
    if running and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
        if currentTarget.Humanoid.Health <= 0 then
            running = false
            autoAttack = false
            currentTarget = nil
            toggle.Text = "BẬT: Đánh Boss"
            autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
            hpLabel.Text = "Máu mục tiêu: Đã chết"
            return
        end

        local angle = tick() * speed
        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        local goalPos = currentTarget.HumanoidRootPart.Position + offset
        local tween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(goalPos, currentTarget.HumanoidRootPart.Position)})
        tween:Play()
        hum.AutoRotate = false
        hrp.CFrame = CFrame.new(hrp.Position, currentTarget.HumanoidRootPart.Position)

        if autoAttack then attack() end
        hpLabel.Text = "Máu mục tiêu: " .. math.floor(currentTarget.Humanoid.Health)
    elseif running then
        running = false
        autoAttack = false
        currentTarget = nil
        toggle.Text = "BẬT: Đánh Boss"
        autoBtn.Text = "BẬT: Auto Đánh (Riêng)"
        hpLabel.Text = "Máu mục tiêu: Không tìm thấy"
    end
end)

-- Bật tắt chạy vòng
toggle.MouseButton1Click:Connect(function()
    running = not running
    if running then
        currentTarget = getTarget()
    end
    toggle.Text = (running and "TẮT" or "BẬT") .. ": Đánh Boss"
end)

disInput.FocusLost:Connect(function()
    radius = tonumber(disInput.Text) or radius
end)

spdInput.FocusLost:Connect(function()
    speed = tonumber(spdInput.Text) or speed
end)

autoBtn.MouseButton1Click:Connect(function()
    autoAttack = not autoAttack
    autoBtn.Text = (autoAttack and "TẮT" or "BẬT") .. ": Auto Đánh (Riêng)"
end)