-- =====================================================================
-- 索尼克中心 [第一段]：索尼克专属动态加载
-- =====================================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "SonicLoading"
LoadingGui.DisplayOrder = 99999
LoadingGui.IgnoreGuiInset = true
LoadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 深邃背景
local BackFrame = Instance.new("Frame", LoadingGui)
BackFrame.Size = UDim2.new(1, 0, 1, 0)
BackFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25) -- 深邃蓝黑
BackFrame.BorderSizePixel = 0

-- 索尼克标志性金环 (中心旋转)
local Ring = Instance.new("Frame", BackFrame)
Ring.Size = UDim2.new(0, 160, 0, 160)
Ring.Position = UDim2.new(0.5, -80, 0.5, -120)
Ring.BackgroundTransparency = 1
local RingStroke = Instance.new("UIStroke", Ring)
RingStroke.Color = Color3.fromRGB(255, 215, 0) -- 金环颜色
RingStroke.Thickness = 8 -- 加粗做成环
Instance.new("UICorner", Ring).CornerRadius = UDim.new(1, 0)

-- 索尼克蓝色速度闪电特效 (环绕金环)
local RingGlow = Instance.new("UIStroke", Ring)
RingGlow.Color = Color3.fromRGB(0, 150, 255) -- 索尼克蓝
RingGlow.Thickness = 2
RingGlow.Transparency = 0.5

-- 标题文字
local Title = Instance.new("TextLabel", BackFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0.5, 30)
Title.BackgroundTransparency = 1
Title.Text = "SONIC CENTER"
Title.TextColor3 = Color3.fromRGB(0, 200, 255) -- 亮蓝色
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 32
Title.TextStrokeTransparency = 0 -- 加黑边增加立体感
Title.TextStrokeColor3 = Color3.fromRGB(0, 50, 150)
Title.TextTransparency = 1

local SubTitle = Instance.new("TextLabel", BackFrame)
SubTitle.Size = UDim2.new(1, 0, 0, 30)
SubTitle.Position = UDim2.new(0, 0, 0.5, 75)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "GOTTA GO FAST!"
SubTitle.TextColor3 = Color3.fromRGB(255, 215, 0) -- 金色副标题
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 16
SubTitle.TextTransparency = 1

-- 启动动画逻辑
task.spawn(function()
    -- 金环极速旋转 (模拟索尼克速度)
    local spinConn = RunService.RenderStepped:Connect(function()
        Ring.Rotation = Ring.Rotation + 8
    end)
    
    -- 标题淡入
    TweenService:Create(Title, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    
    task.wait(2.5) -- 保持展示2.5秒
    
    -- 索尼克音爆淡出 (金环瞬间变大消失)
    local boomTween = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
    TweenService:Create(Ring, boomTween, {Size = UDim2.new(0, 400, 0, 400), Position = UDim2.new(0.5, -200, 0.5, -240)}):Play()
    TweenService:Create(RingStroke, boomTween, {Transparency = 1}):Play()
    TweenService:Create(RingGlow, boomTween, {Transparency = 1}):Play()
    TweenService:Create(BackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    
    task.wait(0.6)
    spinConn:Disconnect()
    LoadingGui:Destroy()
    _G.SonicLoadDone = true
end)-- =====================================================================
-- 索尼克中心 [第二段]：定制UI与四大核心引擎
-- =====================================================================
if not _G.SonicLoadDone then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local ScriptConfig = {
    ESP_Enabled = true, Hitbox_Enabled = true, Knife_Enabled = true, 
    Aimbot_Enabled = true, NoFlash_Enabled = true,
    Knife_ReachSize = 65, Hitbox_ExpandSize = 18, Aimbot_Smoothness = 0.6
}
local RuntimeCache = { ESP_Cache = {} }

-- UI 构建 (改用索尼克蓝黑主题)
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25) -- 蓝黑底色
MainFrame.BackgroundTransparency = 0.1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 150, 255) -- 索尼克蓝边框
Stroke.Thickness = 2

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 25, 40)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "索尼克中心 | 李佳"
TitleText.TextColor3 = Color3.fromRGB(255, 215, 0) -- 金色字
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18

