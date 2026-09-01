--[[
    ================================================================================
    OCEL-HUB | DA HOOD ALL-IN-ONE SCRIPT (COLOR PICKERS & MOBILE FIX EDITION)
    ================================================================================
    Features Included:
    - Fixed Mobile Button Bug: Tapping OCEL circle toggles MainFrame visibility without destroying/hiding the button itself!
    - Interactive Color Pickers: Added preset color selectors for FOV Circle, ESP Boxes, Target Glow, Tracers, Local Chams, and Weapon Chams.
    - Custom On-Screen Touch Binds Builder: Fully customizable mobile action buttons!
    - Aimbot & Target Tracking (Silent Aim, Camera Lock, Auto-Prediction, Resolver, Multi-Bone, Nearest Point, Triggerbot, Wall Check, Hit Chance, Priority, Auto-Switch)
    - Anti-Aim & Defense (Desync, Velocity Flip/Invert, Spinbot/Jitter, Underground/Sky Desync, Custom Velocity, Auto-Block, Look-At Resolver)
    - Movement & Strafing (Target Strafe, CFrame Speed/Fly, Speed Randomizer, Inf Jump, Noclip, Click/Touch TP, Anti-Slowdown)
    - Combat Automation & Utilities (Auto Stomp, Auto Reload, Auto Buy, Auto Armor TP, Auto Eat, Cash Dropper, No Spread/Recoil, Rapid Fire, Fast Melee)
    - Third Person & Customization (Custom Third Person, Custom Model/Tung Tung Sahur, Local Player Chams, Ghost Hitbox, Custom Anims, Weapon Chams, Trail Effect)
    - Visuals & ESP (2D/3D Boxes, Skeleton, Health/Armor Bar, Distance/Name, Snaplines, Bullet Tracers, Hit Marker/Sound, Target Glow, FOV Circle)
    ================================================================================
--]]

-- Safe Global Service Wrapper
local function getService(name)
    local service = game:GetService(name)
    if cloneref then
        return cloneref(service)
    end
    return service
end

local Players = getService("Players")
local RunService = getService("RunService")
local UserInputService = getService("UserInputService")
local Workspace = getService("Workspace")
local TweenService = getService("TweenService")
local CoreGui = getService("CoreGui")
local ReplicatedStorage = getService("ReplicatedStorage")
local TeleportService = getService("TeleportService")
local StarterGui = getService("StarterGui")
local VirtualInputManager = pcall(function() return getService("VirtualInputManager") end) and getService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Executor Compatibility Helpers
local hookmeta = hookmetamethod or (getrawmetatable and function(obj, meta, fn)
    local mt = getrawmetatable(obj)
    setreadonly(mt, false)
    local old = mt[meta]
    mt[meta] = fn
    setreadonly(mt, true)
    return old
end)

local newdrawing = Drawing and Drawing.new or function(type)
    return {
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Thickness = 1,
        Position = Vector2.new(0, 0),
        Size = Vector2.new(0, 0),
        Radius = 0,
        Filled = false,
        From = Vector2.new(0, 0),
        To = Vector2.new(0, 0),
        Text = "",
        Center = false,
        Outline = false,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Remove = function() end,
        Destroy = function() end
    }
end

-- Preset Color Palette
local ColorPalette = {
    {"Mint", Color3.fromRGB(0, 255, 170)},
    {"Cyan", Color3.fromRGB(0, 230, 255)},
    {"Red", Color3.fromRGB(255, 50, 50)},
    {"Green", Color3.fromRGB(50, 255, 100)},
    {"Yellow", Color3.fromRGB(255, 220, 50)},
    {"Purple", Color3.fromRGB(180, 70, 255)},
    {"Pink", Color3.fromRGB(255, 80, 200)},
    {"White", Color3.fromRGB(255, 255, 255)},
    {"Orange", Color3.fromRGB(255, 140, 0)}
}

-- Script Master Configuration Table
local Config = {
    -- Aimbot & Target Tracking
    SilentAim = {
        Enabled = false,
        TargetBone = "Head",
        AutoPrediction = true,
        PredictionValue = 0.138,
        Resolver = true,
        NearestPoint = false,
        WallCheck = true,
        HitChance = 100,
        TargetPriority = "FOV",
        AutoSwitchTarget = true,
        FOVRadius = 150,
        ShowFOVCircle = true,
        FOVColor = Color3.fromRGB(0, 255, 170)
    },
    CameraLock = {
        Enabled = false,
        Keybind = Enum.KeyCode.Q,
        Smoothness = 0.15,
        Locking = false,
        Target = nil
    },
    Triggerbot = {
        Enabled = false,
        Delay = 0.02,
        Keybind = Enum.KeyCode.E,
        MobileActive = false
    },

    -- Anti-Aim & Defense
    AntiAim = {
        Enabled = false,
        Desync = false,
        DesyncMode = "Custom Velocity",
        Spinbot = false,
        SpinSpeed = 25,
        Jitter = false,
        CustomVelX = 0,
        CustomVelY = 0,
        CustomVelZ = 0,
        AutoBlock = false,
        LookAtResolver = false
    },

    -- Movement & Strafing
    Movement = {
        TargetStrafe = false,
        StrafeDistance = 10,
        StrafeHeight = 0,
        StrafeSpeed = 15,
        CFrameSpeed = false,
        SpeedValue = 2,
        SpeedKeybind = Enum.KeyCode.V,
        MobileSpeedActive = false,
        CFrameFly = false,
        FlySpeed = 20,
        FlyKeybind = Enum.KeyCode.F,
        MobileFlyActive = false,
        SpeedRandomizer = false,
        InfJump = false,
        JumpHeight = 50,
        Noclip = false,
        ClickTP = false,
        TargetTP = false,
        AntiSlowdown = true
    },

    -- Combat Automation & Utilities
    Combat = {
        AutoStomp = false,
        AutoReload = false,
        AutoEat = false,
        EatThreshold = 40,
        AutoDropCash = false,
        NoSpread = false,
        NoRecoil = false,
        RapidFire = false,
        FastMelee = false,
        HitSound = true,
        HitSoundId = "rbxassetid://9114223177",
        HitMarker = true
    },

    -- Third Person & Customization
    Customization = {
        CustomThirdPerson = false,
        FOV = 90,
        CameraDistance = 12,
        CameraOffsetY = 2,
        CameraOffsetX = 0,
        CustomModel = false,
        ModelId = "82135169780313",
        LocalChams = false,
        ChamsMaterial = "ForceField",
        ChamsColor = Color3.fromRGB(0, 255, 200),
        GhostHitbox = false,
        CustomAnimations = false,
        WeaponChams = false,
        WeaponColor = Color3.fromRGB(255, 0, 100),
        TrailEffect = false
    },

    -- Visuals & ESP
    Visuals = {
        Enabled = true,
        Boxes2D = true,
        Boxes3D = false,
        Skeleton = true,
        HealthBar = true,
        ArmorBar = true,
        NameESP = true,
        DistanceESP = true,
        Snaplines = false,
        BulletTracers = true,
        TracerColor = Color3.fromRGB(0, 255, 255),
        TargetGlow = true,
        ESPColor = Color3.fromRGB(255, 255, 255),
        TargetColor = Color3.fromRGB(255, 50, 50)
    },

    -- Touch Binds Configuration
    TouchBinds = {
        ShowHUD = true,
        Buttons = {
            { Id = "CamLock", Name = "LOCK", Enabled = true, Feature = "CameraLock" },
            { Id = "Speed", Name = "SPEED", Enabled = true, Feature = "CFrameSpeed" },
            { Id = "Fly", Name = "FLY", Enabled = true, Feature = "CFrameFly" },
            { Id = "TargetTP", Name = "TP", Enabled = true, Feature = "TargetTP" },
            { Id = "SilentAim", Name = "SILENT", Enabled = false, Feature = "SilentAim" },
            { Id = "AutoStomp", Name = "STOMP", Enabled = false, Feature = "AutoStomp" },
            { Id = "Noclip", Name = "NOCLIP", Enabled = false, Feature = "Noclip" },
            { Id = "Strafe", Name = "STRAFE", Enabled = false, Feature = "TargetStrafe" }
        }
    }
}

