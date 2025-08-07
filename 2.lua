-- ✅ Giao diện Rayfield UI cho auto fram
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- ⚙️ Biến điều khiển
local framActive = false
local spinActive = false
local autoAttackActive = false
local currentTarget = nil
local radius = 10
local speed = 3

-- 🧩 Giao diện Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TT:dongphandzs1",
   LoadingTitle = "Đang khởi động GUI",
   LoadingSubtitle = "Đông Phan",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TTdongphandzs1",
      FileName = "Config"
   },
   Discord = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Auto Fram", 4483362458)

Tab:CreateToggle({
   Name = "Bật Fram",
   CurrentValue = false,
   Callback = function(Value)
      framActive = Value
      if framActive then
         task.spawn(startFram)
      end
   end,
})

Tab:CreateToggle({
   Name = "Bật Spin",
   CurrentValue = false,
   Callback = function(Value)
      spinActive = Value
   end,
})

Tab:CreateToggle({
   Name = "Tự Động Đánh",
   CurrentValue = false,
   Callback = function(Value)
      autoAttackActive = Value
   end,
})

Tab:CreateSlider({
   Name = "Bán kính",
   Range = {5, 30},
   Increment = 1,
   Suffix = "m",
   CurrentValue = 10,
   Callback = function(Value)
      radius = Value
   end,
})

Tab:CreateSlider({
   Name = "Tốc độ",
   Range = {1, 30},
   Increment = 1,
   Suffix = "x",
   CurrentValue = 3,
   Callback = function(Value)
      speed = Value
   end,
})

-- 💥 Auto Attack
function autoAttack()
   VirtualInputManager:SendMouseButtonEvent(100, 100, 0, true, game, 0)
   task.wait(0.05)
   VirtualInputManager:SendMouseButtonEvent(100, 100, 0, false, game, 0)
end

function getNearestCityNPC()
   local nearest, shortest = nil, math.huge
   for _, v in ipairs(workspace:GetDescendants()) do
      if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
         if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
            local dist = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
            if dist < shortest then
               shortest, nearest = dist, v
            end
         end
      end
   end
   return nearest
end

function faceTarget(target)
   if target and target:FindFirstChild("HumanoidRootPart") then
      local lookVector = (target.HumanoidRootPart.Position - HRP.Position).Unit
      HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + lookVector)
   end
end

function runAround(target, radius, speed)
   local angle = 0
   while framActive and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
      local targetPos = target.HumanoidRootPart.Position
      angle += speed * RunService.Heartbeat:Wait()
      local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
      local goal = targetPos + offset
      local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal)})
      tween:Play()
      faceTarget(target)
   end
end

function collectItemsAround(pos, radius)
   for _, item in ipairs(workspace:GetDescendants()) do
      if item:IsA("Tool") or item:IsA("Part") then
         if (item.Position - pos).Magnitude < radius then
            hum:MoveTo(item.Position)
            task.wait(0.4)
         end
      end
   end
end

-- 🌀 Spin effect
task.spawn(function()
   while true do
      if spinActive and HRP then
         HRP.CFrame *= CFrame.Angles(0, math.rad(1000), 0)
      end
      task.wait()
   end
end)

function startFram()
   while framActive do
      currentTarget = getNearestCityNPC()
      if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
         hum:MoveTo(currentTarget.HumanoidRootPart.Position)
         repeat task.wait() until not framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < 15
         
         task.spawn(function()
            while framActive and autoAttackActive and currentTarget and currentTarget.Humanoid.Health > 0 do
               autoAttack()
               task.wait(0.3)
            end
         end)

         runAround(currentTarget, radius, speed)

         if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") and currentTarget.Humanoid.Health <= 0 then
            collectItemsAround(currentTarget.HumanoidRootPart.Position, 20)
         end
      else
         task.wait(1)
      end
   end
end