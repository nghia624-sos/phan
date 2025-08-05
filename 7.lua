--// GUI Menu: Nghia Minh | Kéo được | Đầy đủ tính năng //--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

--== GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NghiaMinh"
local frame = Instance.new("Frame", gui)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Position = UDim2.new(0, 50, 0, 100)
frame.Size = UDim2.new(0, 270, 0, 340)
frame.Active = true
frame.Draggable = true

local uilist = Instance.new("UIListLayout", frame)
uilist.Padding = UDim.new(0, 5)

--== Tạo button
function CreateButton(txt, callback)
	local b = Instance.new("TextButton")
	b.Text = txt
	b.Size = UDim2.new(1, -10, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Parent = frame
	b.MouseButton1Click:Connect(callback)
	return b
end

--== Tạo input
function CreateInput(txt, default, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 30)
	container.BackgroundTransparency = 1
	container.Parent = frame

	local label = Instance.new("TextLabel", container)
	label.Text = txt
	label.TextColor3 = Color3.new(1,1,1)
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1

	local box = Instance.new("TextBox", container)
	box.Text = tostring(default)
	box.Size = UDim2.new(0.6, 0, 1, 0)
	box.Position = UDim2.new(0.4, 0, 0, 0)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.TextColor3 = Color3.new(1, 1, 1)

	box.FocusLost:Connect(function()
		callback(tonumber(box.Text))
	end)
end

--== Tính năng chính
local radius = 10
local speed = 5
local hitboxSize = Vector3.new(5, 5, 5)
local framRunning = false
local autoAttack = false
local highlightBox

--== Tìm NPC gần nhất
function findTarget()
	local closest
	local minDist = math.huge
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
			local name = v.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < minDist then
					minDist = dist
					closest = v
				end
			end
		end
	end
	return closest
end

--== Di chuyển vòng quanh
function moveAroundTarget(target)
	if not target or not target:FindFirstChild("HumanoidRootPart") then return end
	local angle = 0
	while framRunning and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
		angle += speed * 0.03
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius
		local goalPos = target.HumanoidRootPart.Position + offset
		hum:MoveTo(goalPos)
		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
		wait()
	end
end

--== Auto fram
function autoFram()
	framRunning = true
	while framRunning do
		local target = findTarget()
		if target then
			repeat
				moveAroundTarget(target)
				wait()
			until target.Humanoid.Health <= 0 or not framRunning
		end
		wait()
	end
end

--== Auto đánh
RunService.RenderStepped:Connect(function()
	if autoAttack then
		local target = findTarget()
		if target and target:FindFirstChild("Humanoid") then
			for _, tool in pairs(lp.Backpack:GetChildren()) do
				if tool:IsA("Tool") then
					tool.Parent = chr
				end
			end
			for _, v in pairs(chr:GetChildren()) do
				if v:IsA("Tool") and v:FindFirstChild("Handle") then
					v:Activate()
				end
			end
		end
	end
end)

--== Hiển thị vùng sát thương
function showHitbox(size)
	if highlightBox then highlightBox:Destroy() end
	for _, v in pairs(chr:GetChildren()) do
		if v:IsA("Tool") and v:FindFirstChild("Handle") then
			local part = Instance.new("Part", v)
			part.Size = size
			part.CFrame = v.Handle.CFrame
			part.Anchored = false
			part.CanCollide = false
			part.Transparency = 0.5
			part.BrickColor = BrickColor.Red()
			highlightBox = part
		end
	end
end

--== Các nút menu
CreateButton("Bật Fram", function()
	if not framRunning then
		coroutine.wrap(autoFram)()
	end
end)

CreateButton("Tắt Fram", function()
	framRunning = false
end)

CreateButton("Bật Auto Đánh", function()
	autoAttack = true
end)

CreateButton("Tắt Auto Đánh", function()
	autoAttack = false
end)

CreateButton("Hiển thị vùng sát thương", function()
	showHitbox(hitboxSize)
end)

CreateInput("Bán kính:", radius, function(val) radius = val end)
CreateInput("Tốc độ vòng:", speed, function(val) speed = val end)
CreateInput("Kích thước X:", hitboxSize.X, function(v) hitboxSize = Vector3.new(v, hitboxSize.Y, hitboxSize.Z) end)
CreateInput("Kích thước Y:", hitboxSize.Y, function(v) hitboxSize = Vector3.new(hitboxSize.X, v, hitboxSize.Z) end)
CreateInput("Kích thước Z:", hitboxSize.Z, function(v) hitboxSize = Vector3.new(hitboxSize.X, hitboxSize.Y, v) end)