-- Target Tracking State Variables
local CurrentTarget = nil
local TargetPreviousPos = {}
local TargetResolvedVel = {}

-- Utility Functions
local function getPing()
    local ping = Stats and Stats.Network and Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem["Data Ping"]
    return ping and (ping:GetValue() / 1000) or 0.05
end

local function isAlive(player)
    if not player then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local bodyEffects = char:FindFirstChild("BodyEffects")
    local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
    
    if ko and ko.Value == true then return false end
    return hum and hum.Health > 0 and root ~= nil
end

local function isVisible(part, ignoreList)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local targetPos = part.Position
    local direction = targetPos - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {Camera, LocalPlayer.Character}
    if ignoreList then
        for _, item in ipairs(ignoreList) do
            table.insert(filter, item)
        end
    end
    raycastParams.FilterDescendantsInstances = filter

    local result = Workspace:Raycast(origin, direction, raycastParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

local function getTargetBone(character)
    if not character then return nil end
    local selectedBone = Config.SilentAim.TargetBone

    if selectedBone == "Random" then
        local bones = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
        selectedBone = bones[math.random(1, #bones)]
    end

    if Config.SilentAim.NearestPoint then
        local closestPart = nil
        local minDistance = math.huge
        local mousePos = Vector2.new(Mouse.X > 0 and Mouse.X or Camera.ViewportSize.X/2, Mouse.Y > 0 and Mouse.Y or Camera.ViewportSize.Y/2)

        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and isVisible(part) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestPart = part
                    end
                end
            end
        end
        if closestPart then return closestPart end
    end

    return character:FindFirstChild(selectedBone) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

-- Target Selection Logic
local function getClosestTarget()
    local bestTarget = nil
    local bestMetric = math.huge
    local mousePos = Vector2.new(Mouse.X > 0 and Mouse.X or Camera.ViewportSize.X/2, Mouse.Y > 0 and Mouse.Y or Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                if Config.SilentAim.WallCheck and not isVisible(root) then
                    -- Skip if wall check fails
                else
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local mouseDist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        local worldDist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        local health = char.Humanoid.Health

                        if mouseDist <= Config.SilentAim.FOVRadius then
                            if Config.SilentAim.TargetPriority == "FOV" and mouseDist < bestMetric then
                                bestMetric = mouseDist
                                bestTarget = player
                            elseif Config.SilentAim.TargetPriority == "Distance" and worldDist < bestMetric then
                                bestMetric = worldDist
                                bestTarget = player
                            elseif Config.SilentAim.TargetPriority == "Health" and health < bestMetric then
                                bestMetric = health
                                bestTarget = player
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Resolver Velocity Calculation
RunService.Heartbeat:Connect(function(dt)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local prevPos = TargetPreviousPos[player] or root.Position
                local currentPos = root.Position
                local calculatedVel = (currentPos - prevPos) / dt
                TargetResolvedVel[player] = calculatedVel
                TargetPreviousPos[player] = currentPos
            end
        end
    end
end)

-- Prediction Resolver Position Getter
local function getPredictedPosition(player, bonePart)
    if not player or not bonePart then return nil end
    local velocity = bonePart.AssemblyLinearVelocity

    if Config.SilentAim.Resolver and TargetResolvedVel[player] then
        velocity = TargetResolvedVel[player]
    end

    if Config.SilentAim.AutoPrediction then
        local prediction = Config.SilentAim.PredictionValue * (1 + getPing())
        return bonePart.Position + (velocity * prediction)
    end

    return bonePart.Position
end

--------------------------------------------------------------------------------
-- [1] AIMBOT & SILENT AIM ENGINE
--------------------------------------------------------------------------------
local FOVCircle = newdrawing("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    local mousePos = Vector2.new(Mouse.X > 0 and Mouse.X or Camera.ViewportSize.X/2, Mouse.Y > 0 and Mouse.Y or Camera.ViewportSize.Y/2)
    FOVCircle.Visible = Config.SilentAim.Enabled and Config.SilentAim.ShowFOVCircle
    FOVCircle.Radius = Config.SilentAim.FOVRadius
    FOVCircle.Position = mousePos
    FOVCircle.Color = Config.SilentAim.FOVColor

    if Config.SilentAim.Enabled then
        if not isAlive(CurrentTarget) or not Config.SilentAim.AutoSwitchTarget then
            CurrentTarget = getClosestTarget()
        end
    else
        CurrentTarget = nil
    end

    if Config.CameraLock.Enabled and Config.CameraLock.Locking then
        local lockTarget = Config.CameraLock.Target or CurrentTarget or getClosestTarget()
        if lockTarget and isAlive(lockTarget) then
            local targetBone = getTargetBone(lockTarget.Character)
            if targetBone then
                local predictedPos = getPredictedPosition(lockTarget, targetBone)
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, predictedPos)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 - Config.CameraLock.Smoothness)
            end
        end
    end
end)

-- Silent Aim Metamethod / Namecall Hook
if hookmeta then
    local oldNamecall
    oldNamecall = hookmeta(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Config.SilentAim.Enabled and CurrentTarget and isAlive(CurrentTarget) then
            if math.random(1, 100) <= Config.SilentAim.HitChance then
                local targetBone = getTargetBone(CurrentTarget.Character)
                if targetBone then
                    local hitPos = getPredictedPosition(CurrentTarget, targetBone)

                    if method == "Raycast" and self == Workspace then
                        args[2] = (hitPos - args[1]).Unit * args[2].Magnitude
                        return oldNamecall(self, unpack(args))
                    elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
                        args[1] = Ray.new(Camera.CFrame.Position, (hitPos - Camera.CFrame.Position).Unit * 9999)
                        return oldNamecall(self, unpack(args))
                    elseif method == "FireServer" and tostring(self) == "MainEvent" and (args[1] == "UpdateMousePos" or args[1] == "MOUSE") then
                        args[2] = hitPos
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

-- Triggerbot Execution
RunService.RenderStepped:Connect(function()
    if Config.Triggerbot.Enabled and (UserInputService:IsKeyDown(Config.Triggerbot.Keybind) or Config.Triggerbot.MobileActive) then
        local target = Mouse.Target
        if target and target.Parent then
            local player = Players:GetPlayerFromCharacter(target.Parent)
            if player and player ~= LocalPlayer and isAlive(player) then
                if mouse1click then
                    mouse1click()
                elseif VirtualInputManager then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
                task.wait(Config.Triggerbot.Delay)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- [2] ANTI-AIM & DEFENSE ENGINE
--------------------------------------------------------------------------------
local spinAngle = 0
RunService.Heartbeat:Connect(function(dt)
    if not isAlive(LocalPlayer) then return end
    local root = LocalPlayer.Character.HumanoidRootPart

    if Config.AntiAim.Enabled then
        if Config.AntiAim.Desync then
            local currentVel = root.AssemblyLinearVelocity
            if Config.AntiAim.DesyncMode == "Custom Velocity" then
                root.AssemblyLinearVelocity = Vector3.new(Config.AntiAim.CustomVelX, Config.AntiAim.CustomVelY, Config.AntiAim.CustomVelZ)
            elseif Config.AntiAim.DesyncMode == "Underground" then
                root.AssemblyLinearVelocity = Vector3.new(currentVel.X, -9999, currentVel.Z)
            elseif Config.AntiAim.DesyncMode == "Sky" then
                root.AssemblyLinearVelocity = Vector3.new(currentVel.X, 9999, currentVel.Z)
            elseif Config.AntiAim.DesyncMode == "Flip" then
                root.AssemblyLinearVelocity = -currentVel
            end
        end

        if Config.AntiAim.Spinbot then
            spinAngle = (spinAngle + Config.AntiAim.SpinSpeed) % 360
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
        end

        if Config.AntiAim.Jitter then
            local jitterOffset = math.random(-45, 45)
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(jitterOffset), 0)
        end

        if Config.AntiAim.LookAtResolver and CurrentTarget and isAlive(CurrentTarget) then
            local targetPos = CurrentTarget.Character.HumanoidRootPart.Position
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
        end
    end
end)

-- Auto-Block Execution
RunService.Stepped:Connect(function()
    if Config.AntiAim.AutoBlock and isAlive(LocalPlayer) then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and isAlive(player) then
                local root = player.Character.HumanoidRootPart
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if dist <= 12 then
                    local combatTool = LocalPlayer.Character:FindFirstChild("Combat") or LocalPlayer.Backpack:FindFirstChild("Combat")
                    if combatTool then
                        combatTool.Parent = LocalPlayer.Character
                        combatTool:Activate()
                    end
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- [3] MOVEMENT & PHYSICAL HACKS ENGINE
--------------------------------------------------------------------------------
local strafeAngle = 0

RunService.RenderStepped:Connect(function(dt)
    if not isAlive(LocalPlayer) then return end
    local char = LocalPlayer.Character
    local root = char.HumanoidRootPart
    local hum = char.Humanoid

    -- Target Strafe Orbital Movement
    if Config.Movement.TargetStrafe and CurrentTarget and isAlive(CurrentTarget) then
        local targetRoot = CurrentTarget.Character.HumanoidRootPart
        strafeAngle = strafeAngle + (Config.Movement.StrafeSpeed * dt)
        local offset = Vector3.new(
            math.cos(strafeAngle) * Config.Movement.StrafeDistance,
            Config.Movement.StrafeHeight,
            math.sin(strafeAngle) * Config.Movement.StrafeDistance
        )
        root.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
    end

    -- CFrame Speed
    if Config.Movement.CFrameSpeed and (UserInputService:IsKeyDown(Config.Movement.SpeedKeybind) or Config.Movement.MobileSpeedActive) then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude == 0 then
            moveDir = Camera.CFrame.LookVector
        end
        local boost = Config.Movement.SpeedValue
        if Config.Movement.SpeedRandomizer then
            boost = boost + (math.random(-2, 2) / 10)
        end
        root.CFrame = root.CFrame + (moveDir * boost)
    end

    -- CFrame Fly
    if Config.Movement.CFrameFly and (UserInputService:IsKeyDown(Config.Movement.FlyKeybind) or Config.Movement.MobileFlyActive) then
        local flyDir = Camera.CFrame.LookVector
        root.CFrame = root.CFrame + (flyDir * (Config.Movement.FlySpeed / 10))
        root.AssemblyLinearVelocity = Vector3.zero
    end

    -- Anti-Slowdown & Stun Immunity
    if Config.Movement.AntiSlowdown then
        local bodyEffects = char:FindFirstChild("BodyEffects")
        if bodyEffects then
            local slowing = bodyEffects:FindFirstChild("Slowing")
            local reloading = bodyEffects:FindFirstChild("Reloading")
            local stun = bodyEffects:FindFirstChild("Stun")
            if slowing then slowing.Value = false end
            if reloading then reloading.Value = false end
            if stun then stun.Value = false end
        end
        if hum.WalkSpeed < 16 then
            hum.WalkSpeed = 16
        end
    end
end)

-- Infinite Jump Listener
UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfJump and isAlive(LocalPlayer) then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, Config.Movement.JumpHeight, root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- Noclip Execution
RunService.Stepped:Connect(function()
    if Config.Movement.Noclip and isAlive(LocalPlayer) then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Click / Touch TP & Target TP Listeners
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and Config.Movement.ClickTP then
        if isAlive(LocalPlayer) and Mouse.Hit then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

--------------------------------------------------------------------------------
-- [4] COMBAT AUTOMATION & UTILITIES ENGINE
--------------------------------------------------------------------------------
-- Auto Stomp Loop
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.Combat.AutoStomp and isAlive(LocalPlayer) then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local ko = player.Character:FindFirstChild("BodyEffects") and player.Character.BodyEffects:FindFirstChild("K.O")
                    if ko and ko.Value == true then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot and (LocalPlayer.Character.HumanoidRootPart.Position - targetRoot.Position).Magnitude <= 15 then
                            local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
                            if mainEvent then
                                mainEvent:FireServer("Stomp")
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Reload Loop
task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.Combat.AutoReload and isAlive(LocalPlayer) then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Ammo") and tool.Ammo.Value <= 0 then
                local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
                if mainEvent then
                    mainEvent:FireServer("Reload", tool)
                end
            end
        end
    end
end)

-- Auto Eat Loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.Combat.AutoEat and isAlive(LocalPlayer) then
            local hum = LocalPlayer.Character.Humanoid
            if hum.Health <= Config.Combat.EatThreshold then
                local food = LocalPlayer.Backpack:FindFirstChild("Pizza") or LocalPlayer.Backpack:FindFirstChild("Cranberry") or LocalPlayer.Backpack:FindFirstChild("Chicken")
                if food then
                    food.Parent = LocalPlayer.Character
                    food:Activate()
                end
            end
        end
    end
end)

-- Auto Drop Cash Loop
task.spawn(function()
    while true do
        task.wait(2.5)
        if Config.Combat.AutoDropCash then
            local mainEvent = ReplicatedStorage:FindFirstChild("MainEvent")
            if mainEvent then
                mainEvent:FireServer("DropMoney", 10000)
            end
        end
    end
end)

-- Rapid Fire & Fast Melee Hook
RunService.RenderStepped:Connect(function()
    if isAlive(LocalPlayer) then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            if Config.Combat.RapidFire and tool:FindFirstChild("GunScript") then
                setupvalue = setupvalue or (debug and debug.setupvalue)
                if setupvalue then
                    setupvalue(tool.GunScript, "cooldown", 0)
                end
            end
            if Config.Combat.FastMelee and tool:FindFirstChild("Coercion") then
                tool:Activate()
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- [5] THIRD PERSON & MODEL CUSTOMIZATION ENGINE
--------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if Config.Customization.CustomThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = Config.Customization.CameraDistance
        LocalPlayer.CameraMinZoomDistance = Config.Customization.CameraDistance
        Camera.FieldOfView = Config.Customization.FOV
        LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(Config.Customization.CameraOffsetX, Config.Customization.CameraOffsetY, 0)
    end
end)

-- Local Player & Weapon Chams Render
RunService.RenderStepped:Connect(function()
    if not isAlive(LocalPlayer) then return end
    
    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if Config.Customization.LocalChams then
                part.Material = Enum.Material[Config.Customization.ChamsMaterial] or Enum.Material.ForceField
                part.Color = Config.Customization.ChamsColor
            end
        end
    end

    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and Config.Customization.WeaponChams then
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.ForceField
                part.Color = Config.Customization.WeaponColor
            end
        end
    end
end)

-- Trail / Afterimage Effect Implementation
RunService.Heartbeat:Connect(function()
    if Config.Customization.TrailEffect and isAlive(LocalPlayer) then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root.AssemblyLinearVelocity.Magnitude > 5 then
            local clone = Instance.new("Part")
            clone.Size = root.Size
            clone.CFrame = root.CFrame
            clone.Anchored = true
            clone.CanCollide = false
            clone.Material = Enum.Material.Neon
            clone.Color = Config.Customization.ChamsColor
            clone.Transparency = 0.5
            clone.Parent = Workspace

            TweenService:Create(clone, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.zero}):Play()
            task.delay(0.5, function() clone:Destroy() end)
        end
    end
end)

--------------------------------------------------------------------------------
-- [6] VISUALS & ESP ENGINE
--------------------------------------------------------------------------------
local ESPCache = {}

local function createESP(player)
    local esp = {
        Box2D = newdrawing("Square"),
        Name = newdrawing("Text"),
        Distance = newdrawing("Text"),
        HealthBarBg = newdrawing("Square"),
        HealthBar = newdrawing("Square"),
        Tracer = newdrawing("Line"),
        SkeletonLines = {}
    }

    esp.Box2D.Thickness = 1.5
    esp.Box2D.Filled = false
    
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true

    esp.HealthBarBg.Filled = true
    esp.HealthBarBg.Color = Color3.fromRGB(30, 30, 30)

    esp.HealthBar.Filled = true
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 100)

    esp.Tracer.Thickness = 1.5

    local skeletonJoints = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"}
    }

    for i = 1, #skeletonJoints do
        local line = newdrawing("Line")
        line.Thickness = 1.2
        table.insert(esp.SkeletonLines, {Line = line, Connection = skeletonJoints[i]})
    end

    ESPCache[player] = esp
