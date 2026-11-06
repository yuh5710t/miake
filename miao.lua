-- 灵境 | 创作者：李佳 | QQ群：2066484928

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "灵境",
    Text = "创作者：李佳 | QQ群：2066484928",
    Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
})

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

if not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "WindUI 加载失败",
        Duration = 5
    })
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

local Notify = function() end
local Window

local jobEsp, coinV1, coinV2, autoGun, ignoreKnife, killAura = false, false, false, false, false, false
local rangeOn, rangeAll, gunESP, trapESP, antifail = false, false, false, false, false
local jobLoop, coinV1Loop, coinV2Loop, gunLoop, auraLoop = nil, nil, nil, nil, nil
local trackLoop, crosshair, followLoop, autoKillLoop = nil, nil, nil, nil
local rangeSize = 1

local trapHL = Instance.new("Highlight")
trapHL.Name = "TrapESP"
trapHL.FillColor = Color3.fromRGB(255, 112, 10)
trapHL.OutlineColor = trapHL.FillColor
trapHL.FillTransparency = 0.5

local gunHL = Instance.new("Highlight")
gunHL.Name = "GunESP"
gunHL.FillColor = Color3.fromRGB(255, 255, 0)
gunHL.OutlineTransparency = 1
gunHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local function getRoot(p)
    local c = p.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum(p)
    local c = p.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function findMurderer()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Knife") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Knife") then return i end
    end
    return nil
end

local function findSheriff()
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Backpack:FindFirstChild("Gun") then return i end
    end
    for _, i in ipairs(Players:GetPlayers()) do
        if i.Character and i.Character:FindFirstChild("Gun") then return i end
    end
    return nil
end

local function findNearest()
    local near, min = nil, math.huge
    local mr = getRoot(LocalPlayer)
    if not mr then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (mr.Position - r.Position).Magnitude
                if d < min then min = d; near = p end
            end
        end
    end
    return near
end

local function getMap()
    for _, o in ipairs(Workspace:GetChildren()) do
        if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end
    end
    return nil
end

local function GetJob(p)
    local k, s = false, false
    local function c(it)
        if it:IsA("Tool") then
            local n = it.Name:lower()
            if n:find("knife") or n:find("刀") then k = true end
            if n:find("gun") or n:find("手枪") or n:find("警长") or n:find("revolver") then s = true end
        end
    end
    if p.Backpack then for _, v in pairs(p.Backpack:GetChildren()) do c(v) end end
    if p.Character then for _, v in pairs(p.Character:GetChildren()) do c(v) end end
    return k and "杀手" or s and "警长" or "平民"
end

local function GetWeapon(p, t)
    local c, b = p.Character, p.Backpack
    if not c and not b then return nil end
    local kw = t == "knife" and {"knife", "刀"} or {"gun", "手枪", "警长", "revolver"}
    local function ck(i)
        if not i or not i:IsA("Tool") then return false end
        local n = i.Name:lower()
        for _, x in ipairs(kw) do if n:find(x) then return true end end
        return false
    end
    if c then for _, i in ipairs(c:GetChildren()) do if ck(i) then return i end end end
    if b then for _, i in ipairs(b:GetChildren()) do if ck(i) then return i end end end
    return nil
end

local function closestModel(ms)
    local best, min = nil, math.huge
    local mr = getRoot(LocalPlayer)
    if not mr then return nil end
    for _, m in ipairs(ms) do
        local d = (mr.Position - m:GetPivot().Position).Magnitude
        if d < min then min = d; best = m end
    end
    return best
