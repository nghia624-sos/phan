--// UI SCRIPT WITH PvP TAB 

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "TT:dongphandzs1",
   LoadingTitle = "TT:dongphandzs1 Menu",
   LoadingSubtitle = "by dongphandzs1",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TTdongphandzs1Config",
      FileName = "Settings"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

--// PvE TAB (Fram NPC/Boss)
local PvETab = Window:CreateTab("Fram NPC/BOSS", 4483362458)

-- Giữ nguyên các toggle và sliders cho Fram, Spin, Auto Đánh...
-- (Tạm rút gọn để giữ nội dung chính PvP theo yêu cầu)

--// PvP TAB
local PvPTab = Window:CreateTab("PvP", 4483362458)

-- Toggle: Spin nhân vật liên tục
PvPTab:CreateToggle({
    Name = "Spin Nhân Vật",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().Spin = Value
        while getgenv().Spin and task.wait() do
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0)
            end
        end
    end
})

-- Toggle: Hiển thị Hitbox + Line tới tất cả mục tiêu có thể tấn công
PvPTab:CreateToggle({
    Name = "Hiển thị Hitbox + Line (Tất cả mục tiêu)",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().ShowPvPHitbox = Value
        while getgenv().ShowPvPHitbox and task.wait(0.5) do
            for _, target in pairs(game:GetService("Workspace"):GetDescendants()) do
                if target:IsA("Model") and target:FindFirstChild("Humanoid") and target ~= game.Players.LocalPlayer.Character then
                    local root = target:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Hitbox
                        local box = Instance.new("BoxHandleAdornment", root)
                        box.Size = Vector3.new(5,5,5)
                        box.Transparency = 0.6
                        box.Color3 = Color3.new(1,0,0)
                        box.AlwaysOnTop = true
                        box.ZIndex = 5
                        box.Adornee = root

                        -- Line
                        local line = Instance.new("Beam", root)
                        local at0 = Instance.new("Attachment", game.Players.LocalPlayer.Character.HumanoidRootPart)
                        local at1 = Instance.new("Attachment", root)
                        line.Attachment0 = at0
                        line.Attachment1 = at1
                        line.Color = ColorSequence.new(Color3.new(1, 1, 0))
                        line.FaceCamera = true
                        line.Width0 = 0.1
                        line.Width1 = 0.1

                        game.Debris:AddItem(box, 1)
                        game.Debris:AddItem(line, 1)
                        game.Debris:AddItem(at0, 1)
                        game.Debris:AddItem(at1, 1)
                    end
                end
            end
        end
    end
})

-- Toggle: Silent Attack tất cả mục tiêu
PvPTab:CreateToggle({
    Name = "Silent Attack (toàn bản đồ)",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().SilentAttack = Value
        while getgenv().SilentAttack and task.wait(0.3) do
            local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                for _, target in pairs(game:GetService("Workspace"):GetDescendants()) do
                    if target:IsA("Model") and target:FindFirstChild("Humanoid") and target ~= game.Players.LocalPlayer.Character then
                        local hrp = target:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            tool.Handle.CFrame = hrp.CFrame
                        end
                    end
                end
            end
        end
    end
})