lp_key = lp_key or "x"

LP_CUSTOM_LOADER = function(stepOrTime)
    if stepOrTime == 1 then
        local gui = Instance.new("ScreenGui")
        gui.Name = "LPLoader"
        gui.ResetOnSpawn = false
        pcall(function() gui.Parent = game:GetService("CoreGui") end)
        getgenv()._lp_gui = gui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 90)
        frame.Position = UDim2.new(0.5, -140, 0.5, -45)
        frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, 0)
        accent.BackgroundColor3 = Color3.fromRGB(138, 79, 255)
        accent.BorderSizePixel = 0
        accent.Parent = frame
        Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -20, 0, 28)
        title.Position = UDim2.new(0, 14, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = "Authenticating"
        title.TextColor3 = Color3.fromRGB(138, 79, 255)
        title.TextSize = 15
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local status = Instance.new("TextLabel")
        status.Name = "Status"
        status.Size = UDim2.new(1, -20, 0, 22)
        status.Position = UDim2.new(0, 14, 0, 38)
        status.BackgroundTransparency = 1
        status.Text = "Attempting to authenticate..."
        status.TextColor3 = Color3.fromRGB(180, 180, 190)
        status.TextSize = 13
        status.Font = Enum.Font.Gotham
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.Parent = frame

    elseif stepOrTime == 2 then
        local f = getgenv()._lp_gui and getgenv()._lp_gui:FindFirstChild("Frame")
        local s = f and f:FindFirstChild("Status")
        if s then s.Text = "Connecting to LuaProt servers..." end

    else
        local f = getgenv()._lp_gui and getgenv()._lp_gui:FindFirstChild("Frame")
        local s = f and f:FindFirstChild("Status")
        if s then s.Text = "Authenticated in " .. stepOrTime .. "s!" end
        task.delay(1.5, function()
            if getgenv()._lp_gui then getgenv()._lp_gui:Destroy() end
        end)
    end
end

local url
if game.PlaceId == 292439477 then
    url = "https://raw.githubusercontent.com/SamPeter122/Furry-Script/main/PF_Loader.lua"
else
    url = "https://raw.githubusercontent.com/SamPeter122/Furry-Script/main/UWU%20Loader.lua"
end

loadstring(game:HttpGet(url))()
