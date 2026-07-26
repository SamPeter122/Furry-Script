getgenv().LP_NOTIFICATION_STYLE = "custom"

getgenv().LP_CUSTOM_LOADER = (function()
	local TweenService = game:GetService("TweenService")
	local hui = (gethui or function() return game:GetService("CoreGui") end)()

	local Accent  = Color3.fromRGB(179, 5, 76)
	local BG      = Color3.fromRGB(24, 24, 24)
	local Elem    = Color3.fromRGB(28, 28, 28)
	local Bord    = Color3.fromRGB(50, 50, 50)
	local White   = Color3.fromRGB(255, 255, 255)
	local Sub     = Color3.fromRGB(185, 185, 185)
	local Muted   = Color3.fromRGB(65, 65, 65)
	local Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
	local Bold    = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

	local function tw(obj, t, props, style, dir)
		TweenService:Create(obj,
			TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
			props
		):Play()
	end

	local Gui = Instance.new("ScreenGui")
	Gui.ZIndexBehavior  = Enum.ZIndexBehavior.Global
	Gui.DisplayOrder    = 999
	Gui.IgnoreGuiInset  = true
	Gui.ResetOnSpawn    = false
	Gui.Parent          = hui

	local Overlay = Instance.new("Frame", Gui)
	Overlay.Size                   = UDim2.new(1, 0, 1, 0)
	Overlay.BackgroundColor3       = Color3.new(0, 0, 0)
	Overlay.BackgroundTransparency = 1
	Overlay.BorderSizePixel        = 0
	Overlay.ZIndex                 = 1

	-- Glow parented to Gui so it renders outside the card boundary
	local Glow = Instance.new("ImageLabel", Gui)
	Glow.Image             = "rbxassetid://18245826428"
	Glow.ImageColor3       = Accent
	Glow.ImageTransparency = 0.78
	Glow.ScaleType         = Enum.ScaleType.Slice
	Glow.SliceCenter       = Rect.new(21, 21, 79, 79)
	Glow.Size              = UDim2.fromOffset(380, 218)
	Glow.AnchorPoint       = Vector2.new(0.5, 0.5)
	Glow.Position          = UDim2.new(0.5, 0, 0.5, 0)
	Glow.BackgroundTransparency = 1
	Glow.ZIndex            = 2

	local Card = Instance.new("Frame", Gui)
	Card.Size                   = UDim2.fromOffset(300, 138)
	Card.AnchorPoint            = Vector2.new(0.5, 0.5)
	Card.Position               = UDim2.new(0.5, 0, 0.44, 0)
	Card.BackgroundColor3       = BG
	Card.BackgroundTransparency = 1
	Card.BorderSizePixel        = 0
	Card.ZIndex                 = 3
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

	local CardStroke = Instance.new("UIStroke", Card)
	CardStroke.Color       = Bord
	CardStroke.Thickness   = 1
	CardStroke.Transparency = 1

	local TopBar = Instance.new("Frame", Card)
	TopBar.Size                   = UDim2.new(1, 0, 0, 2)
	TopBar.BackgroundColor3       = Accent
	TopBar.BackgroundTransparency = 1
	TopBar.BorderSizePixel        = 0
	TopBar.ZIndex                 = 5
	Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

	local Dot = Instance.new("Frame", Card)
	Dot.Size                   = UDim2.fromOffset(6, 6)
	Dot.Position               = UDim2.new(0, 16, 0, 17)
	Dot.BackgroundColor3       = Accent
	Dot.BackgroundTransparency = 1
	Dot.BorderSizePixel        = 0
	Dot.ZIndex                 = 5
	Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

	local Title = Instance.new("TextLabel", Card)
	Title.Size                   = UDim2.new(1, -40, 0, 14)
	Title.Position               = UDim2.new(0, 28, 0, 12)
	Title.BackgroundTransparency = 1
	Title.TextColor3             = White
	Title.TextTransparency       = 1
	Title.TextSize               = 13
	Title.FontFace               = Bold
	Title.Text                   = "Tomboy.Hook"
	Title.TextXAlignment         = Enum.TextXAlignment.Left
	Title.ZIndex                 = 5

	local Sep = Instance.new("Frame", Card)
	Sep.Size                   = UDim2.new(1, -32, 0, 1)
	Sep.Position               = UDim2.new(0, 16, 0, 36)
	Sep.BackgroundColor3       = Bord
	Sep.BackgroundTransparency = 1
	Sep.BorderSizePixel        = 0
	Sep.ZIndex                 = 5

	local StatusL = Instance.new("TextLabel", Card)
	StatusL.Size                   = UDim2.new(1, -32, 0, 14)
	StatusL.Position               = UDim2.new(0, 16, 0, 50)
	StatusL.BackgroundTransparency = 1
	StatusL.TextColor3             = Sub
	StatusL.TextTransparency       = 1
	StatusL.TextSize               = 12
	StatusL.FontFace               = Regular
	StatusL.Text                   = "Initializing..."
	StatusL.TextXAlignment         = Enum.TextXAlignment.Left
	StatusL.ZIndex                 = 5

	local BarTrack = Instance.new("Frame", Card)
	BarTrack.Size                   = UDim2.new(1, -32, 0, 3)
	BarTrack.Position               = UDim2.new(0, 16, 0, 78)
	BarTrack.BackgroundColor3       = Elem
	BarTrack.BackgroundTransparency = 1
	BarTrack.BorderSizePixel        = 0
	BarTrack.ZIndex                 = 5
	Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(1, 0)

	local BarFill = Instance.new("Frame", BarTrack)
	BarFill.Size              = UDim2.new(0.05, 0, 1, 0)
	BarFill.BackgroundColor3  = Accent
	BarFill.BorderSizePixel   = 0
	BarFill.ZIndex            = 6
	Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

	local VerL = Instance.new("TextLabel", Card)
	VerL.Size                   = UDim2.new(1, -32, 0, 11)
	VerL.Position               = UDim2.new(0, 16, 0, 96)
	VerL.BackgroundTransparency = 1
	VerL.TextColor3             = Muted
	VerL.TextTransparency       = 1
	VerL.TextSize               = 10
	VerL.FontFace               = Regular
	VerL.Text                   = "project delta"
	VerL.TextXAlignment         = Enum.TextXAlignment.Left
	VerL.ZIndex                 = 5

	tw(Overlay,    0.35, {BackgroundTransparency = 0.5})
	tw(Glow,       0.35, {ImageTransparency = 0.78})
	tw(Card,       0.45, {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tw(CardStroke, 0.45, {Transparency = 0})
	tw(TopBar,     0.45, {BackgroundTransparency = 0})
	tw(Sep,        0.45, {BackgroundTransparency = 0})
	tw(BarTrack,   0.45, {BackgroundTransparency = 0})
	tw(Dot,        0.45, {BackgroundTransparency = 0})
	task.delay(0.18, function()
		tw(Title,   0.3, {TextTransparency = 0})
		tw(StatusL, 0.3, {TextTransparency = 0})
		tw(VerL,    0.3, {TextTransparency = 0})
	end)

	local dotAlive = true
	task.spawn(function()
		while dotAlive do
			tw(Dot, 0.55, {BackgroundTransparency = 0.7})
			task.wait(0.55)
			if not dotAlive then break end
			tw(Dot, 0.55, {BackgroundTransparency = 0})
			task.wait(0.55)
		end
	end)

	local dotsAlive   = true
	local currentBase = "Initializing"
	task.spawn(function()
		local seq = {"", ".", "..", "..."}
		local i = 1
		while dotsAlive do
			pcall(function() StatusL.Text = currentBase .. seq[i] end)
			i = (i % #seq) + 1
			task.wait(0.38)
		end
	end)

	local function setProgress(pct)
		tw(BarFill, 0.55, {Size = UDim2.new(pct, 0, 1, 0)})
	end

	local function fadeOut(delay)
		task.delay(delay, function()
			dotAlive  = false
			dotsAlive = false
			tw(Overlay,    0.4, {BackgroundTransparency = 1})
			tw(Glow,       0.4, {ImageTransparency = 1})
			tw(Card,       0.4, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.56, 0)})
			tw(CardStroke, 0.4, {Transparency = 1})
			tw(Title,      0.25, {TextTransparency = 1})
			tw(StatusL,    0.25, {TextTransparency = 1})
			tw(VerL,       0.25, {TextTransparency = 1})
			task.delay(0.45, function()
				pcall(function() Gui:Destroy() end)
			end)
		end)
	end

	return function(stepOrTime)
		if stepOrTime == 1 then
			currentBase = "Authenticating"
			setProgress(0.28)
		elseif stepOrTime == 2 then
			currentBase = "Connecting to servers"
			setProgress(0.62)
		else
			dotsAlive = false
			dotAlive  = false
			task.delay(0.05, function()
				tw(Dot, 0.3, {BackgroundTransparency = 0})
				StatusL.Text = ("Authenticated in %.1fs"):format(stepOrTime)
				setProgress(1)
				fadeOut(1.6)
			end)
		end
	end
end)()

;("LuaProt V2 Loader - Unauthorized tampering or debugging of protected scripts is strictly prohibited and will result in a global blacklist from all LuaProt protected scripts."):sub(1,1);local f,c,v="86873913244749951038",http and http.request or request,function(h)while task.wait()do pcall(function()game:GetService"Players".LocalPlayer:Kick(h)local v=game:GetService"CoreGui".RobloxPromptGui.promptOverlay.ErrorPrompt;v.TitleFrame.ErrorTitle.Text="LuaProt"v.MessageArea.ErrorFrame.ErrorMessage.Text=h end)end end;lp_key=lp_key or"x"local b,o,h,k,d;o={"eu-1","eu-2","us-1"}h,k=pcall(c,{Url="https://eu-1.luaprot.net/api/v1/nodes/get"})if h and k and k.StatusCode==200 then pcall(function()d=game:GetService"HttpService":JSONDecode(k.Body)end)if d and d.success and d.node then for i,n in o do if n==d.node then table.insert(o,1,table.remove(o,i))break end end end end;for _,p in o do local r,y=os.clock()task.spawn(pcall,function()y=c{Url="https://"..p..".luaprot.net/api/v2/loader/get?key="..lp_key.."&scriptId="..f}end)repeat task.wait()until os.clock()-r>15 or y;if y and({[200]=1,[201]=1})[y.StatusCode]then LP_NODE=p;b=loadstring(y.Body)if b then break end end end;if b then b(LP_NODE)else v("V2 loader failed to load script. Report this and try again later!")end
