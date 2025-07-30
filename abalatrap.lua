-- Đảm bảo game đã load xong
if not game:IsLoaded() then game.Loaded:Wait() end

-- Gui + Setup
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MagnetAutoFarmGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 10, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = true

local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 8)

function createButton(text, posY)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 6)
	return btn
end

local toggleScript = createButton("Bật Script", 10)
local toggleMenu = createButton("Ẩn Menu", 50)

local distanceLabel = Instance.new("TextLabel", frame)
distanceLabel.Size = UDim2.new(1, -20, 0, 30)
distanceLabel.Position = UDim2.new(0, 10, 0, 90)
distanceLabel.TextColor3 = Color3.new(1, 1, 1)
distanceLabel.Text = "Khoảng cách: 15"
distanceLabel.BackgroundTransparency = 1
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 14

local hpLabel = Instance.new("TextLabel", frame)
hpLabel.Size = UDim2.new(1, -20, 0, 30)
hpLabel.Position = UDim2.new(0, 10, 0, 125)
hpLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
hpLabel.Text = "Máu mục tiêu: N/A"
hpLabel.BackgroundTransparency = 1
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextSize = 14

-- Cài đặt
local running = false
local keepDistance = 15

toggleScript.MouseButton1Click:Connect(function()
	running = not running
	toggleScript.Text = running and "Tắt Script" or "Bật Script"
end)

toggleMenu.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

mouse.WheelForward:Connect(function()
	keepDistance = keepDistance + 1
	distanceLabel.Text = "Khoảng cách: " .. tostring(keepDistance)
end)

mouse.WheelBackward:Connect(function()
	keepDistance = math.max(5, keepDistance - 1)
	distanceLabel.Text = "Khoảng cách: " .. tostring(keepDistance)
end)

-- Hàm tìm mục tiêu
function getClosestTarget()
	local closest, dist = nil, math.huge
	for _, v in pairs(game.Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local mag = (v.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if mag < dist then
				dist = mag
				closest = v.Character
			end
		end
	end
	return closest, dist
end

-- Auto attack placeholder (tuỳ chỉnh tuỳ game)
function attackTarget(target)
	-- Ví dụ: nếu có tool
	local tool = player.Character:FindFirstChildOfClass("Tool")
	if tool then
		tool:Activate()
	end
end

-- Chạy vòng
game:GetService("RunService").Heartbeat:Connect(function()
	if not running or not char or not hrp then return end

	local target, dist = getClosestTarget()
	if target and target:FindFirstChild("HumanoidRootPart") then
		local trgPos = target.HumanoidRootPart.Position
		local direction = (trgPos - hrp.Position).Unit

		-- Xoay mặt về mục tiêu
		hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(trgPos.X, hrp.Position.Y, trgPos.Z))

		-- Hiển thị máu
		local hp = target:FindFirstChildOfClass("Humanoid")
		if hp then
			hpLabel.Text = "Máu mục tiêu: " .. math.floor(hp.Health)
		end

		-- Đẩy lùi nếu quá gần
		if dist < keepDistance - 1 then
			hrp.Velocity = -direction * 25
		elseif dist > keepDistance + 1 then
			-- Lướt tới nếu quá xa
			hrp.Velocity = direction * 25
		else
			-- Gần đúng khoảng cách -> tấn công
			attackTarget(target)
			hrp.Velocity = Vector3.zero
		end
	end
end)