-- 拖拽逻辑
local isDragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then isDragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and isDragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function CreateToggle(text, yPos, configKey)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0.8, 0, 0, 45)
    Btn.Position = UDim2.new(0.1, 0, 0, yPos)
    Btn.BackgroundColor3 = ScriptConfig[configKey] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(30, 40, 55)
    Btn.Text = text .. ": " .. (ScriptConfig[configKey] and "开启" or "关闭")
    Btn.TextColor3 = ScriptConfig[configKey] and Color3.fromRGB(10,15,25) or Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(function()
        ScriptConfig[configKey] = not ScriptConfig[configKey]
        Btn.BackgroundColor3 = ScriptConfig[configKey] and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(30, 40, 55)
        Btn.Text = text .. ": " .. (ScriptConfig[configKey] and "开启" or "关闭")
        Btn.TextColor3 = ScriptConfig[configKey] and Color3.fromRGB(10,15,25) or Color3.fromRGB(255, 255, 255)
    end)
end

CreateToggle("全图身份透视", 55, "ESP_Enabled")
CreateToggle("敌人骨骼放大", 110, "Hitbox_Enabled")
CreateToggle("杀手超距长臂猿", 165, "Knife_Enabled")
CreateToggle("警长智能平滑锁头", 220, "Aimbot_Enabled")
CreateToggle("防黑屏视野增强", 275, "NoFlash_Enabled")

-- 核心逻辑
local function IsAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not IsAlive(myChar) then return end

    if ScriptConfig.Knife_Enabled then
        local knife = myChar:FindFirstChild("Knife")
        if knife then
            for _, part in pairs(knife:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(ScriptConfig.Knife_ReachSize, ScriptConfig.Knife_ReachSize, ScriptConfig.Knife_ReachSize)
                    part.CanCollide = true; part.Transparency = 1; part.Massless = true
                end
            end
        end
    end

    if ScriptConfig.Aimbot_Enabled then
        local gun = myChar:FindFirstChild("Gun") or myChar:FindFirstChild("Revolver")
        if gun then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and IsAlive(plr.Character) and plr.Character:FindFirstChild("Knife") then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local targetCF = CFrame.new(CurrentCamera.CFrame.Position, head.Position)
                        CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(targetCF, ScriptConfig.Aimbot_Smoothness)
                    end
                end
            end
        end
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr.Character) then
            local tChar, head, root = plr.Character, plr.Character:FindFirstChild("Head"), plr.Character:FindFirstChild("HumanoidRootPart")
            if head and root then
                if ScriptConfig.Hitbox_Enabled then
                    for _, p in pairs(tChar:GetDescendants()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and not p.Parent:IsA("Tool") then
                            if string.find(p.Name, "Head") or string.find(p.Name, "Torso") or string.find(p.Name, "Arm") or string.find(p.Name, "Leg") then
                                p.Size = Vector3.new(ScriptConfig.Hitbox_ExpandSize, ScriptConfig.Hitbox_ExpandSize, ScriptConfig.Hitbox_ExpandSize)
                            end
                        end
                    end
                end
                
                if ScriptConfig.ESP_Enabled then
                    local role, color = "平民", Color3.fromRGB(0, 255, 0)
                    if tChar:FindFirstChild("Knife") then role, color = "杀手", Color3.fromRGB(255, 50, 50)
                    elseif tChar:FindFirstChild("Gun") or tChar:FindFirstChild("Revolver") then role, color = "警长", Color3.fromRGB(50, 150, 255) end
                    
                    if not RuntimeCache.ESP_Cache[plr] then
                        local hl = Instance.new("Highlight", tChar)
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        local bb = Instance.new("BillboardGui", head)
                        bb.Size, bb.StudsOffset, bb.AlwaysOnTop = UDim2.new(0, 160, 0, 50), Vector3.new(0, 2.5, 0), true
                        local nameTxt = Instance.new("TextLabel", bb)
                        nameTxt.Size, nameTxt.BackgroundTransparency, nameTxt.Font, nameTxt.TextSize = UDim2.new(1, 0, 0.5, 0), 1, Enum.Font.GothamBold, 16
                        local roleTxt = Instance.new("TextLabel", bb)
                        roleTxt.Size, roleTxt.Position, roleTxt.BackgroundTransparency, roleTxt.Font, roleTxt.TextSize = UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0.5, 0), 1, Enum.Font.GothamBold, 14
                        RuntimeCache.ESP_Cache[plr] = {HL = hl, Name = nameTxt, Role = roleTxt}
                    end
                    
                    local esp = RuntimeCache.ESP_Cache[plr]
                    esp.HL.FillColor = color
                    esp.Name.Text = plr.Name .. " [" .. math.floor((root.Position - CurrentCamera.CFrame.Position).Magnitude) .. "m]"
                    esp.Name.TextColor3 = Color3.fromRGB(255, 255, 255)
                    esp.Role.Text, esp.Role.TextColor3 = role, color
                end
            end
        end
    end

    if ScriptConfig.NoFlash_Enabled then
        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        Lighting.Brightness = 2
    end
end)
