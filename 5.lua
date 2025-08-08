--[[
Script GUI Fram NPC + Di chuyển tự nhiên bằng MoveTo
Khi đến gần mục tiêu sẽ dùng TweenService chạy vòng quanh
Tương thích KRNL Mobile
Menu tên: Nghia Minh
--]]

-- Tạo GUI đơn giản
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 180)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local StartButton = Instance.new("TextButton", Frame)
StartButton.Size = UDim2.new(1, 0, 0, 40)
StartButton.Position = UDim2.new(0, 0, 0, 0)
StartButton.Text = "Bật Fram NPC"
StartButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Cài đặt
local radius = 8 -- bán kính chạy vòng quanh mục tiêu
local speed = 5 -- tốc độ chạy vòng
local active = false
local isNear = false

-- Tìm NPC gần nhất tên chứa "CityNpc"
function getNearestNPC()
    local nearest
    local shortest = math.huge
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc.Name:lower():find("citynpc") then
            local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < shortest then
                shortest = dist
                nearest = npc
            end
        end
    end
    return nearest
end

-- Chạy vòng quanh mục tiêu
function runAroundTarget(target)
    coroutine.wrap(function()
        while active and isNear and target and target:FindFirstChild("HumanoidRootPart") do
            for angle = 0, 360, 20 do
                if not active or not isNear then break end
                local radians = math.rad(angle)
                local offset = Vector3.new(math.cos(radians) * radius, 0, math.sin(radians) * radius)
                local goalPos = target.HumanoidRootPart.Position + offset
                local tween = TweenService:Create(hrp, TweenInfo.new((goalPos - hrp.Position).Magnitude / speed), {CFrame = CFrame.new(goalPos, target.HumanoidRootPart.Position)})
                tween:Play()
                tween.Completed:Wait()
            end
        end
    end)()
end

-- Chạy tự nhiên liên tục đến NPC
function moveToTarget(target)
    coroutine.wrap(function()
        while active and target and target:FindFirstChild("HumanoidRootPart") and humanoid do
            local dist = (hrp.Position - target.HumanoidRootPart.Position).Magnitude
            if dist > radius + 3 then
                isNear = false
                humanoid:MoveTo(target.HumanoidRootPart.Position)
                humanoid.MoveToFinished:Wait()
            else
                isNear = true
                runAroundTarget(target)
                break
            end
            wait(0.2)
        end
    end)()
end

-- Auto attack khi gần
function autoAttack(target)
    coroutine.wrap(function()
        while active and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
            if isNear then
                humanoid:Move(Vector3.zero) -- đứng yên
                -- Gửi sự kiện đánh nếu có, ví dụ:
                -- game.ReplicatedStorage.Combat:FireServer(target)
            end
            wait(0.5)
        end
    end)()
end

-- Xử lý nút bật/tắt
StartButton.MouseButton1Click:Connect(function()
    active = not active
    StartButton.Text = active and "Đang Fram..." or "Bật Fram NPC"
    StartButton.BackgroundColor3 = active and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(0, 170, 0)

    if active then
        coroutine.wrap(function()
            while active do
                local target = getNearestNPC()
                if target then
                    moveToTarget(target)
                    autoAttack(target)
                    while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and active do
                        wait(0.5)
                    end
                end
                wait(1)
            end
        end)()
    end
end)