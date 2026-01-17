-- =========================
-- Ninja Hub | One Line Load
-- =========================

-- กันรันซ้ำ
if getgenv().NINJA_HUB then return end
getgenv().NINJA_HUB = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- State
local LightOn, ESPOn, Fold = false, false, false
local ESPTags = {}

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "NinjaHub"
Gui.ResetOnSpawn = false
Gui.Parent = game:GetService("CoreGui")

-- ================= Button Creator =================
local function mkBtn(txt)
	local b = Instance.new("TextButton", Gui)
	b.Size = UDim2.new(0,100,0,28)
	b.Text = txt
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 12
	b.AutoButtonColor = false
	b.ZIndex = 10

	Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
	local s = Instance.new("UIStroke", b)
	s.Thickness = 1.4

	return b, s
end

-- ================= Buttons =================
local LightBtn, LightStroke = mkBtn("LIGHT")
local ESPBtn, ESPStroke     = mkBtn("ESP")
local FoldBtn, FoldStroke   = mkBtn("FOLD")
local DelBtn, DelStroke     = mkBtn("DEL")

LightBtn.Position = UDim2.new(0,10,0.4,0)
ESPBtn.Position   = LightBtn.Position + UDim2.new(0,0,0,32)
FoldBtn.Position  = ESPBtn.Position   + UDim2.new(0,0,0,32)
DelBtn.Position   = FoldBtn.Position  + UDim2.new(0,0,0,32)

local Buttons = {LightBtn, ESPBtn, FoldBtn, DelBtn}

-- ================= Drag Group =================
local dragging, startPos, startBtns

for _,b in ipairs(Buttons) do
	b.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = i.Position
			startBtns = {}
			for _,bb in ipairs(Buttons) do
				startBtns[bb] = bb.Position
			end
		end
	end)
end

UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
	or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - startPos
		for _,b in ipairs(Buttons) do
			local p = startBtns[b]
			b.Position = UDim2.new(p.X.Scale,p.X.Offset+d.X,p.Y.Scale,p.Y.Offset+d.Y)
		end
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
	or i.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ================= Light =================
local function setupLight(c)
	local hrp = c:WaitForChild("HumanoidRootPart",5)
	if not hrp then return end
	if hrp:FindFirstChild("NinjaLight") then return end

	local l = Instance.new("PointLight", hrp)
	l.Name = "NinjaLight"
	l.Range = 22
	l.Brightness = 2
	l.Enabled = LightOn
end

if LP.Character then setupLight(LP.Character) end
LP.CharacterAdded:Connect(setupLight)

LightBtn.MouseButton1Click:Connect(function()
	LightOn = not LightOn
	local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:FindFirstChild("NinjaLight") then
		hrp.NinjaLight.Enabled = LightOn
	end
	LightBtn.Text = LightOn and "LIGHT ON" or "LIGHT"
end)

-- ================= ESP =================
local function addESP(p)
	if p == LP then return end
	local function char(c)
		local h = c:WaitForChild("Head",5)
		if not h then return end

		local bg = Instance.new("BillboardGui", h)
		bg.Size = UDim2.new(0,120,0,28)
		bg.AlwaysOnTop = true
		bg.Enabled = false

		local t = Instance.new("TextLabel", bg)
		t.Size = UDim2.new(1,0,1,0)
		t.BackgroundTransparency = 1
		t.TextStrokeTransparency = 0
		t.TextSize = 12

		ESPTags[p] = {bg=bg, text=t, head=h}
	end
	p.CharacterAdded:Connect(char)
	if p.Character then char(p.Character) end
end

for _,p in pairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(function(p)
	if ESPTags[p] then
		ESPTags[p].bg:Destroy()
		ESPTags[p] = nil
	end
end)

ESPBtn.MouseButton1Click:Connect(function()
	ESPOn = not ESPOn
	ESPBtn.Text = ESPOn and "ESP ON" or "ESP"
end)

-- ================= Fold / Delete =================
FoldBtn.MouseButton1Click:Connect(function()
	Fold = not Fold
	for _,b in ipairs(Buttons) do
		if b ~= FoldBtn then
			b.Visible = not Fold
		end
	end
	FoldBtn.Text = Fold and "OPEN" or "FOLD"
end)

DelBtn.MouseButton1Click:Connect(function()
	Gui:Destroy()
	getgenv().NINJA_HUB = nil
end)

-- ================= Keybind =================
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.Minus then
		Gui:Destroy()
	end
end)

-- ================= Main Loop =================
local h = 0
RunService.RenderStepped:Connect(function(dt)
	h = (h + dt*0.4) % 1
	local r = Color3.fromHSV(h,1,1)

	LightStroke.Color = r
	ESPStroke.Color   = r
	FoldStroke.Color  = r
	DelStroke.Color   = r

	if not ESPOn then
		for _,v in pairs(ESPTags) do
			v.bg.Enabled = false
		end
		return
	end

	local myHead = LP.Character and LP.Character:FindFirstChild("Head")
	if not myHead then return end

	for plr,v in pairs(ESPTags) do
		if v.head and v.head.Parent then
			local d = math.floor((v.head.Position - myHead.Position).Magnitude)
			v.text.Text = plr.Name.." ["..d.."m]"
			v.bg.Enabled = true

			if LP.Team and plr.Team then
				v.text.TextColor3 =
					(plr.Team == LP.Team)
					and Color3.fromRGB(0,255,0)
					or Color3.fromRGB(255,60,60)
			else
				v.text.TextColor3 = Color3.new(1,1,1)
			end
		end
	end
end)

print("Ninja Hub Loaded")
