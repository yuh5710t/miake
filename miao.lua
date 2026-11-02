-- =====================================================================
-- 破坏者谜团 2 (李佳专属) [第一段]：沉浸式索尼克开场 + 状态机 UI
-- 版本：V8.0 (企业级模块化规范)
-- 注释：本段负责播放开场动画、构建用户界面、初始化全局配置。
-- =====================================================================

-- ==========================================
-- 模块 0：核心服务与依赖引入
-- ==========================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 模块 1：索尼克经典开场动画引擎
-- ==========================================
local function PlaySonicIntro()
    -- 创建独立的动画 GUI 层，防止干扰后续 UI
    local LoadGui = Instance.new("ScreenGui")
    LoadGui.Name = "SonicIntroUI"
    LoadGui.DisplayOrder = 99999
    LoadGui.IgnoreGuiInset = true
    LoadGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- 经典深蓝背景
    local Bg = Instance.new("Frame", LoadGui)
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.BackgroundColor3 = Color3.fromRGB(10, 20, 50) -- 索尼克深蓝
    Bg.BorderSizePixel = 0

    -- 核心元素：金色大圆环 (Rings)
    local GoldRing = Instance.new("Frame", Bg)
    GoldRing.Size = UDim2.new(0, 220, 0, 220)
    GoldRing.Position = UDim2.new(0.5, -110, 0.5, -110)
    GoldRing.BackgroundTransparency = 1
    
    local RingStroke = Instance.new("UIStroke", GoldRing)
    RingStroke.Color = Color3.fromRGB(255, 215, 0) -- 经典暗金
    RingStroke.Thickness = 18 -- 加粗，呈现真实的厚重感
    
    local RingCorner = Instance.new("UICorner", GoldRing)
    RingCorner.CornerRadius = UDim.new(1, 0) -- 完美正圆

    -- 核心元素：速度蓝光
    local SpeedGlow = Instance.new("Frame", Bg)
    SpeedGlow.Size = UDim2.new(0, 250, 0, 250)
    SpeedGlow.Position = UDim2.new(0.5, -125, 0.5, -125)
    SpeedGlow.BackgroundTransparency = 1
    
    local GlowStroke = Instance.new("UIStroke", SpeedGlow)
    GlowStroke.Color = Color3.fromRGB(0, 150, 255) -- 索尼克蓝
    GlowStroke.Thickness = 4
    GlowStroke.Transparency = 0.3

    -- 文字元素：SONIC
    local Title = Instance.new("TextLabel", Bg)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Position = UDim2.new(0, 0, 0.5, 120)
    Title.BackgroundTransparency = 1
    Title.Text = "SONIC"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 50
    Title.TextStrokeTransparency = 0
    Title.TextStrokeColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextTransparency = 1 -- 初始透明

    -- 文字元素：GOTTA GO FAST
    local Sub = Instance.new("TextLabel", Bg)
    Sub.Size = UDim2.new(1, 0, 0, 30)
    Sub.Position = UDim2.new(0, 0, 0.5, 180)
    Sub.BackgroundTransparency = 1
    Sub.Text = "GOTTA GO FAST!"
    Sub.TextColor3 = Color3.fromRGB(255, 215, 0)
    Sub.Font = Enum.Font.GothamBold
    Sub.TextSize = 22
    Sub.TextTransparency = 1

    -- 动画执行线程
    task.spawn(function()
        -- 环形高速旋转（模拟音速）
        local spinConn = RunService.RenderStepped:Connect(function()
            GoldRing.Rotation = GoldRing.Rotation + 15
            SpeedGlow.Rotation = SpeedGlow.Rotation - 8
        end)
        
        -- 入场：金环瞬间弹射放大
        GoldRing.Size = UDim2.new(0, 0, 0, 0)
        GoldRing.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        local popInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(GoldRing, popInfo, {Size = UDim2.new(0, 220, 0, 220), Position = UDim2.new(0.5, -110, 0.5, -110)}):Play()
        TweenService:Create(SpeedGlow, popInfo, {Size = UDim2.new(0, 250, 0, 250), Position = UDim2.new(0.5, -125, 0.5, -125)}):Play()
        
        -- 文字渐显
        TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        TweenService:Create(Sub, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        
        task.wait(2.5) -- 给玩家留出观看时间
        
        -- 退场：瞬间前冲消散
        local outInfo = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
        TweenService:Create(Bg, outInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(GoldRing, outInfo, {Size = UDim2.new(0, 500, 0, 500), Position = UDim2.new(0.5, -250, 0.5, -250)}):Play()
        TweenService:Create(RingStroke, outInfo, {Transparency = 1}):Play()
        TweenService:Create(GlowStroke, outInfo, {Transparency = 1}):Play()
        TweenService:Create(Title, outInfo, {TextTransparency = 1}):Play()
        TweenService:Create(Sub, outInfo, {TextTransparency = 1}):Play()
        
        task.wait(0.6)
        spinConn:Disconnect()
        LoadGui:Destroy()
    end)
end

-- 执行动画
PlaySonicIntro()

-- ==========================================
-- 模块 2：全局状态机与菜单初始化
-- ==========================================
-- 延时等待动画播完，再创建菜单界面
task.wait(3.2)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- 将 Window 挂载到 _G 上，以便第二段可以安全地接管
_G.MM2Window = WindUI:CreateWindow({
    Title = "破坏者谜团 2",
    Author = "李佳",
    Folder = "MM2_V8",
    Size = UDim2.fromOffset(500, 400),
    Theme = "Dark"
})

-- 初始化核心全局状态机（State Machine）
-- 采用键值对形式，后续只需修改这些布尔值即可控制功能
_G.MM2State = {
    EnableESP = true,       -- 透视开关
    EnableHitbox = true,    -- 骨骼放大（防打不中）
    EnableKnifeSize = true, -- 长臂猿（加大刀距）
    EnableAimbot = true,    -- 静默自瞄
    EnableNoclip = false,   -- 幽灵穿墙
    EnableNoFlash = true,   -- 防黑屏
    
    KnifeSizeValue = 35,    -- 刀距数值
    HitboxValue = 16,       -- 骨骼放大数值
    TargetMurderer = nil    -- 用于自瞄锁定的目标（由第二段动态更新）
}

-- 引用状态机与窗口
local State = _G.MM2State
local Win = _G.MM2Window

-- ==========================================
-- 模块 3：UI 控件模块化挂载
-- ==========================================

-- 标签页 1：视觉系统
local VisualTab = Win:Tab({ Title = "视觉系统", Icon = "eye" })
VisualTab:Toggle({
    Title = "全图身份透视",
    Desc = "显示红名杀手 / 蓝名警长 / 绿名平民",
    Value = true,
    Callback = function(state) State.EnableESP = state end
})
VisualTab:Toggle({
    Title = "防黑屏夜视仪",
    Desc = "无视杀手关灯（Lights Out）",
    Value = true,
    Callback = function(state) State.EnableNoFlash = state end
})

-- 标签页 2：杀手强化
local KillerTab = Win:Tab({ Title = "杀手强化", Icon = "knife" })
KillerTab:Toggle({
    Title = "长臂猿（超距判定）",
    Desc = "增大武器的物理碰撞体积",
    Value = true,
    Callback = function(state) State.EnableKnifeSize = state end
})
KillerTab:Toggle({
    Title = "敌人骨骼放大",
    Desc = "让敌人的受击判定框变大，闭眼都能砍中",
    Value = true,
    Callback = function(state) State.EnableHitbox = state end
})
KillerTab:Slider({
    Title = "自定刀距大小",
    Desc = "数值越大，隔空砍人越远",
    Value = { Min = 10, Max = 70, Default = 35 },
    Callback = function(val) State.KnifeSizeValue = val end
})

-- 标签页 3：警长强化
local SheriffTab = Win:Tab({ Title = "警长强化", Icon = "crosshair" })
SheriffTab:Toggle({
    Title = "静默自瞄锁头",
    Desc = "子弹自动追踪杀手头部（无需瞄准）",
    Value = true,
    Callback = function(state) State.EnableAimbot = state end
})

-- 标签页 4：系统功能
local SysTab = Win:Tab({ Title = "系统功能", Icon = "settings" })
SysTab:Toggle({
    Title = "幽灵穿墙",
    Desc = "无视一切物理障碍物",
    Value = false,
    Callback = function(state) State.EnableNoclip = state end
})

-- 提示第一段加载成功
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "索尼克加载完毕",
    Text = "请立即运行第二段核心逻辑脚本...",
    Duration = 5
})-- =====================================================================
-- 破坏者谜团 2 (李佳专属) [第二段]：卓越级物理与自瞄引擎
-- 版本：V8.0 (企业级模块化规范)
-- 注释：负责实时物理运算、UI渲染循环、底层射线劫持。
-- =====================================================================

