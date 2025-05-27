--==================================================
--                Van Hub (Steve One Piece)
--==================================================

--// Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local player = players.LocalPlayer

--// Tạo Giao Diện Chính
local Window = Fluent:CreateWindow({
    Title = "Van Hub   ",
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
    Misc = Window:AddTab({ Title = "Misc"}),
    Settings = Window:AddTab({ Title = "Settings" })
}

-----------------------------------------------------
--               CHỐNG KICK RA GAME
-----------------------------------------------------

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if getnamecallmethod() == "Kick" and self == player then
        warn("[Anti-Kick] Đã chặn kick")
        return
    end
    return oldNamecall(self, ...)
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
--                  HỆ THỐNG AUTO ATTACK
-----------------------------------------------------
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local SelectedPlayerName = nil

-- Hàm lấy danh sách tên người chơi
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    return names
end

-- Dropdown chọn người chơi
local playerDropdown = Tabs.Teleport:AddDropdown("PlayerTweenDropdown", {
    Title = "Chọn người chơi",
    Values = GetPlayerNames(),
    Default = 1
})


playerDropdown:OnChanged(function(value)
    SelectedPlayerName = value
end)

-- Cập nhật danh sách khi có người chơi mới tham gia hoặc rời đi
Players.PlayerAdded:Connect(function()
    playerDropdown:SetValues(GetPlayerNames())
end)

Players.PlayerRemoving:Connect(function()
    playerDropdown:SetValues(GetPlayerNames())
end)

Tabs.Teleport:AddButton({
    Title = "Tween đến người chơi đã chọn",
    Callback = function()
        local target = Players:FindFirstChild(SelectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = target.Character.HumanoidRootPart.Position
                local tween = TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                    CFrame = CFrame.new(pos + Vector3.new(0, 3, -5))
                })
                tween:Play()
                Fluent:Notify({
                    Title = "Tween thành công",
                    Content = "Đã di chuyển đến " .. SelectedPlayerName,
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Lỗi",
                Content = "Không tìm thấy người chơi hoặc chưa tải xong.",
                Duration = 3
            })
        end
    end
})

-----------------------------------------------------
--                  HỆ THỐNG TELEPORT
-----------------------------------------------------

local TeleportOrder = {
    "Starter Island",
    "Buggy Island",
    "Noob Island",
    "Marine Island",
    "Along Island",
    "Luffy Island",
    "Fruit Seller Island",
    "Sanji Island",
    "Usoap Island",
    "Coconut Island"
}

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

local SelectedLocation = TeleportOrder[1]

Tabs.Teleport:AddDropdown("TeleportDropdown", {
    Title = "Choose Islands",
    Values = TeleportOrder,
    Default = 1
}):OnChanged(function(value)
    SelectedLocation = value
end)

local function TweenTo(position)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local tween = TweenService:Create(hrp, TweenInfo.new(3, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position + Vector3.new(0, 3, 0))})
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
--                 FAST MODE
-----------------------------------------------------

Tabs.Settings:AddButton({
    Title = "Fast Mode (Reduce Lag)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v:Destroy()
    end
end

        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 1e10
        lighting.Brightness = 0.5
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)

        -- Xoá Sky (bầu trời)
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("Sky") then
                v:Destroy()
            end
        end

        local terrain = workspace.Terrain
        terrain.WaterTransparency = 1
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterColor = Color3.fromRGB(0, 0, 0)


        -- Giảm chất lượng đồ họa
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