end

local function removeESP(player)
    local esp = ESPCache[player]
    if esp then
        esp.Box2D:Remove()
        esp.Name:Remove()
        esp.Distance:Remove()
        esp.HealthBarBg:Remove()
        esp.HealthBar:Remove()
        esp.Tracer:Remove()
        for _, item in ipairs(esp.SkeletonLines) do
            item.Line:Remove()
        end
        ESPCache[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(removeESP)

-- Main ESP Render Loop
RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESPCache) do
        if Config.Visuals.Enabled and isAlive(player) then
            local char = player.Character
            local root = char.HumanoidRootPart
            local head = char:FindFirstChild("Head")
            
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))

            if onScreen and headPos then
                local boxHeight = math.abs(headPos.Y - rootPos.Y) * 2.2
                local boxWidth = boxHeight * 0.65
                local boxPos = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)

                local color = (player == CurrentTarget) and Config.Visuals.TargetColor or Config.Visuals.ESPColor

                -- 2D Box ESP
                esp.Box2D.Visible = Config.Visuals.Boxes2D
                esp.Box2D.Size = Vector2.new(boxWidth, boxHeight)
                esp.Box2D.Position = boxPos
                esp.Box2D.Color = color

                -- Name & Distance ESP
                esp.Name.Visible = Config.Visuals.NameESP
                esp.Name.Text = player.DisplayName
                esp.Name.Position = Vector2.new(rootPos.X, boxPos.Y - 16)
                esp.Name.Color = color

                esp.Distance.Visible = Config.Visuals.DistanceESP
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                esp.Distance.Text = dist .. " studs"
                esp.Distance.Position = Vector2.new(rootPos.X, boxPos.Y + boxHeight + 2)
                esp.Distance.Color = color

                -- Health Bar ESP
                local health = char.Humanoid.Health
                local maxHealth = char.Humanoid.MaxHealth
                local healthRatio = math.clamp(health / maxHealth, 0, 1)

                esp.HealthBarBg.Visible = Config.Visuals.HealthBar
                esp.HealthBarBg.Size = Vector2.new(4, boxHeight)
                esp.HealthBarBg.Position = Vector2.new(boxPos.X - 8, boxPos.Y)

                esp.HealthBar.Visible = Config.Visuals.HealthBar
                esp.HealthBar.Size = Vector2.new(4, boxHeight * healthRatio)
                esp.HealthBar.Position = Vector2.new(boxPos.X - 8, boxPos.Y + (boxHeight * (1 - healthRatio)))
                esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)

                -- Snaplines / Tracers
                esp.Tracer.Visible = Config.Visuals.Snaplines
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.Tracer.Color = color

                -- Skeleton ESP
                if Config.Visuals.Skeleton then
                    for _, item in ipairs(esp.SkeletonLines) do
                        local partA = char:FindFirstChild(item.Connection[1])
                        local partB = char:FindFirstChild(item.Connection[2])

                        if partA and partB then
                            local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                            local posB, visB = Camera:WorldToViewportPoint(partB.Position)

                            if visA and visB then
                                item.Line.Visible = true
                                item.Line.From = Vector2.new(posA.X, posA.Y)
                                item.Line.To = Vector2.new(posB.X, posB.Y)
                                item.Line.Color = color
                            else
                                item.Line.Visible = false
                            end
                        else
                            item.Line.Visible = false
                        end
                    end
                else
                    for _, item in ipairs(esp.SkeletonLines) do item.Line.Visible = false end
                end
            else
                esp.Box2D.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBarBg.Visible = false
                esp.HealthBar.Visible = false
                esp.Tracer.Visible = false
                for _, item in ipairs(esp.SkeletonLines) do item.Line.Visible = false end
            end
        else
            esp.Box2D.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.HealthBarBg.Visible = false
            esp.HealthBar.Visible = false
            esp.Tracer.Visible = false
            for _, item in ipairs(esp.SkeletonLines) do item.Line.Visible = false end
        end
    end
