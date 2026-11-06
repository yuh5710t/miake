-- 索尼克脚本 | 注入公告 | UI：MoonLua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local function notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "索尼克脚本",
        Text = msg,
        Duration = 3
    })
end

local annGui = Instance.new("ScreenGui")
annGui.Name = "SonicAnnounceUI"
annGui.ResetOnSpawn = false
annGui.IgnoreGuiInset = true
annGui.DisplayOrder = 999
annGui.Parent = PlayerGui

local black = Instance.new("Frame")
black.Size = UDim2.fromScale(1, 1)
black.BackgroundColor3 = Color3.new(0, 0, 0)
black.BorderSizePixel = 0
black.Parent = annGui

local fxLayer = Instance.new("Frame")
fxLayer.Size = UDim2.fromScale(1, 1)
fxLayer.BackgroundTransparency = 1
fxLayer.Parent = annGui

local function makeGlow(size, pos, color, transparency)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BackgroundColor3 = color
    f.BackgroundTransparency = transparency or 0.6
    f.BorderSizePixel = 0
    f.Parent = fxLayer
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = f
    return f
end

local glow1 = makeGlow(UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200), Color3.fromRGB(30, 80, 180), 0.8)
local glow2 = makeGlow(UDim2.new(0, 260, 0, 260), UDim2.new(0.5, -130, 0.5, -130), Color3.fromRGB(20, 50, 130), 0.75)

local ring = makeGlow(UDim2.new(0, 180, 0, 180), UDim2.new(0.5, -90, 0.5, -90), Color3.fromRGB(60, 120, 255), 0.7)
TweenService:Create(ring, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
    Size = UDim2.new(0, 260, 0, 260),
    Position = UDim2.new(0.5, -130, 0.5, -130),
    BackgroundTransparency = 0.9
}):Play()

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0.5, -120)
title.BackgroundTransparency = 1
title.Text = "索尼克脚本"
title.TextColor3 = Color3.fromRGB(180, 210, 255)
title.TextSize = 34
title.Font = Enum.Font.GothamBold
title.Parent = annGui

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 30)
subtitle.Position = UDim2.new(0, 0, 0.5, -50)
subtitle.BackgroundTransparency = 1
subtitle.Text = "注入成功，正在启动..."
subtitle.TextColor3 = Color3.fromRGB(130, 150, 180)
subtitle.TextSize = 16
subtitle.Font = Enum.Font.Gotham
subtitle.Parent = annGui

local lines = {
    "抓方块 → 吃 · 抓砸 · 换服",
    "升大小 · 速度 · 次数 · 乘数",
    "防摔 · 防滑 · 虚块 · 自动收币",
}
for i, text in ipairs(lines) do
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 24)
    l.Position = UDim2.new(0, 0, 0.5, 10 + (i - 1) * 28)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(80, 120, 200)
    l.TextSize = 14
    l.Font = Enum.Font.Gotham
    l.Parent = annGui
end

local progress = Instance.new("Frame")
progress.Size = UDim2.new(0, 0, 0, 3)
progress.Position = UDim2.new(0.5, -150, 0.5, 130)
progress.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
progress.BorderSizePixel = 0
progress.Parent = annGui
Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    TweenService:Create(progress, TweenInfo.new(3), {Size = UDim2.new(0, 300, 0, 3)}):Play()
    task.wait(3.2)
    annGui:Destroy()
    notify("索尼克脚本已注入")
    repeat task.wait(0.1) until StartMain
    StartMain()
end)

