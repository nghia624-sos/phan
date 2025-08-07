local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TT:dongphandzs1",
   LoadingTitle = "Đang khởi động GUI",
   LoadingSubtitle = "by ChatGPT",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TTdongphandzs1",
      FileName = "Config"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

local Tab = Window:CreateTab("Đánh BOSS", 4483362458)

-- ⚙️ Biến điều khiển
local AutoFarm = false
local SpinAround = false
local Radius = 10
local Speed = 5

-- 🟢 Toggle bật fram
Tab:CreateToggle({
   Name = "Bật Fram BOSS",
   CurrentValue = false,
   Callback = function(Value)
      AutoFarm = Value
   end,
})

-- 🌀 Toggle chạy vòng quanh
Tab:CreateToggle({
   Name = "Chạy vòng quanh mục tiêu",
   CurrentValue = false,
   Callback = function(Value)
      SpinAround = Value
   end,
})

-- 📏 Chỉnh bán kính vòng
Tab:CreateSlider({
   Name = "Bán kính chạy vòng",
   Range = {5, 30},
   Increment = 1,
   Suffix = "m",
   CurrentValue = 10,
   Callback = function(Value)
      Radius = Value
   end,
})

-- ⚡ Chỉnh tốc độ quay vòng
Tab:CreateSlider({
   Name = "Tốc độ quay",
   Range = {1, 50},
   Increment = 1,
   Suffix = "speed",
   CurrentValue = 5,
   Callback = function(Value)
      Speed = Value
   end,
})

-- ❤️ Hiển thị máu mục tiêu
local TargetHP = Tab:CreateParagraph({Title = "Máu BOSS", Content = "Chưa có mục tiêu"})

-- 🔁 Vòng lặp chính Fram
task.spawn(function()
   while true do
      task.wait(0.1)
      if AutoFarm then
         local target = nil
         for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("boss") then
               target = v
               break
            end
         end

         if target and target:FindFirstChild("HumanoidRootPart") then
            -- Cập nhật máu
            TargetHP:Set("Máu BOSS: " .. math.floor(target.Humanoid.Health))

            local plr = game.Players.LocalPlayer
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
               local root = char.HumanoidRootPart

               -- Đến gần boss
               local dist = (root.Position - target.HumanoidRootPart.Position).Magnitude
               if dist > Radius + 3 then
                  root.CFrame = root.CFrame:Lerp(CFrame.new(target.HumanoidRootPart.Position + Vector3.new(0, 0, -Radius)), 0.05)
               elseif SpinAround then
                  local angle = tick() * Speed
                  local x = math.cos(angle) * Radius
                  local z = math.sin(angle) * Radius
                  local spinPos = target.HumanoidRootPart.Position + Vector3.new(x, 0, z)
                  root.CFrame = CFrame.new(spinPos, target.HumanoidRootPart.Position)
               end
            end
         else
            TargetHP:Set("Không tìm thấy BOSS")
         end
      end
   end
end)