endlocal function powerfulFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then Notify("目标玩家无效") return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and hum.RootPart
    local tChar = targetPlayer.Character
    local tHum = tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tHum and tHum.RootPart
    local tHead = tChar:FindFirstChild("Head")
    if not char or not hum or not root then Notify("你的角色无效") return end
    if root.Velocity.Magnitude < 50 then getgenv().OldPos = root.CFrame end
    if not getgenv().FPDH then getgenv().FPDH = Workspace.FallenPartsDestroyHeight end
    if tHead then
        Workspace.CurrentCamera.CameraSubject = tHead
    elseif tHum and tRoot then
        Workspace.CurrentCamera.CameraSubject = tHum
    end
    Workspace.FallenPartsDestroyHeight = -50000
    local bv = Instance.new("BodyVelocity")
    bv.Name = "EpixVel"
    bv.Parent = root
    bv.Velocity = Vector3.new(9e7, 9e8, 9e7)
    bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local bp = tHead or tRoot
    if not bp then Notify("找不到合适的甩飞部位") bv:Destroy() return end
    local timeout = tick() + 2
    repeat
        if root and tHum then
            root.CFrame = CFrame.new(bp.Position) * CFrame.Angles(math.rad(math.random(0, 360)), 0, 0)
            char:SetPrimaryPartCFrame(root.CFrame)
            root.Velocity = Vector3.new(9e7, 9e8, 9e7)
            root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            task.wait()
        else break end
    until bp.Velocity.Magnitude > 500 or not tChar or tHum.Health <= 0 or tick() > timeout
    bv:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    Workspace.CurrentCamera.CameraSubject = hum
    repeat
        root.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
        char:SetPrimaryPartCFrame(root.CFrame)
        hum:ChangeState("GettingUp")
        for _, x in pairs(char:GetChildren()) do
            if x:IsA("BasePart") then x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new() end
        end
        task.wait()
    until (root.Position - getgenv().OldPos.p).Magnitude < 25
    Workspace.FallenPartsDestroyHeight = getgenv().FPDH
end

local function enableCoinV2()
    coinV2 = true
    if coinV2Loop then task.cancel(coinV2Loop) end
    coinV2Loop = task.spawn(function()
        while task.wait(0.01) and coinV2 do
            local map = getMap()
            if map and map:FindFirstChild("CoinContainer") then
                local coins = map.CoinContainer:GetChildren()
                if #coins > 1 then
                    local closest = closestModel(coins)
                    local root = getRoot(LocalPlayer)
                    if closest and root then
                        local dist = (root.Position - closest:GetPivot().Position).Magnitude
                        local tw = TweenService:Create(root, TweenInfo.new(dist * 0.05), {CFrame = closest:GetPivot()})
                        tw:Play()
                        tw.Completed:Wait()
                        task.wait(0.01)
                        closest:Destroy()
                    end
                end
            end
        end
    end)
end

local function disableCoinV2()
    coinV2 = false
    if coinV2Loop then task.cancel(coinV2Loop) end
end

local function enableCoinV1()
    coinV1 = true
    if coinV1Loop then task.cancel(coinV1Loop) end
    coinV1Loop = task.spawn(function()
        while coinV1 do
            task.wait(0.3)
            pcall(function()
                local root = getRoot(LocalPlayer)
                local hum = getHum(LocalPlayer)
                if not root or not hum or hum.Health <= 0 then return end
                local golds = {}
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    local nl = desc.Name:lower()
                    local isGold = false
                    for _, kw in ipairs({"coin", "金币", "gold", "money", "cash", "钱"}) do
                        if nl:find(kw) then isGold = true break end
                    end
                    if isGold and (desc:IsA("Tool") or desc:IsA("BasePart") or desc:IsA("Model")) then
                        table.insert(golds, desc)
                    end
                end
                for _, gold in ipairs(golds) do
                    if not coinV1 then break end
                    if gold:IsA("Tool") then
                        if gold.Parent ~= LocalPlayer.Backpack and gold.Parent ~= LocalPlayer.Character then
                            gold.Parent = LocalPlayer.Backpack
                            task.wait(0.3)
                        end
                    else
                        local pos = gold:IsA("Model") and gold:FindFirstChild("HumanoidRootPart") and gold.HumanoidRootPart.Position or (gold:IsA("BasePart") and gold.Position or nil)
                        if pos then
                            local orig = root.CFrame
                            root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                            task.wait(0.05)
                            root.CFrame = orig
                            task.wait(0.3)
                        end
                    end
                end
            end)
        end
    end)