task.spawn(function()
    while annGui.Parent do
        glow1.Position = UDim2.new(0.5, -200 + math.sin(tick()) * 40, 0.5, -200 + math.cos(tick()) * 30)
        glow2.Position = UDim2.new(0.5, -130 + math.cos(tick() * 1.3) * 50, 0.5, -130 + math.sin(tick() * 1.3) * 40)
        task.wait(0.03)
    end
end)StartMain = function()
    local ok, Library = pcall(function()
        return loadstring(game:HttpGet("https://sikon.226618.xyz/moon lua UI源码.lua"))()
    end)
    if not ok or type(Library) ~= "table" then
        notify("MoonLua UI 加载失败")
        return
    end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local StarterGui = game:GetService("StarterGui")
    local RunService = game:GetService("RunService")
    local TeleportService = game:GetService("TeleportService")

    local State = {
        AutoEat = false,
        Size = false,
        Speed = false,
        EatSpeed = false,
        Multiplier = false,
        AntiFall = false,
        AntiSlip = false,
        AutoCoins = false,
        SpeedValue = 100,
        Loops = {},
        LastSafe = nil,
    }
    local Alive = true

    local function Notify(Title, Text, Duration)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = tostring(Title),
                Text = tostring(Text),
                Duration = Duration or 4
            })
        end)
    end

    local function Character() return LocalPlayer.Character end
    local function Humanoid() local C = Character() return C and C:FindFirstChildOfClass("Humanoid") end
    local function Root() local C = Character() return C and C:FindFirstChild("HumanoidRootPart") end
    local function Events() return ReplicatedStorage:FindFirstChild("Events") end

    local function FindRemote(keywords)
        local E = Events()
        if not E then return nil end
        for _, obj in ipairs(E:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local nl = string.lower(obj.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(nl, kw, 1, true) then return obj end
                end
            end
        end
        return nil
    end

    local function Fire(keywords, ...)
        local R = FindRemote(keywords)
        if not R then return false end
        local args = { ... }
        return pcall(function()
            if R:IsA("RemoteFunction") then
                R:InvokeServer(unpack(args))
            else
                R:FireServer(unpack(args))
            end
        end)
    end

    local function Loop(Name, Enabled, Interval, Callback)
        State.Loops[Name] = (State.Loops[Name] or 0) + 1
        local Token = State.Loops[Name]
        if not Enabled then return end
        task.spawn(function()
            while Alive and State.Loops[Name] == Token do
                local Ok, Error = pcall(Callback)
                if not Ok then warn(tostring(Error)) end
                task.wait(Interval)
            end
        end)
    end

    -- 找最近的可抓方块/物体
    local function FindNearestBlock()
        local R = Root()
        if not R then return nil end
        local nearest, minDist = nil, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.CanCollide and obj.Name ~= "Platform" then
                local nl = string.lower(obj.Name)
                if not string.find(nl, "baseplate", 1, true) and not string.find(nl, "bedrock", 1, true) then
                    local d = (obj.Position - R.Position).Magnitude
                    if d < 120 and d < minDist then
                        minDist = d
                        nearest = obj
                    end
                end
            end
        end
        return nearest
    end

    -- 抓方块 → 吃
    local function GrabAndEat()
        local R = Root()
        if not R then return false end
        local block = FindNearestBlock()
        if block then
            local old = R.CFrame
            R.CFrame = block.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.08)
            Fire({"grab", "pickup", "collect"}, block)
            task.wait(0.08)
            Fire({"eat", "consume", "bite"}, "Grab")
            R.CFrame = old
            return true
        end
        Fire({"eat", "consume", "bite"}, "Grab")
        return false
    end

    local function ProbeRemotes()
        local E = Events()
        if not E then Notify("探测", "找不到 ReplicatedStorage.Events") return end
        local names = {}
        for _, obj in ipairs(E:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(names, obj.Name)
            end
        end
        if #names == 0 then
            Notify("探测", "Events 下没有远程事件")
        else
            print("[索尼克] Events 远程列表: " .. table.concat(names, ", "))
            Notify("探测", "已打印远程列表到控制台，共 " .. #names .. " 个", 6)
        end
    end

    local function GrabTarget(Throw)
        local R = Root()
        if not R then Notify("抓砸", "角色无效") return end
        local myPos = R.CFrame
        local nearest, minDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tr = p.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    local d = (tr.Position - R.Position).Magnitude
                    if d < minDist then minDist = d; nearest = p end
                end
            end
        end
        if not nearest then Notify("抓砸", "附近没有玩家") return end
        local tr = nearest.Character:FindFirstChild("HumanoidRootPart")
        if not tr then Notify("抓砸", "目标无效") return end
        R.CFrame = tr.CFrame * CFrame.new(0, 0, -2)
        task.wait(0.15)
        Fire({"grab"}, nearest.Character)
        task.wait(0.3)
        if Throw then Fire({"throw"}, tr.CFrame.LookVector * 800 + Vector3.new(0, 1000, 0)) end
        R.CFrame = myPos
    end

    local function CreatePlatform()
        local R = Root()
        if not R then return end
        local old = workspace:FindFirstChild("PlatformFolder_" .. LocalPlayer.UserId)
        if old then old:Destroy() end
        local Folder = Instance.new("Folder")
        Folder.Name = "PlatformFolder_" .. LocalPlayer.UserId
        Folder.Parent = workspace
        local Part = Instance.new("Part")
        Part.Name = "Platform"
        Part.Anchored = true
        Part.CanCollide = true
        Part.Size = Vector3.new(24, 1, 24)
        Part.Position = R.Position - Vector3.new(0, 4, 0)
        Part.Color = Color3.fromRGB(70, 200, 235)
        Part.Material = Enum.Material.DiamondPlate
        Part.Transparency = 0.15
        Part.Parent = Folder
        Notify("虚块", "已生成")
    end

    local function TeleportServer()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end

    local function AutoCoinsOnce()
        local R = Root()
        if not R or not firetouchinterest then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj:FindFirstChildOfClass("TouchTransmitter") then
                local nl = string.lower(obj.Name)
                if string.find(nl, "coin", 1, true) or string.find(obj.Name, "金币", 1, true) then
                    pcall(function()
                        firetouchinterest(R, obj, 0)
                        firetouchinterest(R, obj, 1)
                    end)
                end
            end
        end
    end

    RunService.Heartbeat:Connect(function()
        if not Alive then return end
        local H = Humanoid()
        local R = Root()
        if H and State.Speed then H.WalkSpeed = State.SpeedValue end
        if R and H and H.Health > 0 and R.Position.Y > workspace.FallenPartsDestroyHeight + 50 and R.AssemblyLinearVelocity.Magnitude < 150 then
            State.LastSafe = R.CFrame
        end
        if R and State.AntiFall and R.Position.Y < workspace.FallenPartsDestroyHeight + 20 and State.LastSafe then
            R.CFrame = State.LastSafe + Vector3.new(0, 5, 0)
            R.AssemblyLinearVelocity = Vector3.zero
        end
        if R and State.AntiSlip then
            R.AssemblyAngularVelocity = Vector3.zero
            if H then H.AutoRotate = true end
        end
    end)    local Window = Library:CreateWindow({
        Name = "SonicScript",
        Title = "索尼克脚本",
        Version = "v1.4",
        Theme = "Water",
        Backdrop = true,
        ShowBackdrop = true,
        GradientAnimation = true,
        ConfigFolder = "SonicScript",
        SearchTab = false,
        Visible = true,
    })

    Window:SetCustomTheme(Color3.fromRGB(30, 90, 200), Color3.fromRGB(20, 50, 130))

    local TabAuto = Window:CreateTab("自动")
    local PageAuto = TabAuto:CreateModule("抓方块 → 吃", "zap", {})

    PageAuto:CreateToggle("自动抓方块吃", false, function(v)
        State.AutoEat = v
        Loop("AutoEat", v, 0.35, GrabAndEat)
    end)
    PageAuto:CreateButton("探测远程", function() ProbeRemotes() end)
    PageAuto:CreateToggle("自动升大小", false, function(v)
        State.Size = v
        Loop("Size", v, 1, function() Fire({"purchase"}, "MaxSize") end)
    end)
    PageAuto:CreateToggle("自动升速度", false, function(v)
        State.Speed = v
        Loop("Speed", v, 1, function() Fire({"purchase"}, "Speed") end)
    end)
    PageAuto:CreateToggle("自动升次数", false, function(v)
        State.EatSpeed = v
        Loop("EatSpeed", v, 1, function() Fire({"purchase"}, "EatSpeed") end)
    end)
    PageAuto:CreateToggle("自动升乘数", false, function(v)
        State.Multiplier = v
        Loop("Multiplier", v, 1, function() Fire({"purchase"}, "Multiplier") end)
    end)
    PageAuto:CreateToggle("自动收金币", false, function(v)
        State.AutoCoins = v
        Loop("AutoCoins", v, 0.5, AutoCoinsOnce)
    end)

    local TabMove = Window:CreateTab("移动")
    local PageMove = TabMove:CreateModule("防护", "shield", {})

    PageMove:CreateToggle("防摔", false, function(v) State.AntiFall = v end)
    PageMove:CreateToggle("防滑", false, function(v) State.AntiSlip = v end)
    PageMove:CreateInput("速度值", "100", function(t)
        State.SpeedValue = math.clamp(tonumber(t) or 100, 0, 1000)
    end)

    local TabTool = Window:CreateTab("工具")
    local PageTool = TabTool:CreateModule("操作", "wrench", {})

    PageTool:CreateButton("抓砸", function() GrabTarget(false) end)
    PageTool:CreateButton("砸人", function() GrabTarget(true) end)
    PageTool:CreateButton("虚块", CreatePlatform)
    PageTool:CreateButton("换服务器", TeleportServer)

    Window:Notify({
        Title = "索尼克脚本",
        Content = "抓方块→吃 / 抓砸 / 换服 / 升大小·速度·次数·乘数 / 防摔 / 防滑 / 虚块 / 自动收币",
        Duration = 5
    })
end