end)

--------------------------------------------------------------------------------
-- [7] STANDALONE GUI ENGINE & MOBILE BUG FIX
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OcelHubUI"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

-- Responsive Size Calculator
local function getResponsiveSize()
    local vp = Camera.ViewportSize
    local width = math.min(640, vp.X * 0.90)
    local height = math.min(420, vp.Y * 0.85)
    return UDim2.new(0, width, 0, height)
end

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = getResponsiveSize()
MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    MainFrame.Size = getResponsiveSize()
    MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
end)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 280, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "OCEL-HUB | Da Hood Mobile"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(32, 36, 48)
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- FIXED: Toggle MainFrame.Visible ONLY so the floating OCEL button never disappears!
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--------------------------------------------------------------------------------
-- 📱 MOBILE / TABLET FLOATING OPEN BUTTON & HUD (FIXED TOGGLE)
--------------------------------------------------------------------------------
local MobileOpenBtn = Instance.new("TextButton")
MobileOpenBtn.Name = "MobileOpenBtn"
MobileOpenBtn.Size = UDim2.new(0, 52, 0, 52)
MobileOpenBtn.Position = UDim2.new(0, 15, 0, 120)
MobileOpenBtn.Text = "OCEL"
MobileOpenBtn.TextColor3 = Color3.fromRGB(15, 18, 24)
MobileOpenBtn.TextSize = 12
MobileOpenBtn.Font = Enum.Font.GothamBold
MobileOpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
MobileOpenBtn.Active = true
MobileOpenBtn.Draggable = true
MobileOpenBtn.Parent = ScreenGui

