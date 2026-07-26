getgenv().LP_NOTIFICATION_STYLE = "custom"

getgenv().LP_CUSTOM_LOADER = (function()
	local TweenService = game:GetService("TweenService")
	local RunService   = game:GetService("RunService")
	local Lighting     = game:GetService("Lighting")
	local hui = (gethui or function() return game:GetService("CoreGui") end)()

	local Accent = Color3.fromRGB(179, 5, 76)
	local Hot    = Color3.fromRGB(238, 40, 118)
	local BG     = Color3.fromRGB(19, 19, 21)
	local Elem   = Color3.fromRGB(34, 34, 37)
	local Bord   = Color3.fromRGB(48, 48, 52)
	local White  = Color3.fromRGB(255, 255, 255)
	local Sub    = Color3.fromRGB(176, 176, 182)
	local Muted  = Color3.fromRGB(92, 92, 98)

	local Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
	local Medium  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
	local Bold    = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

	local QUART = Enum.EasingStyle.Quart
	local QUINT = Enum.EasingStyle.Quint
	local BACK  = Enum.EasingStyle.Back
	local OUT   = Enum.EasingDirection.Out

	local conns, alive = {}, true
	local function bind(sig, fn)
		local c = sig:Connect(fn)
		table.insert(conns, c)
		return c
	end
	local function tw(obj, t, props, style, dir)
		local tween = TweenService:Create(obj, TweenInfo.new(t, style or QUART, dir or OUT), props)
		tween:Play()
		return tween
	end
	local function new(class, parent, props)
		local o = Instance.new(class)
		for k, v in props do o[k] = v end
		o.Parent = parent
		return o
	end
	local function corner(parent, r)
		return new("UICorner", parent, {CornerRadius = UDim.new(0, r)})
	end

	--=====================================================================
	-- root
	--=====================================================================
	local Gui = new("ScreenGui", hui, {
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder   = 999999,
		IgnoreGuiInset = true,
		ResetOnSpawn   = false,
	})

	local Blur = new("BlurEffect", Lighting, {Size = 0})

	local Overlay = new("Frame", Gui, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 1,
	})
	new("UIGradient", Overlay, {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.35),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0.35),
		}),
	})

	--=====================================================================
	-- drifting particles
	--=====================================================================
	local Field = new("Frame", Gui, {
		Size = UDim2.fromOffset(520, 340),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 2,
	})

	local motes = {}
	for i = 1, 18 do
		local m = new("Frame", Field, {
			Size = UDim2.fromOffset(2, 2),
			BackgroundColor3 = Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
		})
		corner(m, 4)
		motes[i] = {
			obj   = m,
			x     = math.random(),
			y     = math.random(),
			speed = 0.02 + math.random() * 0.05,
			sway  = math.random() * 6.283,
			amp   = 0.004 + math.random() * 0.012,
			alpha = 0.55 + math.random() * 0.35,
		}
	end

	local fieldFade, fieldTgt = 1, 1
	bind(RunService.RenderStepped, function(dt)
		fieldFade = fieldFade + (fieldTgt - fieldFade) * math.min(dt * 3, 1)
		for _, m in motes do
			m.y = m.y - m.speed * dt
			if m.y < -0.05 then
				m.y = 1.05
				m.x = math.random()
			end
			m.sway = m.sway + dt * 1.4
			local ox = math.sin(m.sway) * m.amp
			m.obj.Position = UDim2.fromScale(m.x + ox, m.y)
			local edge = math.min(m.y, 1 - m.y, 0.25) / 0.25
			m.obj.BackgroundTransparency = 1 - (1 - m.alpha) * math.clamp(edge, 0, 1) * (1 - fieldFade)
		end
	end)

	--=====================================================================
	-- glow
	--=====================================================================
	local Glow = new("ImageLabel", Gui, {
		Image = "rbxassetid://18245826428",
		ImageColor3 = Accent,
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(21, 21, 79, 79),
		Size = UDim2.fromOffset(452, 244),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 3,
	})

	--=====================================================================
	-- card
	--=====================================================================
	local CW, CH = 340, 132

	local Card = new("Frame", Gui, {
		Size = UDim2.fromOffset(CW, CH),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 26),
		BackgroundColor3 = BG,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 4,
	})
	corner(Card, 8)
	local CardScale = new("UIScale", Card, {Scale = 0.94})

	new("UIGradient", Card, {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 34)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 18)),
		}),
	})

	-- rotating conic accent border
	local Stroke = new("UIStroke", Card, {
		Thickness = 1.4,
		Color = White,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	local StrokeGrad = new("UIGradient", Stroke, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Bord),
			ColorSequenceKeypoint.new(0.28, Bord),
			ColorSequenceKeypoint.new(0.45, Accent),
			ColorSequenceKeypoint.new(0.50, Hot),
			ColorSequenceKeypoint.new(0.55, Accent),
			ColorSequenceKeypoint.new(0.72, Bord),
			ColorSequenceKeypoint.new(1.00, Bord),
		}),
	})

	-- top accent hairline, fading at both edges
	local TopBar = new("Frame", Card, {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Hot,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 9,
	})
	new("UIGradient", TopBar, {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	--------------------------------------------------------------------
	-- reactor mark
	--------------------------------------------------------------------
	local Mark = new("Frame", Card, {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.new(0, 18, 0, 18),
		BackgroundTransparency = 1,
		ZIndex = 6,
	})

	local RingOuter = new("Frame", Mark, {
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 6,
	})
	corner(RingOuter, 4)
	local RingOuterS = new("UIStroke", RingOuter, {Color = Accent, Thickness = 1.2, Transparency = 1})

	local RingInner = new("Frame", Mark, {
		Size = UDim2.fromOffset(11, 11),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = 6,
	})
	corner(RingInner, 2)
	local RingInnerS = new("UIStroke", RingInner, {Color = Hot, Thickness = 1.2, Transparency = 1})

	local Core = new("Frame", Mark, {
		Size = UDim2.fromOffset(4, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Hot,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 7,
	})
	corner(Core, 4)

	--------------------------------------------------------------------
	-- titles
	--------------------------------------------------------------------
	local Title = new("TextLabel", Card, {
		Size = UDim2.new(1, -66, 0, 15),
		Position = UDim2.new(0, 48, 0, 17),
		BackgroundTransparency = 1,
		TextColor3 = White,
		TextTransparency = 1,
		TextSize = 14,
		FontFace = Bold,
		Text = "Tomboy.Hook",
		TextXAlignment = Enum.TextXAlignment.Left,
		MaxVisibleGraphemes = 0,
		ZIndex = 6,
	})

	local SubT = new("TextLabel", Card, {
		Size = UDim2.new(1, -66, 0, 11),
		Position = UDim2.new(0, 48, 0, 34),
		BackgroundTransparency = 1,
		TextColor3 = Muted,
		TextTransparency = 1,
		TextSize = 10,
		FontFace = Regular,
		Text = "project delta",
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	})

	local Sep = new("Frame", Card, {
		Size = UDim2.new(0, 0, 0, 1),
		Position = UDim2.new(0, 18, 0, 60),
		BackgroundColor3 = Bord,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	})
	new("UIGradient", Sep, {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	--------------------------------------------------------------------
	-- status + pips
	--------------------------------------------------------------------
	local StatusL = new("TextLabel", Card, {
		Size = UDim2.new(1, -80, 0, 14),
		Position = UDim2.new(0, 18, 0, 74),
		BackgroundTransparency = 1,
		TextColor3 = Sub,
		TextTransparency = 1,
		TextSize = 12,
		FontFace = Medium,
		Text = "Initializing",
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	})

	local Pips = {}
	for i = 1, 3 do
		local p = new("Frame", Card, {
			Size = UDim2.fromOffset(8, 3),
			Position = UDim2.new(0, CW - 18 - 34 + (i - 1) * 13, 0, 79),
			BackgroundColor3 = Elem,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 6,
		})
		corner(p, 2)
		Pips[i] = p
	end

	--------------------------------------------------------------------
	-- progress
	--------------------------------------------------------------------
	local BarW = 260
	local BarTrack = new("Frame", Card, {
		Size = UDim2.fromOffset(BarW, 4),
		Position = UDim2.new(0, 18, 0, 102),
		BackgroundColor3 = Elem,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 6,
	})
	corner(BarTrack, 2)

	local BarFill = new("Frame", BarTrack, {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 7,
	})
	corner(BarFill, 2)
	new("UIGradient", BarFill, {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Accent),
			ColorSequenceKeypoint.new(1, Hot),
		}),
	})

	-- travelling shimmer inside the fill
	local Shine = new("Frame", BarFill, {
		Size = UDim2.new(0, 46, 1, 0),
		BackgroundColor3 = White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 8,
	})
	new("UIGradient", Shine, {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.45),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	-- glowing head that rides the fill
	local Head = new("Frame", BarTrack, {
		Size = UDim2.fromOffset(4, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 9,
	})
	corner(Head, 4)

	local Pct = new("TextLabel", Card, {
		Size = UDim2.fromOffset(38, 14),
		Position = UDim2.new(0, CW - 18 - 38, 0, 97),
		BackgroundTransparency = 1,
		TextColor3 = Muted,
		TextTransparency = 1,
		TextSize = 11,
		FontFace = Medium,
		Text = "0%",
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 6,
	})

	--------------------------------------------------------------------
	-- one-shot sheen across the card
	--------------------------------------------------------------------
	local Sheen = new("Frame", Card, {
		Size = UDim2.new(0, 90, 2, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(-0.3, 0, 0.5, 0),
		Rotation = 18,
		BackgroundColor3 = White,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10,
	})
	new("UIGradient", Sheen, {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.92),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	--=====================================================================
	-- entrance
	--=====================================================================
	fieldTgt = 0
	tw(Blur,       0.55, {Size = 14})
	tw(Overlay,    0.45, {BackgroundTransparency = 0.42})
	tw(Glow,       0.7,  {ImageTransparency = 0.76})
	tw(Card,       0.65, {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}, QUINT)
	tw(CardScale,  0.7,  {Scale = 1}, BACK)
	tw(Stroke,     0.6,  {Transparency = 0})
	tw(TopBar,     0.6,  {BackgroundTransparency = 0})
	tw(RingOuterS, 0.6,  {Transparency = 0.15})
	tw(RingInnerS, 0.6,  {Transparency = 0.3})
	tw(Core,       0.6,  {BackgroundTransparency = 0})

	task.delay(0.14, function()
		if not alive then return end
		tw(Sep,     0.7, {Size = UDim2.new(1, -36, 0, 1), BackgroundTransparency = 0}, QUINT)
		tw(Title,   0.3, {TextTransparency = 0})
		tw(Title,   0.55, {MaxVisibleGraphemes = 11}, Enum.EasingStyle.Linear)
		tw(BarTrack, 0.5, {BackgroundTransparency = 0})
		tw(BarFill,  0.5, {BackgroundTransparency = 0})
		tw(Head,     0.5, {BackgroundTransparency = 0})
	end)
	task.delay(0.3, function()
		if not alive then return end
		tw(SubT,    0.45, {TextTransparency = 0})
		tw(StatusL, 0.45, {TextTransparency = 0})
		tw(Pct,     0.45, {TextTransparency = 0})
		for i, p in Pips do
			task.delay((i - 1) * 0.05, function()
				if alive then tw(p, 0.35, {BackgroundTransparency = 0}) end
			end)
		end
	end)
	task.delay(0.45, function()
		if not alive then return end
		tw(Sheen, 0.85, {Position = UDim2.new(1.3, 0, 0.5, 0), BackgroundTransparency = 0},
			Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		task.delay(0.9, function() pcall(function() Sheen.Visible = false end) end)
	end)

	--=====================================================================
	-- perpetual motion
	--=====================================================================
	local t = 0
	local curPct, tgtPct = 0, 0.04
	local shinePos = -0.4
	local done = false

	bind(RunService.RenderStepped, function(dt)
		t = t + dt

		-- rotating border light
		StrokeGrad.Rotation = (t * 62) % 360

		-- counter-rotating reactor rings
		RingOuter.Rotation =  t * 48
		RingInner.Rotation = -t * 74

		-- breathing core + glow
		local pulse = 0.5 + 0.5 * math.sin(t * 3.1)
		Core.Size = UDim2.fromOffset(3 + pulse * 2.5, 3 + pulse * 2.5)
		if not done then
			Glow.ImageTransparency = 0.76 - pulse * 0.07
		end

		-- eased progress
		curPct = curPct + (tgtPct - curPct) * math.min(dt * 5.5, 1)
		BarFill.Size = UDim2.new(curPct, 0, 1, 0)
		Head.Position = UDim2.new(curPct, 0, 0.5, 0)
		Head.Size = UDim2.fromOffset(4 + pulse * 3, 4 + pulse * 3)
		Head.BackgroundTransparency = 0.15 + pulse * 0.35
		Pct.Text = math.floor(curPct * 100 + 0.5) .. "%"

		-- shimmer sweep along the fill
		shinePos = shinePos + dt * 0.85
		if shinePos > 1.4 then shinePos = -0.4 end
		Shine.Position = UDim2.new(shinePos, 0, 0, 0)
	end)

	-- animated ellipsis
	local base = "Initializing"
	task.spawn(function()
		local seq = {"", ".", "..", "..."}
		local i = 1
		while alive and not done do
			pcall(function() StatusL.Text = base .. seq[i] end)
			i = (i % #seq) + 1
			task.wait(0.36)
		end
	end)

	--=====================================================================
	-- api
	--=====================================================================
	local function litPip(n)
		local p = Pips[n]
		if not p then return end
		tw(p, 0.3, {BackgroundColor3 = Hot})
		tw(p, 0.25, {Size = UDim2.fromOffset(14, 3)}, BACK)
		p.Position = UDim2.new(0, CW - 18 - 34 + (n - 1) * 13, 0, 79)
	end

	local function teardown()
		alive = false
		tw(Blur,      0.45, {Size = 0})
		tw(Overlay,   0.45, {BackgroundTransparency = 1})
		tw(Glow,      0.45, {ImageTransparency = 1})
		tw(Card,      0.45, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -22)}, QUINT)
		tw(CardScale, 0.45, {Scale = 0.96})
		tw(Stroke,    0.35, {Transparency = 1})
		tw(TopBar,    0.35, {BackgroundTransparency = 1})
		tw(Title,     0.3,  {TextTransparency = 1})
		tw(SubT,      0.3,  {TextTransparency = 1})
		tw(StatusL,   0.3,  {TextTransparency = 1})
		tw(Pct,       0.3,  {TextTransparency = 1})
		tw(Sep,       0.3,  {BackgroundTransparency = 1})
		tw(BarTrack,  0.3,  {BackgroundTransparency = 1})
		tw(BarFill,   0.3,  {BackgroundTransparency = 1})
		tw(Head,      0.3,  {BackgroundTransparency = 1})
		tw(RingOuterS, 0.3, {Transparency = 1})
		tw(RingInnerS, 0.3, {Transparency = 1})
		tw(Core,      0.3,  {BackgroundTransparency = 1})
		for _, p in Pips do tw(p, 0.3, {BackgroundTransparency = 1}) end
		fieldTgt = 1

		task.delay(0.6, function()
			for _, c in conns do pcall(function() c:Disconnect() end) end
			pcall(function() Blur:Destroy() end)
			pcall(function() Gui:Destroy() end)
		end)
	end

	return function(stepOrTime)
		if stepOrTime == 1 then
			base   = "Authenticating"
			tgtPct = 0.3
			litPip(1)
		elseif stepOrTime == 2 then
			base   = "Establishing secure link"
			tgtPct = 0.68
			litPip(2)
		else
			done   = true
			tgtPct = 1
			litPip(3)

			pcall(function()
				StatusL.Text = ("Authenticated in %.2fs"):format(stepOrTime)
			end)

			-- success flash
			tw(StatusL, 0.3, {TextColor3 = White})
			tw(Glow,    0.25, {ImageTransparency = 0.52})
			tw(CardScale, 0.18, {Scale = 1.015})
			task.delay(0.18, function()
				if not alive then return end
				tw(CardScale, 0.45, {Scale = 1}, BACK)
				tw(Glow, 0.6, {ImageTransparency = 0.78})
			end)
			task.delay(0.5, function()
				if alive then tw(Shine, 0.01, {BackgroundTransparency = 1}) end
			end)

			task.delay(1.5, teardown)
		end
	end
end)()

;("LuaProt V2 Loader - Unauthorized tampering or debugging of protected scripts is strictly prohibited and will result in a global blacklist from all LuaProt protected scripts."):sub(1,1);local f,c,v="86873913244749951038",http and http.request or request,function(h)while task.wait()do pcall(function()game:GetService"Players".LocalPlayer:Kick(h)local v=game:GetService"CoreGui".RobloxPromptGui.promptOverlay.ErrorPrompt;v.TitleFrame.ErrorTitle.Text="LuaProt"v.MessageArea.ErrorFrame.ErrorMessage.Text=h end)end end;lp_key=lp_key or"x"local b,o,h,k,d;o={"eu-1","eu-2","us-1"}h,k=pcall(c,{Url="https://eu-1.luaprot.net/api/v1/nodes/get"})if h and k and k.StatusCode==200 then pcall(function()d=game:GetService"HttpService":JSONDecode(k.Body)end)if d and d.success and d.node then for i,n in o do if n==d.node then table.insert(o,1,table.remove(o,i))break end end end end;for _,p in o do local r,y=os.clock()task.spawn(pcall,function()y=c{Url="https://"..p..".luaprot.net/api/v2/loader/get?key="..lp_key.."&scriptId="..f}end)repeat task.wait()until os.clock()-r>15 or y;if y and({[200]=1,[201]=1})[y.StatusCode]then LP_NODE=p;b=loadstring(y.Body)if b then break end end end;if b then b(LP_NODE)else v("V2 loader failed to load script. Report this and try again later!")end
