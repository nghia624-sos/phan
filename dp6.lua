local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local hrp = chr:WaitForChild("HumanoidRootPart")
local mouse = lp:GetMouse()

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = library.CreateLib("Nghia Minh", "Ocean")

-- TAB CHÍNH
local tab = Window:NewTab("Fram NPC")
local sec = tab:NewSection("Tính năng chính")

-- CÁC BIẾN
local hitboxEnabled = false
local sizeX, sizeY, sizeZ = 5, 5, 5
local hitboxPart = nil
local framEnabled = false
local autoHit = false
local radius, speed = 10, 5
local targetName = "CityNPC"
local npc = nil

-- TÌM NPC
function getNPC()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():match(targetName:lower()) then
			return v
		end
	end
end

-- CHẠY VÒNG
function runAroundTarget()
	if not npc or not npc:FindFirstChild("HumanoidRootPart") then return end
	local angle = 0
	RunService:BindToRenderStep("RunAround", Enum.RenderPriority.Character.Value, function(dt)
		if not framEnabled then RunService:UnbindFromRenderStep("RunAround") return end
		angle = angle + dt * speed
		local pos = npc.HumanoidRootPart.Position + Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
		hum:MoveTo(pos)
		hrp.CFrame = CFrame.new(hrp.Position, npc.HumanoidRootPart.Position)
	end)
end

-- AUTO HIT
RunService.RenderStepped:Connect(function()
	if autoHit and npc and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Humanoid").Health > 0 then
		mouse1press()
		wait()
		mouse1release()
	end
end)

-- HIỂN THỊ HITBOX
function toggleHitbox(on)
	if hitboxPart then hitboxPart:Destroy() hitboxPart = nil end
	if on then
		local tool = chr:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			local handle = tool.Handle
			hitboxPart = Instance.new("Part", handle)
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

-- GUI
sec:NewToggle("Bật Fram", "Tự động tìm và đánh NPC", function(v)
	framEnabled = v
	if v then
		spawn(function()
			while framEnabled do
				npc = getNPC()
				if npc then
					repeat
						local pos = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position or hrp.Position
						hum:MoveTo(pos)
						wait(0.5)
					until (npc.Humanoid.Health <= 0 or not framEnabled)
				end
				wait(0.5)
			end
		end)
	end
end)

sec:NewToggle("Chạy vòng", "Chạy vòng quanh mục tiêu", function(v)
	framEnabled = v
	if v then runAroundTarget() end
end)

sec:NewToggle("Đánh tự động", "Tự tấn công mục tiêu", function(v)
	autoHit = v
end)

sec:NewToggle("Bật/Tắt Hitbox", "Hiển thị vùng sát thương", function(v)
	hitboxEnabled = v
	toggleHitbox(v)
end)

sec:NewTextBox("Khoảng cách:", "Nhập bán kính chạy vòng", function(val)
	radius = tonumber(val) or 10
end)

sec:NewTextBox("Tốc độ:", "Nhập tốc độ chạy vòng", function(val)
	speed = tonumber(val) or 5
end)

-- GIAO DIỆN HITBOX
sec:NewTextBox("Hitbox X:", "Chiều dài", function(val)
	sizeX = tonumber(val) or 5
	if hitboxEnabled then toggleHitbox(true) end
end)

sec:NewTextBox("Hitbox Y:", "Chiều cao", function(val)
	sizeY = tonumber(val) or 5
	if hitboxEnabled then toggleHitbox(true) end
end)

sec:NewTextBox("Hitbox Z:", "Chiều rộng", function(val)
	sizeZ = tonumber(val) or 5
	if hitboxEnabled then toggleHitbox(true) end
end)

sec:NewTextBox("Mẫu mục tiêu", "VD: CityNPC", function(val)
	targetName = val or "CityNPC"
end)

-- TAB PHỤ
local tab2 = Window:NewTab("Cài đặt")
tab2:NewButton("Tắt Menu", "Đóng menu", function()
	library:ToggleUI()
end)