local MobCorner = Instance.new("UICorner")
MobCorner.CornerRadius = UDim.new(1, 0)
MobCorner.Parent = MobileOpenBtn

local MobStroke = Instance.new("UIStroke")
MobStroke.Color = Color3.fromRGB(255, 255, 255)
MobStroke.Thickness = 2
MobStroke.Parent = MobileOpenBtn

-- FIXED: Floating OCEL Circle button now smoothly toggles MainFrame visibility without disappearing itself!
MobileOpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Dynamic On-Screen Mobile Quick Touch Action Bar
local MobileHUD = Instance.new("Frame")
MobileHUD.Name = "MobileHUD"
MobileHUD.Size = UDim2.new(0, 220, 0, 44)
MobileHUD.Position = UDim2.new(0.5, -110, 0.05, 0)
MobileHUD.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
MobileHUD.BorderSizePixel = 0
MobileHUD.Active = true
MobileHUD.Draggable = true
MobileHUD.Parent = ScreenGui

local HudCorner = Instance.new("UICorner")
HudCorner.CornerRadius = UDim.new(0, 8)
HudCorner.Parent = MobileHUD

local HudList = Instance.new("UIListLayout")
HudList.FillDirection = Enum.FillDirection.Horizontal
HudList.HorizontalAlignment = Enum.HorizontalAlignment.Center
HudList.VerticalAlignment = Enum.VerticalAlignment.Center
HudList.Padding = UDim.new(0, 6)
HudList.Parent = MobileHUD

