-- Khởi tạo
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "Phan: Fram NPC"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 300)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, 0, 0, 30)
toggleBtn.Text = "Bắt đầu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleBtn.TextColor3 = Color3.new(1,1,1)

local radiusLabel = Instance.new("TextLabel", frame)
radiusLabel.Text = "Bán kính:"
radiusLabel.Size = UDim2.new(0, 100, 0, 25)
radiusLabel.Position = UDim2.new(0, 0, 0, 40)
radiusLabel.TextColor3 = Color3.new(1,1,1)
radiusLabel.BackgroundTransparency = 1

local radiusBox = Instance.new("TextBox", frame)
radiusBox.Size = UDim2.new(0, 100, 0, 25)
radiusBox.Position = UDim2.new(0, 100, 0, 40)
radiusBox.Text = "10"

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Text = "Tốc độ:"
speedLabel.Size = UDim2.new(0, 100, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 70)
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(0, 100, 0, 25)
speedBox.Position = UDim2.new(0, 100, 0, 70)
speedBox.Text = "2"

-- Hàm tìm NPC gần nhất
local function getNearestNPC()
	local closest, shortest = nil, math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("npccity") then
			local npcHRP = v:FindFirstChild("HumanoidRootPart")
			if npcHRP then
				local dist = (npcHRP.Position - hrp.Position).Magnitude
				if dist < shortest then
					closest = v
					shortest = dist
				end
			end
		end
	end
	return closest
end

-- Pathfinding + MoveTo
local PathfindingService = game:GetService("PathfindingService")
local function moveToTarget(pos)
	local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true})
	path:ComputeAsync(hrp.Position, pos)
	if path.Status == Enum.PathStatus.Complete then
		for _, waypoint in pairs(path:GetWaypoints()) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	else
		humanoid:MoveTo(pos)
	end
end

-- Vòng quanh mục tiêu
local running = false
spawn(function()
	while wait(0.1) do
		if running then
			local radius = tonumber(radiusBox.Text) or 10
			local speed = tonumber(speedBox.Text) or 2
			local target = getNearestNPC()
			if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
				-- Di chuyển tới mục tiêu bằng Pathfinding
				moveToTarget(target.HumanoidRootPart.Position + Vector3.new(0,0,3))

				while target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 and running do
					local tPos = target.HumanoidRootPart.Position
					local time = tick()
					local angle = math.rad((tick()*speed*50)%360)
					local offset = Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
					local movePos = tPos + offset
					humanoid:MoveTo(movePos)

					-- Quay mặt về NPC
					hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(tPos.X, hrp.Position.Y, tPos.Z))

					-- Auto đánh
					local tool = char:FindFirstChildOfClass("Tool")
					if tool and tool:FindFirstChild("Handle") then
						tool:Activate()
					end
					task.wait(0.1)
				end
			end
		end
	end
end)

-- Bật/tắt
toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "TẮT " or "BẬT "
end)