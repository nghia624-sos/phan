local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")

-- TẢI UI Library KHÁC (Finity)
local Finity = loadstring(game:HttpGet("https://pastebin.com/raw/fPqHvxzK"))()
local FinityWindow = Finity.new(true, "Nghia Minh - Fram NPC")
FinityWindow.ChangeToggleKey(Enum.KeyCode.RightControl) -- Nhấn Ctrl phải để ẩn/hiện menu

-- Tạo Tab & Category
local mainTab = FinityWindow:CreateCategory("Fram NPC")
local mainSector = mainTab:CreateSector("Tính năng", "left")
local hitboxSector = mainTab:CreateSector("Tùy chỉnh Hitbox", "right")

-- Biến toàn cục
local framEnabled = false
local runAround = false
local autoHit = false
local radius, speed = 10, 5
local sizeX, sizeY, sizeZ = 5, 5, 5
local hitboxEnabled = false
local targetName = "CityNPC"
local npc = nil
local hitboxPart = nil

-- Tìm NPC phù hợp
function getNPC()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():match(targetName:lower()) then
			return v
		end
	end
end

-- Auto hit
RunService.RenderStepped:Connect(function()
	if autoHit and npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
		mouse1press()
		wait()
		mouse1release()
	end
end)

-- Hitbox
function toggleHitbox(on)
	if hitboxPart then hitboxPart:Destroy() hitboxPart = nil end
	if on then
		local tool = chr:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			local handle = tool.Handle
			hitboxPart = Instance.new("Part", handle)
			hitboxPart.Name = "CustomHitbox"
			hitboxPart.Size = Vector3.new(sizeX, sizeY, sizeZ)
			hitboxPart.Color = Color3.new(1, 0, 0)
			hitboxPart.Material = Enum.Material.Neon
			hitboxPart.Transparency = 0.3
			hitboxPart.Anchored = false
			hitboxPart.CanCollide = false
			local weld = Instance.new("WeldConstraint", hitboxPart)
			weld.Part0 = handle
			weld.Part1 = hitboxPart
			hitboxPart.CFrame = handle.CFrame
		end
	end
end

-- Chạy vòng quanh NPC
function runAroundTarget()
	local angle = 0
	RunService:BindToRenderStep("RunAround", Enum.RenderPriority.Character.Value, function(dt)
		if not runAround or not npc or not npc:FindFirstChild("HumanoidRootPart") then
			RunService:UnbindFromRenderStep("RunAround")
			return
		end
		angle = angle + dt * speed
		local targetPos = npc.HumanoidRootPart.Position + Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
		hum:MoveTo(targetPos)
		hrp.CFrame = CFrame.new(hrp.Position, npc.HumanoidRootPart.Position)
	end)
end

-- Khi bật Fram
mainSector:AddToggle("Bật Fram", false, function(state)
	framEnabled = state
	if state then
		spawn(function()
			while framEnabled do
				npc = getNPC()
				if npc then
					repeat
						local pos = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position or hrp.Position
						hum:MoveTo(pos)
						wait(0.5)
					until (not framEnabled) or npc.Humanoid.Health <= 0
				end
				wait(0.5)
			end
		end)
	end
end)

mainSector:AddToggle("Chạy vòng quanh", false, function(state)
	runAround = state
	if state then runAroundTarget() end
end)

mainSector:AddToggle("Tự động đánh", false, function(state)
	autoHit = state
end)

mainSector:AddTextbox("Tên NPC (ví dụ: CityNPC)", "CityNPC", function(val)
	targetName = val
end)

mainSector:AddTextbox("Bán kính chạy vòng", "10", function(val)
	radius = tonumber(val) or 10
end)

mainSector:AddTextbox("Tốc độ chạy vòng", "5", function(val)
	speed = tonumber(val) or 5
end)

-- Cài đặt hitbox
hitboxSector:AddToggle("Hiển thị Hitbox", false, function(state)
	hitboxEnabled = state
	toggleHitbox(state)
end)

hitboxSector:AddTextbox("Chiều X", "5", function(val)
	sizeX = tonumber(val) or 5
	if hitboxEnabled then toggleHitbox(true) end
end)

hitboxSector:AddTextbox("Chiều Y", "5", function(val)
	sizeY = tonumber(val) or 5
	if hitboxEnabled then toggleHitbox(true) end
end)

hitboxSector:AddTextbox("Chiều Z", "5", function(val)
	sizeZ = tonumber(val) or 5
	if hitboxEnabled then toggleHitbox(true) end
end)