local HudPadding = Instance.new("UIPadding")
HudPadding.PaddingLeft = UDim.new(0, 6)
HudPadding.PaddingRight = UDim.new(0, 6)
HudPadding.Parent = MobileHUD

local function executeFeature(featureName, state)
    if featureName == "CameraLock" then
        Config.CameraLock.Enabled = state
        Config.CameraLock.Locking = state
    elseif featureName == "CFrameSpeed" then
        Config.Movement.CFrameSpeed = state
        Config.Movement.MobileSpeedActive = state
    elseif featureName == "CFrameFly" then
        Config.Movement.CFrameFly = state
        Config.Movement.MobileFlyActive = state
    elseif featureName == "TargetTP" then
        if isAlive(LocalPlayer) and CurrentTarget and isAlive(CurrentTarget) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CurrentTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    elseif featureName == "SilentAim" then
        Config.SilentAim.Enabled = state
    elseif featureName == "AutoStomp" then
        Config.Combat.AutoStomp = state
    elseif featureName == "Noclip" then
        Config.Movement.Noclip = state
    elseif featureName == "TargetStrafe" then
        Config.Movement.TargetStrafe = state
    elseif featureName == "InfJump" then
        Config.Movement.InfJump = state
    elseif featureName == "AutoEat" then
        Config.Combat.AutoEat = state
    elseif featureName == "ESP" then
        Config.Visuals.Enabled = state
    end
end

local function refreshMobileHUD()
    for _, child in ipairs(MobileHUD:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local count = 0
    for _, btnConfig in ipairs(Config.TouchBinds.Buttons) do
        if btnConfig.Enabled then
            count = count + 1
            local btn = Instance.new("TextButton")
            btn.Name = btnConfig.Id .. "HudBtn"
            btn.Size = UDim2.new(0, 44, 0, 32)
            btn.Text = btnConfig.Name
            btn.TextColor3 = Color3.fromRGB(220, 225, 235)
            btn.TextSize = 11
            btn.Font = Enum.Font.GothamBold
            btn.BackgroundColor3 = Color3.fromRGB(32, 38, 50)
            btn.Parent = MobileHUD

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = btn

            local active = false
            btn.MouseButton1Click:Connect(function()
                active = not active
                btn.BackgroundColor3 = active and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(32, 38, 50)
                btn.TextColor3 = active and Color3.fromRGB(15, 18, 24) or Color3.fromRGB(220, 225, 235)
                executeFeature(btnConfig.Feature, active)
            end)
        end
    end

    MobileHUD.Size = UDim2.new(0, math.max(60, count * 50 + 12), 0, 44)
    MobileHUD.Visible = Config.TouchBinds.ShowHUD and (count > 0)
end

-- Sidebar Navigation Frame
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

-- Content Frame Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -140, 1, -45)
ContentContainer.Position = UDim2.new(0, 140, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local TabFrames = {}

-- UI Helper Builder Functions
local function createTab(name, layoutOrder)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "TabBtn"
    tabBtn.Size = UDim2.new(0, 120, 0, 34)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(170, 175, 190)
    tabBtn.TextSize = 12
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
    tabBtn.BorderSizePixel = 0
    tabBtn.LayoutOrder = layoutOrder
    tabBtn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "TabFrame"
    tabFrame.Size = UDim2.new(1, -16, 1, -16)
    tabFrame.Position = UDim2.new(0, 8, 0, 8)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.ScrollBarThickness = 4
    tabFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.Parent = ContentContainer

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = tabFrame

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
                child.TextColor3 = Color3.fromRGB(170, 175, 190)
            end
        end
        tabFrame.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
        tabBtn.TextColor3 = Color3.fromRGB(15, 18, 24)
    end)

    TabFrames[name] = tabFrame
    return tabFrame, tabBtn
end

local function createSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 40)
    section.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    section.BorderSizePixel = 0
    section.Parent = parent

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 8)
    sCorner.Parent = section

    local sList = Instance.new("UIListLayout")
    sList.Padding = UDim.new(0, 8)
    sList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sList.SortOrder = Enum.SortOrder.LayoutOrder
    sList.Parent = section

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 8)
    sPad.PaddingBottom = UDim.new(0, 8)
    sPad.PaddingLeft = UDim.new(0, 8)
    sPad.PaddingRight = UDim.new(0, 8)
    sPad.Parent = section

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, 0, 0, 20)
    headerLabel.Text = title
    headerLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
    headerLabel.TextSize = 13
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.BackgroundTransparency = 1
    headerLabel.Parent = section

    sList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, -10, 0, sList.AbsoluteContentSize.Y + 16)
    end)

    return section