-- ==========================================
-- 模块 0：服务引入与安全检查
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

-- 从第一段提取状态机
local State = _G.MM2State
if not State then
    -- 安全拦截：如果玩家没跑第一段，直接中断并警告
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "致命错误", Text = "检测到未运行第一段代码！", Duration = 5
    })
    return
end

local ESPCache = {}

-- ==========================================
-- 模块 1：工具库（独立封装）
-- ==========================================
-- 检查角色是否存活
local function IsAlive(character)
    if not character or not character.Parent then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- 计算 3D 空间距离
local function GetDistance(pos1, pos2)
    return math.floor((pos1 - pos2).Magnitude)
end

-- ==========================================
-- 模块 2：物理改造引擎（穿墙 + 长臂猿）
-- ==========================================
local function ProcessPhysics(myChar)
    -- 2.1 长臂猿大刀距
    local knife = myChar:FindFirstChild("Knife")
    if knife and State.EnableKnifeSize then
        for _, part in pairs(knife:GetDescendants()) do
            if part:IsA("BasePart") then
                -- 放大物理判定体积
                part.Size = Vector3.new(State.KnifeSizeValue, State.KnifeSizeValue, State.KnifeSizeValue)
                part.CanCollide = true
                part.Transparency = 1 -- 隐形放大的模型，防止挡视线
                part.Massless = true   -- 去除质量，防止拖慢移速
            end
        end
    end

    -- 2.2 幽灵穿墙
    if State.EnableNoclip then
        for _, part in pairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    else
        -- 恢复碰撞（小心不要卡在地图里）
        for _, part in pairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- ==========================================
