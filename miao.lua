-- =====================================================================
-- 脚本名称：索尼克中心 (物理引擎与渲染模块)
-- 作者：李佳
-- 版本：V4.0.0 (275行精装排版版)
-- 功能：全图身份透视 | 骨骼级碰撞箱放大 | 杀手超距判定 | 警长自动追踪
-- =====================================================================

-- ==========================================
-- 模块 0：核心服务与全局引用
-- ==========================================
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer
local CurrentCamera = Services.Workspace.CurrentCamera

-- ==========================================
-- 模块 1：全局配置中心
-- ==========================================
local CONFIG = {
    ESP = {
        Enabled = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        RoleColors = {
            Innocent = Color3.fromRGB(0, 255, 0),
            Murderer = Color3.fromRGB(255, 50, 50),
            Sheriff  = Color3.fromRGB(50, 150, 255)
        }
    },
    Hitbox = {
        Enabled = true,
        Size = Vector3.new(18, 18, 18) -- 敌人大胖子尺寸
    },
    Knife = {
        Enabled = true,
        Size = Vector3.new(65, 65, 65) -- 40米大刀尺寸
    },
    Aimbot = {
        Enabled = true,
        Smoothness = 0.6 -- 锁头平滑度
    }
}

-- ==========================================
-- 模块 2：状态与缓存管理器
-- ==========================================
local State = {
    ESPCache = {},
    TrackedPlayers = {}
}

-- ==========================================
-- 模块 3：通用工具函数
-- ==========================================
local function IsCharacterAlive(character)
    if not character or not character.Parent then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        return true
    end
    return false
end

local function GetDistance(pos1, pos2)
    return math.floor((pos1 - pos2).Magnitude)
end

local function GetRoleInfo(character)
    if character:FindFirstChild("Knife") then 
        return "杀手 (Murderer)", CONFIG.ESP.RoleColors.Murderer
    elseif character:FindFirstChild("Gun") or character:FindFirstChild("Revolver") then 
        return "警长 (Sheriff)", CONFIG.ESP.RoleColors.Sheriff
    else 
        return "平民 (Innocent)", CONFIG.ESP.RoleColors.Innocent
    end
end

