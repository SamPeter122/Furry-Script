local PhantomForces = {
	[292439477] = true,
}

local IsPF = PhantomForces[game.PlaceId] == true

local UI = (function()
	local TweenService = game:GetService("TweenService")
	local RunService   = game:GetService("RunService")
	local hui = (gethui or function() return game:GetService("CoreGui") end)()

	local FromRGB = Color3.fromRGB
	local FromHex = Color3.fromHex
	local UDim2New = UDim2.new
	local Vector2New = Vector2.new
	local NumSequence = NumberSequence.new
	local NumSequenceKeypoint = NumberSequenceKeypoint.new

	local Theme = {
		Accent       = FromRGB(179, 5, 76),
		Background1  = FromRGB(20, 20, 20),
		Text         = FromRGB(255, 255, 255),
		Element      = FromHex("#1c1c1c"),
		InactiveText = FromRGB(185, 185, 185),
		Border       = FromHex("#323232"),
	}

	local Font_ = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)

	local TweenTime  = 0.25
	local TweenStyle = Enum.EasingStyle.Quart
	local TweenDir   = Enum.EasingDirection.Out
	local FadeSpeed  = 0.2

	local Conns     = {}
	local Alive     = true
	local Done      = false
	local Started   = false
	local Awaiting  = false
	local BuildTime = os.clock()

	local function Tween(Item, Goal, Time)
		local T = TweenService:Create(Item,
			TweenInfo.new(Time or TweenTime, TweenStyle, TweenDir), Goal)
		T:Play()
		return T
	end

	local function Create(Class, Properties)
		local Item = Instance.new(Class)
		for Property, Value in Properties do
			Item[Property] = Value
		end
		return Item
	end

	local Holder = Create("ScreenGui", {
		Parent = hui,
		Name = "\0",
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 10,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	})

	-- Every instance in the library is named "\0" (stored as an empty name), including
	-- this card. Tag it so any loader can tell a loader card apart from the real menu.
	pcall(function() Holder:SetAttribute("__tbloader", true) end)

	local CW, CH = 280, 82

	local Window = Create("Frame", {
		Parent = Holder,
		Name = "\0",
		AnchorPoint = Vector2New(0.5, 0.5),
		Position = UDim2New(0.5, 0, 0.5, 14),
		Size = UDim2New(0, CW, 0, CH),
		BorderColor3 = FromRGB(0, 0, 0),
		BorderSizePixel = 2,
		BackgroundColor3 = Theme.Background1,
		BackgroundTransparency = 1,
		ZIndex = 5,
	})

	local WindowScale = Create("UIScale", {
		Parent = Window,
		Name = "\0",
		Scale = 0.88,
	})

	local WindowStroke = Create("UIStroke", {
		Parent = Window,
		Name = "\0",
		Color = Theme.Accent,
		LineJoinMode = Enum.LineJoinMode.Miter,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = 1,
	})
	Create("UIGradient", {
		Parent = WindowStroke,
		Name = "\0",
		Rotation = 90,
		Transparency = NumSequence{
			NumSequenceKeypoint(0, 0),
			NumSequenceKeypoint(0.696, 0.2749999761581421),
			NumSequenceKeypoint(0.84, 0.574999988079071),
			NumSequenceKeypoint(1, 1)
		},
	})

	local Glow = Create("ImageLabel", {
		Parent = Window,
		Name = "\0",
		ImageColor3 = Theme.Accent,
		ScaleType = Enum.ScaleType.Slice,
		ImageTransparency = 1,
		BorderColor3 = FromRGB(0, 0, 0),
		BackgroundColor3 = FromRGB(255, 255, 255),
		Size = UDim2New(1, 25, 1, 25),
		AnchorPoint = Vector2New(0.5, 0.5),
		Image = "rbxassetid://18245826428",
		BackgroundTransparency = 1,
		Position = UDim2New(0.5, 0, 0.5, 0),
		ZIndex = 4,
		BorderSizePixel = 0,
		SliceCenter = Rect.new(Vector2New(21, 21), Vector2New(79, 79)),
	})
	Create("UIGradient", {
		Parent = Glow,
		Name = "\0",
		Rotation = 90,
		Transparency = NumSequence{NumSequenceKeypoint(0, 0), NumSequenceKeypoint(1, 1)},
	})

	local Title = Create("TextLabel", {
		Parent = Window,
		Name = "\0",
		FontFace = Font_,
		TextColor3 = Theme.Text,
		BorderColor3 = FromRGB(0, 0, 0),
		Text = "Tomboy.Hook",
		Position = UDim2New(0, 10, 0, 8),
		Size = UDim2New(0, 0, 0, 15),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		TextSize = 13,
		ZIndex = 5,
		BackgroundColor3 = FromRGB(255, 255, 255),
	})

	local Project = Create("TextLabel", {
		Parent = Window,
		Name = "\0",
		FontFace = Font_,
		TextColor3 = Theme.InactiveText,
		BorderColor3 = FromRGB(0, 0, 0),
		Text = IsPF and "Phantom Forces" or "Project Delta",
		AnchorPoint = Vector2New(1, 0),
		Position = UDim2New(1, -10, 0, 8),
		Size = UDim2New(0, 0, 0, 15),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0,
		TextSize = 13,
		ZIndex = 5,
		BackgroundColor3 = FromRGB(255, 255, 255),
	})

	local Liner = Create("Frame", {
		Parent = Window,
		Name = "\0",
		Position = UDim2New(0, 10, 0, 30),
		Size = UDim2New(1, -20, 0, 1),
		BorderColor3 = FromRGB(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 1,
		ZIndex = 5,
	})

	local Status = Create("TextLabel", {
		Parent = Window,
		Name = "\0",
		FontFace = Font_,
		TextColor3 = Theme.InactiveText,
		BorderColor3 = FromRGB(0, 0, 0),
		Text = "Initializing",
		Position = UDim2New(0, 10, 0, 38),
		Size = UDim2New(1, -70, 0, 15),
		BackgroundTransparency = 1,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		TextSize = 13,
		ZIndex = 5,
		BackgroundColor3 = FromRGB(255, 255, 255),
	})

	local Percent = Create("TextLabel", {
		Parent = Window,
		Name = "\0",
		FontFace = Font_,
		TextColor3 = Theme.Text,
		BorderColor3 = FromRGB(0, 0, 0),
		Text = "0%",
		AnchorPoint = Vector2New(1, 0),
		Position = UDim2New(1, -10, 0, 38),
		Size = UDim2New(0, 40, 0, 15),
		BackgroundTransparency = 1,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0,
		TextSize = 13,
		ZIndex = 5,
		BackgroundColor3 = FromRGB(255, 255, 255),
	})

	local BarTrack = Create("Frame", {
		Parent = Window,
		Name = "\0",
		Position = UDim2New(0, 10, 0, 60),
		Size = UDim2New(1, -20, 0, 6),
		BorderColor3 = FromRGB(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 1,
		ZIndex = 5,
	})

	local BarStroke = Create("UIStroke", {
		Parent = BarTrack,
		Name = "\0",
		Color = Theme.Border,
		LineJoinMode = Enum.LineJoinMode.Miter,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = 1,
	})

	local BarFill = Create("Frame", {
		Parent = BarTrack,
		Name = "\0",
		Size = UDim2New(0, 0, 1, 0),
		BorderColor3 = FromRGB(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 6,
	})

	local Shine = Create("Frame", {
		Parent = BarFill,
		Name = "\0",
		Size = UDim2New(0, 60, 1, 0),
		Position = UDim2New(0, -60, 0, 0),
		BorderColor3 = FromRGB(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Theme.Text,
		BackgroundTransparency = 1,
		ZIndex = 7,
	})
	Create("UIGradient", {
		Parent = Shine,
		Name = "\0",
		Transparency = NumSequence{
			NumSequenceKeypoint(0, 1),
			NumSequenceKeypoint(0.5, 0.55),
			NumSequenceKeypoint(1, 1)
		},
	})

	local Value = Create("NumberValue", {Parent = Holder, Name = "\0", Value = 0})

	local ShineX = -60
	table.insert(Conns, RunService.RenderStepped:Connect(function(Delta)
		BarFill.Size = UDim2New(Value.Value, 0, 1, 0)
		Percent.Text = math.floor(Value.Value * 100 + 0.5) .. "%"

		ShineX = ShineX + Delta * 250
		if ShineX > CW - 20 then ShineX = -60 end
		Shine.Position = UDim2New(0, ShineX, 0, 0)
	end))

	Tween(Window, {BackgroundTransparency = 0, Position = UDim2New(0.5, 0, 0.5, 0)}, 0.4)
	Tween(WindowScale, {Scale = 1}, 0.4)
	Tween(WindowStroke, {Transparency = 0}, 0.4)
	Tween(Glow, {ImageTransparency = 0.5}, 0.45)

	task.delay(0.12, function()
		if not Alive then return end
		Tween(Liner, {BackgroundTransparency = 0}, 0.3)
		Tween(Title, {TextTransparency = 0}, 0.3)
		Tween(Project, {TextTransparency = 0}, 0.3)
	end)

	task.delay(0.2, function()
		if not Alive then return end
		Tween(Status, {TextTransparency = 0}, 0.3)
		Tween(Percent, {TextTransparency = 0}, 0.3)
		Tween(BarTrack, {BackgroundTransparency = 0}, 0.3)
		Tween(BarStroke, {Transparency = 0}, 0.3)
		Tween(BarFill, {BackgroundTransparency = 0}, 0.3)
		Tween(Shine, {BackgroundTransparency = 0}, 0.3)
		if not Started then
			Tween(Value, {Value = 0.04})
		end
	end)

	local Base = "Initializing"

	task.spawn(function()
		local Dots = {"", ".", "..", "..."}
		local Index = 1
		while Alive and not Done do
			pcall(function() Status.Text = Base .. Dots[Index] end)
			Index = (Index % #Dots) + 1
			task.wait(0.35)
		end
	end)

	-- Menu GUIs we temporarily disabled so the card can finish before they appear
	local Held = {}

	local function HoldMenu()
		pcall(function()
			for _, Child in hui:GetChildren() do
				if Child ~= Holder
					and Child:IsA("ScreenGui")
					and #Child.Name == 0
					and Child:GetAttribute("__tbloader") == nil
					and Child.Enabled
				then
					Child.Enabled = false
					table.insert(Held, Child)
				end
			end
		end)
	end

	local function ReleaseMenu()
		for _, Gui in Held do
			pcall(function() Gui.Enabled = true end)
		end
		Held = {}
	end

	local function Unload()
		Alive = false

		Tween(Liner, {BackgroundTransparency = 1}, FadeSpeed)
		Tween(BarTrack, {BackgroundTransparency = 1}, FadeSpeed)
		Tween(BarStroke, {Transparency = 1}, FadeSpeed)
		Tween(BarFill, {BackgroundTransparency = 1}, FadeSpeed)
		Tween(Shine, {BackgroundTransparency = 1}, FadeSpeed)
		Tween(Title, {TextTransparency = 1}, FadeSpeed)
		Tween(Project, {TextTransparency = 1}, FadeSpeed)
		Tween(Status, {TextTransparency = 1}, FadeSpeed)
		Tween(Percent, {TextTransparency = 1}, FadeSpeed)

		Tween(Window, {BackgroundTransparency = 1, Position = UDim2New(0.5, 0, 0.5, 14)}, 0.3)
		Tween(WindowScale, {Scale = 0.9}, 0.3)
		Tween(WindowStroke, {Transparency = 1}, 0.3)
		Tween(Glow, {ImageTransparency = 1}, 0.3)

		task.delay(0.45, function()
			for _, Connection in Conns do
				pcall(function() Connection:Disconnect() end)
			end
			pcall(function() Holder:Destroy() end)
			ReleaseMenu()
		end)
	end

	local API = {}

	function API.Status(Text)
		Started = true
		Base = Text
	end

	function API.Progress(Amount, Time)
		Started = true
		Tween(Value, {Value = Amount}, Time)
	end

	function API.Finish(Text, Dwell)
		if Done then return end
		Done = true
		Started = true
		Tween(Value, {Value = 1}, 0.18)
		pcall(function()
			Status.Text = Text
			Status.TextColor3 = Theme.Text
		end)
		task.delay(Dwell or 1.5, Unload)
	end

	function API.Fail(Text)
		if Done then return end
		Done = true
		pcall(function() Status.Text = Text end)
		task.delay(2.5, Unload)
	end

	-- true once a ScreenGui that is not ours shows up in the UI container
	function API.MenuLoaded()
		local Ok, Container = pcall(function() return hui end)
		if not Ok or not Container then return false end
		local Found = false
		pcall(function()
			-- Roblox stores Name = "\0" as an empty string, so match on length, not "\0".
			-- Skip every loader card, not just our own, so a second injection does not
			-- mistake the first card for the menu.
			for _, Child in Container:GetChildren() do
				if Child ~= Holder
					and Child:IsA("ScreenGui")
					and #Child.Name == 0
					and Child:GetAttribute("__tbloader") == nil
				then
					Found = true
					break
				end
			end
		end)
		return Found
	end

	-- Hold the card until the menu actually exists. Authentication finishing is not the
	-- same as the script being ready -- it still has to fetch and build its library.
	function API.AwaitMenu(Timeout)
		if Awaiting or Done then return end
		Awaiting = true
		task.spawn(function()
			API.Status("Loading script")
			local Deadline = os.clock() + (Timeout or 45)
			local NextCreep = 0
			repeat
				task.wait(0.05)
				if os.clock() >= NextCreep then
					NextCreep = os.clock() + 0.3
					local Elapsed = os.clock() - BuildTime
					API.Progress(0.35 + 0.57 * (1 - math.exp(-Elapsed / 7)), 0.35)
				end
			until API.MenuLoaded() or os.clock() > Deadline

			if API.MenuLoaded() then
				-- Keep the menu hidden until the card has finished and faded out,
				-- so they do not sit on screen together.
				HoldMenu()
				API.Finish(("Loaded in %.2fs"):format(os.clock() - BuildTime), 0.45)
			else
				API.Fail("Timed out waiting for script")
			end
		end)
	end

	-- LuaProt's callback shape, used where the payload shares our environment
	function API.Step(StepOrTime)
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
end)()

if IsPF then

	-- Requires the CLEAN PF script on LuaProt (wrapper stripped). We dispatch to the
	-- actor thread ourselves; that thread has isolated globals, so LuaProt cannot call
	-- back into this UI and we drive the card locally instead.
	task.spawn(function()
		UI.Status("Authenticating")
		UI.Progress(0.3)
		task.wait(0.45)
		UI.AwaitMenu()
	end)

	;("LuaProt V2 Loader - Unauthorized tampering or debugging of protected scripts is strictly prohibited and will result in a global blacklist from all LuaProt protected scripts."):sub(1,1);local f,c,v="41584802510542174988",http and http.request or request,function(h)while task.wait()do pcall(function()game:GetService"Players".LocalPlayer:Kick(h)local v=game:GetService"CoreGui".RobloxPromptGui.promptOverlay.ErrorPrompt;v.TitleFrame.ErrorTitle.Text="LuaProt"v.MessageArea.ErrorFrame.ErrorMessage.Text=h end)end end;lp_key=lp_key or"x"local b,o,h,k,d,SRC;o={"eu-1","eu-2","us-1"}h,k=pcall(c,{Url="https://eu-1.luaprot.net/api/v1/nodes/get"})if h and k and k.StatusCode==200 then pcall(function()d=game:GetService"HttpService":JSONDecode(k.Body)end)if d and d.success and d.node then for i,n in o do if n==d.node then table.insert(o,1,table.remove(o,i))break end end end end;for _,p in o do local r,y=os.clock()task.spawn(pcall,function()y=c{Url="https://"..p..".luaprot.net/api/v2/loader/get?key="..lp_key.."&scriptId="..f}end)repeat task.wait()until os.clock()-r>15 or y;if y and({[200]=1,[201]=1})[y.StatusCode]then LP_NODE=p;SRC=y.Body;b=loadstring(y.Body)if b then break end end end

	if b and SRC then
		local Threads
		for _ = 1, 100 do
			local Ok, Result = pcall(getactorthreads)
			if Ok and type(Result) == "table" and #Result > 0 then
				Threads = Result
				break
			end
			task.wait(0.1)
		end

		if Threads then
			local Prelude = ("lp_key=%q LP_NODE=%q "):format(tostring(lp_key), tostring(LP_NODE))
			run_on_thread(Threads[1], Prelude .. SRC, LP_NODE)
		else
			UI.Fail("No actor thread available")
		end
	else
		v("V2 loader failed to load script. Report this and try again later!")
	end

else

	getgenv().LP_CUSTOM_LOADER = UI.Step

	;("LuaProt V2 Loader - Unauthorized tampering or debugging of protected scripts is strictly prohibited and will result in a global blacklist from all LuaProt protected scripts."):sub(1,1);local f,c,v="86873913244749951038",http and http.request or request,function(h)while task.wait()do pcall(function()game:GetService"Players".LocalPlayer:Kick(h)local v=game:GetService"CoreGui".RobloxPromptGui.promptOverlay.ErrorPrompt;v.TitleFrame.ErrorTitle.Text="LuaProt"v.MessageArea.ErrorFrame.ErrorMessage.Text=h end)end end;lp_key=lp_key or"x"local b,o,h,k,d;o={"eu-1","eu-2","us-1"}h,k=pcall(c,{Url="https://eu-1.luaprot.net/api/v1/nodes/get"})if h and k and k.StatusCode==200 then pcall(function()d=game:GetService"HttpService":JSONDecode(k.Body)end)if d and d.success and d.node then for i,n in o do if n==d.node then table.insert(o,1,table.remove(o,i))break end end end end;for _,p in o do local r,y=os.clock()task.spawn(pcall,function()y=c{Url="https://"..p..".luaprot.net/api/v2/loader/get?key="..lp_key.."&scriptId="..f}end)repeat task.wait()until os.clock()-r>15 or y;if y and({[200]=1,[201]=1})[y.StatusCode]then LP_NODE=p;b=loadstring(y.Body)if b then break end end end;if b then b(LP_NODE)else v("V2 loader failed to load script. Report this and try again later!")end

end
