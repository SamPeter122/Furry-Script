do

local Names = {
	[7336302630] = "Project Delta",
	[7353845952] = "Project Delta",
	[73594312486948] = "Project Delta",
	[292439477] = "Phantom Forces",
}

local GameName = "Project Delta"
pcall(function() GameName = Names[game.PlaceId] or "Project Delta" end)

-- the whole build is wrapped: if anything in here throws, the consumer still
-- gets a callable LP_CUSTOM_LOADER instead of indexing a nil
local Built, UI = pcall(function()

	local TweenService = game:GetService("TweenService")
	local RunService   = game:GetService("RunService")
	local Lighting     = game:GetService("Lighting")

	local Containers = {}
	do
		local Seen = {}
		local function Add(Container)
			if Container and not Seen[Container] then
				Seen[Container] = true
				table.insert(Containers, Container)
			end
		end
		pcall(function() Add(game:GetService("CoreGui")) end)
		pcall(function() if gethui then Add(gethui()) end end)
	end

	local hui = Containers[#Containers]
	if not hui then
		hui = game:GetService("CoreGui")
		table.insert(Containers, hui)
	end

	local FromRGB = Color3.fromRGB
	local UDim2New = UDim2.new
	local FromOffset = UDim2.fromOffset
	local Vector2New = Vector2.new
	local Floor = math.floor
	local Min = math.min
	local Clamp = math.clamp

	local Ink    = FromRGB(255, 255, 255)
	local Accent = FromRGB(229, 79, 82)
	local Quiet  = FromRGB(128, 128, 130)
	local Hush   = FromRGB(70, 70, 72)
	local Rule   = FromRGB(48, 48, 50)

	-- a nil FontFace is simply never assigned, so a client missing a family
	-- falls back to the default font instead of erroring
	local Display, Body, Mono
	pcall(function() Display = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold) end)
	pcall(function() Body    = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium) end)
	pcall(function() Mono    = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Medium) end)
	Mono = Mono or Body

	local EXPO  = Enum.EasingStyle.Exponential
	local QUINT = Enum.EasingStyle.Quint
	local QUART = Enum.EasingStyle.Quart
	local OUT   = Enum.EasingDirection.Out

	local Conns     = {}
	local Alive     = true
	local Done      = false
	local Awaiting  = false
	local BuildTime = os.clock()

	local Unload  -- forward declared: the watchdogs below need it

	local function Tween(Item, Goal, Time, Style, Dir)
		if typeof(Item) ~= "Instance" or Item.Parent == nil then return end
		local Ok, Handle = pcall(function()
			return TweenService:Create(Item,
				TweenInfo.new(Time or 0.25, Style or QUART, Dir or OUT), Goal)
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

	----------------------------------------------------------------
	-- clear anything a previous inject left behind
	----------------------------------------------------------------

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
		Parent = hui,
		Name = "\0",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 1000002,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	})
	if not Holder then error("holder") end
	pcall(function() Holder:SetAttribute("__tbloader", true) end)

	local Blur
	pcall(function()
		Blur = Create("BlurEffect", {Parent = Lighting, Size = 0})
		if Blur then Blur:SetAttribute("__tbloader", true) end
	end)

	local Wash = Create("Frame", {
		Parent = Holder,
		Name = "\0",
		Size = UDim2New(1, 0, 1, 0),
		BackgroundColor3 = FromRGB(6, 6, 7),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 1,
	})

	-- everything lives on one left-aligned column
	local MARGIN = 0.105
	local RIGHT  = 0.105
	local PAGE_H = 380

	local Page = Create("Frame", {
		Parent = Holder,
		Name = "\0",
		Size = UDim2New(1 - MARGIN - RIGHT, 0, 0, PAGE_H),
		Position = UDim2New(MARGIN, 0, 0.5, 0),
		AnchorPoint = Vector2New(0, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	-- small windows and odd aspect ratios get scaled down rather than clipped
	local PageScale = Create("UIScale", {Parent = Page, Name = "\0", Scale = 1})
	local function Fit()
		local Camera = workspace.CurrentCamera
		if not Camera or not PageScale then return end
		local View = Camera.ViewportSize
		if View.X < 1 or View.Y < 1 then return end
		local Factor = Clamp(Min(View.X / 1280, View.Y / 720), 0.55, 1)
		PageScale.Scale = Factor
		-- children scale from the top-left, so nudge the page back to centre
		Page.Position = UDim2New(MARGIN, 0, 0.5, Floor(PAGE_H * (1 - Factor) / 2))
	end
	pcall(Fit)
	pcall(function()
		table.insert(Conns, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize")
			:Connect(function() pcall(Fit) end))
	end)

	-- wipe reveal: a clipping window whose width opens
	local function Wipe(Height, Y, Z)
		return Create("Frame", {
			Parent = Page,
			Name = "\0",
			Size = UDim2New(0, 0, 0, Height),
			Position = FromOffset(0, Y),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = Z or 3,
		})
	end

	local function Word(Parent, Text, Size, Colour, Y)
		return Create("TextLabel", {
			Parent = Parent,
			Name = "\0",
			FontFace = Display,
			Text = Text,
			TextColor3 = Colour,
			TextSize = Size,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Position = FromOffset(0, Y or 0),
			Size = UDim2New(2, 0, 0, Size + 10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
		})
	end

	local W1 = Wipe(76, 0)
	Word(W1, "TOMBOY", 68, Accent)
	local W2 = Wipe(76, 78)
	Word(W2, "HOOK", 68, Ink)

	-- hairline that splits the wordmark
	local Split = Create("Frame", {
		Parent = Page,
		Name = "\0",
		Position = FromOffset(0, 77),
		Size = FromOffset(0, 1),
		BackgroundColor3 = Rule,
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	local KickerWipe = Wipe(16, 172)
	Create("TextLabel", {
		Parent = KickerWipe,
		Name = "\0",
		FontFace = Mono,
		Text = GameName:upper(),
		TextColor3 = Quiet,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2New(2, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
	})

	local Dot = Create("Frame", {
		Parent = Page,
		Name = "\0",
		AnchorPoint = Vector2New(1, 0.5),
		Position = UDim2New(1, 0, 0, 77),
		Size = FromOffset(5, 5),
		BackgroundColor3 = Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	local StatusWipe = Wipe(16, 196)
	local Status = Create("TextLabel", {
		Parent = StatusWipe,
		Name = "\0",
		FontFace = Mono,
		Text = "INITIALIZING",
		TextColor3 = Hush,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2New(2, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
	})

	----------------------------------------------------------------
	-- odometer numeral, bottom right of the page
	----------------------------------------------------------------

	local DIGIT_H = 108
	local DIGIT_W = 62

	local Numeral = Create("Frame", {
		Parent = Page,
		Name = "\0",
		Size = FromOffset(DIGIT_W * 3 + 30, DIGIT_H),
		Position = UDim2New(1, 0, 0, 150),
		AnchorPoint = Vector2New(1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	local Slots = {}
	for Slot = 1, 3 do
		local Window = Create("Frame", {
			Parent = Numeral,
			Name = "\0",
			Size = FromOffset(DIGIT_W, DIGIT_H),
			Position = FromOffset((Slot - 1) * DIGIT_W, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 3,
		})
		local Column = Create("Frame", {
			Parent = Window,
			Name = "\0",
			Size = FromOffset(DIGIT_W, DIGIT_H * 10),
			Position = FromOffset(0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 3,
		})
		local Labels = {}
		for Digit = 0, 9 do
			local Label = Create("TextLabel", {
				Parent = Column,
				Name = "\0",
				FontFace = Display,
				Text = (Slot == 1 and Digit == 0) and "" or tostring(Digit),
				TextColor3 = Ink,
				TextSize = 96,
				TextTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Position = FromOffset(0, Digit * DIGIT_H),
				Size = FromOffset(DIGIT_W, DIGIT_H),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 4,
			})
			if Label then table.insert(Labels, Label) end
		end
		Slots[Slot] = {Column = Column, Shown = 0, Labels = Labels}
	end

	local PctMark = Create("TextLabel", {
		Parent = Numeral,
		Name = "\0",
		FontFace = Body,
		Text = "%",
		TextColor3 = Hush,
		TextSize = 22,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = FromOffset(DIGIT_W * 3 + 6, 26),
		Size = FromOffset(24, 24),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 4,
	})

	----------------------------------------------------------------
	-- progress hairline + footer
	----------------------------------------------------------------

	local TrackY = 292

	local Track = Create("Frame", {
		Parent = Page,
		Name = "\0",
		Position = FromOffset(0, TrackY),
		Size = UDim2New(0, 0, 0, 1),
		BackgroundColor3 = Rule,
		BorderSizePixel = 0,
		ZIndex = 3,
	})
	local Fill = Create("Frame", {
		Parent = Track,
		Name = "\0",
		Size = UDim2New(0, 0, 1, 0),
		BackgroundColor3 = Ink,
		BorderSizePixel = 0,
		ZIndex = 4,
	})
	local Nib = Create("Frame", {
		Parent = Track,
		Name = "\0",
		Size = FromOffset(1, 9),
		AnchorPoint = Vector2New(0, 0.5),
		Position = UDim2New(0, 0, 0.5, 0),
		BackgroundColor3 = Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	local FootWipe = Wipe(14, 312)
	local function Foot(Text, X)
		return Create("TextLabel", {
			Parent = FootWipe,
			Name = "\0",
			FontFace = Mono,
			Text = Text,
			TextColor3 = Hush,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2New(X, 0, 0, 0),
			Size = UDim2New(0.4, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
		})
	end

	local PlaceText, Session = "LOCAL", "LOCAL"
	pcall(function() PlaceText = tostring(game.PlaceId) end)
	pcall(function()
		local Job = tostring(game.JobId):gsub("%-", ""):sub(1, 10)
		if #Job > 0 then Session = Job:upper() end
	end)

	Foot("PLACE " .. PlaceText, 0)
	Foot("SESSION " .. Session, 0.26)
	local Timer = Foot("0.00s", 0.52)

	----------------------------------------------------------------
	-- entrance
	----------------------------------------------------------------

	if Blur then
		Tween(Blur, {Size = 24}, 0.7, EXPO)
	end
	Tween(Wash, {BackgroundTransparency = 0.12}, 0.5)

	local function OpenWipe(Window, Delay, Width, Time)
		if not Window then return end
		task.delay(Delay, function()
			if not Alive then return end
			Tween(Window, {Size = UDim2New(0, Width, 0, Window.Size.Y.Offset)}, Time or 0.75, EXPO)
		end)
	end

	OpenWipe(W1, 0.10, 620, 0.8)
	OpenWipe(W2, 0.17, 620, 0.8)

	task.delay(0.22, function()
		if not Alive then return end
		Tween(Split, {Size = UDim2New(1, 0, 0, 1)}, 0.9, EXPO)
	end)

	OpenWipe(KickerWipe, 0.38, 420, 0.6)
	OpenWipe(StatusWipe, 0.44, 420, 0.6)
	OpenWipe(FootWipe, 0.58, 900, 0.7)

	task.delay(0.4, function()
		if not Alive then return end
		Tween(Dot, {BackgroundTransparency = 0}, 0.3)
		Tween(Track, {Size = UDim2New(1, 0, 0, 1)}, 0.9, EXPO)
	end)

	task.delay(0.5, function()
		if not Alive then return end
		Tween(PctMark, {TextTransparency = 0}, 0.5)
		Tween(Nib, {BackgroundTransparency = 0}, 0.4)
		for _, Slot in Slots do
			for _, Label in Slot.Labels do
				Tween(Label, {TextTransparency = 0}, 0.5)
			end
		end
	end)

	----------------------------------------------------------------
	-- menu capture
	--
	-- this hides the user's menu, so every path out of here has to put it
	-- back. ReleaseMenu is idempotent and is called from unload, from the
	-- watchdogs, and from the holder being destroyed by anything else.
	----------------------------------------------------------------

	local Held = {}

	local function ReleaseMenu()
		local Copy = Held
		Held = {}
		for _, Gui in Copy do
			pcall(function() Gui.Enabled = true end)
		end
	end

	local Dirty = true
	for _, Container in Containers do
		pcall(function()
			table.insert(Conns, Container.ChildAdded:Connect(function() Dirty = true end))
		end)
	end

	local function ScanOnce()
		for _, Container in Containers do
			for _, Child in Container:GetChildren() do
				if Child ~= Holder and Child:IsA("ScreenGui") and #Child.Name == 0
					and Child:GetAttribute("__tbloader") == nil and Child.Enabled then
					Child.Enabled = false
					if not table.find(Held, Child) then table.insert(Held, Child) end
				end
			end
		end
	end

	local function Disconnect()
		local Copy = Conns
		Conns = {}
		for _, Connection in Copy do
			pcall(function() Connection:Disconnect() end)
		end
	end

	-- every abnormal exit goes through here, so no path can forget a step.
	-- safe to call repeatedly.
	local function ForceDown()
		Alive = false
		ReleaseMenu()
		pcall(function() if Blur then Blur:Destroy() end end)
		pcall(function() if Holder then Holder:Destroy() end end)
		task.defer(Disconnect)
	end

	-- if anything else destroys the holder, still hand the menu back
	pcall(function()
		table.insert(Conns, Holder.AncestryChanged:Connect(function(_, Parent)
			if Parent == nil then ForceDown() end
		end))
	end)

	----------------------------------------------------------------
	-- per frame
	----------------------------------------------------------------

	local Value = Create("NumberValue", {Parent = Holder, Name = "\0", Value = 0})

	local Clock, NextSweep, LastPct, LastTime = 0, 0, -1, -1

	local function SetDigit(Slot, Digit)
		local Entry = Slots[Slot]
		if not Entry or not Entry.Column or Entry.Shown == Digit then return end
		Entry.Shown = Digit
		Tween(Entry.Column, {Position = FromOffset(0, -Digit * DIGIT_H)}, 0.55, EXPO)
	end

	local function Frame(Delta)
		Clock = Clock + Delta

		if Dirty or Clock >= NextSweep then
			Dirty = false
			NextSweep = Clock + 0.25
			pcall(ScanOnce)
		end

		local Progress = Value and Value.Value or 0
		Fill.Size = UDim2New(Progress, 0, 1, 0)
		Nib.Position = UDim2New(Progress, 0, 0.5, 0)

		local Pct = Floor(Progress * 100 + 0.5)
		if Pct ~= LastPct then
			LastPct = Pct
			SetDigit(1, Floor(Pct / 100))
			SetDigit(2, Floor(Pct / 10) % 10)
			SetDigit(3, Pct % 10)
		end

		if not Done then
			local Seconds = os.clock() - BuildTime
			local Rounded = Floor(Seconds * 100)
			if Rounded ~= LastTime then
				LastTime = Rounded
				Timer.Text = ("%.2fs"):format(Seconds)
			end
		end
	end

	-- a broken frame must never turn into an error every frame forever
	local Faults = 0
	pcall(function()
		table.insert(Conns, RunService.RenderStepped:Connect(function(Delta)
			if not Alive then return end

			-- if anything else destroyed the holder, hand the menu back.
			-- this lives on RunService, not on the holder, so it still runs
			-- after the holder is gone - the holder's own events do not.
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

	local Base = "INITIALIZING"
	task.spawn(function()
		local Dots = {"", ".", "..", "..."}
		local Index = 1
		while Alive and not Done do
			pcall(function()
				if Done then return end
				Status.Text = Base .. Dots[Index]
			end)
			Index = Index % #Dots + 1
			task.wait(0.34)
		end
	end)

	----------------------------------------------------------------
	-- teardown
	----------------------------------------------------------------

	local Torn = false

	function Unload()
		if Torn then return end
		Torn = true
		Alive = false

		if Blur then Tween(Blur, {Size = 0}, 0.5) end
		Tween(Wash, {BackgroundTransparency = 1}, 0.5)
		for _, Window in {W1, W2, KickerWipe, StatusWipe, FootWipe} do
			if Window then
				Tween(Window, {Size = UDim2New(0, 0, 0, Window.Size.Y.Offset)}, 0.45, QUINT)
			end
		end
		Tween(Split, {Size = UDim2New(0, 0, 0, 1)}, 0.4, QUINT)
		Tween(Track, {Size = UDim2New(0, 0, 0, 1)}, 0.45, QUINT)
		Tween(Dot,     {BackgroundTransparency = 1}, 0.3)
		Tween(Nib,     {BackgroundTransparency = 1}, 0.3)
		Tween(PctMark, {TextTransparency = 1}, 0.3)
		for _, Slot in Slots do
			for _, Label in Slot.Labels do
				Tween(Label, {TextTransparency = 1}, 0.35)
			end
		end

		task.delay(0.7, function()
			Disconnect()
			pcall(function() if Blur then Blur:Destroy() end end)
			pcall(function() Holder:Destroy() end)
			ReleaseMenu()
		end)
	end

	-- nothing may sit on the user's screen, or hold their menu hidden,
	-- longer than this - whatever the caller does or fails to do
	task.delay(75, function()
		if not Torn then
			pcall(Unload)
		end
	end)
	task.delay(82, ForceDown)

	----------------------------------------------------------------
	-- api
	----------------------------------------------------------------

	local API = {}

	function API.Status(Text)
		if not Alive then return end
		Base = tostring(Text):upper()
	end

	function API.Progress(Amount, Time)
		if not Alive or not Value then return end
		Amount = tonumber(Amount)
		if not Amount then return end
		Tween(Value, {Value = Clamp(Amount, 0, 1)}, tonumber(Time) or 0.4, QUINT)
	end

	function API.Finish(Text, Dwell)
		if Done or not Alive then return end
		Done = true
		Tween(Value, {Value = 1}, 0.35, QUINT)
		pcall(function()
			Status.Text = tostring(Text):upper()
			Status.TextColor3 = Ink
		end)
		Tween(Fill,  {BackgroundColor3 = Accent}, 0.3)
		Tween(Split, {BackgroundColor3 = Accent}, 0.25)
		task.delay(tonumber(Dwell) or 1.5, function() pcall(Unload) end)
	end

	function API.Fail(Text)
		if Done or not Alive then return end
		Done = true
		pcall(function()
			Status.Text = tostring(Text):upper()
			Status.TextColor3 = Accent
		end)
		Tween(Fill, {BackgroundColor3 = Accent}, 0.3)
		task.delay(2.5, function() pcall(Unload) end)
	end

	function API.MenuLoaded()
		return #Held > 0
	end

	function API.AwaitMenu(Timeout)
		if Awaiting or Done or not Alive then return end
		Awaiting = true
		task.spawn(function()
			API.Status("Loading script")
			local Deadline = os.clock() + (tonumber(Timeout) or 45)
			local NextCreep = 0
			repeat
				task.wait(0.05)
				if os.clock() >= NextCreep then
					NextCreep = os.clock() + 0.35
					local Since = os.clock() - BuildTime
					API.Progress(0.35 + 0.57 * (1 - math.exp(-Since / 7)), 0.4)
				end
			until API.MenuLoaded() or os.clock() > Deadline or not Alive

			if not Alive then return end
			if API.MenuLoaded() then
				API.Finish(("Ready in %.2fs"):format(os.clock() - BuildTime), 0.7)
			else
				API.Fail("Timed out waiting for script")
			end
		end)
	end

	function API.Step(StepOrTime)
		if not Alive then return end
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

if Built and type(UI) == "table" and type(UI.Step) == "function" then
	getgenv().LP_CUSTOM_LOADER = function(...)
		-- a throw in here must never take the calling script down
		pcall(UI.Step, ...)
	end
else
	warn("[tomboy.loader] init failed: " .. tostring(UI))
	getgenv().LP_CUSTOM_LOADER = function() end
end

end

do end

("LuaProt V2 Loader - Unauthorized tampering or debugging of protected scripts is strictly prohibited and will result in a global blacklist from all LuaProt protected scripts."):sub(1,1);local f,c,v="92831408182287630702",http and http.request or request,function(h)while task.wait()do pcall(function()game:GetService"Players".LocalPlayer:Kick(h)local v=game:GetService"CoreGui".RobloxPromptGui.promptOverlay.ErrorPrompt;v.TitleFrame.ErrorTitle.Text="LuaProt"v.MessageArea.ErrorFrame.ErrorMessage.Text=h end)end end;lp_key=lp_key or"x"local b,o,h,k,d;o={"eu-1","eu-2","us-1"}h,k=pcall(c,{Url="https://eu-1.luaprot.net/api/v1/nodes/get"})if h and k and k.StatusCode==200 then pcall(function()d=game:GetService"HttpService":JSONDecode(k.Body)end)if d and d.success and d.node then for i,n in o do if n==d.node then table.insert(o,1,table.remove(o,i))break end end end end;for _,p in o do local r,y=os.clock()task.spawn(pcall,function()y=c{Url="https://"..p..".luaprot.net/api/v2/loader/get?key="..lp_key.."&scriptId="..f}end)repeat task.wait()until os.clock()-r>15 or y;if y and({[200]=1,[201]=1})[y.StatusCode]then LP_NODE=p;b=loadstring(y.Body)if b then break end end end;if b then b(LP_NODE)else v("V2 loader failed to load script. Report this and try again later!")end

