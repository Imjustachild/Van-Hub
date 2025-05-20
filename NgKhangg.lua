local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Van Hub  (Steve One Piece)",
    SubTitle = "by NgKhangg",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "" })
}

local Options = Fluent.Options

-- Anti-Kick Hook
local oldKick
oldKick = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if tostring(method) == "Kick" and self == game.Players.LocalPlayer then
        warn("[Anti-Kick] Blocked kick attempt.")
        return -- Bỏ qua kick
    end
    return oldKick(self, ...)
end)

local TweenService = game:GetService("TweenService")

-- Auto Farm Setup
local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
})

local function GetLuffyMob()
    for _, mob in pairs(workspace.Npcs:GetChildren()) do
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
        while AutoFarmToggle.Value
            and mob
            and mob:FindFirstChild("HumanoidRootPart")
            and mob:FindFirstChild("Humanoid")
            and mob.Humanoid.Health > 0 do

            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)
            end
            task.wait()
        end
    end)
end

local function HoldAttack(tool)
    task.spawn(function()
        while AutoFarmToggle.Value and tool and tool.Parent == game.Players.LocalPlayer.Character do
    tool:Activate()
    task.wait(0.3) -- thay vì spam mỗi frame
        end
    end)
end

AutoFarmToggle:OnChanged(function()
    if AutoFarmToggle.Value then
        task.spawn(function()
            while AutoFarmToggle.Value and not Fluent.Unloaded do
                local mob = GetLuffyMob()
                if mob then
                    ForceBringMob(mob)
                    task.wait(0.2)
                    local char = game.Players.LocalPlayer.Character
                    local tool = char and (char:FindFirstChild("Gryphon") or char:FindFirstChildOfClass("Tool"))
                    if tool then
                        HoldAttack(tool)
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

-- Teleport Setup
local function GetKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

local TeleportLocations = {
    ["Starter Island"] = Vector3.new(322.350098, -0.564548492, 310.374451),
    ["Buggy Island"] = Vector3.new(-4513.21973, 44.978241, 1245.51892),
    ["Noob Island"] = Vector3.new(2973.29297, 1.64065552, 1589.4353),
    ["Marine Island"] = Vector3.new(3328.55371, 162.169952, 6303.39551),
    ["Along Island"] = Vector3.new(-5406.54736, 33.9853745, -4748.22363),
    ["Luffy Island"] = Vector3.new(-2284.22998, 105.540787, -3939.89941),
    ["Sanji Island"] = Vector3.new(-1304.70532, 7.10070372, 4964.49023),
    ["Fruit Seller Island"] = Vector3.new(2233.50391, 34.3625221, -3278.6665),
    ["Usoap Island"] = Vector3.new(-4528.54346, 101.832092, 4035.17041),
    ["Coconut Island"] = Vector3.new(-4679.20654, 108.822418, -2082.8374)
}

local SelectedLocation = "Starter Island"

local Dropdown = Tabs.Teleport:AddDropdown("TeleportDropdown", {
    Title = "Choose Islands",
    Values = GetKeys(TeleportLocations),
    Default = 1
})

Dropdown:OnChanged(function(Value)
    SelectedLocation = Value
    print("Bạn đã chọn:", SelectedLocation)
end)

local function TweenTo(position)
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(2, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position + Vector3.new(0, 3, 0))} -- bay lên 3 đơn vị
    )
    tween:Play()
end

Tabs.Teleport:AddButton({
    Title = "Teleport",
    Callback = function()
        local destination = TeleportLocations[SelectedLocation]
        if destination then
            TweenTo(destination)
            print("Teleported to:", SelectedLocation)
        else
            warn("Invalid location!")
        end
    end
})

local isFastMode = false

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
            Content = "Lag Reduction",
            Duration = 4
        })
    end
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "Van Hub",
    Content = "The script has been loaded.",
    Duration = 5
})