-- 模块 3：视觉与判定引擎（透视 + 骨骼放大）
-- ==========================================
local function ProcessVisuals()
    State.TargetMurderer = nil -- 每帧重置自瞄锁定目标
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr.Character) then
            local tChar = plr.Character
            local head = tChar:FindFirstChild("Head")
            local root = tChar:FindFirstChild("HumanoidRootPart")
            
            if head and root then
                -- 3.1 敌人受击框放大（骨骼放大）
                if State.EnableHitbox then
                    local isR6 = tChar:FindFirstChild("Torso") ~= nil
                    for _, p in pairs(tChar:GetDescendants()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and not p.Parent:IsA("Tool") then
                            if (isR6 and (p.Name == "Head" or p.Name == "Torso" or string.find(p.Name, "Arm"))) or 
                               (not isR6 and (string.find(p.Name, "Head") or string.find(p.Name, "Torso") or string.find(p.Name, "Arm"))) then
                                p.Size = Vector3.new(State.HitboxValue, State.HitboxValue, State.HitboxValue)
                            end
                        end
                    end
                end
                
                -- 3.2 身份判定与自瞄锁定
                local role, color = "平民", Color3.fromRGB(0, 255, 0)
                if tChar:FindFirstChild("Knife") then 
                    role, color = "杀手", Color3.fromRGB(255, 50, 50)
                    State.TargetMurderer = head -- 捕获杀手头部，供底层 Hook 使用
                elseif tChar:FindFirstChild("Gun") or tChar:FindFirstChild("Revolver") then 
                    role, color = "警长", Color3.fromRGB(50, 150, 255) 
                end
                
                -- 3.3 全图身份透视渲染（ESP）
                if State.EnableESP then
                    if not ESPCache[plr] then
                        -- 初始化 UI 对象
                        local hl = Instance.new("Highlight", tChar)
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        local bb = Instance.new("BillboardGui", head)
                        bb.Size, bb.StudsOffset, bb.AlwaysOnTop = UDim2.new(0, 160, 0, 50), Vector3.new(0, 2.5, 0), true
                        
                        local nameTxt = Instance.new("TextLabel", bb)
                        nameTxt.Size, nameTxt.BackgroundTransparency, nameTxt.Font, nameTxt.TextSize = UDim2.new(1, 0, 0.5, 0), 1, Enum.Font.GothamBold, 16
                        
                        local roleTxt = Instance.new("TextLabel", bb)
                        roleTxt.Size, roleTxt.Position, roleTxt.BackgroundTransparency, roleTxt.Font, roleTxt.TextSize = UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0.5, 0), 1, Enum.Font.GothamBold, 14
                        
                        ESPCache[plr] = {HL = hl, Name = nameTxt, Role = roleTxt}
                    end
                    
                    -- 实时更新数据
                    local esp = ESPCache[plr]
                    local dist = GetDistance(root.Position, CurrentCamera.CFrame.Position)
                    
                    esp.HL.FillColor = color
                    esp.Name.Text = plr.Name .. " [" .. dist .. "m]"
                    esp.Name.TextColor3 = Color3.fromRGB(255, 255, 255)
                    esp.Role.Text, esp.Role.TextColor3 = role, color
                end
            end
        end
    end
