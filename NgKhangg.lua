--==================================================
--                Van Hub (Steve One Piece)
--==================================================

--// Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

--// Tạo Giao Diện Chính
local Window = Fluent:CreateWindow({
    Title = "Van Hub  (Steve One Piece)   ",
    SubTitle = "by NgKhangg",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main" }),
    Teleport = Window:AddTab({ Title = "Teleport" }),
    Settings = Window:AddTab({ Title = "Settings" })
}

-----------------------------------------------------
--               CHỐNG KICK RA GAME
-----------------------------------------------------
local oldKick
oldKick = hookmetamethod(game, "__namecall", function(self, ...)
    if getnamecallmethod() == "Kick" and self == player then
        warn("[Anti-Kick] Đã chặn kick")
        return
    end
    return oldKick(self, ...)
end)

-----------------------------------------------------
--              CẤU HÌNH AUTO FARM LUFFY
-----------------------------------------------------
local function GetLuffyMob()
    for _, mob in ipairs(workspace.Npcs:GetChildren()) do
        if mob:IsA("Model") and mob.Name == "Luffy(Lvl:1000)" and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            if mob.Humanoid.Health > 0 then
                return mob
            end
        end
    end
    return nil
end

local function ForceBringMob(mob)
    task.spawn(function()
        while Tabs.Main:GetToggle("AutoFarm").Value and mob and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)
            end
            task.wait()
        end
    end)
end

local function HoldAttack(tool)
    task.spawn(function()
        while Tabs.Main:GetToggle("AutoFarm").Value and tool and tool.Parent == player.Character do
            tool:Activate()
            task.wait(0.3)
        end
    end)
end

-- Toggle
local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
})

AutoFarmToggle:OnChanged(function()
    if AutoFarmToggle.Value then
        task.spawn(function()
            while AutoFarmToggle.Value and not Fluent.Unloaded do
                local mob = GetLuffyMob()
                if mob then
                    ForceBringMob(mob)
                    task.wait(0.2)

                    local char = player.Character
                    local tool = char and (char:FindFirstChild("Gryphon") or char:FindFirstChildOfClass("Tool"))
                    if tool then HoldAttack(tool) end
                end
                task.wait(1)
            end
        end)
    end
end)

-----------------------------------------------------
--                  HỆ THỐNG TELEPORT
-----------------------------------------------------
local TeleportLocations = {
    ["Starter Island"] = Vector3.new(322, 0, 310),
    ["Buggy Island"] = Vector3.new(-4513, 45, 1245),
    ["Noob Island"] = Vector3.new(2973, 1.6, 1589),
    ["Marine Island"] = Vector3.new(3328, 162, 6303),
    ["Along Island"] = Vector3.new(-5406, 33, -4748),
    ["Luffy Island"] = Vector3.new(-2284, 105, -3939),
    ["Sanji Island"] = Vector3.new(-1304, 7, 4964),
    ["Fruit Seller Island"] = Vector3.new(2233, 34, -3278),
    ["Usoap Island"] = Vector3.new(-4528, 101, 4035),
    ["Coconut Island"] = Vector3.new(-4679, 108, -2082)
}

local SelectedLocation = "Starter Island"

Tabs.Teleport:AddDropdown("TeleportDropdown", {
    Title = "Choose Islands",
    Values = (function(tbl) local keys = {} for k in pairs(tbl) do table.insert(keys, k) end return keys end)(TeleportLocations),
    Default = 1
}):OnChanged(function(value)
    SelectedLocation = value
end)

local function TweenTo(position)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local tween = TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position + Vector3.new(0, 3, 0))})
        tween:Play()
    end
end

Tabs.Teleport:AddButton({
    Title = "Teleport",
    Callback = function()
        local pos = TeleportLocations[SelectedLocation]
        if pos then TweenTo(pos) end
    end
})

-----------------------------------------------------
--                 FAST MODE (GIẢM LAG)
-----------------------------------------------------
Tabs.Settings:AddButton({
    Title = "Fast Mode (Reduce Lag)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end

        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        lighting.Brightness = 1
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)

        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        Fluent:Notify({
            Title = "Fast Mode",
            Content = "Lag Reduction Applied!",
            Duration = 4
        })
    end
})

-----------------------------------------------------
--                     LOAD HOÀN TẤT
-----------------------------------------------------
Window:SelectTab(1)
Fluent:Notify({
    Title = "Van Hub",
    Content = "The script has been loaded.",
    Duration = 5
})
