-- 忍者传奇 | 适配 Delta
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local autoSwing = false
local autoSell = false
local autoBuySword = false
local autoBuyBelt = false
local autoBuyRank = false
local autoBuySkill = false
local swingLoop, sellLoop

local function notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "忍者传奇",
        Text = msg,
        Duration = 3
    })
end

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function autoSwingStart()
    if swingLoop then return end
    autoSwing = true
    swingLoop = task.spawn(function()
        while autoSwing do
            local char = getCharacter()
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
                task.wait(0.1)
            else
                task.wait(0.5)
            end
        end
    end)
    notify("自动挥刀已开启")
end

local function autoSwingStop()
    autoSwing = false
    if swingLoop then task.cancel(swingLoop) swingLoop = nil end
    notify("自动挥刀已关闭")
end

local function autoSellStart()
    if sellLoop then return end
    autoSell = true
    sellLoop = task.spawn(function()
        while autoSell do
            local char = getCharacter()
            local sellZone = Workspace:FindFirstChild("SellZone", true)
            if char and sellZone then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local old = root.CFrame
                    root.CFrame = sellZone.CFrame
                    task.wait(0.2)
                    root.CFrame = old
                end
            end
            task.wait(1)
        end
    end)
    notify("自动卖已开启")
end

local function autoSellStop()
    autoSell = false
    if sellLoop then task.cancel(sellLoop) sellLoop = nil end
    notify("自动卖已关闭")
end

local function autoBuyShopStart(flagSetter, shopName, label)
    flagSetter(true)
    notify(label .. "已开启")
    task.spawn(function()
        while flagSetter() do
            local shop = Workspace:FindFirstChild("Shop", true)
            if shop then
                local sub = shop:FindFirstChild(shopName, true)
                if sub then
                    local remote = sub:FindFirstChildWhichIsA("RemoteFunction") or sub:FindFirstChildWhichIsA("RemoteEvent")
                    if remote then
                        pcall(function()
                            if remote:IsA("RemoteFunction") then
                                remote:InvokeServer()
                            else
                                remote:FireServer()
                            end
                        end)
                    end
                end
            end
            task.wait(2)
        end
    end)
endlocal function autoBuySwordStart() autoBuySword = true notify("自动买剑已开启") end
local function autoBuySwordStop() autoBuySword = false notify("自动买剑已关闭") end
local function autoBuyBeltStart() autoBuyBelt = true notify("自动买腰带已开启") end
local function autoBuyBeltStop() autoBuyBelt = false notify("自动买腰带已关闭") end
local function autoBuyRankStart() autoBuyRank = true notify("自动买等级已开启") end
local function autoBuyRankStop() autoBuyRank = false notify("自动买等级已关闭") end
local function autoBuySkillStart() autoBuySkill = true notify("自动买技能已开启") end
local function autoBuySkillStop() autoBuySkill = false notify("自动买技能已关闭") end

local function shopLoop(getFlag, shopName)
    task.spawn(function()
        while getFlag() do
            local shop = Workspace:FindFirstChild("Shop", true)
            if shop then
                local sub = shop:FindFirstChild(shopName, true)
                if sub then
                    local remote = sub:FindFirstChildWhichIsA("RemoteFunction") or sub:FindFirstChildWhichIsA("RemoteEvent")
                    if remote then
                        pcall(function()
                            if remote:IsA("RemoteFunction") then
                                remote:InvokeServer()
                            else
                                remote:FireServer()
                            end
                        end)
                    end
                end
            end
            task.wait(2)
        end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NinjaLegendsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 320)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.BorderSizePixel = 0
Title.Text = "忍者传奇"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local function makeButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = Frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local swingBtn = makeButton("自动挥刀: 关", 50, function()
    if autoSwing then autoSwingStop() swingBtn.Text = "自动挥刀: 关"
    else autoSwingStart() swingBtn.Text = "自动挥刀: 开" end
end)

local sellBtn = makeButton("自动卖: 关", 90, function()
    if autoSell then autoSellStop() sellBtn.Text = "自动卖: 关"
    else autoSellStart() sellBtn.Text = "自动卖: 开" end
end)

local swordBtn = makeButton("自动买剑: 关", 130, function()
    if autoBuySword then
        autoBuySwordStop() swordBtn.Text = "自动买剑: 关"
    else
        autoBuySwordStart() swordBtn.Text = "自动买剑: 开"
        shopLoop(function() return autoBuySword end, "Swords")
    end
end)

local beltBtn = makeButton("自动买腰带: 关", 170, function()
    if autoBuyBelt then
        autoBuyBeltStop() beltBtn.Text = "自动买腰带: 关"
    else
        autoBuyBeltStart() beltBtn.Text = "自动买腰带: 开"
        shopLoop(function() return autoBuyBelt end, "Belts")
    end
end)

local rankBtn = makeButton("自动买等级: 关", 210, function()
    if autoBuyRank then
        autoBuyRankStop() rankBtn.Text = "自动买等级: 关"
    else
        autoBuyRankStart() rankBtn.Text = "自动买等级: 开"
        shopLoop(function() return autoBuyRank end, "Ranks")
    end
end)

local skillBtn = makeButton("自动买技能: 关", 250, function()
    if autoBuySkill then
        autoBuySkillStop() skillBtn.Text = "自动买技能: 关"
    else
        autoBuySkillStart() skillBtn.Text = "自动买技能: 开"
        shopLoop(function() return autoBuySkill end, "Skills")
    end
end)

makeButton("关闭界面", 290, function()
    ScreenGui:Destroy()
end)

notify("忍者传奇脚本已加载")
