local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local framEnabled = false
local runTween = nil
local currentNPC = nil

local function getCharacter()
    local chr = lp.Character or lp.CharacterAdded:Wait()
    local hrp = chr:WaitForChild("HumanoidRootPart", 5)
    local hum = chr:WaitForChild("Humanoid", 5)
    if hrp and hum then
        return chr, hrp, hum
    end
    return nil
end

local function getClosestTarget()
    local npcs = workspace:GetDescendants()
    local closest = nil
    local minDist = math.huge
    local chr, hrp = getCharacter()
    if not hrp then return nil end

    for _, npc in ipairs(npcs) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
            local name = npc.Name:lower()
            if string.find(name, "citynpc") or string.find(name, "npcity") then
                local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

local function stopTween()
    if runTween then
        runTween:Cancel()
        runTween = nil
    end
end

local function moveToTarget(npc)
    local chr, hrp, hum = getCharacter()
    if not hrp or not npc or not npc:FindFirstChild("HumanoidRootPart") then return end

    stopTween()

    local goal = npc.HumanoidRootPart.Position + Vector3.new(0, 0, -5)
    local dist = (goal - hrp.Position).Magnitude
    local tweenInfo = TweenInfo.new(dist / 16, Enum.EasingStyle.Linear)
    runTween = TweenService:Create(hrp, tweenInfo, {Position = goal})
    runTween:Play()
end

local function runFram()
    spawn(function()
        while framEnabled do
            local chr, hrp, hum = getCharacter()
            if not hrp then task.wait(1) continue end

            currentNPC = getClosestTarget()
            if currentNPC then
                moveToTarget(currentNPC)
                
                repeat
                    task.wait(0.2)
                until (hrp.Position - currentNPC.HumanoidRootPart.Position).Magnitude < 10 or not framEnabled

                -- Khi đến gần thì bắt đầu chạy vòng quanh
                if framEnabled then
                    local angle = 0
                    while framEnabled and currentNPC and currentNPC:FindFirstChild("HumanoidRootPart") do
                        local pos = currentNPC.HumanoidRootPart.Position
                        local radius = 10
                        angle += math.rad(5)
                        local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                        hrp.CFrame = CFrame.new(pos + offset, pos)
                        task.wait(0.03)
                    end
                end
            else
                task.wait(1)
            end
        end
        stopTween()
    end)
end

-- Bật/tắt Fram
_G.ToggleFram = function()
    framEnabled = not framEnabled
    if framEnabled then
        runFram()
    else
        stopTween()
    end
end