end

-- ==========================================
-- 模块 4：底层劫持引擎（静默自瞄）
-- ==========================================
-- 原理：通过 Hook 游戏底层的 getrawmetatable，劫持 Raycast（射线检测）
-- 当开枪瞬间，强行修改射线终点为杀手头部，实现子弹拐弯。
local mt = getrawmetatable(game)
if mt and mt.__namecall then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- 检测是否为射线操作
        if tostring(method) == "Raycast" or tostring(self) == "Ray" then
            -- 如果开启自瞄且发现了杀手目标
            if State.EnableAimbot and State.TargetMurderer and State.TargetMurderer.Parent then
                local origin = CurrentCamera.CFrame.Position
                -- 重定向向量：直接指向杀手头部
                local direction = (State.TargetMurderer.Position - origin).Unit * 1000
                
                -- 覆盖游戏的原始参数
                if type(args[2]) == "Vector3" then
                    args[2] = direction 
                end
            end
        end
        
        -- 执行被拦截后的原始操作
        return oldNamecall(self, unpack(args))
    end)
    
    setreadonly(mt, true)
end

-- ==========================================
-- 模块 5：环境光干预（防黑屏）
-- ==========================================
local function ProcessLighting()
    if State.EnableNoFlash then
        -- 强制拉高环境光亮度，无视杀手拉闸
        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        Lighting.Brightness = 2
    end
end

-- ==========================================
-- 模块 6：主控渲染大循环 (RenderStepped)
-- ==========================================
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    
    -- 本地角色未加载或死亡时，停止运算，节省性能
    if not IsAlive(myChar) then 
        return 
    end

    -- 顺序执行各功能引擎
    ProcessPhysics(myChar)    -- 物理（刀距、穿墙）
    ProcessVisuals()          -- 视觉（骨骼、透视、目标锁定）
    ProcessLighting()         -- 环境（防黑屏）
end)