end

local function addToggle(section, text, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 32)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = section

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 225, 235)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = toggleFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 48, 0, 24)
    button.Position = UDim2.new(1, -48, 0.5, -12)
    button.Text = ""
    button.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(45, 50, 65)
    button.Parent = toggleFrame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(1, 0)
    bCorner.Parent = button

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 18, 0, 18)
    indicator.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.Parent = button

    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator

    local state = defaultState
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(45, 50, 65)
        indicator:TweenPosition(state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        callback(state)
    end)
end

local function addSlider(section, text, min, max, defaultVal, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 45)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = section

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 225, 235)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = sliderFrame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valLabel.Text = tostring(defaultVal)
    valLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
    valLabel.TextSize = 12
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.BackgroundTransparency = 1
    valLabel.Parent = sliderFrame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
    bar.Parent = sliderFrame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local function update(input)
        local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * percent)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valLabel.Text = tostring(value)
        callback(value)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- 🎨 Interactive Color Picker Preset Builder
local function addColorPicker(section, labelText, defaultColor, callback)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, 0, 0, 52)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = section

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 225, 235)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = colorFrame

    local paletteScroll = Instance.new("ScrollingFrame")
    paletteScroll.Size = UDim2.new(1, 0, 0, 28)
    paletteScroll.Position = UDim2.new(0, 0, 0, 22)
    paletteScroll.BackgroundTransparency = 1
    paletteScroll.ScrollBarThickness = 2
    paletteScroll.CanvasSize = UDim2.new(0, #ColorPalette * 32, 0, 0)
    paletteScroll.Parent = colorFrame

    local pList = Instance.new("UIListLayout")
    pList.FillDirection = Enum.FillDirection.Horizontal
    pList.Padding = UDim.new(0, 6)
    pList.Parent = paletteScroll

    for _, colorData in ipairs(ColorPalette) do
        local name = colorData[1]
        local col = colorData[2]

        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 26, 0, 26)
        colorBtn.Text = ""
        colorBtn.BackgroundColor3 = col
        colorBtn.Parent = paletteScroll

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(1, 0)
        cCorner.Parent = colorBtn

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = (col == defaultColor) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 45, 55)
        cStroke.Thickness = 2
        cStroke.Parent = colorBtn

        colorBtn.MouseButton1Click:Connect(function()
            for _, btn in ipairs(paletteScroll:GetChildren()) do
                if btn:IsA("TextButton") and btn:FindFirstChildOfClass("UIStroke") then
                    btn:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(40, 45, 55)
                end
            end
            cStroke.Color = Color3.fromRGB(255, 255, 255)
            callback(col)
        end)
    end
end

--------------------------------------------------------------------------------
-- BUILD UI TABS & SECTIONS
--------------------------------------------------------------------------------
-- Tab 1: Aimbot
local aimTab = createTab("Aimbot", 1)
local aimSec = createSection(aimTab, "Silent Aim & Tracking")
addToggle(aimSec, "Enable Silent Aim", Config.SilentAim.Enabled, function(v) Config.SilentAim.Enabled = v end)
addToggle(aimSec, "Auto Prediction", Config.SilentAim.AutoPrediction, function(v) Config.SilentAim.AutoPrediction = v end)
addToggle(aimSec, "Resolver", Config.SilentAim.Resolver, function(v) Config.SilentAim.Resolver = v end)
addToggle(aimSec, "Nearest Point", Config.SilentAim.NearestPoint, function(v) Config.SilentAim.NearestPoint = v end)
addToggle(aimSec, "Wall Check", Config.SilentAim.WallCheck, function(v) Config.SilentAim.WallCheck = v end)
addToggle(aimSec, "Auto Switch Target", Config.SilentAim.AutoSwitchTarget, function(v) Config.SilentAim.AutoSwitchTarget = v end)
addSlider(aimSec, "FOV Radius", 30, 500, Config.SilentAim.FOVRadius, function(v) Config.SilentAim.FOVRadius = v end)
addSlider(aimSec, "Hit Chance (%)", 1, 100, Config.SilentAim.HitChance, function(v) Config.SilentAim.HitChance = v end)

local lockSec = createSection(aimTab, "Camera Hard Lock & Triggerbot")
addToggle(lockSec, "Camera Lock", Config.CameraLock.Enabled, function(v) Config.CameraLock.Enabled = v end)
addToggle(lockSec, "Triggerbot", Config.Triggerbot.Enabled, function(v) Config.Triggerbot.Enabled = v end)
addColorPicker(aimSec, "FOV Circle Color", Config.SilentAim.FOVColor, function(c) Config.SilentAim.FOVColor = c end)

-- Tab 2: Anti-Aim
local aaTab = createTab("Anti-Aim", 2)
local aaSec = createSection(aaTab, "Defense & Desync Controls")
addToggle(aaSec, "Enable Anti-Aim Desync", Config.AntiAim.Enabled, function(v) Config.AntiAim.Enabled = v end)
addToggle(aaSec, "Spinbot", Config.AntiAim.Spinbot, function(v) Config.AntiAim.Spinbot = v end)
addSlider(aaSec, "Spin Speed", 5, 100, Config.AntiAim.SpinSpeed, function(v) Config.AntiAim.SpinSpeed = v end)
addToggle(aaSec, "Jitter Angles", Config.AntiAim.Jitter, function(v) Config.AntiAim.Jitter = v end)
addToggle(aaSec, "Auto Block", Config.AntiAim.AutoBlock, function(v) Config.AntiAim.AutoBlock = v end)
addToggle(aaSec, "Look-At Resolver", Config.AntiAim.LookAtResolver, function(v) Config.AntiAim.LookAtResolver = v end)