end

local function disableCoinV1()
    coinV1 = false
    if coinV1Loop then task.cancel(coinV1Loop) end
end

local function ClearHighlights()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "JobHighlight" then v:Destroy() end
    end
end

local function UpdateHighlights()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local hl = char:FindFirstChild("JobHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "JobHighlight"
                        hl.Parent = char
                        hl.FillTransparency = 0.6
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    local job = GetJob(plr)
                    if job == "杀手" then
                        hl.FillColor = Color3.new(1, 0, 0)
                        hl.OutlineColor = Color3.new(1, 0, 0)
                    elseif job == "警长" then
                        hl.FillColor = Color3.new(0, 0.5, 1)
                        hl.OutlineColor = Color3.new(0, 0.5, 1)
                    else
                        hl.FillColor = Color3.new(1, 1, 1)
                        hl.OutlineColor = Color3.new(1, 1, 1)
                    end
                end
            end
        end
    end
end

local function enableJobESP()
    jobEsp = true
    if jobLoop then task.cancel(jobLoop) end
    jobLoop = task.spawn(function()
        while jobEsp do
            pcall(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local label = head:FindFirstChild("JobLabel")
                        if not label then
                            label = Instance.new("BillboardGui")
                            label.Name = "JobLabel"
                            label.Parent = head
                            label.Size = UDim2.new(0, 100, 0, 30)
                            label.StudsOffset = Vector3.new(0, 2.5, 0)
                            label.AlwaysOnTop = true
                            local txt = Instance.new("TextLabel")
                            txt.Parent = label
                            txt.BackgroundTransparency = 1
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.TextSize = 15
                            txt.Font = Enum.Font.ArialBold
                            label.TextLabel = txt
                        end
                        local txt = label.TextLabel
                        local job = GetJob(plr)
                        txt.Text = job
                        if job == "杀手" then
                            txt.TextColor3 = Color3.new(1, 0, 0)
                        elseif job == "警长" then
                            txt.TextColor3 = Color3.new(0, 0.5, 1)
                        else
                            txt.TextColor3 = Color3.new(1, 1, 1)
                        end
                    end
                end
                UpdateHighlights()
            end)
            task.wait(0.3)
        end
    end)
end

local function disableJobESP()
    jobEsp = false
    if jobLoop then task.cancel(jobLoop) end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            local label = plr.Character.Head:FindFirstChild("JobLabel")
            if label then label:Destroy() end
        end
    end
    ClearHighlights()
end

local function enableAutoPickGun()
    autoGun = true
    if gunLoop then task.cancel(gunLoop) end
    gunLoop = task.spawn(function()
        while autoGun do
            task.wait(0.3)
            local root = getRoot(LocalPlayer)
            local hum = getHum(LocalPlayer)
            if root and hum and hum.Health > 0 and not GetWeapon(LocalPlayer, "gun") then
                local target
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("Tool") then
                        local nl = desc.Name:lower()
                        local isGun = false
                        for _, kw in ipairs({"gun", "手枪", "警长", "revolver"}) do
                            if nlocal function enableCoinV2()
    coinV2 = true
    if coinV2Loop then task.cancel(coinV2Loop) end
    coinV2Loop = task.spawn(function()
        while task.wait(0.01) and coinV2 do
            local map = getMap()
            if map and map:FindFirstChild("CoinContainer") then
                local coins = map.CoinContainer:GetChildren()
                if #coins > 1 then
                    local closest = closestModel(coins)
                    local root = getRoot(LocalPlayer)
                    if closest and root then
                        local dist = (root.Position - closest:GetPivot().Position).Magnitude
                        local tw = TweenService:Create(root, TweenInfo.new(dist * 0.05), {CFrame = closest:GetPivot()})
                        tw:Play()
                        tw.Completed:Wait()
                        task.wait(0.01)
                        closest:Destroy()
                    end
                end
            end
        end
    end)
end

local function disableCoinV2()
    coinV2 = false
    if coinV2Loop then task.cancel(coinV2Loop) end
end

local function enableCoinV1()
    coinV1 = true
    if coinV1Loop then task.cancel(coinV1Loop) end
    coinV1Loop = task.spawn(function()
        while coinV1 do
            task.wait(0.3)
            pcall(function()
                local root = getRoot(LocalPlayer)
                local hum = getHum(LocalPlayer)
                if not root or not hum or hum.Health <= 0 then return end
                local golds = {}
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    local nl = desc.Name:lower()
                    local isGold = false
                    for _, kw in ipairs({"coin", "金币", "gold", "money", "cash", "钱"}) do
                        if nl:find(kw) then isGold = true break end
                    end
                    if isGold and (desc:IsA("Tool") or desc:IsA("BasePart") or desc:IsA("Model")) then
                        table.insert(golds, desc)
                    end
                end
                for _, gold in ipairs(golds) do
                    if not coinV1 then break end
                    if gold:IsA("Tool") then
                        if gold.Parent ~= LocalPlayer.Backpack and gold.Parent ~= LocalPlayer.Character then
                            gold.Parent = LocalPlayer.Backpack
                            task.wait(0.3)
                        end
                    else
                        local pos = gold:IsA("Model") and gold:FindFirstChild("HumanoidRootPart") and gold.HumanoidRootPart.Position or (gold:IsA("BasePart") and gold.Position or nil)
                        if pos then
                            local orig = root.CFrame
                            root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                            task.wait(0.05)
                            root.CFrame = orig
                            task.wait(0.3)
                        end
                    end
                end
            end)
        end
    end)
end

local function disableCoinV1()
    coinV1 = false
    if coinV1Loop then task.cancel(coinV1Loop) end
end

local function ClearHighlights()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "JobHighlight" then v:Destroy() end
    end
end

local function UpdateHighlights()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local hl = char:FindFirstChild("JobHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "JobHighlight"
                        hl.Parent = char
                        hl.FillTransparency = 0.6
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    local job = GetJob(plr)
                    if job == "杀手" then
                        hl.FillColor = Color3.new(1, 0, 0)
                        hl.OutlineColor = Color3.new(1, 0, 0)
                    elseif job == "警长" then
                        hl.FillColor = Color3.new(0, 0.5, 1)
                        hl.OutlineColor = Color3.new(0, 0.5, 1)
                    else
                        hl.FillColor = Color3.new(1, 1, 1)
                        hl.OutlineColor = Color3.new(1, 1, 1)
                    end
                end
            end
        end
    end
end

local function enableJobESP()
    jobEsp = true
    if jobLoop then task.cancel(jobLoop) end
    jobLoop = task.spawn(function()
        while jobEsp do
            pcall(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local label = head:FindFirstChild("JobLabel")
                        if not label then
                            label = Instance.new("BillboardGui")
                            label.Name = "JobLabel"
                            label.Parent = head
                            label.Size = UDim2.new(0, 100, 0, 30)
                            label.StudsOffset = Vector3.new(0, 2.5, 0)
                            label.AlwaysOnTop = true
                            local txt = Instance.new("TextLabel")
                            txt.Parent = label
                            txt.BackgroundTransparency = 1
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.TextSize = 15
                            txt.Font = Enum.Font.ArialBold
                            label.TextLabel = txt
                        end
                        local txt = label.TextLabel
                        local job = GetJob(plr)
                        txt.Text = job
                        if job == "杀手" then
                            txt.TextColor3 = Color3.new(1, 0, 0)
                        elseif job == "警长" then
                            txt.TextColor3 = Color3.new(0, 0.5, 1)
                        else
                            txt.TextColor3 = Color3.new(1, 1, 1)
                        end
                    end
                end
                UpdateHighlights()
            end)
            task.wait(0.3)
        end
    end)
end

local function disableJobESP()
    jobEsp = false
    if jobLoop then task.cancel(jobLoop) end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            local label = plr.Character.Head:FindFirstChild("JobLabel")
            if label then label:Destroy() end
        end
    end
    ClearHighlights()
end

local function enableAutoPickGun()
    autoGun = true
    if gunLoop then task.cancel(gunLoop) end
    gunLoop = task.spawn(function()
        while autoGun do
            task.wait(0.3)
            local root = getRoot(LocalPlayer)
            local hum = getHum(LocalPlayer)
            if root and hum and hum.Health > 0 and not GetWeapon(LocalPlayer, "gun") then
                local target
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("Tool") then
                        local nl = desc.Name:lower()
                        local isGun = false
                        for _, kw in ipairs({"gun", "手枪", "警长", "revolver"}) do
                            if nl:find(kw) then isGun = true break end
                        end
                        if isGun and desc:IsDescendantOf(Workspace) and not desc:IsDescendantOf(LocalPlayer) then
                            target = desc
                            break
                        end
                    end
                end
                if target then
                    local orig = root.CFrame
                    local pos = target:IsA("BasePart") and target.Position or (target:FindFirstChild("Handle") and target.Handle.Position) or nil
                    if pos then
                        root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                        task.wait(0.3)
                        pcall(function() target.Parent = LocalPlayer.Backpack end)
                        root.CFrame = orig
                        Notify("已拾取一把警长枪械")
                    end
                end
            end
        end
    end)
end

local function disableAutoPickGun()
    autoGun = false
    if gunLoop then task.cancel(gunLoop) end
                                        endWindow = WindUI:CreateWindow({
    Title = "灵境",
    Author = "李佳 | QQ群：2066484928",
    Folder = "灵境",
    Icon = "door-open",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark"
})

Notify = function(msg)
    WindUI:Notify({
        Title = "灵境",
        Content = msg,
        Duration = 3
    })
end

local TabMain = Window:Tab({ Title = "主要", Icon = "zap" })

TabMain:Section({ Title = "功能开关" })

TabMain:Toggle({
    Title = "职业透视",
    Desc = "显示玩家职业",
    Value = false,
    Callback = function(v)
        if v then enableJobESP() else disableJobESP() end
    end
})

TabMain:Toggle({
    Title = "自动捡金币 v1",
    Desc = "扫描所有金币物体并瞬移拾取",
    Value = false,
    Callback = function(v)
        if v then enableCoinV1() else disableCoinV1() end
    end
})

TabMain:Toggle({
    Title = "自动捡金币 v2",
    Desc = "只针对地图金币容器",
    Value = false,
    Callback = function(v)
        if v then enableCoinV2() else disableCoinV2() end
    end
})

TabMain:Toggle({
    Title = "自动捡警长枪",
    Desc = "没有枪时自动拾取地上枪支",
    Value = false,
    Callback = function(v)
        if v then enableAutoPickGun() else disableAutoPickGun() end
    end
})local TabSettings = Window:Tab({ Title = "设置", Icon = "settings" })

TabSettings:Section({ Title = "脚本信息" })

TabSettings:Paragraph({
    Title = "灵境",
    Desc = "创作者：李佳 | QQ群：2066484928"
})

TabSettings:Section({ Title = "操作" })

TabSettings:Button({
    Title = "卸载脚本",
    Desc = "关闭界面并停止所有功能",
    Callback = function()
        disableJobESP()
        disableCoinV1()
        disableCoinV2()
        disableAutoPickGun()
        Window:Destroy()
    end
})
