local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Tìm NPC chứa "CityNPC"
local function getNearestCityNPC()
	local nearest = nil
	local minDist = math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.lower(v.Name):find("citynpc") and v.Humanoid.Health > 0 then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = v
				end
			end
		end
	end
	return nearest
end

-- Hiện thông báo trên màn hình
local gui = Instance.new("ScreenGui", game.CoreGui)
local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(1, 0, 0, 30)
label.Position = UDim2.new(0, 0, 0, 0)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextScaled = true
label.Text = "Đang tìm NPC..."

-- Vòng lặp chính
while true do
	wait(1)
	local npc = getNearestCityNPC()
	if npc then
		label.Text = "Tới: " .. npc.Name
		hum:MoveTo(npc.HumanoidRootPart.Position)
	else
		label.Text = "Không tìm thấy NPC có tên CityNPC"
	end
end