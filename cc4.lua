-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Menu Teo Nhỏ Nhân Vật",
    LoadingTitle = "Đang tải menu...",
    LoadingSubtitle = "Bởi Nghia Minh",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "TeoNhoNhanVat"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- Lấy Player và Character
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- Hàm thay đổi kích thước nhân vật
local function SetCharacterScale(scale)
    local char = GetCharacter()
    if not char:FindFirstChild("Humanoid") then return end

    -- Scale nhân vật
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            obj.Size = obj.Size * scale
        end
    end
end

-- Tab
local MainTab = Window:CreateTab("Tùy chỉnh", 4483362458)

-- Input để chỉnh scale
MainTab:CreateInput({
    Name = "Nhập kích thước (ví dụ: 0.5)",
    PlaceholderText = "0.5 = nhỏ hơn, 2 = to hơn",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local scale = tonumber(Text)
        if scale and scale > 0 then
            SetCharacterScale(scale)
        end
    end
})

Rayfield:LoadConfiguration()