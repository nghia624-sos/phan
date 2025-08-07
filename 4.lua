-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cấu hình menu
local Window = Rayfield:CreateWindow({
   Name = "TT:dongphandzs1",
   LoadingTitle = "TT:dongphandzs1 Menu",
   Theme = "Dark",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local FramTab = Window:CreateTab("Fram NPC", "framer")
local SpinTab = Window:CreateTab("Spin", "refresh-ccw")

local FramSection = FramTab:CreateSection("Auto Fram NPC")
local SpinSection = SpinTab:CreateSection("Auto Spin")

-- Thanh điều chỉnh
local radius = 10
local speed = 3
local framActive = false
local spinActive = false

FramSection:CreateSlider({
   Name = "Bán kính",
   Range = {1,50},
   Increment = 1,
   Suffix = "studs",
   CurrentValue = radius,
   Flag = "Radius",
   Callback = function(value) radius = value end
})

FramSection:CreateSlider({
   Name = "Tốc độ quay",
   Range = {1,10},
   Increment = 0.5,
   Suffix = "",
   CurrentValue = speed,
   Flag = "Speed",
   Callback = function(value) speed = value end
})

FramSection:CreateToggle({
   Name = "Bật Fram",
   CurrentValue = framActive,
   Flag = "FramToggle",
   Callback = function(val)
      framActive = val
      if framActive then task.spawn(startFram) end
   end
})

SpinSection:CreateToggle({
   Name = "Bật Spin",
   CurrentValue = spinActive,
   Flag = "SpinToggle",
   Callback = function(val) spinActive = val end
})

-- Các hàm core
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local currentTarget = nil

function faceTarget(target)
   local pos = target.HumanoidRootPart.Position
   local look = (pos - HRP.Position).Unit
   HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + look)
end

function runAround(target)
   local angle = 0
   while framActive and target and target.Humanoid.Health > 0 do
      local pos = target.HumanoidRootPart.Position
      angle += speed * RunService.Heartbeat:Wait()
      local offset = Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
      local goal = pos + offset
      local tween = TweenService:Create(HRP, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(goal)})
      tween:Play()
      faceTarget(target)
      task.wait(0.1)
   end
end

function autoAttackLoop()
   while framActive and currentTarget and currentTarget.Humanoid.Health > 0 do
      VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
      task.wait(0.1)
      VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
      task.wait(0.2)
   end
end

function getNearestCityNPC()
   local nearest, dist = nil, math.huge
   for _, v in ipairs(workspace:GetDescendants()) do
      if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
         if string.match(string.lower(v.Name),"citynpc") and v.Humanoid.Health > 0 then
            local d = (v.HumanoidRootPart.Position - HRP.Position).Magnitude
            if d < dist then dist, nearest = d, v end
         end
      end
   end
   return nearest
end

function collectItemsAround(pos)
   for _, item in ipairs(workspace:GetDescendants()) do
      if (item:IsA("Part") or item:IsA("Tool")) and item:FindFirstChild("Position") then
         local ip = item.Position
         if (ip - pos).Magnitude <= (radius*2) then
            hum:MoveTo(ip)
            task.wait(0.3)
         end
      end
   end
end

function startFram()
   while framActive do
      currentTarget = getNearestCityNPC()
      if currentTarget and currentTarget.Humanoid.Health > 0 then
         hum:MoveTo(currentTarget.HumanoidRootPart.Position)
         repeat task.wait() until not framActive or (HRP.Position - currentTarget.HumanoidRootPart.Position).Magnitude < radius
         task.spawn(autoAttackLoop)
         runAround(currentTarget)
         if currentTarget.Humanoid.Health <= 0 then
            collectItemsAround(currentTarget.HumanoidRootPart.Position)
         end
      else
         task.wait(1)
      end
   end
end

-- Spin logic
task.spawn(function()
   while task.wait(0.05) do
      if spinActive then
         HRP.CFrame *= CFrame.Angles(0, math.rad(15), 0)
      end
   end
end)