-- Khởi tạo GUI
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoFarmGui"

local frame = Instance.new("Frame", gui)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 50, 0, 100)
frame.Active = true
frame.Draggable = true

local function createBtn(name, yPos)
    local btn = Instance.new("TextButton", frame)
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    return btn
end

local toggleFarm = false
local attackDistance = 10
local moveSpeed = 5
local spinRadius = 15

-- Menu nút điều chỉnh
local toggleBtn = createBtn("Bật/Tắt Quay Vòng", 0)
local upBtn = createBtn("↑ Lên", 40)
local downBtn = createBtn("↓ Xuống", 80)
local leftBtn = createBtn("← Trái", 120)
local rightBtn = createBtn("→ Phải", 160)

toggleBtn.MouseButton1Click:Connect(function()
    toggleFarm = not toggleFarm
    toggleBtn.Text = toggleFarm and "Đang Quay Vòng" or "Bật/Tắt Quay Vòng"
end)

-- Dịch chuyển giao diện
upBtn.MouseButton1Click:Connect(function()
    frame.Position = frame.Position - UDim2.new(0, 0, 0, 20)
end)
downBtn.MouseButton1Click:Connect(function()
    frame.Position = frame.Position + UDim2.new(0, 0, 0, 20)
end)
leftBtn.MouseButton1Click:Connect(function()
    frame.Position = frame.Position - UDim2.new(0, 20, 0, 0)
end)
rightBtn.MouseButton1Click:Connect(function()
    frame.Position = frame.Position + UDim2.new(0, 20, 0, 0)
end)

-- Hàm tìm mục tiêu gần nhất
local function getNearestTarget()
    local nearest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= char then
            local h = v.Humanoid
            if h.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    nearest, dist = v, d
                end
            end
        end
    end
    return nearest
end

-- Hàm đánh
local function attack(target)
    if target and target:FindFirstChild("Humanoid") then
        humanoid:MoveTo(target.HumanoidRootPart.Position) -- moveTo nhẹ
        target.Humanoid:TakeDamage(1) -- Nếu game cho phép đánh qua TakeDamage (tùy game)
    end
end

-- Quay vòng
task.spawn(function()
    while true do task.wait()
        if toggleFarm then
            local target = getNearestTarget()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local tPos = target.HumanoidRootPart.Position
                local time = tick()
                local angle = time * moveSpeed
                local offset = Vector3.new(math.cos(angle) * spinRadius, 0, math.sin(angle) * spinRadius)
                local movePos = tPos + offset
                humanoid:MoveTo(movePos)

                -- Hướng mặt vào mục tiêu
                local lookVec = (tPos - hrp.Position).Unit
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(lookVec.X, 0, lookVec.Z))

                -- Nếu trong tầm thì đánh
                if (tPos - hrp.Position).Magnitude <= attackDistance then
                    attack(target)
                end
            end
        end
    end
end)