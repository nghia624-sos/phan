local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local BtnFram = Instance.new("TextButton")
local BtnAutoHit = Instance.new("TextButton")
local DistLabel = Instance.new("TextLabel")
local DistBox = Instance.new("TextBox")
local SpeedLabel = Instance.new("TextLabel")
local SpeedBox = Instance.new("TextBox")
local HPLabel = Instance.new("TextLabel")
local UIS = game:GetService("UserInputService")

ScreenGui.Parent = game.CoreGui
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 200, 0, 230)
Frame.Position = UDim2.new(0.1, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

Title.Parent = Frame
Title.Text = "TT:dongphandzs1"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

BtnFram.Parent = Frame
BtnFram.Size = UDim2.new(1, -20, 0, 30)
BtnFram.Position = UDim2.new(0, 10, 0, 40)
BtnFram.Text = "Bật Fram NPC2"
BtnFram.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnFram.TextColor3 = Color3.new(1, 1, 1)

BtnAutoHit.Parent = Frame
BtnAutoHit.Size = UDim2.new(1, -20, 0, 30)
BtnAutoHit.Position = UDim2.new(0, 10, 0, 80)
BtnAutoHit.Text = "Bật Auto Đánh"
BtnAutoHit.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnAutoHit.TextColor3 = Color3.new(1, 1, 1)

DistLabel.Parent = Frame
DistLabel.Size = UDim2.new(1, -20, 0, 20)
DistLabel.Position = UDim2.new(0, 10, 0, 120)
DistLabel.BackgroundTransparency = 1
DistLabel.TextColor3 = Color3.new(1, 1, 1)
DistLabel.Text = "Khoảng cách:"

DistBox.Parent = Frame
DistBox.Size = UDim2.new(1, -20, 0, 25)
DistBox.Position = UDim2.new(0, 10, 0, 140)
DistBox.Text = "10"

SpeedLabel.Parent = Frame
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 170)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.Text = "Tốc độ quay:"

SpeedBox.Parent = Frame
SpeedBox.Size = UDim2.new(1, -20, 0, 25)
SpeedBox.Position = UDim2.new(0, 10, 0, 190)
SpeedBox.Text = "5"

HPLabel.Parent = Frame
HPLabel.Size = UDim2.new(1, -20, 0, 20)
HPLabel.Position = UDim2.new(0, 10, 0, 220)
HPLabel.BackgroundTransparency = 1
HPLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
HPLabel.Text = "Máu: 0"

-- // Kéo GUI
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- // Logic tìm & đánh NPC2
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local FramActive = false
local AutoHitActive = false
local Target

local function findNPC2()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChildOfClass("Humanoid") then
			if string.find(string.lower(obj.Name), "npc2") then
				return obj
			end
		end
	end
	return nil
end

local function moveToTarget(targetPos)
	local path = PathfindingService:CreatePath()
	path:ComputeAsync(HRP.Position, targetPos)
	local waypoints = path:GetWaypoints()
	for _, point in ipairs(waypoints) do
		Humanoid:MoveTo(point.Position)
		Humanoid.MoveToFinished:Wait()
	end
end

local function circleTarget(target, radius, speed)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	local angle = tick() * speed
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	Humanoid:MoveTo(target.HumanoidRootPart.Position + offset)
	HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(target.HumanoidRootPart.Position.X, HRP.Position.Y, target.HumanoidRootPart.Position.Z))
end

RunService.RenderStepped:Connect(function()
	if FramActive then
		if not Target or not Target.Parent or Target:FindFirstChildOfClass("Humanoid").Health <= 0 then
			Target = findNPC2()
		end
		if Target then
			HPLabel.Text = "Máu: " .. math.floor(Target:FindFirstChildOfClass("Humanoid").Health)
			if (HRP.Position - Target.HumanoidRootPart.Position).Magnitude > tonumber(DistBox.Text) then
				moveToTarget(Target.HumanoidRootPart.Position)
			else
				circleTarget(Target, tonumber(DistBox.Text), tonumber(SpeedBox.Text))
				if AutoHitActive then
					for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
						if tool:IsA("Tool") then
							Humanoid:EquipTool(tool)
							tool:Activate()
						end
					end
				end
			end
		end
	end
end)

BtnFram.MouseButton1Click:Connect(function()
	FramActive = not FramActive
	BtnFram.BackgroundColor3 = FramActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
end)

BtnAutoHit.MouseButton1Click:Connect(function()
	AutoHitActive = not AutoHitActive
	BtnAutoHit.BackgroundColor3 = AutoHitActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
end)