-- GUI + Fram NPC + Hitbox + Tự động chạy vòng khi đến gần mục tiêu

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "NghiaMinhMenu"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 500)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true

-- === CÁC BIẾN ĐIỀU KHIỂN ===
local isFramming = false
local autoRound = true
local autoAttack = true
local showHitbox = false
local hitboxSize = Vector3.new(10, 10, 10)
local distance = 10
local speed = 5

-- === TÌM NPC ===
local function findNearestNPC()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") then
			local name = npc.Name:lower()
			if name:find("citynpc") or name:find("npcity") then
				return npc
			end
		end
	end
end

-- === AUTO ATTACK ===
local function attackTarget(target)
	while autoAttack and target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
		local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			tool:Activate()
		end
		task.wait(0.3)
	end
end

-- === CHẠY VÒNG QUANH MỤC TIÊU ===
local function runAroundTarget(target)
	while autoRound and target and target:FindFirstChild("HumanoidRootPart") and target.Humanoid.Health > 0 do
		local angle = tick() * speed
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * distance
		local goal = target.HumanoidRootPart.Position + offset
		hum:MoveTo(goal)
		hrp.CFrame = CFrame.new(hrp.Position, target.HumanoidRootPart.Position)
		task.wait(0.1)
	end
end

-- === MAIN LOOP ===
task.spawn(function()
	while true do
		if isFramming then
			local npc = findNearestNPC()
			if npc and npc:FindFirstChild("HumanoidRootPart") then
				hum:MoveTo(npc.HumanoidRootPart.Position)
				repeat
					task.wait(0.2)
				until (hrp.Position - npc.HumanoidRootPart.Position).Magnitude < distance or not isFramming
				task.wait(0.1)
				if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
					task.spawn(attackTarget, npc)
					task.spawn(runAroundTarget, npc)
				end
			end
		end
		task.wait(0.5)
	end
end)

-- === HIỆN HITBOX ===
task.spawn(function()
	while true do
		if showHitbox then
			local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				if not tool.Handle:FindFirstChild("HitboxPart") then
					local part = Instance.new("Part", tool.Handle)
					part.Name = "HitboxPart"
					part.Anchored = false
					part.CanCollide = false
					part.Transparency = 0.5
					part.Color = Color3.fromRGB(255, 0, 0)
					part.Material = Enum.Material.Neon
					part.Size = hitboxSize
					local weld = Instance.new("WeldConstraint", part)
					weld.Part0 = part
					weld.Part1 = tool.Handle
				else
					tool.Handle.HitboxPart.Size = hitboxSize
				end
			end
		else
			local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") and tool.Handle:FindFirstChild("HitboxPart") then
				tool.Handle.HitboxPart:Destroy()
			end
		end
		task.wait(0.5)
	end
end)

-- === GUI MENU ===
local function createButton(text, yPos, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.new(0, 5, 0, yPos)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local y = 10

createButton("Bật/Tắt Fram", y, function()
	isFramming = not isFramming
end) y += 35

createButton("Bật/Tắt đánh tự động", y, function()
	autoAttack = not autoAttack
end) y += 35

createButton("Bật/Tắt chạy vòng", y, function()
	autoRound = not autoRound
end) y += 35

createButton("Bật/Tắt Hitbox", y, function()
	showHitbox = not showHitbox
end) y += 35

local distBox = Instance.new("TextBox", frame)
distBox.Size = UDim2.new(1, -10, 0, 30)
distBox.Position = UDim2.new(0, 5, 0, y)
distBox.PlaceholderText = "Khoảng cách: " .. distance
distBox.FocusLost:Connect(function()
	local val = tonumber(distBox.Text)
	if val then distance = val end
end) y += 35

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1, -10, 0, 30)
speedBox.Position = UDim2.new(0, 5, 0, y)
speedBox.PlaceholderText = "Tốc độ: " .. speed
speedBox.FocusLost:Connect(function()
	local val = tonumber(speedBox.Text)
	if val then speed = val end
end) y += 35

local hitboxSizeBox = Instance.new("TextBox", frame)
hitboxSizeBox.Size = UDim2.new(1, -10, 0, 30)
hitboxSizeBox.Position = UDim2.new(0, 5, 0, y)
hitboxSizeBox.PlaceholderText = "Kích thước hitbox (X Y Z)"
hitboxSizeBox.FocusLost:Connect(function()
	local x,y,z = hitboxSizeBox.Text:match("(%d+)%s+(%d+)%s+(%d+)")
	if x and y and z then
		hitboxSize = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
	end
end) y += 35

-- Thêm nút ẩn/hiện menu
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.Text = "Menu"
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 120, 80)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)