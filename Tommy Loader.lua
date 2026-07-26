getgenv().LP_NOTIFICATION_STYLE = "custom"

getgenv().LP_CUSTOM_LOADER = (function()
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

	local Conns   = {}
	local Alive   = true
	local Done    = false
	local Started = false

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
		Text = "Project Delta",
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

		task.delay(0.1, function()
			Tween(Window, {BackgroundTransparency = 1, Position = UDim2New(0.5, 0, 0.5, 14)}, 0.3)
			Tween(WindowScale, {Scale = 0.9}, 0.3)
			Tween(WindowStroke, {Transparency = 1}, 0.3)
			Tween(Glow, {ImageTransparency = 1}, 0.3)
		end)

		task.delay(0.6, function()
			for _, Connection in Conns do
				pcall(function() Connection:Disconnect() end)
			end
			pcall(function() Holder:Destroy() end)
		end)
	end

	return function(StepOrTime)
		Started = true
		if StepOrTime == 1 then
			Base = "Authenticating"
			Tween(Value, {Value = 0.3})
		elseif StepOrTime == 2 then
			Base = "Connecting to servers"
			Tween(Value, {Value = 0.68})
		else
			Done = true
			Tween(Value, {Value = 1})
			pcall(function()
				Status.Text = ("Authenticated in %.2fs"):format(StepOrTime)
				Status.TextColor3 = Theme.Text
			end)

			task.delay(1.5, Unload)
		end
	end
end)()

;("LuaProt V2 Loader - Unauthorized tampering or debugging of protected scripts is strictly prohibited and will result in a global blacklist from all LuaProt protected scripts."):sub(1,1);local f,c,v="86873913244749951038",http and http.request or request,function(h)while task.wait()do pcall(function()game:GetService"Players".LocalPlayer:Kick(h)local v=game:GetService"CoreGui".RobloxPromptGui.promptOverlay.ErrorPrompt;v.TitleFrame.ErrorTitle.Text="LuaProt"v.MessageArea.ErrorFrame.ErrorMessage.Text=h end)end end;lp_key=lp_key or"x"local b,o,h,k,d;o={"eu-1","eu-2","us-1"}h,k=pcall(c,{Url="https://eu-1.luaprot.net/api/v1/nodes/get"})if h and k and k.StatusCode==200 then pcall(function()d=game:GetService"HttpService":JSONDecode(k.Body)end)if d and d.success and d.node then for i,n in o do if n==d.node then table.insert(o,1,table.remove(o,i))break end end end end;for _,p in o do local r,y=os.clock()task.spawn(pcall,function()y=c{Url="https://"..p..".luaprot.net/api/v2/loader/get?key="..lp_key.."&scriptId="..f}end)repeat task.wait()until os.clock()-r>15 or y;if y and({[200]=1,[201]=1})[y.StatusCode]then LP_NODE=p;b=loadstring(y.Body)if b then break end end end;if b then b(LP_NODE)else v("V2 loader failed to load script. Report this and try again later!")end