-- ==========================================
-- 模块 4：物理系统 (大刀距与骨骼放大)
-- ==========================================
local function ProcessPhysics(myChar)
    -- 4.1 杀手超距判定
    local knife = myChar:FindFirstChild("Knife")
    if knife and CONFIG.Knife.Enabled then
        for _, part in pairs(knife:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Size = CONFIG.Knife.Size
                part.CanCollide = true
                part.Transparency = 1
                part.Massless = true
            end
        end
    end

    -- 4.2 敌人骨骼碰撞箱放大
    if CONFIG.Hitbox.Enabled then
        for _, plr in pairs(Services.Players:GetPlayers()) do
            if plr ~= LocalPlayer and IsCharacterAlive(plr.Character) then
                local targetChar = plr.Character
                local isR6 = targetChar:FindFirstChild("Torso") ~= nil
                
                for _, part in pairs(targetChar:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not part.Parent:IsA("Tool") then
                        -- R6/R15 骨骼兼容判定
                        local isValidBone = false
                        if isR6 then
                            if part.Name == "Head" or part.Name == "Torso" or string.find(part.Name, "Arm") or string.find(part.Name, "Leg") then
                                isValidBone = true
                            end
                        else
                            if string.find(part.Name, "Head") or string.find(part.Name, "Torso") or string.find(part.Name, "Arm") or string.find(part.Name, "Leg") then
                                isValidBone = true
                            end
                        end
                        
                        if isValidBone then
                            part.Size = CONFIG.Hitbox.Size
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end

-- ==========================================
-- 模块 5：警长智能平滑自瞄系统
-- ==========================================
local function ProcessAimbot(myChar)
    local gun = myChar:FindFirstChild("Gun") or myChar:FindFirstChild("Revolver")
    if not gun or not CONFIG.Aimbot.Enabled then return end
    
    local closestMurdererHead = nil
    local minDistance = 150
    
    -- 扫描全场杀手
    for _, plr in pairs(Services.Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsCharacterAlive(plr.Character) then
            if plr.Character:FindFirstChild("Knife") then
                local head = plr.Character:FindFirstChild("Head")
                local dist = GetDistance(head.Position, CurrentCamera.CFrame.Position)
                
                if dist < minDistance then
                    minDistance = dist
                    closestMurdererHead = head
                end
            end
        end
    end
    
    -- 平滑锁定视角
    if closestMurdererHead then
        local targetCFrame = CFrame.new(CurrentCamera.CFrame.Position, closestMurdererHead.Position)
        CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(targetCFrame, CONFIG.Aimbot.Smoothness)
    end
end

-- ==========================================
-- 模块 6：全息身份透视渲染引擎
-- ==========================================
local function ProcessVisuals()
    if not CONFIG.ESP.Enabled then return end
    
    for _, plr in pairs(Services.Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsCharacterAlive(plr.Character) then
            local char = plr.Character
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if head and root then
                local roleText, roleColor = GetRoleInfo(char)
                local distance = GetDistance(root.Position, CurrentCamera.CFrame.Position)
                
                -- 延迟创建 UI 节点
                if not State.ESPCache[plr] then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Parent = char
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    Highlight.FillTransparency = 0.5
                    
                    local BB = Instance.new("BillboardGui")
                    BB.Parent = head
                    BB.Size = UDim2.new(0, 160, 0, 50)
                    BB.StudsOffset = Vector3.new(0, 2.8, 0)
                    BB.AlwaysOnTop = true
                    
                    local NameUI = Instance.new("TextLabel", BB)
                    NameUI.Size = UDim2.new(1, 0, 0.5, 0)
                    NameUI.BackgroundTransparency = 1
                    NameUI.Font = Enum.Font.GothamBold
                    NameUI.TextSize = 16
                    NameUI.TextStrokeTransparency = 0
                    
                    local RoleUI = Instance.new("TextLabel", BB)
                    RoleUI.Size = UDim2.new(1, 0, 0.5, 0)
                    RoleUI.Position = UDim2.new(0, 0, 0.5, 0)
                    RoleUI.BackgroundTransparency = 1
                    RoleUI.Font = Enum.Font.GothamBold
                    RoleUI.TextSize = 14
                    RoleUI.TextStrokeTransparency = 0
                    
                    State.ESPCache[plr] = {
                        Highlight = Highlight,
                        NameUI = NameUI,
                        RoleUI = RoleUI
                    }
                end
                
                -- 更新渲染数据
                local cache = State.ESPCache[plr]
                cache.Highlight.FillColor = roleColor
                cache.Highlight.OutlineColor = roleColor
                cache.NameUI.Text = string.format("%s [%dm]", plr.Name, distance)
                cache.NameUI.TextColor3 = CONFIG.ESP.NameColor
                cache.RoleUI.Text = roleText
                cache.RoleUI.TextColor3 = roleColor
            end
        end
    end
end

-- ==========================================
-- 模块 7：垃圾回收与防内存泄漏
-- ==========================================
local function CleanupEngine()
    for plr, uiElements in pairs(State.ESPCache) do
        if not plr.Parent or not plr.Character or not IsCharacterAlive(plr.Character) then
            if uiElements.Highlight then uiElements.Highlight:Destroy() end
            if uiElements.NameUI then uiElements.NameUI.Parent:Destroy() end
            State.ESPCache[plr] = nil
        end
    end
end

-- ==========================================
-- 模块 8：主控渲染循环
-- ==========================================
Services.RunService.RenderStepped:Connect(function()
    -- 检查本地玩家状态
    local myChar = LocalPlayer.Character
    if not myChar or not IsCharacterAlive(myChar) then 
        CleanupEngine()
        return 
    end

    -- 依次执行各模块
    ProcessPhysics(myChar)
    ProcessAimbot(myChar)
    ProcessVisuals()
end)
