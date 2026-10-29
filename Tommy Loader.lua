
do

if not LPH_OBFUSCATED then
	LPH_ATTRIBUTES = function() end
	VM = function() end
end

local IsClient = false
pcall(function()
	IsClient = typeof(game) == "Instance" and game:IsA("DataModel")
		and game:GetService("Players").LocalPlayer ~= nil
end)
if not IsClient then return end

do
	local G = _G
	pcall(function() if getgenv then G = getgenv() end end)
	G.__tb_loader_seq = (G.__tb_loader_seq or 0) + 1
end

local Builder = (function() LPH_ATTRIBUTES(VM(NONE))

	local TweenService = game:GetService("TweenService")
	local RunService   = game:GetService("RunService")
	local Lighting     = game:GetService("Lighting")

	local Candidates = {}
	do
		local Seen = {}
		local function Add(Container)
			if typeof(Container) == "Instance" and not Seen[Container] then
				Seen[Container] = true
				table.insert(Candidates, Container)
			end
		end
		pcall(function() if gethui then Add(gethui()) end end)
		pcall(function() Add(game:GetService("CoreGui")) end)
		pcall(function()
			local Player = game:GetService("Players").LocalPlayer
			Add(Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui", 5))
		end)
	end

	local Containers = {}
	for _, Container in Candidates do
		if pcall(function() return Container:GetChildren() end) then
			table.insert(Containers, Container)
		end
	end

	local FromRGB = Color3.fromRGB
	local UDim2New = UDim2.new
	local FromOffset = UDim2.fromOffset
	local Vector2New = Vector2.new
	local Vector3New = Vector3.new
	local CFrameNew = CFrame.new
	local Angles = CFrame.Angles
	local Floor = math.floor
	local Clamp = math.clamp
	local Max = math.max
	local Sin = math.sin
	local Exp = math.exp
	local Random_ = math.random
	local OsClock = os.clock

	local Ink    = FromRGB(255, 255, 255)
	local Accent = FromRGB(229, 79, 82)
	local Quiet  = FromRGB(128, 128, 130)
	local Hush   = FromRGB(70, 70, 72)
	local Rule   = FromRGB(44, 44, 47)
	local Void   = FromRGB(5, 5, 6)
	local Metal  = FromRGB(100, 100, 110)
	local White  = FromRGB(236, 236, 242)
	local Ember  = FromRGB(96, 30, 32)

	local Mono
	pcall(function() Mono = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium) end)
	local MonoBold
	pcall(function() MonoBold = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold) end)

	local EXPO   = Enum.EasingStyle.Exponential
	local QUINT  = Enum.EasingStyle.Quint
	local QUART  = Enum.EasingStyle.Quart
	local QUAD   = Enum.EasingStyle.Quad
	local LINEAR = Enum.EasingStyle.Linear
	local OUT    = Enum.EasingDirection.Out
	local IN     = Enum.EasingDirection.In

	local Conns     = {}
	local Alive     = true
	local Done      = false
	local Ended     = false
	local Torn      = false
	local Dead      = false
	local Exploding = false
	local BuildTime = OsClock()
	local Clock     = 0

	local function Now()
		return OsClock() - BuildTime
	end

	local Queue = {}

	local function At(Moment, Callback)
		table.insert(Queue, {At = Moment, Run = Callback})
	end

	local function After(Delay, Callback)
		At(Now() + Delay, Callback)
	end

	local function Drain(Moment)
		local Index = 1
		while Index <= #Queue do
			local Item = Queue[Index]
			if Item.At <= Moment then
				table.remove(Queue, Index)
				pcall(Item.Run)
			else
				Index = Index + 1
			end
		end
	end

	local function Tween(Item, Goal, Time, Style, Dir, Delay)
		if typeof(Item) ~= "Instance" or Item.Parent == nil then return end
		local Ok, Handle = pcall(function()
			return TweenService:Create(Item, TweenInfo.new(Time or 0.25, Style or QUART, Dir or OUT, 0, false, Delay or 0), Goal)
		end)
		if Ok and Handle then
			pcall(function() Handle:Play() end)
			return Handle
		end
	end

	local function Create(Class, Properties)
		local Ok, Item = pcall(Instance.new, Class)
		if not Ok or not Item then return nil end
		local ParentTo = Properties.Parent
		Properties.Parent = nil
		for Property, Value in Properties do
			pcall(function() Item[Property] = Value end)
		end
		if ParentTo then pcall(function() Item.Parent = ParentTo end) end
		return Item
	end

	local function Keep(List, Item)
		if Item then table.insert(List, Item) end
		return Item
	end

	for _, Container in Containers do
		pcall(function()
			for _, Child in Container:GetChildren() do
				if Child:GetAttribute("__tbloader") then
					pcall(function() Child:Destroy() end)
				end
			end
		end)
	end
	pcall(function()
		for _, Effect in Lighting:GetChildren() do
			if Effect:GetAttribute("__tbloader") then
				pcall(function() Effect:Destroy() end)
			end
		end
	end)

	local Holder = Create("ScreenGui", {
		Name = "\0",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 1000002,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	})
	if not Holder then error("holder") end
	pcall(function() Holder:SetAttribute("__tbloader", true) end)
	for _, Container in Candidates do
		pcall(function() Holder.Parent = Container end)
		if Holder.Parent == Container then break end
	end
	if Holder.Parent == nil then error("no gui container") end

	local Blur
	pcall(function()
		Blur = Create("BlurEffect", {Parent = Lighting, Size = 0})
		if Blur then Blur:SetAttribute("__tbloader", true) end
	end)

	local Known = {}
	local Found = false
	for _, Container in Containers do
		pcall(function()
			for _, Child in Container:GetChildren() do
				if Child:IsA("ScreenGui") and #Child.Name == 0 and Child:GetAttribute("__tbloader") == nil then
					Known[Child] = true
				end
			end
		end)
	end

	local Glyph = {
		T = {"#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."},
		O = {".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."},
		M = {"#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"},
		B = {"####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."},
		Y = {"#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."},
		H = {"#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"},
		K = {"#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"},
		["."] = {"..", "..", "..", "..", "..", "##", "##"},
	}

	local WORD = "TOMBOY.HOOK"
	local Cells = {}
	local Cursor = 0
	for Index = 1, #WORD do
		local Rows = Glyph[string.sub(WORD, Index, Index)]
		local Width = #Rows[1]
		for Row = 1, 7 do
			for Col = 1, Width do
				if string.sub(Rows[Row], Col, Col) == "#" then
					table.insert(Cells, {X = Cursor + Col - 1, Y = 7 - Row, Hot = Index <= 6})
				end
			end
		end
		Cursor = Cursor + Width + 1
	end
	local SpanX = Cursor - 1
	local SPAN_FRACTION = 0.62
	local TAN = math.tan(math.rad(15))
	local VOX = Vector3New(0.9, 0.9, 1.6)
	local SPECK = Vector3New(0.22, 0.22, 0.22)

	local Wash = Create("Frame", {
		Parent = Holder, Name = "\0",
		Size = UDim2New(1, 0, 1, 0),
		BackgroundColor3 = Void,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 1,
	})

	-- edge vignette, four soft gradients, keeps the eye on the centre
	local function Edge(Name, Rotation, Anchor, Pos, Size)
		local F = Create("Frame", {
			Parent = Holder, Name = "\0",
			AnchorPoint = Anchor,
			Position = Pos,
			Size = Size,
			BackgroundColor3 = Void,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
		})
		if F then
			Create("UIGradient", {
				Parent = F,
				Rotation = Rotation,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				}),
			})
		end
		return F
	end
	local Vign = {}
	Keep(Vign, Edge("T", 90, Vector2New(0.5, 0), UDim2New(0.5, 0, 0, 0), UDim2New(1, 0, 0.22, 0)))
	Keep(Vign, Edge("B", 270, Vector2New(0.5, 1), UDim2New(0.5, 0, 1, 0), UDim2New(1, 0, 0.22, 0)))
	Keep(Vign, Edge("L", 0, Vector2New(0, 0.5), UDim2New(0, 0, 0.5, 0), UDim2New(0.18, 0, 1, 0)))
	Keep(Vign, Edge("R", 180, Vector2New(1, 0.5), UDim2New(1, 0, 0.5, 0), UDim2New(0.18, 0, 1, 0)))

	local View = Create("ViewportFrame", {
		Parent = Holder, Name = "\0",
		Size = UDim2New(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Ambient = FromRGB(110, 110, 120),
		LightColor = FromRGB(235, 235, 245),
		LightDirection = Vector3New(-0.5, -1, -0.7),
		ImageTransparency = 0,
		ZIndex = 3,
	})
	if not View then error("viewport") end

	local Cam = Create("Camera", {Parent = View, Name = "\0", FieldOfView = 30})
	pcall(function() View.CurrentCamera = Cam end)

	local function Scatter()
		return CFrameNew(
			(Random_() - 0.5) * 150,
			(Random_() - 0.5) * 80,
			-70 + Random_() * 120
		) * Angles(Random_() * 6.28, Random_() * 6.28, Random_() * 6.28)
	end

	local Voxels = {}
	for _, Cell in Cells do
		local Part = Create("Part", {
			Parent = View, Name = "\0",
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
			Material = Enum.Material.SmoothPlastic,
			Color = Metal,
			Size = SPECK,
			CFrame = Scatter(),
		})
		if Part then
			table.insert(Voxels, {
				Part = Part,
				Target = CFrameNew(Cell.X - (SpanX - 1) / 2, Cell.Y - 3, 0),
				Nx = Cell.X / SpanX,
				Glow = Cell.Hot and Accent or White,
				Lit = false,
				LandAt = math.huge,
			})
		end
	end
	local Unlit = #Voxels
	local Assembled = 0

	local Row = Create("Frame", {
		Parent = Holder, Name = "\0",
		AnchorPoint = Vector2New(0.5, 0),
		Position = UDim2New(0.5, 0, 0.5, 90),
		Size = UDim2New(SPAN_FRACTION, 0, 0, 72),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	-- detected game title, sits just under the logo with an accent line each side
	local Title = Create("TextLabel", {
		Parent = Row, Name = "\0",
		FontFace = MonoBold or Mono,
		Text = "",
		TextColor3 = White,
		TextSize = 16,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		AnchorPoint = Vector2New(0.5, 0),
		Position = UDim2New(0.5, 0, 0, -30),
		Size = FromOffset(600, 22),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	})
	local Flanks = {}
	for _, Side in { -1, 1 } do
		Keep(Flanks, Create("Frame", {
			Parent = Row, Name = "\0",
			AnchorPoint = Vector2New(Side < 0 and 1 or 0, 0.5),
			Position = UDim2New(0.5, 0, 0, -19),
			Size = FromOffset(0, 1),
			BackgroundColor3 = Accent,
			BorderSizePixel = 0,
			ZIndex = 6,
		}))
	end

	local RuleLine = Create("Frame", {
		Parent = Row, Name = "\0",
		AnchorPoint = Vector2New(0.5, 0),
		Position = UDim2New(0.5, 0, 0, 10),
		Size = UDim2New(0, 0, 0, 1),
		BackgroundColor3 = Rule,
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	local RuleFill = Create("Frame", {
		Parent = RuleLine, Name = "\0",
		Size = UDim2New(0, 0, 1, 0),
		BackgroundColor3 = Accent,
		BorderSizePixel = 0,
		ZIndex = 6,
	})

	local Marker = Create("Frame", {
		Parent = Row, Name = "\0",
		Position = FromOffset(0, 26),
		Size = FromOffset(2, 0),
		BackgroundColor3 = Accent,
		BorderSizePixel = 0,
		ZIndex = 6,
	})

	local Texts = {}
	local function Text(Str, XScale, Y, Size, Colour, Align, Anchor, XOffset)
		return Keep(Texts, Create("TextLabel", {
			Parent = Row, Name = "\0",
			FontFace = Mono,
			Text = Str,
			TextColor3 = Colour,
			TextSize = Size,
			TextTransparency = 1,
			TextXAlignment = Align,
			TextYAlignment = Enum.TextYAlignment.Center,
			AnchorPoint = Vector2New(Anchor, 0),
			Position = UDim2New(XScale, XOffset or 0, 0, Y),
			Size = FromOffset(500, Size + 6),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 6,
		}))
	end

	local LEFT = Enum.TextXAlignment.Left
	local RIGHT = Enum.TextXAlignment.Right
	local CENTER = Enum.TextXAlignment.Center

	local PlaceText, Session = "LOCAL", "LOCAL"
	pcall(function() PlaceText = tostring(game.PlaceId) end)
	pcall(function()
		local Job = string.sub(string.gsub(tostring(game.JobId), "%-", ""), 1, 10)
		if #Job > 0 then Session = string.upper(Job) end
	end)

	local Dim = FromRGB(98, 98, 102)
	local Status  = Text("", 0, 24, 14, Quiet, LEFT, 0, 12)
	local Percent = Text("0%", 1, 24, 14, Ink, RIGHT, 1)
	local PlaceLabel = Text("PLACE " .. PlaceText, 0, 52, 11, Dim, LEFT, 0)
	local Timer = Text("0.00S", 0.5, 52, 11, Dim, CENTER, 0.5)
	Text("SESSION " .. Session, 1, 52, 11, Dim, RIGHT, 1)
	local WarnLabel = Text("", 0.5, 52, 11, Accent, CENTER, 0.5)
	local Warned = false
	local Revealed = false

	local Dist = 100
	local Fitted = false

	local function Fit()
		local Size = Holder.AbsoluteSize
		if Size.X < 2 or Size.Y < 2 then
			local Camera = workspace.CurrentCamera
			if not Camera then return end
			Size = Camera.ViewportSize
		end
		if Size.X < 2 or Size.Y < 2 then return end
		local Aspect = Size.X / Size.Y
		local VisibleW = SpanX / SPAN_FRACTION
		Dist = VisibleW / (2 * TAN * Aspect)
		local HalfWordPx = 3.6 / (VisibleW / Aspect) * Size.Y
		Row.Position = UDim2New(0.5, 0, 0.5, Floor(HalfWordPx + 20))
		pcall(function() Timer.Visible = not Warned and Size.X * SPAN_FRACTION >= 440 end)
		Fitted = true
	end
	pcall(Fit)
	pcall(function()
		table.insert(Conns, Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() pcall(Fit) end))
	end)

	local StatusTween
	local function SetStatus(Str, Colour)
		Str = string.upper(tostring(Str))
		if StatusTween then
			pcall(function() StatusTween:Cancel() end)
			StatusTween = nil
		end
		pcall(function()
			Status.Text = Str
			Status.MaxVisibleGraphemes = 0
			if Colour then Status.TextColor3 = Colour end
		end)
		StatusTween = Tween(Status, {MaxVisibleGraphemes = #Str}, Clamp(#Str * 0.02, 0.15, 0.55), LINEAR)
	end

	local function Spaced(Str)
		local Out = {}
		for Index = 1, #Str do
			local Char = string.sub(Str, Index, Index)
			table.insert(Out, Char == " " and "  " or Char)
		end
		return table.concat(Out, " ")
	end

	local function SetTitle(Str)
		pcall(function() PlaceLabel.Text = string.upper(tostring(Str)) .. " / " .. PlaceText end)
	end

	local Value = Create("NumberValue", {Parent = Holder, Name = "\0", Value = 0})
	local High = 0

	local function SetProgress(Amount, Time)
		if type(Amount) ~= "number" or Amount ~= Amount then return end
		Amount = Clamp(Amount, 0, 1)
		if Amount <= High then return end
		High = Amount
		Tween(Value, {Value = Amount}, Time or 0.5, QUINT)
	end

	-- the menu's guis are held hidden while the loader plays out and handed back
	-- (with whatever Enabled the menu last asked for) once the loader starts fading
	local Holding = false
	local Released = false
	local Held = {}
	local HeldConns = {}

	local function Hold(Gui)
		if Released or Held[Gui] ~= nil then return end
		Held[Gui] = Gui.Enabled
		local Own = 0
		local function Hide()
			if Gui.Enabled then
				Own = Own + 1
				pcall(function() Gui.Enabled = false end)
			end
		end
		pcall(function()
			table.insert(HeldConns, Gui:GetPropertyChangedSignal("Enabled"):Connect(function()
				if Released then return end
				if not Gui.Enabled and Own > 0 then
					Own = Own - 1
					return
				end
				Held[Gui] = Gui.Enabled
				Hide()
			end))
		end)
		Hide()
	end

	local function Release()
		if Released then return end
		Released = true
		for _, Connection in HeldConns do
			pcall(function() Connection:Disconnect() end)
		end
		HeldConns = {}
		for Gui, Wanted in Held do
			pcall(function()
				if Gui.Parent then Gui.Enabled = Wanted end
			end)
		end
		Held = {}
	end

	local function ScanOnce()
		for _, Container in Containers do
			local Ok, Kids = pcall(Container.GetChildren, Container)
			if Ok then
				for _, Child in Kids do
					if not Known[Child] and Child ~= Holder and #Child.Name == 0
						and Child:IsA("ScreenGui") and Child:GetAttribute("__tbloader") == nil then
						Found = true
						if Holding then Hold(Child) end
					end
				end
			end
		end
	end

	local Dirty = true
	local NextSweep = 0
	for _, Container in Containers do
		pcall(function()
			table.insert(Conns, Container.ChildAdded:Connect(function()
				Dirty = true
				if Holding and not Released then task.defer(function() pcall(ScanOnce) end) end
			end))
		end)
	end

	local function Disconnect()
		local Copy = Conns
		Conns = {}
		for _, Connection in Copy do
			pcall(function() Connection:Disconnect() end)
		end
	end

	local function ForceDown()
		if Dead then return end
		Dead = true
		Alive = false
		Torn = true
		Queue = {}
		Release()
		pcall(function() if Blur then Blur:Destroy() end end)
		pcall(function() if Holder then Holder:Destroy() end end)
		task.defer(Disconnect)
	end

	pcall(function()
		table.insert(Conns, Holder.AncestryChanged:Connect(function(_, Parent)
			if Parent == nil then ForceDown() end
		end))
	end)

	local function Light(Voxel)
		Voxel.Lit = true
		Unlit = Unlit - 1
		pcall(function() Voxel.Part.Material = Enum.Material.Neon end)
		Tween(Voxel.Part, {Color = Voxel.Glow}, 0.35)
		pcall(function()
			TweenService:Create(Voxel.Part, TweenInfo.new(0.09, QUAD, OUT, 0, true), {Size = VOX * 1.22}):Play()
		end)
	end

	local function Explode()
		Exploding = true
		for _, Voxel in Voxels do
			pcall(function()
				Voxel.Part.Material = Enum.Material.Neon
				Voxel.Part.Color = Ink
			end)
			Tween(Voxel.Part, {Size = VOX * 1.3}, 0.14, QUAD, OUT)
		end
		After(0.14, function()
			if Torn then return end
			for _, Voxel in Voxels do
				local Pos = Voxel.Target.Position
				local Dir = Pos + Vector3New((Random_() - 0.5) * 6, (Random_() - 0.5) * 6, 5 + Random_() * 8)
				Dir = Dir.Magnitude > 0.01 and Dir.Unit or Vector3New(0, 0, 1)
				local Far = Pos + Dir * (40 + Random_() * 75)
				Tween(Voxel.Part, {Color = Voxel.Glow}, 0.6)
				Tween(Voxel.Part, {
					CFrame = CFrameNew(Far) * Angles(Random_() * 9, Random_() * 9, Random_() * 9),
					Size = SPECK,
				}, 1.4 + Random_() * 0.35, QUART, OUT)
			end
			Tween(View, {ImageTransparency = 1}, 0.9, QUART, IN, 0.45)
		end)
	end

	local function Collapse()
		Exploding = true
		for _, Voxel in Voxels do
			local Pos = Voxel.Target.Position
			pcall(function() Voxel.Part.Material = Enum.Material.SmoothPlastic end)
			Tween(Voxel.Part, {Color = Ember}, 0.4)
			Tween(Voxel.Part, {
				CFrame = CFrameNew(Pos.X, Pos.Y - 45, Pos.Z) * Angles(Random_() * 3, 0, Random_() * 3),
			}, 0.9 + Random_() * 0.4, QUAD, IN, 0.35 + Voxel.Nx * 0.45)
		end
	end

	local function Unload()
		if Torn then return end
		Torn = true
		Alive = false
		Release()

		Tween(View, {ImageTransparency = 1}, 0.5)
		Tween(RuleLine, {Size = UDim2New(0, 0, 0, 1)}, 0.45, QUINT, IN)
		Tween(Marker, {Size = FromOffset(2, 0)}, 0.3, QUINT)
		for _, Label in Texts do Tween(Label, {TextTransparency = 1}, 0.25) end
		Tween(Title, {TextTransparency = 1}, 0.25)
		for _, Flank in Flanks do Tween(Flank, {Size = FromOffset(0, 1)}, 0.3, QUINT, IN) end
		for _, V in Vign do Tween(V, {BackgroundTransparency = 1}, 0.4) end

		After(0.2, function()
			Tween(Wash, {BackgroundTransparency = 1}, 0.5)
			if Blur then Tween(Blur, {Size = 0}, 0.5) end
		end)

		After(0.9, ForceDown)
	end

	local function Finish(Str)
		At(Assembled + 0.15, function()
			if not Alive then return end
			Ended = true
			SetStatus(Str, Ink)
			pcall(function() Marker.BackgroundTransparency = 0 end)
			SetProgress(1, 0.5)
			After(0.85, function()
				if not Alive then return end
				Explode()
				After(1.45, Unload)
			end)
		end)
	end

	local function Fail(Str)
		At(Assembled + 0.15, function()
			if not Alive then return end
			Ended = true
			SetStatus(Str, Accent)
			pcall(function() Marker.BackgroundTransparency = 0 end)
			Collapse()
			After(2.2, Unload)
		end)
	end

	local Awaiting = false
	local AwaitDeadline = 0
	local NextCreep = 0
	local LastPct, LastTime = -1, -1

	local function Frame(Delta)
		Clock = Clock + (Delta < 0.1 and Delta or 0.1)
		local Moment = Now()

		Drain(Moment)
		if Dead then return end

		if not Fitted then pcall(Fit) end

		local Settle = Clamp(Moment / Max(Assembled, 1), 0, 1)
		local Ease = 1 - (1 - Settle) ^ 3
		local Yaw = Sin(Clock * 0.45) * 0.15 * Ease + (1 - Ease) * 0.75
		local Pitch = 0.08 + Sin(Clock * 0.33) * 0.035
		Cam.CFrame = Angles(0, Yaw, 0) * Angles(-Pitch, 0, 0) * CFrameNew(0, 0, Dist * (0.7 + 0.3 * Ease))

		if not Alive then return end

		if Dirty or Clock >= NextSweep then
			Dirty = false
			NextSweep = Clock + 0.25
			pcall(ScanOnce)
		end

		if Awaiting and not Done then
			if Found then
				Awaiting = false
				Done = true
				Finish(string.format("Ready in %.2fs", Moment))
			elseif Clock >= AwaitDeadline then
				Awaiting = false
				Done = true
				Fail("Took too long, try again")
			elseif Moment >= NextCreep then
				NextCreep = Moment + 0.35
				SetProgress(0.35 + 0.57 * (1 - Exp(-Moment / 7)), 0.45)
			end
		end

		local Progress = Value and Value.Value or 0
		if Progress ~= Progress then Progress = 0 end
		Progress = Clamp(Progress, 0, 1)
		RuleFill.Size = UDim2New(Progress, 0, 1, 0)

		if Unlit > 0 and not Exploding then
			for Index = 1, #Voxels do
				local Voxel = Voxels[Index]
				if not Voxel.Lit and Progress >= Voxel.Nx and Moment >= Voxel.LandAt then
					Light(Voxel)
				end
			end
		end

		local Pct = Clamp(Floor(Progress * 100 + 0.5), 0, 100)
		if Pct ~= LastPct then
			LastPct = Pct
			Percent.Text = Pct .. "%"
		end

		if Ended then return end

		Marker.BackgroundTransparency = 0.1 + (0.5 + 0.5 * Sin(Clock * 4.2)) * 0.6

		local Rounded = Floor(Moment * 100)
		if Rounded ~= LastTime then
			LastTime = Rounded
			Timer.Text = string.format("%.2fS", Moment)
		end
	end

	local Faults = 0
	pcall(function()
		table.insert(Conns, RunService.RenderStepped:Connect(function(Delta)
			if Dead then return end
			if Holder.Parent == nil then
				ForceDown()
				return
			end
			if not pcall(Frame, Delta) then
				Faults = Faults + 1
				if Faults > 45 then ForceDown() end
			end
		end))
	end)

	if Blur then Tween(Blur, {Size = 22}, 0.8, EXPO) end
	Tween(Wash, {BackgroundTransparency = 0.25}, 0.6)
	for _, V in Vign do Tween(V, {BackgroundTransparency = 0.35}, 0.7, QUART) end

	local Launched = Now()
	for _, Voxel in Voxels do
		local Delay = 0.3 + Voxel.Nx * 0.9 + Random_() * 0.25
		local Time = 1.25 + Random_() * 0.2
		Voxel.LandAt = Launched + Delay + Time
		if Voxel.LandAt > Assembled then Assembled = Voxel.LandAt end
		Tween(Voxel.Part, {CFrame = Voxel.Target, Size = VOX}, Time, EXPO, OUT, Delay)
	end

	At(Assembled - 0.7, function()
		if not Alive then return end
		Tween(RuleLine, {Size = UDim2New(1, 0, 0, 1)}, 1.0, EXPO)
	end)

	At(Assembled - 0.3, function()
		if not Alive then return end
		Revealed = true
		Tween(Marker, {Size = FromOffset(2, 14)}, 0.5, QUINT)
		for Index, Label in Texts do
			Tween(Label, {TextTransparency = 0}, 0.45, QUART, OUT, Index * 0.04)
		end
		if Status and Status.Text == "" then SetStatus("Initializing") end
	end)

	task.delay(120, function()
		if not Torn then After(0, Unload) end
	end)
	task.delay(128, ForceDown)

	local API = {}

	function API.Status(Str)
		if not Alive or Done then return end
		Str = tostring(Str)
		At(0, function() if Alive and not Done then SetStatus(Str) end end)
	end

	function API.SetGame(Str)
		Str = tostring(Str)
		At(0, function() if Alive then SetTitle(Str) end end)
	end

	function API.Progress(Amount, Time)
		if not Alive or Done then return end
		Amount = tonumber(Amount)
		if not Amount then return end
		Time = tonumber(Time)
		At(0, function() if Alive and not Done then SetProgress(Amount, Time) end end)
	end

	function API.MenuLoaded()
		return Found
	end

	function API.AwaitMenu(Timeout)
		if Awaiting or Done or not Alive then return end
		Timeout = tonumber(Timeout) or 45
		Holding = true
		At(0, function()
			if Awaiting or Done or not Alive then return end
			SetStatus("Loading script")
			AwaitDeadline = Clock + Timeout
			NextCreep = 0
			Awaiting = true
		end)
	end

	function API.Reject(Str)
		if not Alive then return end
		At(Assembled + 0.15, function()
			if not Alive then return end
			Done = true
			Ended = true
			SetStatus(Str or "Unsupported game", Accent)
			pcall(function() Marker.BackgroundTransparency = 0 end)
			Collapse()
			After(2.6, Unload)
		end)
	end

	function API.Warn(Str)
		Str = string.upper(tostring(Str))
		At(0, function()
			if not Alive then return end
			Warned = true
			pcall(function() Timer.Visible = false end)
			pcall(function() WarnLabel.Text = Str end)
			if Revealed then Tween(WarnLabel, {TextTransparency = 0}, 0.45, QUART) end
		end)
	end

	function API.Step(StepOrTime)
		if not Alive or Done then return end
		if StepOrTime == 1 then
			API.Status("Authenticating")
			API.Progress(0.3)
		elseif StepOrTime == 2 then
			API.Status("Connecting to servers")
			API.Progress(0.55)
		else
			API.AwaitMenu()
		end
	end

	return API
end)

local Built, UI = pcall(Builder)

local Env = _G
pcall(function() if getgenv then Env = getgenv() end end)

if Built and type(UI) == "table" and type(UI.Step) == "function" then
	-- this LuaProt build breaks when LP_CUSTOM_LOADER is defined, so we never set it;
	-- the loader instead watches for the menu to appear (UI.AwaitMenu) and finishes then
	pcall(function() Env.LP_CUSTOM_LOADER = nil end)
	Env.__tb_loader_ui = UI
	local Needed = { "hookmetamethod", "hookfunction", "getgc", "getconnections", "getnamecallmethod", "newcclosure", "getrawmetatable" }
	local Missing = 0
	for _, Name in Needed do
		local Ok, F = pcall(function() return Env[Name] end)
		if not Ok or type(F) ~= "function" then Missing = Missing + 1 end
	end
	if Missing > 0 then
		pcall(UI.Warn, "Limited executor support")
	end
else
	pcall(warn, "[tomboy.loader] ui failed: " .. tostring(UI))
	pcall(function() Env.LP_CUSTOM_LOADER = nil end)
	Env.__tb_loader_ui = nil
end

end

local GAMES = {
	{
		Name = "Project Delta",
		Places = { [7336302630] = true, [7353845952] = true, [73594312486948] = true },
		Url = "https://luaprot.net/api/v3/loaders/get/92831408182287630702",
	},
	{
		Name = "Fust Survival",
		Places = { [79862723087324] = true },
		Url = "https://luaprot.net/api/v3/loaders/get/70326341049745107066",
	},
}

local Env = getgenv and getgenv() or _G
local UI = Env.__tb_loader_ui
local MySeq = Env.__tb_loader_seq

if type(loadstring) ~= "function" then
	if UI then pcall(UI.Reject, "Executor not supported") end
	return
end
local PlaceId = game.PlaceId
local Current
for _, G in ipairs(GAMES) do
	if G.Places[PlaceId] then Current = G break end
end

if not Current then
	if UI then pcall(UI.Reject, "This game is not supported") end
	return
end

if UI then pcall(UI.SetGame, Current.Name) end

local function Fetch(Url)
	for Try = 1, 2 do
		local Ok, Body = pcall(game.HttpGet, game, Url)
		if Ok and type(Body) == "string" and #Body > 0 then
			local Fn = loadstring(Body)
			if Fn then return Fn end
		end
		if Try == 1 then task.wait(1) end
	end
end

local Run = Fetch(Current.Url)
if Env.__tb_loader_seq ~= MySeq then return end
if not Run then
	if UI then pcall(UI.Reject, "Couldn't reach the server") end
	return
end

if UI then pcall(UI.AwaitMenu, 45) end
local Ok = pcall(Run)
if not Ok and UI then pcall(UI.Reject, "Script failed to start") end
