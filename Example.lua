local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "NhanHub UI    ",
    SubTitle = "by Nhan",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Thông báo",
        Content = "NhanHub đã hoạt động!",
        Duration = 5
    })
end
-- Config và Settings
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("NhanHub")
SaveManager:SetFolder("NhanHub/Config")

SaveManager:BuildConfigSection(Tabs.Settings)

-- Tab Teleport



-- Tab Farm
local AutoFarmGroup = Tabs.Main:AddSection("Auto Farm")
local autofarmThread -- Biến lưu luồng farm để dừng khi cần

Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "Auto Click (Fast Click)",
    Default = false
}):OnChanged(function(Value)
    _G.auto = Value
    if Value then
        print("Auto Click Started")

        autofarmThread = task.spawn(function()
            while _G.auto do
                pcall(function()
                    local rs = game:GetService("ReplicatedStorage")
                    local remote = rs:WaitForChild("Packages"):WaitForChild("Knit")
                        :WaitForChild("Services"):WaitForChild("ClickService")
                        :WaitForChild("RF"):WaitForChild("Click")
                    remote:InvokeServer()
                end)
                task.wait(0.1)
            end
        end)

    else
        print("Auto Farm Stopped")
    end
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "NhanHub",
    Content = "The script has been loaded.",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
