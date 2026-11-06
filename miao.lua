--源码由司空提供，盗卖4000+
--加入群聊获取更多源码
--神秘数字 1108203505
local UI_URL = "https://sikon.226618.xyz/moon lua UI源码.lua"

local ok, Library = pcall(function()
    return loadstring(game:HttpGet(UI_URL))()
end)

if not ok or type(Library) ~= "table" then
    warn("[索尼脚本] UI 库加载失败: " .. tostring(Library))
    return
end
print("[索尼脚本] 库版本:", Library.Version)

local Window = Library:CreateWindow({
    Name              = "索尼脚本",
    Title             = "索尼脚本",
    Version           = "v1.0",
    Theme             = "Nord",
    Backdrop          = true,
    ShowBackdrop      = true,
    GradientAnimation = true,
    ConfigFolder      = "索尼脚本",
    SearchTab         = true,
    Visible           = true,
})

-- 唯一的页签：配置
local TabConfig = Window:CreateTab("配置")

-- 配置页里的“外观”分组
local PageStyle = TabConfig:CreateModule("外观", "palette", {})

for _, themeName in ipairs({ "Nord", "Rainbow", "Gothic", "Purple", "Creida", "Cherry", "Winter" }) do
    PageStyle:CreateButton("切换到 " .. themeName, function()
        Window:SetTheme(themeName)
        Window:Notify({ Title = "主题", Content = themeName, Duration = 2 })
    end)
end

PageStyle:CreateButton("自定义配色", function()
    Window:SetCustomTheme(Color3.fromRGB(140, 90, 255), Color3.fromRGB(255, 110, 200))
end)

local grad = PageStyle:CreateToggle("渐变流动", true, function(value)
    Window:SetGradientAnimation(value)
end)

PageStyle:CreateButton("隐藏窗口", function() Window:Hide() end)
PageStyle:CreateButton("显示窗口", function() Window:Show() end)
PageStyle:CreateButton("开关切换", function() Window:Toggle() end)

-- 配置页里的“系统”分组
local PageSys = TabConfig:CreateModule("系统", "wrench", {})

PageSys:CreateButton("保存配置", function()
    local okk, err = pcall(function() Window:SaveConfig("我的配置") end)
    Window:Notify({
        Title    = okk and "已保存" or "保存失败",
        Content  = okk and "我的配置" or tostring(err),
        Duration = 3,
    })
end)

PageSys:CreateButton("读取配置", function()
    local okk, err = pcall(function() Window:LoadConfig("我的配置") end)
    if okk then
        Window:Notify({ Title = "已读取", Content = "我的配置", Duration = 3 })
    else
        Window:Notify({ Title = "读取失败", Content = tostring(err), Duration = 3 })
    end
end)

PageSys:CreateButton("删除配置", function()
    local okk, err = pcall(function() Window:DeleteConfig("我的配置") end)
    Window:Notify({
        Title    = okk and "已删除" or "删除失败",
        Content  = okk and "我的配置" or tostring(err),
        Duration = 3,
    })
end)

PageSys:CreateButton("全部恢复默认", function()
    grad:Set(true)
    Window:SetTheme("Nord")
    Window:SetGradientAnimation(true)
    Window:Notify({ Title = "重置", Content = "已恢复默认", Duration = 3 })
end)

PageSys:CreateButton("库级通知", function()
    Library:Notify("来自 索尼脚本", "这条不经过窗口", 4)
end)

PageSys:CreateButton("打印自适应字号", function()
    print("[索尼脚本] 字号:", Library.GetFontSize(14, 1))
end)

PageSys:CreateToggle("折叠外观分组", false, function(value)
    pcall(function() PageStyle:SetExpanded(not value) end)
end)

Window:Notify({
    Title    = "索尼脚本 已加载",
    Content  = "配置页内含 外观 / 系统 两个分组",
    Duration = 5,
})
