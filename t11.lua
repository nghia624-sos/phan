--// Script Auto Boss + Auto Heal + Equip Weapon lại
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Cấu hình
local bossNameKeyword = "NPC2" -- Tìm mục tiêu chứa chữ này (ko phân biệt hoa/thường)
local circleRadius = 10 -- bán kính chạy vòng
local circleSpeed = 3 -- tốc độ chạy vòng
local healThreshold = 60 -- máu dưới mức này sẽ heal
local healing = false
local equippedWeapon = nil

-- Hàm tìm Boss
local function findBoss()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if string.find(string.lower(v.Name), string.lower(bossNameKeyword)) then
                if v.Humanoid.Health > 0 then
                    return v
                end
            end
        end
    end
    return nil
end

-- Hàm Auto Heal
local function autoHeal()
    if healing then return end
    if hum.Health < healThreshold then
        healing = true
        -- Lưu vũ khí đang cầm
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                equippedWeapon = tool
                break
            end
        end
        -- Lấy băng gạc từ Backpack
        local bandage = nil
        for _, item in ipairs(lp.Backpack:GetChildren()) do
            if string.find(string.lower(item.Name), "bandage") or string.find(string.lower(item.Name), "băng") then
                bandage = item
                break
            end
        end
        if bandage then
            hum:EquipTool(bandage)
            task.wait(0.5)
            -- Giả lập dùng băng gạc (nếu là Tool sẽ click)
            pcall(function() bandage:Activate() end)
            -- Chờ hồi máu xong
            repeat task.wait(0.5) until hum.Health >= healThreshold or bandage.Parent ~= char
        end
        -- Trang bị lại vũ khí cũ
        if equippedWeapon and equippedWeapon.Parent == lp.Backpack then
            hum:EquipTool(equippedWeapon)
        end
        healing = false
    end
end

-- Hàm MoveTo tới Boss
local function moveToTarget(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(hrp.Position, target.HumanoidRootPart.Position)
    path:MoveTo(hrp)
end

-- Hàm chạy vòng quanh Boss
local function circleAround(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local root = target.HumanoidRootPart
    local angle = 0
    while target.Humanoid.Health > 0 do
        autoHeal()
        angle = angle + circleSpeed * RunService.Heartbeat:Wait()
        local offset = Vector3.new(math.cos(angle) * circleRadius, 0, math.sin(angle) * circleRadius)
        local pos = root.Position + offset
        TweenService:Create(hrp, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos, root.Position)}):Play()
        -- Auto đánh
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool:Activate() end)
            end
        end
    end
end

-- Noclip
RunService.Stepped:Connect(function()
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

-- Chạy chính
task.spawn(function()
    while task.wait(0.5) do
        local boss = findBoss()
        if boss then
            moveToTarget(boss)
            -- Khi đủ gần thì chạy vòng
            repeat
                task.wait(0.1)
                autoHeal()
            until (hrp.Position - boss.HumanoidRootPart.Position).Magnitude <= circleRadius + 5 or boss.Humanoid.Health <= 0
            if boss.Humanoid.Health > 0 then
                circleAround(boss)
            end
        end
    end
end)