--// GUI ĐƠN GIẢN
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FramNpcCITY"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 230)
frame.Position = UDim2.new(0, 10, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

--// BUTTON BẬT TẮT
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 40)
toggle.Position = UDim2.new(0, 0, 0, 0)
toggle.Text = "Fram NpcCITY"
toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 18

--// Ô nhập bán kính
local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(1, -10, 0, 30)
radiusBox.Position = UDim2.new(0, 5, 0, 50)
radiusBox.PlaceholderText = "Bán kính chạy vòng (mặc định 6)"
radiusBox.Text = ""
radiusBox.TextSize = 14
radiusBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
radiusBox.TextColor3 = Color3.new(1, 1, 1)

--// Ô nhập tốc độ quay
local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -10, 0, 30)
speedBox.Position = UDim2.new(0, 5, 0, 90)
speedBox.PlaceholderText = "Tốc độ chạy vòng (mặc định 2)"
speedBox.Text = ""
speedBox.TextSize = 14
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.TextColor3 = Color3.new(1, 1, 1)

--// Ô nhập tốc độ đánh
local atkBox = Instance.new("TextBox", frame)
atkBox.Size = UDim2.new(1, -10, 0, 30)
atkBox.Position = UDim2.new(0, 5, 0, 130)
atkBox.PlaceholderText = "Tốc độ đánh (giây, mặc định 0.3)"
atkBox.Text = ""
atkBox.TextSize = 14
atkBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
atkBox.TextColor3 = Color3.new(1, 1, 1)

--// BIẾN
local running = false
local radius = 6
local speed = 2
local attackCooldown = 0.3

--// TÌM NPC (không phân biệt hoa thường)
local function findNpc()
	local closest
	local shortest = math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			if string.find(string.lower(v.Name), "npccity") then
				local mag = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if mag < shortest then
					shortest = mag
					closest = v
				end
			end
		end
	end
	return closest
end

--// DI CHUYỂN TỚI NPC
local function moveToTarget(target)
	local path = game:GetService("PathfindingService"):CreatePath()
	path:ComputeAsync(hrp.Position, target.HumanoidRootPart.Position)
	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in pairs(path:GetWaypoints()) do
			char:MoveTo(waypoint.Position)
			char:WaitForChild("Humanoid").MoveToFinished:Wait()
		end
	end
end

--// CHẠY VÒNG, ĐÁNH, QUAY
local function framTarget(target)
	local angle = 0
	while running and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local pos = target.HumanoidRootPart.Position + offset
		char:MoveTo(pos)

		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)

		local tool = char:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			for _, obj in pairs(tool:GetDescendants()) do
				if obj:IsA("RemoteEvent") then
					pcall(function() obj:FireServer() end)
				end
			end
		end

		angle += speed * 0.05
		wait(attackCooldown)
	end
end

--// NÚT BẬT TẮT
toggle.MouseButton1Click:Connect(function()
	running = not running
	if running then
		-- Đọc giá trị từ ô nhập
		if tonumber(radiusBox.Text) then radius = tonumber(radiusBox.Text) end
		if tonumber(speedBox.Text) then speed = tonumber(speedBox.Text) end
		if tonumber(atkBox.Text) then attackCooldown = tonumber(atkBox.Text) end

		toggle.Text = "Đang Fram..."
		local target = findNpc()
		if target then
			moveToTarget(target)
			wait(0.5)
			framTarget(target)
		else
			toggle.Text = "Không tìm thấy npccity"
			wait(2)
			toggle.Text = "Fram NpcCITY"
			running = false
		end
	else
		toggle.Text = "Fram NpcCITY"
	end
end)