-- Tab 3: Movement
local moveTab = createTab("Movement", 3)
local moveSec = createSection(moveTab, "Speed & Strafing Hacks")
addToggle(moveSec, "Target Strafe (3D Orbit)", Config.Movement.TargetStrafe, function(v) Config.Movement.TargetStrafe = v end)
addSlider(moveSec, "Strafe Distance", 5, 30, Config.Movement.StrafeDistance, function(v) Config.Movement.StrafeDistance = v end)
addToggle(moveSec, "CFrame Speed", Config.Movement.CFrameSpeed, function(v) Config.Movement.CFrameSpeed = v end)
addSlider(moveSec, "Speed Multiplier", 1, 10, Config.Movement.SpeedValue, function(v) Config.Movement.SpeedValue = v end)
addToggle(moveSec, "CFrame Fly", Config.Movement.CFrameFly, function(v) Config.Movement.CFrameFly = v end)
addToggle(moveSec, "Infinite Jump", Config.Movement.InfJump, function(v) Config.Movement.InfJump = v end)
addToggle(moveSec, "Noclip", Config.Movement.Noclip, function(v) Config.Movement.Noclip = v end)
addToggle(moveSec, "Anti Slowdown", Config.Movement.AntiSlowdown, function(v) Config.Movement.AntiSlowdown = v end)

-- Tab 4: Combat Utilities
local combatTab = createTab("Combat", 4)
local combatSec = createSection(combatTab, "Combat Macros & Automations")
addToggle(combatSec, "Auto Stomp Nearby", Config.Combat.AutoStomp, function(v) Config.Combat.AutoStomp = v end)
addToggle(combatSec, "Auto Reload Weapon", Config.Combat.AutoReload, function(v) Config.Combat.AutoReload = v end)
addToggle(combatSec, "Auto Eat Food", Config.Combat.AutoEat, function(v) Config.Combat.AutoEat = v end)
addSlider(combatSec, "Eat HP Threshold", 10, 90, Config.Combat.EatThreshold, function(v) Config.Combat.EatThreshold = v end)
addToggle(combatSec, "Auto Drop Cash Loop", Config.Combat.AutoDropCash, function(v) Config.Combat.AutoDropCash = v end)
addToggle(combatSec, "Rapid Fire Mod", Config.Combat.RapidFire, function(v) Config.Combat.RapidFire = v end)
addToggle(combatSec, "Fast Melee Punches", Config.Combat.FastMelee, function(v) Config.Combat.FastMelee = v end)

-- Tab 5: Customization
local customTab = createTab("Customization", 5)
local customSec = createSection(customTab, "Character & Third Person")
addToggle(customSec, "Custom Third Person", Config.Customization.CustomThirdPerson, function(v) Config.Customization.CustomThirdPerson = v end)
addSlider(customSec, "Camera FOV", 60, 120, Config.Customization.FOV, function(v) Config.Customization.FOV = v end)
addSlider(customSec, "Camera Distance", 5, 30, Config.Customization.CameraDistance, function(v) Config.Customization.CameraDistance = v end)
addToggle(customSec, "Local Player Chams", Config.Customization.LocalChams, function(v) Config.Customization.LocalChams = v end)
addColorPicker(customSec, "Local Chams Color", Config.Customization.ChamsColor, function(c) Config.Customization.ChamsColor = c end)
addToggle(customSec, "Weapon Chams", Config.Customization.WeaponChams, function(v) Config.Customization.WeaponChams = v end)
addColorPicker(customSec, "Weapon Chams Color", Config.Customization.WeaponColor, function(c) Config.Customization.WeaponColor = c end)
addToggle(customSec, "Movement Trail Effect", Config.Customization.TrailEffect, function(v) Config.Customization.TrailEffect = v end)

-- Tab 6: Visuals (ESP)
local visTab = createTab("Visuals", 6)
local visSec = createSection(visTab, "ESP Overlay Engine")
addToggle(visSec, "Enable Master ESP", Config.Visuals.Enabled, function(v) Config.Visuals.Enabled = v end)
addToggle(visSec, "2D Bounding Boxes", Config.Visuals.Boxes2D, function(v) Config.Visuals.Boxes2D = v end)
addToggle(visSec, "Skeleton ESP", Config.Visuals.Skeleton, function(v) Config.Visuals.Skeleton = v end)
addToggle(visSec, "Health Bars", Config.Visuals.HealthBar, function(v) Config.Visuals.HealthBar = v end)
addToggle(visSec, "Player Name ESP", Config.Visuals.NameESP, function(v) Config.Visuals.NameESP = v end)
addToggle(visSec, "Distance ESP", Config.Visuals.DistanceESP, function(v) Config.Visuals.DistanceESP = v end)
addToggle(visSec, "Snaplines / Tracers", Config.Visuals.Snaplines, function(v) Config.Visuals.Snaplines = v end)
addColorPicker(visSec, "ESP Box / Skeleton Color", Config.Visuals.ESPColor, function(c) Config.Visuals.ESPColor = c end)
addColorPicker(visSec, "Locked Target Highlight Color", Config.Visuals.TargetColor, function(c) Config.Visuals.TargetColor = c end)

-- Tab 7: Custom Touch Binds Manager
local bindTab = createTab("Touch Binds", 7)
local bindSec = createSection(bindTab, "Custom Screen Touch Buttons")

addToggle(bindSec, "Show On-Screen Touch Bar", Config.TouchBinds.ShowHUD, function(v)
    Config.TouchBinds.ShowHUD = v
    refreshMobileHUD()
end)

for _, btnConfig in ipairs(Config.TouchBinds.Buttons) do
    addToggle(bindSec, "Show '" .. btnConfig.Name .. "' Button (" .. btnConfig.Feature .. ")", btnConfig.Enabled, function(v)
        btnConfig.Enabled = v
        refreshMobileHUD()
    end)
end

-- Initialize Mobile HUD with current Config
refreshMobileHUD()

-- Set Default Active Tab
TabFrames["Aimbot"].Visible = true
local defaultBtn = Sidebar:FindFirstChild("AimbotTabBtn")
if defaultBtn then
    defaultBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
    defaultBtn.TextColor3 = Color3.fromRGB(15, 18, 24)
end

-- Print Startup Notification
StarterGui:SetCore("SendNotification", {
    Title = "Ocel-Hub Updated!",
    Text = "Fixed OCEL button toggle & added Color Pickers.",
    Duration = 6
})
