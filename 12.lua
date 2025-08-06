-- Tải thư viện Rayfield UI
loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Tạo GUI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "TT:dongphandzs1",
    LoadingTitle = "TT:dongphandzs1",
    LoadingSubtitle = "by Nghia",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TT_dongphandzs1",
        FileName = "config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Tạo Tab Đánh BOSS
local MainTab = Window:CreateTab("Đánh BOSS", 4483362458)

-- Bật/Tắt Fram
local ToggleFram = MainTab:CreateToggle({
    Name = "Bật Fram",
    CurrentValue = false,
    Callback = function(Value)
        _G.Fram = Value
        -- logic chạy đến mục tiêu
    end,
})

-- Chạy vòng quanh + auto đánh
local ToggleCircle = MainTab:CreateToggle({
    Name = "Chạy vòng quanh + Auto đánh",
    CurrentValue = false,
    Callback = function(Value)
        _G.VongQuanh = Value
        -- logic chạy vòng quanh mục tiêu
    end,
})

-- Hiển thị máu mục tiêu
local TargetHP = MainTab:CreateParagraph({Title = "Máu Mục Tiêu", Content = "Chưa tìm thấy mục tiêu"})

-- Cập nhật máu liên tục
task.spawn(function()
    while true do
        task.wait(1)
        local target = --[[ tìm mục tiêu của bạn ]]
        if target and target:FindFirstChild("Humanoid") then
            TargetHP:Set("Máu Mục Tiêu: " .. math.floor(target.Humanoid.Health))
        else
            TargetHP:Set("Chưa tìm thấy mục tiêu")
        end
    end
end)

-- Tốc độ quay + khoảng cách
MainTab:CreateInput({
    Name = "Tốc độ quay vòng",
    PlaceholderText = "2",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        _G.Speed = tonumber(Text)
    end,
})

MainTab:CreateInput({
    Name = "Khoảng cách vòng tròn",
    PlaceholderText = "10",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        _G.Distance = tonumber(Text)
    end,
})