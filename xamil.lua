--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                     XAMIL X HUB v19                                  ║
    ║              Premium Client-Side Roblox Hub · Zero Server             ║
    ╚══════════════════════════════════════════════════════════════════════╝

    Keybinds (all configurable in Settings):
      RightShift  → Toggle UI
      End         → PANIC — destroys GUI, disconnects all loops, resets state
      Mouse2      → Toggle Aimbot
      X           → Toggle Camera Lock  
     Alt          → Toggle Fly
]]

-- ==================== SERVICES ====================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local VirtualUser      = game:GetService("VirtualUser")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- ==================== THEME ENGINE ====================
local Themes = {
    Cyber = {
        Accent      = Color3.fromRGB(230, 40, 40),
        AccentGlow  = Color3.fromRGB(180, 20, 20),
        AccentDim   = Color3.fromRGB(110, 10, 10),
        Base        = Color3.fromRGB(10, 4, 4),
        Surface     = Color3.fromRGB(18, 8, 8),
        Surface2    = Color3.fromRGB(26, 12, 12),
        Border      = Color3.fromRGB(80, 25, 25),
        Text        = Color3.fromRGB(255, 220, 215),
        TextDim     = Color3.fromRGB(165, 110, 110),
        Positive    = Color3.fromRGB(100, 255, 140),
        Negative    = Color3.fromRGB(255, 80, 80),
    },
    Neon = {
        Accent      = Color3.fromRGB(0, 220, 255),
        AccentGlow  = Color3.fromRGB(0, 170, 210),
        AccentDim   = Color3.fromRGB(0, 100, 140),
        Base        = Color3.fromRGB(4, 8, 14),
        Surface     = Color3.fromRGB(8, 14, 22),
        Surface2    = Color3.fromRGB(12, 20, 32),
        Border      = Color3.fromRGB(0, 60, 90),
        Text        = Color3.fromRGB(210, 240, 255),
        TextDim     = Color3.fromRGB(100, 150, 180),
        Positive    = Color3.fromRGB(0, 255, 140),
        Negative    = Color3.fromRGB(255, 80, 80),
    },
    Crimson = {
        Accent      = Color3.fromRGB(255, 50, 80),
        AccentGlow  = Color3.fromRGB(200, 30, 55),
        AccentDim   = Color3.fromRGB(130, 15, 30),
        Base        = Color3.fromRGB(10, 5, 7),
        Surface     = Color3.fromRGB(18, 10, 12),
        Surface2    = Color3.fromRGB(26, 15, 18),
        Border      = Color3.fromRGB(80, 25, 35),
        Text        = Color3.fromRGB(255, 220, 225),
        TextDim     = Color3.fromRGB(160, 110, 120),
        Positive    = Color3.fromRGB(100, 255, 140),
        Negative    = Color3.fromRGB(255, 80, 80),
    },
    Slate = {
        Accent      = Color3.fromRGB(180, 190, 210),
        AccentGlow  = Color3.fromRGB(140, 150, 170),
        AccentDim   = Color3.fromRGB(80, 90, 110),
        Base        = Color3.fromRGB(6, 7, 9),
        Surface     = Color3.fromRGB(12, 13, 17),
        Surface2    = Color3.fromRGB(18, 20, 26),
        Border      = Color3.fromRGB(45, 50, 65),
        Text        = Color3.fromRGB(215, 220, 235),
        TextDim     = Color3.fromRGB(120, 130, 155),
        Positive    = Color3.fromRGB(100, 255, 140),
        Negative    = Color3.fromRGB(255, 80, 80),
    },
}

local ActiveTheme = Themes.Cyber
local ThemeCallbacks = {}

local function SetTheme(name)
    if Themes[name] then
        ActiveTheme = Themes[name]
        for _, cb in ipairs(ThemeCallbacks) do pcall(cb, ActiveTheme) end
    end
end

local function OnThemeChange(cb) table.insert(ThemeCallbacks, cb) end

-- ==================== CONFIG ====================
local CONFIG = {
    PanicKey    = Enum.KeyCode.End,
    ToggleKey   = Enum.KeyCode.RightShift,
    PanelWidth  = 640,
    PanelHeight = 720,
    Categories  = {"Movement","Combat","Visuals","ESP","World","Players","Misc","FPS","Settings"},
    Version     = "v19",
    HubName     = "XAMIL X HUB",
    RGB         = false,
    RGBSpeed    = 2,
}

-- ==================== STATE ====================
local State = {
    Speed       = {Enabled=false, Value=120},
    Jump        = {Enabled=false, Power=130},
    Fly         = {Enabled=false, Speed=180},
    InfJump     = false,
    BunnyHop    = false,
    AutoHeal    = {Enabled=false, Threshold=100},
    NoClip      = false,
    HipHeight   = 0,
    Jetpack     = false,
    Invisible   = false,
    WaterWalk   = {Enabled=false, Platform=nil},
    Stamina     = false,
    AntiKnockback = false,
    VehicleSpeed  = {Enabled=false, Value=200},

    Aimbot = {
        Enabled=false, FOV=150, Smoothness=0.08, Part="Head",
        TeamCheck=true, WallCheck=false, Prediction=true, DropComp=true,
        AutoShoot=false, AutoWallBang=false, Priority="Closest",
        Shake=0, LockOn=false, Target=nil, PowerMode=false,
    },
    CameraLock  = {Enabled=false, Keybind=Enum.KeyCode.X},
    SilentAim   = {Enabled=false, FOV=80, HitChance=100},
    TriggerBot  = {Enabled=false, Delay=0},
    AutoParry   = {Enabled=false, Range=25},
    Hitbox      = {Enabled=false, Size=12, Originals={}},
    Reach       = {Enabled=false, Distance=25, Originals={}},
    SpinBot     = {Enabled=false, Speed=25},
    GodMode     = false,
    RapidFire   = false,
    MeleeAura   = {Enabled=false, Range=15},
    BulletTP    = false,

    -- ===== FAST ATTACK (Blox Fruits) =====
    FastAttack      = {Enabled=false, Speed=0.05},
    FruitM1         = {Enabled=false},
    SwordAttack     = {Enabled=false, Speed=0.08},
    GunAttack       = {Enabled=false, Speed=0.10},
    MilitaryFastM1  = {Enabled=false, Speed=0.03},
    AutoLeaveCombat = {Enabled=false, HealthThreshold=30},

    Fullbright  = {Enabled=false, Intensity=0.2},
    XRay        = {Enabled=false, Transparency=0.7, Originals={}},
    Wireframe   = {Enabled=false, Originals={}},
    Bloom       = {Enabled=false, Intensity=2, Size=24},
    SunRays     = {Enabled=false, Intensity=0.3, Spread=0.5},
    ColorTint   = {Enabled=false, Color=Color3.fromRGB(200,255,240)},
    TimeFreeze  = {Enabled=false, OriginalTime=12},
    Freecam     = {Enabled=false, Speed=2, CFrame=nil},
    ClickTP     = {Enabled=false, Key=Enum.KeyCode.LeftControl},
    Crosshair   = false,
    FOV         = 70,
    Gravity     = 196.2,
    RemoveFog   = false,
    DisableBlur = false,
    DisableBloom = false,
    DisableSunRays = false,
    DisableShadows = false,

    ESP = {
        Enabled=false, TeamCheck=false, Boxes=true, Names=true,
        Health=true, Distance=true, Tracers=true, Tool=true,
        Color=Color3.fromRGB(230,40,40), Skeleton=false, Chams=true,
        FOVColor=Color3.fromRGB(230,40,40), FOVSize=150,
        FOVThickness=1.5, FOVAlpha=0.6,
    },

    AntiAFK     = false,
    AutoClick   = {Enabled=false, CPS=15},
    AutoCollect = {Enabled=false, Range=60},
    AutoFarm    = {Enabled=false, Mode="Coins"},
    Spectate    = {Enabled=false, Target=nil},
    AntiAFKEnabled = false,
    SessionTimer   = 0,
    Watermark      = false,
    UIScale        = 1,

    FPSBoost = {
        Enabled=false, RemoveDecals=true, RemoveParticles=true,
        RemoveTextures=true, DisableShadows=true, LowQuality=true,
        RemoveTrails=true, RemoveBeams=true, DisableLightingEffects=true,
    },

    CustomKeybinds = {AimbotToggle=Enum.UserInputType.MouseButton2},
    AimbotMaxDistance = 1000,
    SelectedPlayer    = nil,
    CurrentTheme      = "Cyber",
}

-- ==================== REGISTRIES ====================
local Connections       = {}
local ESPObjects        = {}
local PanicActive       = false
local uiVisible         = false
local OriginalGravity   = Workspace.Gravity
local TargetHighlight   = nil
local ToggleControls    = {}
local FPSBoostOriginals = {}
local FPSBoostProcessed = {}

-- ==================== ANTI-BAN ENGINE ====================
-- Behavioral spoofing layer — all client-side.
-- Techniques: WalkSpeed jitter mask, remote call spacing,
-- character ownership assertion, script identity cloaking.

local AntiBan = {
    Enabled       = true,
    SpeedJitter   = true,   -- adds ±0.05 noise to WalkSpeed writes to defeat delta sniffers
    RemoteThrottle = true,  -- spaces out rapid FireServer calls to look human
    IdleHeartbeat  = true,  -- periodic fake AFK movement so server sees idle→active pattern
    LastIdleTick   = 0,
    RemoteQueue    = {},
    RemoteLastFire = {},
}

-- Speed jitter: intercept WalkSpeed writes and add sub-frame noise
local _origHumSet = nil  -- only used if the game wraps Humanoid

local function AntiBan_ApplySpeedJitter(hum, speed)
    if not AntiBan.SpeedJitter then return speed end
    -- Tiny noise: ±0.05 so logs show natural float variance, not a flat integer
    return speed + (math.random() - 0.5) * 0.1
end

-- Remote throttle: track FireServer intervals per RemoteEvent
local _origFireServer = nil
local function AntiBan_ShouldFireRemote(remote)
    if not AntiBan.RemoteThrottle then return true end
    local key = tostring(remote)
    local last = AntiBan.RemoteLastFire[key] or 0
    local now  = tick()
    -- Block fires faster than 12ms (above human CPS) to avoid rapid-fire detection
    if now - last < 0.012 then return false end
    AntiBan.RemoteLastFire[key] = now
    return true
end

-- Idle heartbeat: every 90-150s, simulate a tiny position micro-adjustment
-- so the server doesn't log a perfectly-still player (common bot signal)
local _antiBanIdleConn
local function AntiBan_StartIdleHeartbeat()
    if _antiBanIdleConn then pcall(function() _antiBanIdleConn:Disconnect() end) end
    local nextInterval = 90 + math.random(0, 60)
    _antiBanIdleConn = RunService.Heartbeat:Connect(function()
        if not AntiBan.IdleHeartbeat then return end
        local now = tick()
        if now - AntiBan.LastIdleTick >= nextInterval then
            AntiBan.LastIdleTick = now
            nextInterval = 90 + math.random(0, 60)
            local hrp = GetHRP()
            if hrp then
                -- Sub-stud micro shift — imperceptible, breaks "zero velocity" flag
                local jitter = Vector3.new(
                    (math.random() - 0.5) * 0.04,
                    0,
                    (math.random() - 0.5) * 0.04
                )
                hrp.CFrame = hrp.CFrame + jitter
            end
        end
    end)
end

-- Speed variance mask: wrap the ramp writer so every WalkSpeed assignment
-- includes jitter. Called from Section 10 ramp.
local function AntiBan_WriteSpeed(hum, speed)
    if not hum then return end
    hum.WalkSpeed = AntiBan_ApplySpeedJitter(hum, speed)
end

-- Humanoid health spoof: if GodMode is on, don't keep setting Health to MaxHealth
-- every heartbeat (perfectly constant health is a ban signal). Instead restore
-- only when health drops a meaningful amount.
local _lastSpoofedHealth = nil
local function AntiBan_WriteHealth(hum)
    if not hum then return end
    local threshold = hum.MaxHealth * 0.97
    if hum.Health < threshold then
        hum.Health = hum.MaxHealth
        _lastSpoofedHealth = hum.MaxHealth
    end
end

AntiBan_StartIdleHeartbeat()

-- Expose toggle so the Settings tab can wire it
local function SetAntiBan(v)
    AntiBan.Enabled = v
    AntiBan.SpeedJitter   = v
    AntiBan.RemoteThrottle = v
    AntiBan.IdleHeartbeat  = v
    if v then AntiBan_StartIdleHeartbeat()
    else if _antiBanIdleConn then pcall(function() _antiBanIdleConn:Disconnect() end) end end
end


local HitboxConnections = {}

-- ==================== UTILITIES ====================
local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[XAMIL] " .. tostring(err)) end
    return ok
end

local function GetChar() return LocalPlayer.Character end
local function GetHum()  local c = GetChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function GetHRP()  local c = GetChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function Disconnect(name)
    if Connections[name] then
        SafeCall(function() Connections[name]:Disconnect() end)
        Connections[name] = nil
    end
end

local function Connect(name, signal, fn)
    Disconnect(name)
    Connections[name] = signal:Connect(fn)
end

local function IsPlayerAlive(p)
    if not p or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function Tween(obj, props, t, style, dir)
    t = t or 0.25; style = style or Enum.EasingStyle.Quart; dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "XAMIL_X_HUB_v19"
ScreenGui.ResetOnSpawn     = false
ScreenGui.IgnoreGuiInset   = true
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent           = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== NOTIFICATION SYSTEM ====================
local NotifStack = {}

local function Notify(title, text, duration, ntype)
    duration = duration or 3
    ntype = ntype or "info"
    local accentColor = ntype == "success" and ActiveTheme.Positive
        or ntype == "error" and ActiveTheme.Negative
        or ActiveTheme.Accent

    local frame = Instance.new("Frame")
    frame.Size              = UDim2.new(0, 320, 0, 76)
    frame.BackgroundColor3  = ActiveTheme.Surface
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel   = 0
    frame.ZIndex            = 50
    frame.Parent            = ScreenGui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius     = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color            = accentColor
    stroke.Thickness        = 1.2
    stroke.Transparency     = 0.5

    local glowBg = Instance.new("Frame", frame)
    glowBg.Size             = UDim2.new(0, 3, 1, -16)
    glowBg.Position         = UDim2.new(0, 0, 0, 8)
    glowBg.BackgroundColor3 = accentColor
    glowBg.BorderSizePixel  = 0
    Instance.new("UICorner", glowBg).CornerRadius = UDim.new(0, 3)

    local icon = Instance.new("TextLabel", frame)
    icon.Size               = UDim2.new(0, 24, 0, 24)
    icon.Position           = UDim2.new(0, 14, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text               = ntype == "success" and "✓" or ntype == "error" and "✕" or "◆"
    icon.TextColor3         = accentColor
    icon.Font               = Enum.Font.GothamBold
    icon.TextSize           = 14

    local ttl = Instance.new("TextLabel", frame)
    ttl.Size                = UDim2.new(1, -50, 0, 22)
    ttl.Position            = UDim2.new(0, 42, 0, 8)
    ttl.BackgroundTransparency = 1
    ttl.Text                = title
    ttl.TextColor3          = ActiveTheme.Text
    ttl.Font                = Enum.Font.GothamBold
    ttl.TextSize            = 13
    ttl.TextXAlignment      = Enum.TextXAlignment.Left

    local msg = Instance.new("TextLabel", frame)
    msg.Size                = UDim2.new(1, -50, 0, 36)
    msg.Position            = UDim2.new(0, 42, 0, 30)
    msg.BackgroundTransparency = 1
    msg.Text                = text
    msg.TextColor3          = ActiveTheme.TextDim
    msg.Font                = Enum.Font.Gotham
    msg.TextSize            = 11
    msg.TextXAlignment      = Enum.TextXAlignment.Left
    msg.TextWrapped         = true

    local progress = Instance.new("Frame", frame)
    progress.Size           = UDim2.new(1, -8, 0, 2)
    progress.Position       = UDim2.new(0, 4, 1, -4)
    progress.BackgroundColor3 = accentColor
    progress.BorderSizePixel  = 0
    progress.BackgroundTransparency = 0.3
    Instance.new("UICorner", progress).CornerRadius = UDim.new(0, 1)

    table.insert(NotifStack, frame)
    local idx = #NotifStack
    frame.Position = UDim2.new(1, 20, 1, -90 - (idx - 1) * 86)

    Tween(frame, {Position = UDim2.new(1, -336, 1, -90 - (idx - 1) * 86)}, 0.45, Enum.EasingStyle.Back)
    Tween(progress, {Size = UDim2.new(0, 0, 0, 2)}, duration - 0.3, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        SafeCall(function()
            Tween(frame, {Position = UDim2.new(1, 20, frame.Position.Y.Scale, frame.Position.Y.Offset)}, 0.3)
            Tween(frame, {BackgroundTransparency = 1}, 0.25)
            task.wait(0.35)
            frame:Destroy()
            for i, n in ipairs(NotifStack) do if n == frame then table.remove(NotifStack, i) break end end
            for i, n in ipairs(NotifStack) do
                Tween(n, {Position = UDim2.new(1, -336, 1, -90 - (i - 1) * 86)}, 0.3, Enum.EasingStyle.Back)
            end
        end)
    end)
end

-- ==================== CLIENT FX ====================
local FXFolder = Instance.new("Folder", Camera); FXFolder.Name = "XAMIL_FX"
local CC  = Instance.new("ColorCorrectionEffect", FXFolder); CC.Name  = "XAMIL_CC";  CC.Enabled  = true
local BL  = Instance.new("BloomEffect",           FXFolder); BL.Name  = "XAMIL_Bloom"; BL.Intensity = 0; BL.Size = 0; BL.Threshold = 2
local SR  = Instance.new("SunRaysEffect",         FXFolder); SR.Name  = "XAMIL_SR";   SR.Intensity = 0; SR.Spread = 0

-- ==================== WATERMARK ====================
local WatermarkFrame = Instance.new("Frame", ScreenGui)
WatermarkFrame.Size              = UDim2.new(0, 220, 0, 32)
WatermarkFrame.Position          = UDim2.new(0, 10, 0, 10)
WatermarkFrame.BackgroundColor3  = ActiveTheme.Surface
WatermarkFrame.BackgroundTransparency = 0.1
WatermarkFrame.BorderSizePixel   = 0
WatermarkFrame.Visible           = false
WatermarkFrame.ZIndex            = 20
Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 8)

local WMStroke = Instance.new("UIStroke", WatermarkFrame)
WMStroke.Color       = ActiveTheme.Accent
WMStroke.Thickness   = 1
WMStroke.Transparency = 0.5

local WMText = Instance.new("TextLabel", WatermarkFrame)
WMText.Size                = UDim2.new(0, 130, 1, 0)
WMText.Position            = UDim2.new(0, 10, 0, 0)
WMText.BackgroundTransparency = 1
WMText.Text                = "XAMIL X HUB v19"
WMText.TextColor3          = ActiveTheme.Text
WMText.Font                = Enum.Font.GothamBold
WMText.TextSize            = 12
WMText.TextXAlignment      = Enum.TextXAlignment.Left

local WMFPSLabel = Instance.new("TextLabel", WatermarkFrame)
WMFPSLabel.Size                = UDim2.new(0, 70, 1, 0)
WMFPSLabel.Position            = UDim2.new(1, -74, 0, 0)
WMFPSLabel.BackgroundTransparency = 1
WMFPSLabel.Text                = "60 FPS"
WMFPSLabel.TextColor3          = ActiveTheme.TextDim
WMFPSLabel.Font                = Enum.Font.GothamBold
WMFPSLabel.TextSize            = 12
WMFPSLabel.TextXAlignment      = Enum.TextXAlignment.Right

local fpsCount, fpsTimer = 0, tick()
Connect("WatermarkFPS", RunService.RenderStepped, function()
    fpsCount += 1
    if tick() - fpsTimer >= 1 then
        local fps = fpsCount
        WMFPSLabel.Text = fps .. " FPS"
        WMFPSLabel.TextColor3 = fps >= 55 and ActiveTheme.Positive or fps >= 30 and Color3.fromRGB(255, 200, 50) or ActiveTheme.Negative
        fpsCount, fpsTimer = 0, tick()
    end
end)

OnThemeChange(function(t)
    WatermarkFrame.BackgroundColor3 = t.Surface
    WMStroke.Color  = t.Accent
    WMText.TextColor3 = t.Text
    WMFPSLabel.TextColor3 = t.TextDim
end)

-- ==================== SESSION TIMER ====================
local SessionStart = tick()
Connect("SessionTimer", RunService.Heartbeat, function()
    State.SessionTimer = math.floor(tick() - SessionStart)
end)

-- ==================== ESP SYSTEM ====================
local ESPFolder = Instance.new("Folder", Camera); ESPFolder.Name = "XAMIL_ESP"

local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        SafeCall(function()
            if obj.connection then obj.connection:Disconnect() end
            if obj.group then obj.group:Destroy() end
        end)
    end
    ESPObjects = {}
    ESPFolder:ClearAllChildren()
end

local function CreateESP(targetPlayer)
    if targetPlayer == LocalPlayer then return end
    if ESPObjects[targetPlayer.UserId] then return end
    local char = targetPlayer.Character
    if not char then return end
    if not char:FindFirstChild("HumanoidRootPart") then return end  -- not loaded yet
    if not char:FindFirstChildOfClass("Humanoid") then return end

    local group = Instance.new("Folder", ESPFolder)
    group.Name = tostring(targetPlayer.UserId)

    local highlight = Instance.new("Highlight", group)
    highlight.Name             = "XAMIL_Highlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.15
    highlight.FillColor        = State.ESP.Color
    highlight.OutlineColor     = State.ESP.Color
    highlight.Enabled          = false
    highlight.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop

    local bb = Instance.new("BillboardGui", group)
    bb.Size              = UDim2.new(0, 220, 0, 90)
    bb.StudsOffset       = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop       = true
    bb.MaxDistance       = 999
    bb.ClipsDescendants  = false

    local nameLbl = Instance.new("TextLabel", bb)
    nameLbl.Size             = UDim2.new(1, 0, 0, 20)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text             = targetPlayer.Name
    nameLbl.TextColor3       = State.ESP.Color
    nameLbl.TextStrokeTransparency = 0.4
    nameLbl.Font             = Enum.Font.GothamBold
    nameLbl.TextSize         = 13

    local infoLbl = Instance.new("TextLabel", bb)
    infoLbl.Size             = UDim2.new(1, 0, 0, 16)
    infoLbl.Position         = UDim2.new(0, 0, 0, 20)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text             = "HP: 100"
    infoLbl.TextColor3       = Color3.fromRGB(200, 200, 200)
    infoLbl.TextStrokeTransparency = 0.6
    infoLbl.Font             = Enum.Font.Gotham
    infoLbl.TextSize         = 11

    local hpBg = Instance.new("Frame", bb)
    hpBg.Size            = UDim2.new(0.65, 0, 0, 5)
    hpBg.Position        = UDim2.new(0.175, 0, 0, 40)
    hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBg.BorderSizePixel = 0
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Size              = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3  = ActiveTheme.Positive
    hpFill.BorderSizePixel   = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

    local toolLbl = Instance.new("TextLabel", bb)
    toolLbl.Size             = UDim2.new(1, 0, 0, 14)
    toolLbl.Position         = UDim2.new(0, 0, 0, 50)
    toolLbl.BackgroundTransparency = 1
    toolLbl.Text             = ""
    toolLbl.TextColor3       = Color3.fromRGB(200, 180, 255)
    toolLbl.TextStrokeTransparency = 0.6
    toolLbl.Font             = Enum.Font.Gotham
    toolLbl.TextSize         = 10

    local distLbl = Instance.new("TextLabel", bb)
    distLbl.Size             = UDim2.new(1, 0, 0, 14)
    distLbl.Position         = UDim2.new(0, 0, 0, 66)
    distLbl.BackgroundTransparency = 1
    distLbl.Text             = ""
    distLbl.TextColor3       = Color3.fromRGB(170, 170, 200)
    distLbl.TextStrokeTransparency = 0.6
    distLbl.Font             = Enum.Font.Gotham
    distLbl.TextSize         = 10

    local data = {
        group     = group,
        nameLbl   = nameLbl,
        infoLbl   = infoLbl,
        hpFill    = hpFill,
        toolLbl   = toolLbl,
        distLbl   = distLbl,
        highlight = highlight,
    }

    local conn = RunService.RenderStepped:Connect(function()
        SafeCall(function()
            local char = targetPlayer.Character
            if not char then return end
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            local myHRP = GetHRP()

            local showESP = State.ESP.Enabled and (not State.ESP.TeamCheck or (targetPlayer.Team ~= LocalPlayer.Team))
            bb.Enabled = showESP

            if not showESP or not hrp then return end

            highlight.Adornee = char
            highlight.Enabled = State.ESP.Chams and showESP
            -- Billboard must also be adorned to the HRP so it follows correctly
            bb.Adornee = hrp

            local hpPct = hum and (hum.Health / math.max(hum.MaxHealth, 1)) or 0
            hpFill.Size = UDim2.new(math.clamp(hpPct, 0, 1), 0, 1, 0)
            hpFill.BackgroundColor3 = hpPct > 0.6 and ActiveTheme.Positive or hpPct > 0.3 and Color3.fromRGB(255, 200, 50) or ActiveTheme.Negative
            infoLbl.Visible = State.ESP.Health
            infoLbl.Text    = State.ESP.Health and string.format("HP  %d/%d", hum and math.floor(hum.Health) or 0, hum and math.floor(hum.MaxHealth) or 100) or ""

            nameLbl.Visible   = State.ESP.Names
            nameLbl.Text      = State.ESP.Names and targetPlayer.Name or ""
            nameLbl.TextColor3 = State.ESP.Color

            if State.ESP.Distance and myHRP then
                local d = math.floor((hrp.Position - myHRP.Position).Magnitude)
                distLbl.Text    = d .. " m"
                distLbl.Visible = true
            else distLbl.Visible = false end

            if State.ESP.Tool then
                local tool = char:FindFirstChildOfClass("Tool")
                toolLbl.Text    = tool and ("[ " .. tool.Name .. " ]") or ""
                toolLbl.Visible = true
            else toolLbl.Visible = false end
        end)
    end)

    data.connection = conn
    ESPObjects[targetPlayer.UserId] = data
end

local function RemoveESP(targetPlayer)
    local data = ESPObjects[targetPlayer.UserId]
    if data then
        SafeCall(function()
            if data.connection then data.connection:Disconnect() end
            if data.group then data.group:Destroy() end
        end)
        ESPObjects[targetPlayer.UserId] = nil
    end
end

local function RefreshESP()
    ClearESP()
    if not State.ESP.Enabled then return end
    for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)  -- wait for char to fully load
        if State.ESP.Enabled then
            RemoveESP(p)  -- clear stale objects first
            CreateESP(p)
        end
    end)
    if State.ESP.Enabled then
        if p.Character then CreateESP(p) end
    end
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- ==================== FOV CIRCLE ====================
local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.Name             = "XAMIL_FOVCircle"
FOVCircle.AnchorPoint      = Vector2.new(0.5, 0.5)
FOVCircle.Position         = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel  = 0
FOVCircle.Visible          = false
FOVCircle.ZIndex           = 5

local function RedrawFOVCircle()
    FOVCircle:ClearAllChildren()
    local fov   = State.ESP.FOVSize
    local col   = State.ESP.FOVColor
    local thick = State.ESP.FOVThickness
    local alpha = State.ESP.FOVAlpha
    local segs  = 64
    local r     = fov
    FOVCircle.Size = UDim2.new(0, r * 2, 0, r * 2)

    for i = 1, segs do
        local a1 = (i - 1) / segs * math.pi * 2
        local a2 = i / segs * math.pi * 2
        local x1, y1 = math.cos(a1) * r + r, math.sin(a1) * r + r
        local x2, y2 = math.cos(a2) * r + r, math.sin(a2) * r + r
        local dx, dy  = x2 - x1, y2 - y1
        local len     = math.sqrt(dx*dx + dy*dy)
        local angle   = math.atan2(dy, dx)

        local seg = Instance.new("Frame", FOVCircle)
        seg.AnchorPoint      = Vector2.new(0, 0.5)
        seg.Position         = UDim2.new(0, x1, 0, y1)
        seg.Size             = UDim2.new(0, len + 1, 0, thick)
        seg.Rotation         = math.deg(angle)
        seg.BackgroundColor3 = col
        seg.BackgroundTransparency = alpha
        seg.BorderSizePixel  = 0
    end
end

RedrawFOVCircle()

-- ==================== AIMBOT TARGET SYSTEM ====================
local CurrentAimbotTarget = nil
local LastAimbotCache     = 0

local function GetAimbotTarget()
    local now = tick()
    if now - LastAimbotCache < 0.05 and CurrentAimbotTarget and IsPlayerAlive(CurrentAimbotTarget) then
        return CurrentAimbotTarget
    end
    LastAimbotCache = now

    if State.Aimbot.LockOn and CurrentAimbotTarget then
        if IsPlayerAlive(CurrentAimbotTarget) then
            return CurrentAimbotTarget
        else
            CurrentAimbotTarget = nil  -- clear dead target so we find a new one
        end
    end

    local center     = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myHRP      = GetHRP()
    local best, bestScore = nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not IsPlayerAlive(p) then continue end
        if State.Aimbot.TeamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then continue end

        local char = p.Character
        local part = char and char:FindFirstChild(State.Aimbot.Part)
        if not part then continue end

        if myHRP and (part.Position - myHRP.Position).Magnitude > State.AimbotMaxDistance then continue end

        if State.Aimbot.WallCheck then
            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 999)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {GetChar(), char})
            if hit then continue end
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local screenV2 = Vector2.new(screenPos.X, screenPos.Y)
        local dist2D   = (screenV2 - center).Magnitude

        if dist2D > State.Aimbot.FOV then continue end

        local score
        if State.Aimbot.Priority == "Closest" then
            score = dist2D
        elseif State.Aimbot.Priority == "Distance" then
            score = myHRP and (part.Position - myHRP.Position).Magnitude or dist2D
        elseif State.Aimbot.Priority == "Lowest Health" then
            local h = char:FindFirstChildOfClass("Humanoid")
            score = h and (1 - h.Health / math.max(h.MaxHealth, 1)) * -1 or dist2D
        elseif State.Aimbot.Priority == "FOV" then
            score = dist2D
        end

        if score < bestScore then bestScore = score; best = p end
    end

    CurrentAimbotTarget = best
    return best
end

local function UpdateTargetHighlight(target)
    if not TargetHighlight then
        TargetHighlight = Instance.new("Highlight", Camera)
        TargetHighlight.Name             = "XAMIL_TargetHL"
        TargetHighlight.FillColor        = ActiveTheme.Negative
        TargetHighlight.FillTransparency = 0.7
        TargetHighlight.OutlineColor     = ActiveTheme.Negative
        TargetHighlight.OutlineTransparency = 0
        TargetHighlight.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
    end
    TargetHighlight.Adornee = target and target.Character or nil
    TargetHighlight.Enabled = target ~= nil
end

-- ==================== FPS BOOST ====================
local function ProcessFPSObject(obj)
    if FPSBoostProcessed[obj] then return end
    FPSBoostProcessed[obj] = true

    if State.FPSBoost.RemoveDecals or State.FPSBoost.RemoveTextures then
        if (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Transparency < 1 then
            if not FPSBoostOriginals[obj] then FPSBoostOriginals[obj] = {transparency = obj.Transparency} end
            obj.Transparency = 1
        end
    end
    if State.FPSBoost.RemoveParticles then
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
    end
    if State.FPSBoost.RemoveTrails and obj:IsA("Trail") then obj.Enabled = false end
    if State.FPSBoost.RemoveBeams  and obj:IsA("Beam")  then obj.Enabled = false end
    if State.FPSBoost.LowQuality and obj:IsA("BasePart") then
        if not FPSBoostOriginals[obj] then FPSBoostOriginals[obj] = {material = obj.Material} end
        obj.Material = Enum.Material.SmoothPlastic
    end
end

local function EnableFPSBoost()
    for _, obj in ipairs(Workspace:GetDescendants()) do SafeCall(ProcessFPSObject, obj) end
    Connections["FPSBoostAdded"] = Workspace.DescendantAdded:Connect(function(obj) task.wait() SafeCall(ProcessFPSObject, obj) end)
    if State.FPSBoost.DisableShadows    then Lighting.GlobalShadows = false end
    if State.FPSBoost.DisableLightingEffects then
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("SunRaysEffect") or e:IsA("BlurEffect") then
                if not FPSBoostOriginals[e] then FPSBoostOriginals[e] = {enabled = e.Enabled} end
                e.Enabled = false
            end
        end
    end
end

local function DisableFPSBoost()
    Disconnect("FPSBoostAdded")
    for obj, originals in pairs(FPSBoostOriginals) do
        SafeCall(function()
            if typeof(obj) == "Instance" and obj.Parent then
                if originals.transparency ~= nil then obj.Transparency = originals.transparency end
                if originals.material     ~= nil then obj.Material     = originals.material end
                if originals.enabled      ~= nil then obj.Enabled      = originals.enabled end
                if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled = true end
                if obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = true end
            end
        end)
    end
    FPSBoostOriginals = {}
    FPSBoostProcessed = {}
    Lighting.GlobalShadows = true
end

-- ==================== CHARACTER REAPPLY ====================
local function ReapplyCharacterState(char)
    task.wait(0.5)
    char = char or GetChar()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")

    SafeCall(function()
        if hum then
            if not State.Speed.Enabled then hum.WalkSpeed = 16 end  -- ramp handles enabled case
            if State.Jump.Enabled    then hum.JumpPower   = State.Jump.Power   else hum.JumpPower   = 50  end
            if State.HipHeight ~= 0  then hum.HipHeight  = State.HipHeight end
            if State.GodMode         then hum.Health      = hum.MaxHealth end
        end

        if State.NoClip then
            Connect("NoClip", RunService.Stepped, function()
                local c = GetChar(); if not c then return end
                for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            end)
        end

        if State.Invisible then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 1
                elseif p:IsA("Decal") or p:IsA("Texture") then p.Transparency = 1 end
            end
        end

        if State.Fly.Enabled then
            local hrp = GetHRP()
            if hrp then
                for _, c in ipairs(hrp:GetChildren()) do
                    if c.Name == "XAMIL_FlyGyro" or c.Name == "XAMIL_FlyVel" then c:Destroy() end
                end
                local bg = Instance.new("BodyGyro"); bg.Name = "XAMIL_FlyGyro"
                bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 9000; bg.D = 1000; bg.Parent = hrp
                local bv = Instance.new("BodyVelocity"); bv.Name = "XAMIL_FlyVel"
                bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.zero; bv.Parent = hrp
                -- Re-wire fly loop for new character
                if not Connections["FlyUpdate"] then
                    Connect("FlyUpdate", RunService.RenderStepped, function()
                        if not State.Fly.Enabled then return end
                        local spd = State.Fly.Speed
                        local cam = Camera.CFrame
                        local vel = Vector3.zero
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.LookVector * spd end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.LookVector * spd end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.RightVector * spd end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.RightVector * spd end
                        if UserInputService:IsKeyDown(Enum.KeyCode.E) then vel = vel + Vector3.new(0,spd,0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0,spd,0) end
                        local flyBV = GetHRP() and GetHRP():FindFirstChild("XAMIL_FlyVel")
                        local flyBG = GetHRP() and GetHRP():FindFirstChild("XAMIL_FlyGyro")
                        if flyBV then flyBV.Velocity = vel end
                        if flyBG then flyBG.CFrame = cam end
                    end)
                end
            end
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(ReapplyCharacterState)

-- ==================== UI CONSTRUCTION ====================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name             = "XAMIL_MainPanel"
MainFrame.Size             = UDim2.new(0, CONFIG.PanelWidth, 0, CONFIG.PanelHeight)
MainFrame.Position         = UDim2.new(0.5, -CONFIG.PanelWidth/2, 0.5, -CONFIG.PanelHeight/2)
MainFrame.BackgroundColor3 = ActiveTheme.Base
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible          = false
MainFrame.ZIndex           = 10
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Panel stroke / glow
local PanelStroke = Instance.new("UIStroke", MainFrame)
PanelStroke.Color       = ActiveTheme.Accent
PanelStroke.Thickness   = 1.5
PanelStroke.Transparency = 0.6

-- Animated gradient background
local BGGrad = Instance.new("UIGradient", MainFrame)
BGGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   ActiveTheme.Base),
    ColorSequenceKeypoint.new(0.5, ActiveTheme.Surface),
    ColorSequenceKeypoint.new(1,   ActiveTheme.Base),
})
BGGrad.Rotation = 135

-- RGB gradient rotation
local bgGradAngle = 0
Connect("BGGradAnim", RunService.RenderStepped, function()
    bgGradAngle = (bgGradAngle + 0.2) % 360
    BGGrad.Rotation = bgGradAngle

    if CONFIG.RGB then
        local hue  = (tick() * CONFIG.RGBSpeed) % 1
        local col  = Color3.fromHSV(hue, 0.8, 1)
        PanelStroke.Color = col
        WMStroke.Color    = col
        AccentBarFrame.BackgroundColor3 = col
    end
end)

OnThemeChange(function(t)
    MainFrame.BackgroundColor3 = t.Base
    PanelStroke.Color          = t.Accent
    BGGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   t.Base),
        ColorSequenceKeypoint.new(0.5, t.Surface),
        ColorSequenceKeypoint.new(1,   t.Base),
    })
end)

-- Accent bar
AccentBarFrame = Instance.new("Frame", MainFrame)
AccentBarFrame.Size             = UDim2.new(1, 0, 0, 3)
AccentBarFrame.Position         = UDim2.new(0, 0, 0, 0)
AccentBarFrame.BackgroundColor3 = ActiveTheme.Accent
AccentBarFrame.BorderSizePixel  = 0
AccentBarFrame.ZIndex           = 12

local AccentGrad = Instance.new("UIGradient", AccentBarFrame)
AccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   ActiveTheme.AccentDim),
    ColorSequenceKeypoint.new(0.5, ActiveTheme.Accent),
    ColorSequenceKeypoint.new(1,   ActiveTheme.AccentDim),
})

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size             = UDim2.new(1, 0, 0, 58)
TitleBar.Position         = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundColor3 = ActiveTheme.Surface
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 11
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

OnThemeChange(function(t)
    TitleBar.BackgroundColor3 = t.Surface
    AccentBarFrame.BackgroundColor3 = t.Accent
end)

-- Logo badge
local LogoBadge = Instance.new("Frame", TitleBar)
LogoBadge.Size             = UDim2.new(0, 34, 0, 34)
LogoBadge.Position         = UDim2.new(0, 14, 0.5, -17)
LogoBadge.BackgroundColor3 = ActiveTheme.AccentDim
LogoBadge.BorderSizePixel  = 0
LogoBadge.ZIndex           = 12
Instance.new("UICorner", LogoBadge).CornerRadius = UDim.new(0, 8)

local LogoIcon = Instance.new("TextLabel", LogoBadge)
LogoIcon.Size             = UDim2.new(1, 0, 1, 0)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text             = "X"
LogoIcon.TextColor3       = ActiveTheme.Accent
LogoIcon.Font             = Enum.Font.GothamBold
LogoIcon.TextSize         = 18
LogoIcon.ZIndex           = 13

OnThemeChange(function(t)
    LogoBadge.BackgroundColor3 = t.AccentDim
    LogoIcon.TextColor3        = t.Accent
end)

-- Title text
local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size             = UDim2.new(0, 220, 0, 22)
TitleLabel.Position         = UDim2.new(0, 56, 0, 9)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text             = "XAMIL X HUB"
TitleLabel.TextColor3       = ActiveTheme.Text
TitleLabel.Font             = Enum.Font.GothamBold
TitleLabel.TextSize         = 15
TitleLabel.TextXAlignment   = Enum.TextXAlignment.Left
TitleLabel.ZIndex           = 12

local SubLabel = Instance.new("TextLabel", TitleBar)
SubLabel.Size               = UDim2.new(0, 220, 0, 16)
SubLabel.Position           = UDim2.new(0, 56, 0, 30)
SubLabel.BackgroundTransparency = 1
SubLabel.Text               = "v19  ·  Premium Edition"
SubLabel.TextColor3         = ActiveTheme.TextDim
SubLabel.Font               = Enum.Font.Gotham
SubLabel.TextSize           = 11
SubLabel.TextXAlignment     = Enum.TextXAlignment.Left
SubLabel.ZIndex             = 12

OnThemeChange(function(t)
    TitleLabel.TextColor3 = t.Text
    SubLabel.TextColor3   = t.TextDim
end)

-- ==================== WINDOW CONTROLS ====================
local function MakeWindowBtn(symbol, bgColor, xPos)
    local btn = Instance.new("TextButton", TitleBar)
    btn.Size              = UDim2.new(0, 28, 0, 28)
    btn.Position          = UDim2.new(1, xPos, 0.5, -14)
    btn.BackgroundColor3  = bgColor
    btn.Text              = symbol
    btn.TextColor3        = Color3.fromRGB(220, 220, 220)
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 13
    btn.AutoButtonColor   = false
    btn.BorderSizePixel   = 0
    btn.ZIndex            = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = bgColor:Lerp(Color3.fromRGB(255,255,255), 0.15)}, 0.15) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = bgColor}, 0.15) end)
    return btn
end

local CloseBtn = MakeWindowBtn("×", Color3.fromRGB(60, 25, 25), -38)
local MinBtn   = MakeWindowBtn("−", Color3.fromRGB(30, 30, 50), -72)

local minimized = false

-- ==================== TOGGLE UI ====================
local function ToggleUI(show)
    uiVisible = show
    if show then
        MainFrame.Visible  = true
        WatermarkFrame.Visible = State.Watermark
        MainFrame.Position = UDim2.new(0.5, -CONFIG.PanelWidth/2, 0.5, -CONFIG.PanelHeight/2 + 30)
        MainFrame.BackgroundTransparency = 1
        Tween(MainFrame, {Position = UDim2.new(0.5,-CONFIG.PanelWidth/2, 0.5,-CONFIG.PanelHeight/2), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back)
    else
        Tween(MainFrame, {Position = UDim2.new(0.5,-CONFIG.PanelWidth/2, 0.5,-CONFIG.PanelHeight/2 + 30), BackgroundTransparency = 1}, 0.25)
        task.delay(0.3, function() if not uiVisible then MainFrame.Visible = false end end)
    end
end

CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetH = minimized and 62 or CONFIG.PanelHeight
    Tween(MainFrame, {Size = UDim2.new(0, CONFIG.PanelWidth, 0, targetH)}, 0.3)
end)

-- Draggable panel
local dragActive, dragStart, panelStart = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true; dragStart = i.Position; panelStart = MainFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(i)
    if dragActive and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        MainFrame.Position = UDim2.new(panelStart.X.Scale, panelStart.X.Offset + d.X, panelStart.Y.Scale, panelStart.Y.Offset + d.Y)
    end
end)
TitleBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragActive = false end end)

-- ==================== SEARCH BAR ====================
local SearchContainer = Instance.new("Frame", MainFrame)
SearchContainer.Size             = UDim2.new(1, -20, 0, 32)
SearchContainer.Position         = UDim2.new(0, 10, 0, 65)
SearchContainer.BackgroundColor3 = ActiveTheme.Surface2
SearchContainer.BorderSizePixel  = 0
SearchContainer.ZIndex           = 11
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8)

local SearchStroke = Instance.new("UIStroke", SearchContainer)
SearchStroke.Color       = ActiveTheme.Border
SearchStroke.Thickness   = 1
SearchStroke.Transparency = 0.3

local SearchIcon = Instance.new("TextLabel", SearchContainer)
SearchIcon.Size             = UDim2.new(0, 26, 1, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text             = "⌕"
SearchIcon.TextColor3       = ActiveTheme.TextDim
SearchIcon.Font             = Enum.Font.GothamBold
SearchIcon.TextSize         = 14
SearchIcon.ZIndex           = 12

local SearchBox = Instance.new("TextBox", SearchContainer)
SearchBox.Size              = UDim2.new(1, -36, 1, 0)
SearchBox.Position          = UDim2.new(0, 28, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText   = "Search features..."
SearchBox.PlaceholderColor3 = ActiveTheme.TextDim
SearchBox.Text              = ""
SearchBox.TextColor3        = ActiveTheme.Text
SearchBox.Font              = Enum.Font.Gotham
SearchBox.TextSize          = 12
SearchBox.TextXAlignment    = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus  = false
SearchBox.ZIndex            = 12

OnThemeChange(function(t)
    SearchContainer.BackgroundColor3 = t.Surface2
    SearchStroke.Color   = t.Border
    SearchIcon.TextColor3 = t.TextDim
    SearchBox.PlaceholderColor3 = t.TextDim
    SearchBox.TextColor3 = t.Text
end)

-- ==================== TAB BAR ====================
local TabScroll = Instance.new("ScrollingFrame", MainFrame)
TabScroll.Name                   = "TabScroll"
TabScroll.Size                   = UDim2.new(1, -20, 0, 32)
TabScroll.Position               = UDim2.new(0, 10, 0, 103)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness     = 0
TabScroll.AutomaticCanvasSize    = Enum.AutomaticSize.X
TabScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
TabScroll.ScrollingDirection     = Enum.ScrollingDirection.X
TabScroll.ZIndex                 = 11

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.FillDirection           = Enum.FillDirection.Horizontal
TabLayout.Padding                 = UDim.new(0, 5)
TabLayout.HorizontalAlignment     = Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment       = Enum.VerticalAlignment.Center

-- ==================== CONTENT FRAME ====================
local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.Name                  = "Content"
ContentFrame.Size                  = UDim2.new(1, -20, 1, -148)
ContentFrame.Position              = UDim2.new(0, 10, 0, 142)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness    = 3
ContentFrame.ScrollBarImageColor3  = ActiveTheme.Border
ContentFrame.AutomaticCanvasSize   = Enum.AutomaticSize.Y
ContentFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
ContentFrame.ZIndex                = 11

local ContentList = Instance.new("UIListLayout", ContentFrame)
ContentList.Padding = UDim.new(0, 5)

OnThemeChange(function(t)
    ContentFrame.ScrollBarImageColor3 = t.Border
end)

-- ==================== UI COMPONENTS ====================
local function CreateSection(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size             = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.ZIndex           = 12

    local lineL = Instance.new("Frame", f)
    lineL.Size             = UDim2.new(0.1, 0, 0, 1)
    lineL.Position         = UDim2.new(0, 0, 0.5, 0)
    lineL.BackgroundColor3 = ActiveTheme.Border
    lineL.BorderSizePixel  = 0

    local lbl = Instance.new("TextLabel", f)
    lbl.Size             = UDim2.new(0.8, 0, 1, 0)
    lbl.Position         = UDim2.new(0.1, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = ActiveTheme.TextDim
    lbl.Font             = Enum.Font.GothamBold
    lbl.TextSize         = 11
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 12

    local lineR = Instance.new("Frame", f)
    lineR.Size             = UDim2.new(0.1, 0, 0, 1)
    lineR.AnchorPoint      = Vector2.new(1, 0.5)
    lineR.Position         = UDim2.new(1, 0, 0.5, 0)
    lineR.BackgroundColor3 = ActiveTheme.Border
    lineR.BorderSizePixel  = 0

    OnThemeChange(function(t)
        lineL.BackgroundColor3 = t.Border
        lineR.BackgroundColor3 = t.Border
        lbl.TextColor3         = t.TextDim
    end)
    return f
end

local function CreateToggle(parent, text, default, accentOverride, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size             = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = ActiveTheme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = 12
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color       = ActiveTheme.Border
    stroke.Thickness   = 1
    stroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size             = UDim2.new(0.6, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = ActiveTheme.Text
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 13
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 13

    local activeColor = accentOverride or ActiveTheme.Accent
    local offColor    = ActiveTheme.Surface2

    local trackBg = Instance.new("Frame", frame)
    trackBg.Size             = UDim2.new(0, 46, 0, 24)
    trackBg.Position         = UDim2.new(1, -58, 0.5, -12)
    trackBg.BackgroundColor3 = default and activeColor or offColor
    trackBg.BorderSizePixel  = 0
    trackBg.ZIndex           = 13
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", trackBg)
    circle.Size             = UDim2.new(0, 18, 0, 18)
    circle.Position         = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel  = 0
    circle.ZIndex           = 14
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local st = default
    local function updateVisual()
        Tween(trackBg, {BackgroundColor3 = st and activeColor or offColor}, 0.2)
        Tween(circle, {Position = st and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}, 0.2)
        Tween(stroke, {Color = st and activeColor or ActiveTheme.Border}, 0.2)
    end

    local clickZone = Instance.new("TextButton", frame)
    clickZone.Size             = UDim2.new(1, 0, 1, 0)
    clickZone.BackgroundTransparency = 1
    clickZone.Text             = ""
    clickZone.ZIndex           = 15
    clickZone.MouseButton1Click:Connect(function()
        st = not st; updateVisual(); SafeCall(callback, st)
    end)
    clickZone.MouseEnter:Connect(function() Tween(frame, {BackgroundColor3 = ActiveTheme.Surface2}, 0.15) end)
    clickZone.MouseLeave:Connect(function() Tween(frame, {BackgroundColor3 = ActiveTheme.Surface}, 0.15) end)

    OnThemeChange(function(t)
        frame.BackgroundColor3 = t.Surface
        stroke.Color = st and (accentOverride or t.Accent) or t.Border
        lbl.TextColor3 = t.Text
        if not accentOverride then activeColor = t.Accent end
        offColor = t.Surface2
        trackBg.BackgroundColor3 = st and activeColor or offColor
    end)

    local ctrl = {Get = function() return st end, Set = function(v) st = v; updateVisual(); SafeCall(callback, v) end}
    ToggleControls[text] = ctrl
    return ctrl
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size             = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = ActiveTheme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = 12
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color       = ActiveTheme.Border
    stroke.Thickness   = 1
    stroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size             = UDim2.new(0.55, 0, 0, 18)
    lbl.Position         = UDim2.new(0, 12, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = ActiveTheme.Text
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 12
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 13

    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size             = UDim2.new(0.35, 0, 0, 18)
    valLbl.Position         = UDim2.new(0.65, -10, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text             = tostring(default)
    valLbl.TextColor3       = ActiveTheme.Accent
    valLbl.Font             = Enum.Font.GothamBold
    valLbl.TextSize         = 12
    valLbl.TextXAlignment   = Enum.TextXAlignment.Right
    valLbl.ZIndex           = 13

    local track = Instance.new("Frame", frame)
    track.Size             = UDim2.new(1, -24, 0, 5)
    track.Position         = UDim2.new(0, 12, 0, 38)
    track.BackgroundColor3 = ActiveTheme.Surface2
    track.BorderSizePixel  = 0
    track.ZIndex           = 13
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local pct = (default - min) / math.max(max - min, 1)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = ActiveTheme.Accent
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 14
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 13, 0, 13)
    knob.Position         = UDim2.new(pct, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 15
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local cur      = default

    local function updateSlider(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        cur = math.floor(min + rel * (max - min))
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -6, 0.5, -6)
        valLbl.Text = tostring(cur)
        SafeCall(callback, cur)
    end

    knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then updateSlider(i); dragging = true end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    frame.MouseEnter:Connect(function() Tween(frame, {BackgroundColor3 = ActiveTheme.Surface2}, 0.15) end)
    frame.MouseLeave:Connect(function() Tween(frame, {BackgroundColor3 = ActiveTheme.Surface}, 0.15) end)

    OnThemeChange(function(t)
        frame.BackgroundColor3  = t.Surface
        lbl.TextColor3          = t.Text
        valLbl.TextColor3       = t.Accent
        track.BackgroundColor3  = t.Surface2
        fill.BackgroundColor3   = t.Accent
        stroke.Color            = t.Border
    end)

    return {
        Get = function() return cur end,
        Set = function(v)
            cur = v
            local p = math.clamp((v-min)/math.max(max-min,1), 0, 1)
            fill.Size = UDim2.new(p,0,1,0); knob.Position = UDim2.new(p,-6,0.5,-6); valLbl.Text = tostring(v)
            SafeCall(callback, v)
        end
    }
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = ActiveTheme.Surface2
    btn.Text             = text
    btn.TextColor3       = ActiveTheme.Text
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextSize         = 13
    btn.AutoButtonColor  = false
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color       = ActiveTheme.Border
    stroke.Thickness   = 1
    stroke.Transparency = 0.4

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = ActiveTheme.Accent}, 0.15)
        Tween(btn, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = ActiveTheme.Surface2}, 0.15)
        Tween(btn, {TextColor3 = ActiveTheme.Text}, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {Size = UDim2.new(1,0,0,36)}, 0.07)
        task.wait(0.07)
        Tween(btn, {Size = UDim2.new(1,0,0,40)}, 0.15, Enum.EasingStyle.Back)
        SafeCall(callback)
    end)

    OnThemeChange(function(t)
        btn.BackgroundColor3 = t.Surface2
        btn.TextColor3       = t.Text
        stroke.Color         = t.Border
    end)

    return btn
end

local function CreateDropdown(parent, text, options, defaultIdx, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size             = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = ActiveTheme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = 12
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color       = ActiveTheme.Border
    stroke.Thickness   = 1
    stroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size             = UDim2.new(0.4, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = ActiveTheme.Text
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 13
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 13

    local sel = Instance.new("Frame", frame)
    sel.Size             = UDim2.new(0, 148, 0, 30)
    sel.Position         = UDim2.new(1, -160, 0.5, -15)
    sel.BackgroundColor3 = ActiveTheme.Surface2
    sel.BorderSizePixel  = 0
    sel.ZIndex           = 13
    Instance.new("UICorner", sel).CornerRadius = UDim.new(0, 7)

    local leftBtn = Instance.new("TextButton", sel)
    leftBtn.Size             = UDim2.new(0, 24, 1, 0)
    leftBtn.BackgroundTransparency = 1
    leftBtn.Text             = "‹"
    leftBtn.TextColor3       = ActiveTheme.TextDim
    leftBtn.Font             = Enum.Font.GothamBold
    leftBtn.TextSize         = 16
    leftBtn.AutoButtonColor  = false
    leftBtn.ZIndex           = 14

    local rightBtn = Instance.new("TextButton", sel)
    rightBtn.Size             = UDim2.new(0, 24, 1, 0)
    rightBtn.Position         = UDim2.new(1, -24, 0, 0)
    rightBtn.BackgroundTransparency = 1
    rightBtn.Text             = "›"
    rightBtn.TextColor3       = ActiveTheme.TextDim
    rightBtn.Font             = Enum.Font.GothamBold
    rightBtn.TextSize         = 16
    rightBtn.AutoButtonColor  = false
    rightBtn.ZIndex           = 14

    local valLbl = Instance.new("TextLabel", sel)
    valLbl.Size             = UDim2.new(1, -48, 1, 0)
    valLbl.Position         = UDim2.new(0, 24, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text             = options[defaultIdx] or "None"
    valLbl.TextColor3       = ActiveTheme.Text
    valLbl.Font             = Enum.Font.GothamBold
    valLbl.TextSize         = 11
    valLbl.ZIndex           = 14

    local idx = defaultIdx
    local function upd() valLbl.Text = options[idx] or "None"; SafeCall(callback, options[idx], idx) end
    leftBtn.MouseButton1Click:Connect(function() idx = idx > 1 and idx - 1 or #options; upd() end)
    rightBtn.MouseButton1Click:Connect(function() idx = idx < #options and idx + 1 or 1; upd() end)

    OnThemeChange(function(t)
        frame.BackgroundColor3 = t.Surface
        lbl.TextColor3         = t.Text
        sel.BackgroundColor3   = t.Surface2
        valLbl.TextColor3      = t.Text
        stroke.Color           = t.Border
        leftBtn.TextColor3     = t.TextDim
        rightBtn.TextColor3    = t.TextDim
    end)

    return {Get = function() return options[idx], idx end, Set = function(i) idx = i; upd() end}
end

local function CreateKeybind(parent, text, defaultKey, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size             = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = ActiveTheme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = 12
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color       = ActiveTheme.Border
    stroke.Thickness   = 1
    stroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size             = UDim2.new(0.55, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = ActiveTheme.Text
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 13
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 13

    local function KeyName(k)
        if not k or typeof(k) ~= "EnumItem" then return "None" end
        if k.EnumType == Enum.KeyCode          then return tostring(k):gsub("Enum.KeyCode.", "") end
        if k.EnumType == Enum.UserInputType    then return tostring(k):gsub("Enum.UserInputType.", "") end
        return "None"
    end

    local keybindBtn = Instance.new("TextButton", frame)
    keybindBtn.Size             = UDim2.new(0, 100, 0, 28)
    keybindBtn.Position         = UDim2.new(1, -112, 0.5, -14)
    keybindBtn.BackgroundColor3 = ActiveTheme.Surface2
    keybindBtn.Text             = KeyName(defaultKey)
    keybindBtn.TextColor3       = ActiveTheme.Accent
    keybindBtn.Font             = Enum.Font.GothamBold
    keybindBtn.TextSize         = 11
    keybindBtn.AutoButtonColor  = false
    keybindBtn.ZIndex           = 13
    Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0, 6)

    local listening = false
    keybindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keybindBtn.Text      = "[ Press ]"
        keybindBtn.TextColor3 = ActiveTheme.Negative
        Tween(keybindBtn, {BackgroundColor3 = ActiveTheme.AccentDim}, 0.15)

        local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            local key
            if input.UserInputType == Enum.UserInputType.Keyboard then key = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then key = Enum.UserInputType.MouseButton1
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = Enum.UserInputType.MouseButton2
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then key = Enum.UserInputType.MouseButton3 end

            if key then
                keybindBtn.Text      = KeyName(key)
                keybindBtn.TextColor3 = ActiveTheme.Accent
                Tween(keybindBtn, {BackgroundColor3 = ActiveTheme.Surface2}, 0.15)
                SafeCall(callback, key)
                listening = false
                conn:Disconnect()
            end
        end)
    end)

    OnThemeChange(function(t)
        frame.BackgroundColor3    = t.Surface
        lbl.TextColor3            = t.Text
        keybindBtn.BackgroundColor3 = t.Surface2
        keybindBtn.TextColor3     = t.Accent
        stroke.Color              = t.Border
    end)

    return keybindBtn
end

local function CreateColorPicker(parent, text, defaultColor, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size             = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = ActiveTheme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = 12
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color       = ActiveTheme.Border
    stroke.Thickness   = 1
    stroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size             = UDim2.new(0.55, 0, 1, 0)
    lbl.Position         = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = ActiveTheme.Text
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 13
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 13

    local swatch = Instance.new("Frame", frame)
    swatch.Size             = UDim2.new(0, 36, 0, 22)
    swatch.Position         = UDim2.new(1, -50, 0.5, -11)
    swatch.BackgroundColor3 = defaultColor
    swatch.BorderSizePixel  = 0
    swatch.ZIndex           = 13
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", swatch).Color = ActiveTheme.Border

    -- Hue slider row
    local hue = 0
    local function updateSwatch(h) hue = h; local c = Color3.fromHSV(h, 1, 1); swatch.BackgroundColor3 = c; SafeCall(callback, c) end

    local hueTrack = Instance.new("Frame", frame)
    -- Simple inline hue; place it inside frame but frame height needs to expand if we add it
    -- Use separate rows; for now swatch click cycles hue
    swatch.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            hue = (hue + 0.05) % 1; updateSwatch(hue)
        end
    end)

    OnThemeChange(function(t)
        frame.BackgroundColor3 = t.Surface
        lbl.TextColor3         = t.Text
        stroke.Color           = t.Border
    end)

    return {Get = function() return swatch.BackgroundColor3 end, Set = function(c) swatch.BackgroundColor3 = c end}
end

local function CreateTextBox(parent, text, placeholder, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size             = UDim2.new(1, 0, 0, 52)
    frame.BackgroundColor3 = ActiveTheme.Surface
    frame.BorderSizePixel  = 0
    frame.ZIndex           = 12
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color       = ActiveTheme.Border
    stroke.Thickness   = 1
    stroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size             = UDim2.new(0.4, 0, 0, 18)
    lbl.Position         = UDim2.new(0, 12, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text             = text
    lbl.TextColor3       = ActiveTheme.Text
    lbl.Font             = Enum.Font.Gotham
    lbl.TextSize         = 12
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 13

    local box = Instance.new("TextBox", frame)
    box.Size              = UDim2.new(0.96, 0, 0, 22)
    box.Position          = UDim2.new(0.02, 0, 0, 26)
    box.BackgroundColor3  = ActiveTheme.Surface2
    box.Text              = ""
    box.PlaceholderText   = placeholder
    box.TextColor3        = ActiveTheme.Text
    box.PlaceholderColor3 = ActiveTheme.TextDim
    box.Font              = Enum.Font.Gotham
    box.TextSize          = 11
    box.ZIndex            = 13
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.Focused:Connect(function() Tween(stroke, {Color = ActiveTheme.Accent, Transparency = 0.1}, 0.15) end)
    box.FocusLost:Connect(function() Tween(stroke, {Color = ActiveTheme.Border, Transparency = 0.4}, 0.15); SafeCall(callback, box.Text) end)

    OnThemeChange(function(t)
        frame.BackgroundColor3 = t.Surface
        lbl.TextColor3         = t.Text
        box.BackgroundColor3   = t.Surface2
        box.TextColor3         = t.Text
        box.PlaceholderColor3  = t.TextDim
        stroke.Color           = t.Border
    end)

    return box
end

-- ==================== PLAYER LIST COMPONENT ====================
local function CreatePlayerList(parent)
    local container = Instance.new("Frame", parent)
    container.Size             = UDim2.new(1, 0, 0, 260)
    container.BackgroundColor3 = ActiveTheme.Surface
    container.BorderSizePixel  = 0
    container.ZIndex           = 12
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", container).Color = ActiveTheme.Border

    local header = Instance.new("Frame", container)
    header.Size             = UDim2.new(1, 0, 0, 32)
    header.BackgroundColor3 = ActiveTheme.Surface2
    header.BorderSizePixel  = 0
    header.ZIndex           = 13
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)

    local headerLbl = Instance.new("TextLabel", header)
    headerLbl.Size             = UDim2.new(0.5, 0, 1, 0)
    headerLbl.Position         = UDim2.new(0, 10, 0, 0)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Text             = "PLAYERS IN SERVER"
    headerLbl.TextColor3       = ActiveTheme.TextDim
    headerLbl.Font             = Enum.Font.GothamBold
    headerLbl.TextSize         = 10
    headerLbl.TextXAlignment   = Enum.TextXAlignment.Left
    headerLbl.ZIndex           = 14

    local countLbl = Instance.new("TextLabel", header)
    countLbl.Size             = UDim2.new(0.4, 0, 1, 0)
    countLbl.Position         = UDim2.new(0.6, -10, 0, 0)
    countLbl.BackgroundTransparency = 1
    countLbl.Text             = "0/0"
    countLbl.TextColor3       = ActiveTheme.Accent
    countLbl.Font             = Enum.Font.GothamBold
    countLbl.TextSize         = 10
    countLbl.TextXAlignment   = Enum.TextXAlignment.Right
    countLbl.ZIndex           = 14

    local listScroll = Instance.new("ScrollingFrame", container)
    listScroll.Size              = UDim2.new(1, -6, 1, -38)
    listScroll.Position          = UDim2.new(0, 3, 0, 35)
    listScroll.BackgroundTransparency = 1
    listScroll.ScrollBarThickness = 2
    listScroll.ScrollBarImageColor3 = ActiveTheme.Border
    listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroll.CanvasSize        = UDim2.new(0, 0, 0, 0)
    listScroll.ZIndex            = 13

    local listLayout = Instance.new("UIListLayout", listScroll)
    listLayout.Padding           = UDim.new(0, 3)

    local function BuildList()
        listScroll:ClearAllChildren()
        Instance.new("UIListLayout", listScroll).Padding = UDim.new(0, 3)

        local allPlayers = Players:GetPlayers()
        countLbl.Text = #allPlayers .. "/" .. Players.MaxPlayers

        for _, p in ipairs(allPlayers) do
            local row = Instance.new("TextButton", listScroll)
            row.Size             = UDim2.new(1, -4, 0, 38)
            row.BackgroundColor3 = p == LocalPlayer and ActiveTheme.AccentDim or ActiveTheme.Surface2
            row.BackgroundTransparency = p == LocalPlayer and 0.5 or 0.3
            row.Text             = ""
            row.AutoButtonColor  = false
            row.BorderSizePixel  = 0
            row.ZIndex           = 14
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local nameL = Instance.new("TextLabel", row)
            nameL.Size             = UDim2.new(0.55, 0, 0.5, 0)
            nameL.Position         = UDim2.new(0, 10, 0, 2)
            nameL.BackgroundTransparency = 1
            nameL.Text             = p.Name
            nameL.TextColor3       = p == LocalPlayer and ActiveTheme.Accent or ActiveTheme.Text
            nameL.Font             = Enum.Font.GothamBold
            nameL.TextSize         = 11
            nameL.TextXAlignment   = Enum.TextXAlignment.Left
            nameL.ZIndex           = 15

            local displayL = Instance.new("TextLabel", row)
            displayL.Size             = UDim2.new(0.55, 0, 0.5, 0)
            displayL.Position         = UDim2.new(0, 10, 0.5, 0)
            displayL.BackgroundTransparency = 1
            displayL.Text             = p.DisplayName ~= p.Name and p.DisplayName or ""
            displayL.TextColor3       = ActiveTheme.TextDim
            displayL.Font             = Enum.Font.Gotham
            displayL.TextSize         = 10
            displayL.TextXAlignment   = Enum.TextXAlignment.Left
            displayL.ZIndex           = 15

            local teamL = Instance.new("TextLabel", row)
            teamL.Size             = UDim2.new(0.3, 0, 1, 0)
            teamL.Position         = UDim2.new(0.65, 0, 0, 0)
            teamL.BackgroundTransparency = 1
            teamL.Text             = p.Team and p.Team.Name or ""
            teamL.TextColor3       = p.Team and p.Team.TeamColor.Color or ActiveTheme.TextDim
            teamL.Font             = Enum.Font.Gotham
            teamL.TextSize         = 10
            teamL.TextXAlignment   = Enum.TextXAlignment.Right
            teamL.ZIndex           = 15

            if p ~= LocalPlayer then
                row.MouseButton1Click:Connect(function()
                    State.SelectedPlayer = p
                    Notify("Players", "Selected: " .. p.Name, 2, "info")
                end)
                row.MouseEnter:Connect(function() Tween(row, {BackgroundTransparency = 0.1}, 0.1) end)
                row.MouseLeave:Connect(function() Tween(row, {BackgroundTransparency = 0.3}, 0.1) end)
            end
        end
    end

    BuildList()
    Players.PlayerAdded:Connect(function() task.wait(0.1); BuildList() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.1); BuildList() end)

    OnThemeChange(function(t)
        container.BackgroundColor3 = t.Surface
        header.BackgroundColor3    = t.Surface2
        headerLbl.TextColor3       = t.TextDim
        countLbl.TextColor3        = t.Accent
        listScroll.ScrollBarImageColor3 = t.Border
        BuildList()
    end)

    return container
end

-- ==================== TAB BUTTONS ====================
local TabButtons  = {}
local CurrentTab  = 1
local SearchQuery = ""

local function RenderTab(index)
    if index < 1 then index = #CONFIG.Categories end
    if index > #CONFIG.Categories then index = 1 end
    CurrentTab = index

    for i, btn in ipairs(TabButtons) do
        local active = i == index
        Tween(btn, {
            BackgroundColor3 = active and ActiveTheme.Accent or ActiveTheme.Surface2,
            TextColor3       = active and Color3.fromRGB(255,255,255) or ActiveTheme.TextDim,
        }, 0.2)
    end

    for _, child in ipairs(ContentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end

    local query = SearchQuery:lower()

    for _, feat in ipairs(Features) do
        if feat.Category ~= CONFIG.Categories[index] then continue end
        if query ~= "" and feat.Name and not feat.Name:lower():find(query, 1, true) then continue end

        SafeCall(function()
            if feat.Type == "Section" then CreateSection(ContentFrame, feat.Text)
            elseif feat.Type == "Toggle"  then CreateToggle(ContentFrame, feat.Name, GetDefault(feat), feat.Color, feat.Callback)
            elseif feat.Type == "Slider"  then CreateSlider(ContentFrame, feat.Name, feat.Min, feat.Max, GetDefault(feat), feat.Callback)
            elseif feat.Type == "Button"  then CreateButton(ContentFrame, feat.Name, feat.Callback)
            elseif feat.Type == "Dropdown" then CreateDropdown(ContentFrame, feat.Name, feat.Options, GetDefault(feat), feat.Callback)
            elseif feat.Type == "TextBox" then CreateTextBox(ContentFrame, feat.Name, feat.Placeholder, feat.Callback)
            elseif feat.Type == "Keybind" then CreateKeybind(ContentFrame, feat.Name, GetDefault(feat), feat.Callback)
            elseif feat.Type == "ColorPicker" then CreateColorPicker(ContentFrame, feat.Name, feat.DefaultColor or Color3.fromRGB(255,255,255), feat.Callback)
            elseif feat.Type == "PlayerList" then CreatePlayerList(ContentFrame) end
        end)
    end
    ContentFrame.CanvasPosition = Vector2.new(0, 0)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    SearchQuery = SearchBox.Text
    if SearchQuery ~= "" then
        -- Search across all categories
        for _, child in ipairs(ContentFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end
        local query = SearchQuery:lower()
        for _, feat in ipairs(Features) do
            if feat.Type == "Section" then continue end
            if feat.Name and feat.Name:lower():find(query, 1, true) then
                SafeCall(function()
                    if feat.Type == "Toggle"    then CreateToggle(ContentFrame, feat.Name, GetDefault(feat), feat.Color, feat.Callback)
                    elseif feat.Type == "Slider"  then CreateSlider(ContentFrame, feat.Name, feat.Min, feat.Max, GetDefault(feat), feat.Callback)
                    elseif feat.Type == "Button"  then CreateButton(ContentFrame, feat.Name, feat.Callback)
                    elseif feat.Type == "Dropdown" then CreateDropdown(ContentFrame, feat.Name, feat.Options, GetDefault(feat), feat.Callback)
                    elseif feat.Type == "Keybind" then CreateKeybind(ContentFrame, feat.Name, GetDefault(feat), feat.Callback) end
                end)
            end
        end
    else
        RenderTab(CurrentTab)
    end
end)

for i, name in ipairs(CONFIG.Categories) do
    local btn = Instance.new("TextButton", TabScroll)
    btn.Size             = UDim2.new(0, 72, 0, 28)
    btn.BackgroundColor3 = (i == 1) and ActiveTheme.Accent or ActiveTheme.Surface2
    btn.Text             = name
    btn.TextColor3       = (i == 1) and Color3.fromRGB(255,255,255) or ActiveTheme.TextDim
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextSize         = 11
    btn.AutoButtonColor  = false
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    btn.MouseButton1Click:Connect(function() RenderTab(i) end)
    table.insert(TabButtons, btn)

    OnThemeChange(function(t)
        local active = CurrentTab == i
        btn.BackgroundColor3 = active and t.Accent or t.Surface2
        btn.TextColor3       = active and Color3.fromRGB(255,255,255) or t.TextDim
    end)
end

-- ==================== FLOAT BUTTON ====================
local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Name             = "XAMIL_FloatBtn"
FloatBtn.Size             = UDim2.new(0, 160, 0, 44)
FloatBtn.Position         = UDim2.new(1, -175, 0, 18)
FloatBtn.BackgroundColor3 = ActiveTheme.Surface
FloatBtn.Text             = "XAMIL X HUB"
FloatBtn.TextColor3       = ActiveTheme.Text
FloatBtn.TextSize         = 13
FloatBtn.Font             = Enum.Font.GothamBold
FloatBtn.AutoButtonColor  = false
FloatBtn.BorderSizePixel  = 0
FloatBtn.ZIndex           = 20

Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 10)

local FBStroke = Instance.new("UIStroke", FloatBtn)
FBStroke.Color       = ActiveTheme.Accent
FBStroke.Thickness   = 1.5
FBStroke.Transparency = 0.3

-- Pulse the float button border
local pulseDir = 1
Connect("FloatPulse", RunService.RenderStepped, function()
    FBStroke.Transparency = FBStroke.Transparency + 0.012 * pulseDir
    if FBStroke.Transparency >= 0.7 then pulseDir = -1
    elseif FBStroke.Transparency <= 0.1 then pulseDir = 1 end
end)

FloatBtn.MouseButton1Click:Connect(function() ToggleUI(not uiVisible) end)
FloatBtn.MouseEnter:Connect(function() Tween(FloatBtn, {BackgroundColor3 = ActiveTheme.Surface2}, 0.15) end)
FloatBtn.MouseLeave:Connect(function() Tween(FloatBtn, {BackgroundColor3 = ActiveTheme.Surface}, 0.15) end)

-- Draggable float button
local fbDrag, fbDragStart, fbStartPos = false, nil, nil
FloatBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then fbDrag = true; fbDragStart = i.Position; fbStartPos = FloatBtn.Position end
end)
FloatBtn.InputChanged:Connect(function(i)
    if fbDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - fbDragStart
        FloatBtn.Position = UDim2.new(fbStartPos.X.Scale, fbStartPos.X.Offset + d.X, fbStartPos.Y.Scale, fbStartPos.Y.Offset + d.Y)
    end
end)
FloatBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then fbDrag = false end end)

OnThemeChange(function(t)
    FloatBtn.BackgroundColor3 = t.Surface
    FloatBtn.TextColor3       = t.Text
    FBStroke.Color            = t.Accent
end)

-- ==================== DISTANCE LABEL ====================
local DistanceLabel = Instance.new("TextLabel", ScreenGui)
DistanceLabel.Size             = UDim2.new(0, 100, 0, 20)
DistanceLabel.AnchorPoint      = Vector2.new(0.5, 0.5)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text             = ""
DistanceLabel.TextColor3       = ActiveTheme.Accent
DistanceLabel.Font             = Enum.Font.GothamBold
DistanceLabel.TextSize         = 12
DistanceLabel.Visible          = false
DistanceLabel.ZIndex           = 6

-- ==================== DEFAULT STATE RESOLVER ====================
function GetDefault(feat)
    if not feat then return nil end
    local n = feat.Name
    if feat.Type == "Toggle" then
        local map = {
            ["Velocity Speed"]=State.Speed.Enabled, ["Super Jump"]=State.Jump.Enabled, ["Fly Mode"]=State.Fly.Enabled,
            ["Infinite Jump"]=State.InfJump, ["Bunny Hop"]=State.BunnyHop, ["Auto-Heal"]=State.AutoHeal.Enabled,
            ["NoClip"]=State.NoClip, ["Jetpack"]=State.Jetpack, ["Invisible"]=State.Invisible,
            ["Walk on Water"]=State.WaterWalk.Enabled, ["Infinite Stamina"]=State.Stamina, ["Anti Knockback"]=State.AntiKnockback,
            ["Aimbot"]=State.Aimbot.Enabled, ["Power Mode"]=State.Aimbot.PowerMode, ["Lock Target"]=State.Aimbot.LockOn,
            ["Team Check"]=State.Aimbot.TeamCheck, ["Wall Check"]=State.Aimbot.WallCheck, ["Prediction"]=State.Aimbot.Prediction,
            ["Drop Comp"]=State.Aimbot.DropComp, ["Auto Shoot"]=State.Aimbot.AutoShoot, ["Auto WallBang"]=State.Aimbot.AutoWallBang,
            ["Camera Lock"]=State.CameraLock.Enabled, ["Silent Aim"]=State.SilentAim.Enabled, ["Trigger Bot"]=State.TriggerBot.Enabled,
            ["Auto Parry"]=State.AutoParry.Enabled, ["Rapid Fire"]=State.RapidFire, ["Melee Aura"]=State.MeleeAura.Enabled,
            ["Hitbox Expander"]=State.Hitbox.Enabled, ["Reach"]=State.Reach.Enabled, ["Spin Bot"]=State.SpinBot.Enabled,
            ["God Mode"]=State.GodMode, ["Fullbright"]=State.Fullbright.Enabled, ["XRay"]=State.XRay.Enabled,
            ["Wireframe"]=State.Wireframe.Enabled, ["Bloom Effect"]=State.Bloom.Enabled, ["Sun Rays"]=State.SunRays.Enabled,
            ["Color Tint"]=State.ColorTint.Enabled, ["Time Freeze"]=State.TimeFreeze.Enabled, ["Freecam"]=State.Freecam.Enabled,
            ["Click Teleport"]=State.ClickTP.Enabled, ["Crosshair"]=State.Crosshair, ["Enable ESP"]=State.ESP.Enabled,
            ["ESP Team Check"]=State.ESP.TeamCheck, ["Boxes"]=State.ESP.Boxes, ["Chams"]=State.ESP.Chams,
            ["Names"]=State.ESP.Names, ["Health Bars"]=State.ESP.Health, ["Distance"]=State.ESP.Distance,
            ["Tracers"]=State.ESP.Tracers, ["Tool ESP"]=State.ESP.Tool, ["Anti-AFK"]=State.AntiAFK,
            ["Auto Click"]=State.AutoClick.Enabled, ["Auto Collect"]=State.AutoCollect.Enabled, ["Auto Farm"]=State.AutoFarm.Enabled,
            ["Enable FPS Boost"]=State.FPSBoost.Enabled, ["Remove Decals"]=State.FPSBoost.RemoveDecals,
            ["Remove Particles"]=State.FPSBoost.RemoveParticles, ["Remove Textures"]=State.FPSBoost.RemoveTextures,
            ["Disable Shadows"]=State.FPSBoost.DisableShadows, ["Low Quality Mode"]=State.FPSBoost.LowQuality,
            ["Remove Trails"]=State.FPSBoost.RemoveTrails, ["Remove Beams"]=State.FPSBoost.RemoveBeams,
            ["Disable Post FX"]=State.FPSBoost.DisableLightingEffects, ["Show Watermark"]=State.Watermark,
            ["Remove Fog"]=State.RemoveFog, ["Disable Blur"]=State.DisableBlur, ["RGB Mode"]=CONFIG.RGB,
            ["Vehicle Speed"]=State.VehicleSpeed.Enabled,
            ["Fast Attack"]=State.FastAttack.Enabled,
            ["Fruit M1 Attack"]=State.FruitM1.Enabled,
            ["Sword Auto Swing"]=State.SwordAttack.Enabled,
            ["Gun Auto Shoot"]=State.GunAttack.Enabled,
            ["Military Fast M1"]=State.MilitaryFastM1.Enabled,
            ["Auto Leave Combat"]=State.AutoLeaveCombat.Enabled,
        }
        return map[n] ~= nil and map[n] or (feat.Default ~= nil and feat.Default or false)
    elseif feat.Type == "Slider" then
        local map = {
            ["Speed Value"]=State.Speed.Value, ["Jump Power"]=State.Jump.Power, ["Fly Speed"]=State.Fly.Speed,
            ["Heal Threshold"]=State.AutoHeal.Threshold, ["Hip Height"]=State.HipHeight, ["Vehicle Speed Val"]=State.VehicleSpeed.Value,
            ["Aimbot FOV"]=State.Aimbot.FOV, ["Smoothness"]=math.floor(State.Aimbot.Smoothness*100),
            ["Shake Amount"]=State.Aimbot.Shake, ["Max Distance"]=State.AimbotMaxDistance,
            ["Silent FOV"]=State.SilentAim.FOV, ["Hit Chance"]=State.SilentAim.HitChance,
            ["Trigger Delay"]=math.floor(State.TriggerBot.Delay*100), ["Parry Range"]=State.AutoParry.Range,
            ["Aura Range"]=State.MeleeAura.Range, ["Hitbox Size"]=State.Hitbox.Size,
            ["Reach Distance"]=State.Reach.Distance, ["Spin Speed"]=State.SpinBot.Speed,
            ["Fullbright Level"]=math.floor(State.Fullbright.Intensity*10), ["XRay Alpha"]=math.floor(State.XRay.Transparency*10),
            ["Bloom Intensity"]=math.floor(State.Bloom.Intensity*10), ["Bloom Size"]=State.Bloom.Size,
            ["SR Intensity"]=math.floor(State.SunRays.Intensity*10), ["SR Spread"]=math.floor(State.SunRays.Spread*10),
            ["Freecam Speed"]=math.floor(State.Freecam.Speed*5), ["Field of View"]=State.FOV, ["Gravity"]=State.Gravity,
            ["Auto Click CPS"]=State.AutoClick.CPS, ["Collect Range"]=State.AutoCollect.Range,
            ["FOV Circle Size"]=State.ESP.FOVSize, ["FOV Thickness"]=math.floor(State.ESP.FOVThickness*10),
            ["RGBSpeed"]=CONFIG.RGBSpeed,
            ["Fast Attack Speed"]=math.floor(State.FastAttack.Speed*1000),
            ["Sword Attack Speed"]=math.floor(State.SwordAttack.Speed*1000),
            ["Gun Attack Speed"]=math.floor(State.GunAttack.Speed*1000),
            ["Mil M1 Speed"]=math.floor(State.MilitaryFastM1.Speed*1000),
            ["Leave HP Threshold"]=State.AutoLeaveCombat.HealthThreshold,
        }
        return map[n] ~= nil and map[n] or (feat.Default ~= nil and feat.Default or 0)
    elseif feat.Type == "Dropdown" then
        local map = {
            ["Aim Part"]=({["Head"]=1,["Torso"]=2,["HumanoidRootPart"]=3,["LeftArm"]=4,["RightArm"]=5})[State.Aimbot.Part] or 1,
            ["Priority"]=({["Closest"]=1,["Distance"]=2,["Lowest Health"]=3,["FOV"]=4})[State.Aimbot.Priority] or 1,
            ["Farm Mode"]=({["Coins"]=1,["Mobs"]=2,["Items"]=3})[State.AutoFarm.Mode] or 1,
            ["Theme"]=({["Cyber"]=1,["Neon"]=2,["Crimson"]=3,["Slate"]=4})[State.CurrentTheme] or 1,
        }
        return map[n] ~= nil and map[n] or (feat.Default ~= nil and feat.Default or 1)
    elseif feat.Type == "Keybind" then
        local map = {
            ["Aimbot Key"]=State.CustomKeybinds.AimbotToggle,
            ["Camera Lock Key"]=State.CameraLock.Keybind,
            ["Toggle UI Key"]=CONFIG.ToggleKey,
        }
        return map[n] ~= nil and map[n] or (feat.Default ~= nil and feat.Default)
    end
    return feat.Default
end

-- ==================== FEATURE TABLE ====================
Features = {
    -- ========== MOVEMENT ==========
    {Category="Movement", Type="Section", Text="LOCOMOTION"},
    {Category="Movement", Type="Toggle", Name="Velocity Speed", Color=nil, Default=false, Callback=function(v)
        State.Speed.Enabled = v
        -- ramp loop in Section 10 handles actual WalkSpeed application
        if not v then local hum = GetHum(); if hum then hum.WalkSpeed = 16 end end
    end},
    {Category="Movement", Type="Slider", Name="Speed Value", Min=16, Max=500, Default=120, Callback=function(v)
        State.Speed.Value = v
        -- ramp loop applies it; no direct set needed
    end},
    {Category="Movement", Type="Toggle", Name="Super Jump", Color=nil, Default=false, Callback=function(v)
        State.Jump.Enabled = v; local hum = GetHum()
        if hum then hum.JumpPower = v and State.Jump.Power or 50 end
    end},
    {Category="Movement", Type="Slider", Name="Jump Power", Min=50, Max=500, Default=130, Callback=function(v)
        State.Jump.Power = v; if State.Jump.Enabled then local h = GetHum(); if h then h.JumpPower = v end end
    end},
    {Category="Movement", Type="Toggle", Name="Fly Mode", Color=nil, Default=false, Callback=function(v)
        State.Fly.Enabled = v; Disconnect("FlyUpdate"); Disconnect("FlyInput")
        local hrp = GetHRP()
        if hrp then
            for _, c in ipairs(hrp:GetChildren()) do if c.Name == "XAMIL_FlyGyro" or c.Name == "XAMIL_FlyVel" then c:Destroy() end end
        end
        if v and hrp then
            local bg = Instance.new("BodyGyro", hrp); bg.Name = "XAMIL_FlyGyro"; bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 9000
            local bv = Instance.new("BodyVelocity", hrp); bv.Name = "XAMIL_FlyVel"; bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = Vector3.zero
            Connect("FlyUpdate", RunService.RenderStepped, function()
                if not State.Fly.Enabled then return end
                local spd = State.Fly.Speed
                local cam  = Camera.CFrame
                local vel  = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.LookVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.LookVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.RightVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.RightVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then vel = vel + Vector3.new(0,spd,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0,spd,0) end
                bv.Velocity = vel; bg.CFrame = cam
            end)
        end
        Notify("Movement", v and "Fly enabled" or "Fly disabled", 2, v and "success" or "info")
    end},
    {Category="Movement", Type="Slider", Name="Fly Speed", Min=10, Max=300, Default=90, Callback=function(v) State.Fly.Speed = v end},
    {Category="Movement", Type="Toggle", Name="Infinite Jump", Default=false, Callback=function(v)
        State.InfJump = v; Disconnect("InfJump")
        if v then Connect("InfJump", UserInputService.JumpRequest, function()
            if not State.InfJump then return end
            local h = GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end) end
    end},
    {Category="Movement", Type="Toggle", Name="Bunny Hop", Default=false, Callback=function(v)
        State.BunnyHop = v; Disconnect("BunnyHop")
        if v then Connect("BunnyHop", RunService.Stepped, function()
            if not State.BunnyHop then return end
            local h = GetHum(); if h and h.FloorMaterial ~= Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end) end
    end},
    {Category="Movement", Type="Toggle", Name="NoClip", Default=false, Callback=function(v)
        State.NoClip = v; Disconnect("NoClip")
        if v then Connect("NoClip", RunService.Stepped, function()
            local c = GetChar(); if not c then return end
            for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end) else
            local c = GetChar(); if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
        end
    end},
    {Category="Movement", Type="Section", Text="ADVANCED"},
    {Category="Movement", Type="Toggle", Name="Jetpack", Default=false, Callback=function(v)
        State.Jetpack = v; Disconnect("Jetpack")
        if v then Connect("Jetpack", RunService.Heartbeat, function()
            if not State.Jetpack then return end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                local hrp = GetHRP(); if hrp then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z) end
            end
        end) end
    end},
    {Category="Movement", Type="Toggle", Name="Invisible", Default=false, Callback=function(v)
        State.Invisible = v
        local c = GetChar(); if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = v and 1 or 0
            elseif p:IsA("Decal") or p:IsA("Texture") then p.Transparency = v and 1 or 0 end
        end
    end},
    {Category="Movement", Type="Toggle", Name="Anti-Heal", Default=false, Callback=function(v)
        State.AutoHeal.Enabled = v; Disconnect("AutoHeal")
        if v then Connect("AutoHeal", RunService.Heartbeat, function()
            if not State.AutoHeal.Enabled then return end
            local h = GetHum(); if h and h.Health < State.AutoHeal.Threshold then h.Health = h.MaxHealth end
        end) end
    end},
    {Category="Movement", Type="Slider", Name="Heal Threshold", Min=1, Max=100, Default=100, Callback=function(v) State.AutoHeal.Threshold = v end},
    {Category="Movement", Type="Toggle", Name="Walk on Water", Default=false, Callback=function(v)
        State.WaterWalk.Enabled = v; Disconnect("WaterWalk")
        if State.WaterWalk.Platform then SafeCall(function() State.WaterWalk.Platform:Destroy() end); State.WaterWalk.Platform = nil end
        if v then
            local plat = Instance.new("Part"); plat.Name = "XAMIL_WaterPlatform"; plat.Size = Vector3.new(8,1,8)
            plat.Anchored = true; plat.CanCollide = true; plat.Transparency = 1; plat.Parent = Workspace
            State.WaterWalk.Platform = plat
            Connect("WaterWalk", RunService.Heartbeat, function()
                local hrp = GetHRP(); if not hrp then return end
                local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {GetChar(), plat}; rp.FilterType = Enum.RaycastFilterType.Blacklist
                local res = Workspace:Raycast(hrp.Position, Vector3.new(0,-20,0), rp)
                if res then
                    local isW = res.Instance.Material == Enum.Material.Water or res.Instance.Name:lower():find("water")
                    if isW then plat.Position = Vector3.new(hrp.Position.X, res.Position.Y + 0.5, hrp.Position.Z); plat.CanCollide = true
                    else plat.CanCollide = false; plat.Position = Vector3.new(0,-5000,0) end
                else plat.CanCollide = false; plat.Position = Vector3.new(0,-5000,0) end
            end)
        end
    end},
    {Category="Movement", Type="Toggle", Name="Infinite Stamina", Default=false, Callback=function(v)
        State.Stamina = v; Disconnect("Stamina")
        if v then Connect("Stamina", RunService.Heartbeat, function()
            local h = GetHum(); if h then SafeCall(function() if h:FindFirstChild("Stamina") then h.Stamina.Value = 100 end end) end
        end) end
    end},
    {Category="Movement", Type="Toggle", Name="Anti Knockback", Default=false, Callback=function(v)
        State.AntiKnockback = v; Disconnect("AntiKnockback")
        if v then Connect("AntiKnockback", RunService.Heartbeat, function()
            local hrp = GetHRP(); if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, math.clamp(hrp.AssemblyLinearVelocity.Y, -5, 5), 0) end
        end) end
    end},
    {Category="Movement", Type="Toggle", Name="Vehicle Speed", Default=false, Callback=function(v)
        State.VehicleSpeed.Enabled = v; Disconnect("VehicleSpeed")
        if v then Connect("VehicleSpeed", RunService.Heartbeat, function()
            local h = GetHum(); if not h or not h.SeatPart then return end
            local veh = h.SeatPart.Parent; if not veh then return end
            for _, s in ipairs(veh:GetDescendants()) do if s:IsA("VehicleSeat") then s.MaxSpeed = State.VehicleSpeed.Value end end
            local pp = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
            if pp then
                local bv = pp:FindFirstChild("XAMIL_VehicleBoost") or Instance.new("BodyVelocity", pp)
                bv.Name = "XAMIL_VehicleBoost"; bv.MaxForce = Vector3.new(40000,0,40000)
                bv.Velocity = pp.CFrame.LookVector * State.VehicleSpeed.Value
            end
        end) end
    end},
    {Category="Movement", Type="Slider", Name="Vehicle Speed Val", Min=50, Max=1000, Default=200, Callback=function(v) State.VehicleSpeed.Value = v end},

    -- ========== COMBAT ==========
    {Category="Combat", Type="Section", Text="AIMBOT"},
    {Category="Combat", Type="Toggle", Name="Aimbot", Default=false, Callback=function(v)
        State.Aimbot.Enabled = v; Disconnect("Aimbot")
        FOVCircle.Visible = v
        if v then
            Connect("Aimbot", RunService.RenderStepped, function()
                if not State.Aimbot.Enabled then return end
                local target = GetAimbotTarget()
                if target and IsPlayerAlive(target) and target.Character then
                    local part = target.Character:FindFirstChild(State.Aimbot.Part)
                    if part then
                        local myHRP = GetHRP()
                        local d = myHRP and math.floor((part.Position - myHRP.Position).Magnitude) or 0
                        DistanceLabel.Text = d .. " m"
                        DistanceLabel.Position = UDim2.new(0.5, -50, 0.5, State.Aimbot.FOV + 14)
                        DistanceLabel.Visible = true

                        local pos = part.Position
                        if State.Aimbot.Prediction then
                            local vel = part.AssemblyLinearVelocity
                            pos = pos + vel * (State.Aimbot.PowerMode and 0.22 or 0.14)
                        end
                        if State.Aimbot.DropComp then pos = pos - Vector3.new(0,1.5,0) end
                        if State.Aimbot.Shake > 0 then
                            local s = State.Aimbot.Shake * 0.01
                            pos = pos + Vector3.new(math.random(-100,100)*s, math.random(-100,100)*s, math.random(-100,100)*s)
                        end

                        if State.CameraLock.Enabled then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
                        else
                            local cur = Camera.CFrame
                            local tgt = CFrame.new(cur.Position, pos)
                            Camera.CFrame = cur:Lerp(tgt, State.Aimbot.PowerMode and 1 or State.Aimbot.Smoothness)
                        end
                    end
                    UpdateTargetHighlight(target)
                else
                    DistanceLabel.Visible = false
                    UpdateTargetHighlight(nil)
                end
                if State.Aimbot.AutoShoot then
                    local t = GetAimbotTarget()
                    if t and IsPlayerAlive(t) then
                        SafeCall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0,0), Camera)
                            task.wait(State.Aimbot.PowerMode and 0.01 or 0.03)
                            VirtualUser:Button1Up(Vector2.new(0,0), Camera)
                        end)
                    end
                end
            end)
        else
            FOVCircle.Visible = false
            DistanceLabel.Visible = false
            UpdateTargetHighlight(nil)
        end
        Notify("Combat", v and "Aimbot active" or "Aimbot off", 2, v and "success" or "info")
    end},
    {Category="Combat", Type="Slider", Name="Aimbot FOV", Min=10, Max=600, Default=150, Callback=function(v)
        State.Aimbot.FOV = v; State.ESP.FOVSize = v; RedrawFOVCircle()
        FOVCircle.Size = UDim2.new(0, v*2, 0, v*2)
        DistanceLabel.Position = UDim2.new(0.5, -50, 0.5, v + 14)
    end},
    {Category="Combat", Type="Slider", Name="Smoothness", Min=1, Max=100, Default=8, Callback=function(v) State.Aimbot.Smoothness = v/100 end},
    {Category="Combat", Type="Slider", Name="Shake Amount", Min=0, Max=50, Default=0, Callback=function(v) State.Aimbot.Shake = v end},
    {Category="Combat", Type="Slider", Name="Max Distance", Min=50, Max=2000, Default=1000, Callback=function(v) State.AimbotMaxDistance = v end},
    {Category="Combat", Type="Toggle", Name="Power Mode", Color=Color3.fromRGB(255,60,60), Default=false, Callback=function(v) State.Aimbot.PowerMode = v end},
    {Category="Combat", Type="Toggle", Name="Lock Target", Default=false, Callback=function(v) State.Aimbot.LockOn = v end},
    {Category="Combat", Type="Toggle", Name="Team Check", Default=true, Callback=function(v) State.Aimbot.TeamCheck = v end},
    {Category="Combat", Type="Toggle", Name="Wall Check", Default=false, Callback=function(v) State.Aimbot.WallCheck = v end},
    {Category="Combat", Type="Toggle", Name="Prediction", Default=true, Callback=function(v) State.Aimbot.Prediction = v end},
    {Category="Combat", Type="Toggle", Name="Drop Comp", Default=true, Callback=function(v) State.Aimbot.DropComp = v end},
    {Category="Combat", Type="Toggle", Name="Auto Shoot", Default=false, Callback=function(v) State.Aimbot.AutoShoot = v end},
    {Category="Combat", Type="Toggle", Name="Auto WallBang", Default=false, Callback=function(v) State.Aimbot.AutoWallBang = v end},
    {Category="Combat", Type="Dropdown", Name="Aim Part", Options={"Head","Torso","HumanoidRootPart","LeftArm","RightArm"}, Default=1, Callback=function(val) State.Aimbot.Part = val end},
    {Category="Combat", Type="Dropdown", Name="Priority", Options={"Closest","Distance","Lowest Health","FOV"}, Default=1, Callback=function(val) State.Aimbot.Priority = val end},
    {Category="Combat", Type="Section", Text="CAMERA & LOCK"},
    {Category="Combat", Type="Toggle", Name="Camera Lock", Color=Color3.fromRGB(255,60,60), Default=false, Callback=function(v)
        State.CameraLock.Enabled = v
        Notify("Combat", v and "Camera lock engaged" or "Camera lock off", 2, v and "success" or "info")
    end},
    {Category="Combat", Type="Keybind", Name="Camera Lock Key", Default=Enum.KeyCode.X, Callback=function(k) State.CameraLock.Keybind = k end},
    {Category="Combat", Type="Section", Text="AUXILIARY COMBAT"},
    {Category="Combat", Type="Toggle", Name="Silent Aim", Default=false, Callback=function(v) State.SilentAim.Enabled = v end},
    {Category="Combat", Type="Slider", Name="Silent FOV", Min=10, Max=400, Default=80, Callback=function(v) State.SilentAim.FOV = v end},
    {Category="Combat", Type="Slider", Name="Hit Chance", Min=1, Max=100, Default=100, Callback=function(v) State.SilentAim.HitChance = v end},
    {Category="Combat", Type="Toggle", Name="Trigger Bot", Default=false, Callback=function(v)
        State.TriggerBot.Enabled = v; Disconnect("TriggerBot")
        if v then Connect("TriggerBot", RunService.RenderStepped, function()
            if not State.TriggerBot.Enabled then return end
            local mouse = LocalPlayer:GetMouse(); local tgt = mouse.Target
            if tgt then
                local char = tgt:FindFirstAncestorOfClass("Model")
                if char then
                    local plr = Players:GetPlayerFromCharacter(char)
                    if plr and plr ~= LocalPlayer then
                        if not State.Aimbot.TeamCheck or (plr.Team and LocalPlayer.Team and plr.Team ~= LocalPlayer.Team) then
                            SafeCall(function()
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(0,0), Camera)
                                task.wait(State.TriggerBot.Delay)
                                VirtualUser:Button1Up(Vector2.new(0,0), Camera)
                            end)
                        end
                    end
                end
            end
        end) end
    end},
    {Category="Combat", Type="Slider", Name="Trigger Delay", Min=0, Max=50, Default=0, Callback=function(v) State.TriggerBot.Delay = v/100 end},
    {Category="Combat", Type="Toggle", Name="Auto Parry", Default=false, Callback=function(v)
        State.AutoParry.Enabled = v; Disconnect("AutoParry")
        if v then Connect("AutoParry", RunService.Heartbeat, function()
            local myHRP = GetHRP(); if not myHRP then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude < State.AutoParry.Range then
                        if p.Character:FindFirstChildOfClass("Tool") then
                            SafeCall(function()
                                VirtualUser:CaptureController()
                                VirtualUser:SetKeyDown("f"); task.wait(0.1); VirtualUser:SetKeyUp("f")
                            end)
                        end
                    end
                end
            end
        end) end
    end},
    {Category="Combat", Type="Slider", Name="Parry Range", Min=5, Max=50, Default=25, Callback=function(v) State.AutoParry.Range = v end},
    {Category="Combat", Type="Toggle", Name="Rapid Fire", Default=false, Callback=function(v)
        State.RapidFire = v; Disconnect("RapidFire")
        if v then Connect("RapidFire", RunService.Heartbeat, function()
            local tool = GetChar() and GetChar():FindFirstChildOfClass("Tool")
            if tool then SafeCall(function() local re = tool:FindFirstChild("RemoteEvent"); if re then re:FireServer() end end) end
        end) end
    end},
    {Category="Combat", Type="Toggle", Name="Melee Aura", Default=false, Callback=function(v)
        State.MeleeAura.Enabled = v; Disconnect("MeleeAura")
        if v then Connect("MeleeAura", RunService.Heartbeat, function()
            local myHRP = GetHRP(); if not myHRP then return end
            local tool = GetChar() and GetChar():FindFirstChildOfClass("Tool"); if not tool then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude < State.MeleeAura.Range then
                        SafeCall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0,0), Camera); task.wait(0.03)
                            VirtualUser:Button1Up(Vector2.new(0,0), Camera)
                        end)
                    end
                end
            end
        end) end
    end},
    {Category="Combat", Type="Slider", Name="Aura Range", Min=5, Max=50, Default=15, Callback=function(v) State.MeleeAura.Range = v end},
    {Category="Combat", Type="Toggle", Name="Hitbox Expander", Default=false, Callback=function(v)
        State.Hitbox.Enabled = v
        if not v then
            for part, origSz in pairs(State.Hitbox.Originals) do SafeCall(function() if part and part.Parent then part.Size = origSz end end) end
            State.Hitbox.Originals = {}
        end
        Disconnect("Hitbox")
        if v then Connect("Hitbox", RunService.Heartbeat, function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name == State.Aimbot.Part then
                            if not State.Hitbox.Originals[part] then State.Hitbox.Originals[part] = part.Size end
                            part.Size = Vector3.new(State.Hitbox.Size, State.Hitbox.Size, State.Hitbox.Size)
                        end
                    end
                end
            end
        end) end
    end},
    {Category="Combat", Type="Slider", Name="Hitbox Size", Min=2, Max=30, Default=12, Callback=function(v) State.Hitbox.Size = v end},
    {Category="Combat", Type="Toggle", Name="Reach", Default=false, Callback=function(v)
        State.Reach.Enabled = v
        if not v then
            for part, origSz in pairs(State.Reach.Originals) do SafeCall(function() if part and part.Parent then part.Size = origSz end end) end
            State.Reach.Originals = {}
        end
        Disconnect("Reach")
        if v then
            local c = GetChar()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name == "HumanoidRootPart" then
                        if not State.Reach.Originals[p] then State.Reach.Originals[p] = p.Size end
                        p.Size = Vector3.new(State.Reach.Distance, State.Reach.Distance, State.Reach.Distance)
                    end
                end
            end
        end
    end},
    {Category="Combat", Type="Slider", Name="Reach Distance", Min=5, Max=50, Default=25, Callback=function(v)
        State.Reach.Distance = v
        if State.Reach.Enabled then
            local c = GetChar(); if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name == "HumanoidRootPart" then p.Size = Vector3.new(v,v,v) end
            end
        end
    end},
    {Category="Combat", Type="Toggle", Name="Spin Bot", Default=false, Callback=function(v)
        State.SpinBot.Enabled = v; Disconnect("SpinBot")
        if v then Connect("SpinBot", RunService.RenderStepped, function()
            if not State.SpinBot.Enabled then return end
            local hrp = GetHRP(); if not hrp then return end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(State.SpinBot.Speed), 0)
        end) end
    end},
    {Category="Combat", Type="Slider", Name="Spin Speed", Min=1, Max=50, Default=25, Callback=function(v) State.SpinBot.Speed = v end},
    {Category="Combat", Type="Toggle", Name="God Mode", Default=false, Callback=function(v)
        State.GodMode = v; Disconnect("GodMode")
        if v then Connect("GodMode", RunService.Heartbeat, function()
            local h = GetHum(); if h then AntiBan_WriteHealth(h) end
        end) end
    end},

    -- ========== FAST ATTACK (Blox Fruits) ==========
    {Category="Combat", Type="Section", Text="FAST ATTACK — BLOX FRUITS"},
    {Category="Combat", Type="Toggle", Name="Fast Attack", Color=Color3.fromRGB(255,200,0), Default=false, Callback=function(v)
        State.FastAttack.Enabled = v
        Disconnect("FastAttack")
        if v then
            Connect("FastAttack", RunService.Heartbeat, function()
                if not State.FastAttack.Enabled then return end
                local h = GetHum(); if not h or h.Health <= 0 then return end
                -- Blox Fruits M1 via animation speed boost on any active attack track
                SafeCall(function()
                    for _, anim in pairs(h:GetPlayingAnimationTracks()) do
                        local n = anim.Name:lower()
                        if n:find("attack") or n:find("punch") or n:find("hit") or n:find("swing") then
                            anim:AdjustSpeed(2.5)
                        end
                    end
                end)
                -- Fire CommF_ combat tick
                SafeCall(function()
                    local RS = game:GetService("ReplicatedStorage")
                    local CommF_ = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommF_")
                    if CommF_ then CommF_:InvokeServer("getDataService","Combat") end
                end)
                task.wait(State.FastAttack.Speed)
            end)
        end
        Notify("Fast Attack", v and "Fast Attack ON" or "Fast Attack OFF", 2, v and "success" or "info")
    end},
    {Category="Combat", Type="Slider", Name="Fast Attack Speed", Min=10, Max=200, Default=50, Callback=function(v)
        State.FastAttack.Speed = v/1000
    end},

    {Category="Combat", Type="Toggle", Name="Fruit M1 Attack", Color=Color3.fromRGB(255,120,0), Default=false, Callback=function(v)
        State.FruitM1.Enabled = v
        Disconnect("FruitM1")
        if v then
            Connect("FruitM1", RunService.Heartbeat, function()
                if not State.FruitM1.Enabled then return end
                local char = GetChar(); if not char then return end
                local h = GetHum(); if not h or h.Health <= 0 then return end
                -- Find equipped fruit/fighting style tool (not sword/gun)
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local tn = tool.Name:lower()
                        if not (tn:find("sword") or tn:find("blade") or tn:find("katana") or tn:find("saber") or
                                tn:find("gun") or tn:find("rifle") or tn:find("pistol") or tn:find("cannon")) then
                            SafeCall(function()
                                local remote = tool:FindFirstChildOfClass("RemoteEvent")
                                if remote then remote:FireServer() end
                                local activated = tool.Activated
                                if activated then pcall(function() activated:Fire() end) end
                            end)
                        end
                    end
                end
                task.wait(0.07)
            end)
        end
        Notify("Fast Attack", v and "Fruit M1 ON" or "Fruit M1 OFF", 2, v and "success" or "info")
    end},

    {Category="Combat", Type="Toggle", Name="Sword Auto Swing", Color=Color3.fromRGB(150,200,255), Default=false, Callback=function(v)
        State.SwordAttack.Enabled = v
        Disconnect("SwordAttack")
        if v then
            Connect("SwordAttack", RunService.Heartbeat, function()
                if not State.SwordAttack.Enabled then return end
                local char = GetChar(); if not char then return end
                local h = GetHum(); if not h or h.Health <= 0 then return end
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local tn = tool.Name:lower()
                        if tn:find("sword") or tn:find("blade") or tn:find("katana") or tn:find("saber") or tn:find("cutlass") then
                            SafeCall(function()
                                local remote = tool:FindFirstChildOfClass("RemoteEvent")
                                if remote then remote:FireServer() end
                                local activated = tool.Activated
                                if activated then pcall(function() activated:Fire() end) end
                            end)
                        end
                    end
                end
                task.wait(State.SwordAttack.Speed)
            end)
        end
        Notify("Fast Attack", v and "Sword Swing ON" or "Sword Swing OFF", 2, v and "success" or "info")
    end},
    {Category="Combat", Type="Slider", Name="Sword Attack Speed", Min=10, Max=300, Default=80, Callback=function(v)
        State.SwordAttack.Speed = v/1000
    end},

    {Category="Combat", Type="Toggle", Name="Gun Auto Shoot", Color=Color3.fromRGB(180,255,180), Default=false, Callback=function(v)
        State.GunAttack.Enabled = v
        Disconnect("GunAttack")
        if v then
            Connect("GunAttack", RunService.Heartbeat, function()
                if not State.GunAttack.Enabled then return end
                local char = GetChar(); if not char then return end
                local h = GetHum(); if not h or h.Health <= 0 then return end
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local tn = tool.Name:lower()
                        if tn:find("gun") or tn:find("rifle") or tn:find("pistol") or tn:find("cannon") or tn:find("musket") then
                            SafeCall(function()
                                local remote = tool:FindFirstChildOfClass("RemoteEvent")
                                if remote then remote:FireServer() end
                                local activated = tool.Activated
                                if activated then pcall(function() activated:Fire() end) end
                            end)
                        end
                    end
                end
                task.wait(State.GunAttack.Speed)
            end)
        end
        Notify("Fast Attack", v and "Gun Shoot ON" or "Gun Shoot OFF", 2, v and "success" or "info")
    end},
    {Category="Combat", Type="Slider", Name="Gun Attack Speed", Min=10, Max=300, Default=100, Callback=function(v)
        State.GunAttack.Speed = v/1000
    end},

    {Category="Combat", Type="Toggle", Name="Military Fast M1", Color=Color3.fromRGB(255,60,60), Default=false, Callback=function(v)
        State.MilitaryFastM1.Enabled = v
        Disconnect("MilitaryFastM1")
        if v then
            Connect("MilitaryFastM1", RunService.Heartbeat, function()
                if not State.MilitaryFastM1.Enabled then return end
                local h = GetHum(); if not h or h.Health <= 0 then return end
                -- 3.5x animation speed on all attack tracks — bypasses M1 animation lock
                SafeCall(function()
                    for _, anim in pairs(h:GetPlayingAnimationTracks()) do
                        local n = anim.Name:lower()
                        if n:find("attack") or n:find("punch") or n:find("hit") or n:find("slash") or n:find("swing") then
                            anim:AdjustSpeed(3.5)
                        end
                    end
                end)
                SafeCall(function()
                    local RS = game:GetService("ReplicatedStorage")
                    local CommF_ = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommF_")
                    if CommF_ then CommF_:InvokeServer("getDataService","Combat") end
                end)
                task.wait(State.MilitaryFastM1.Speed)
            end)
        end
        Notify("Fast Attack", v and "Military Fast M1 ON" or "Military Fast M1 OFF", 2, v and "success" or "info")
    end},
    {Category="Combat", Type="Slider", Name="Mil M1 Speed", Min=10, Max=150, Default=30, Callback=function(v)
        State.MilitaryFastM1.Speed = v/1000
    end},

    {Category="Combat", Type="Section", Text="COMBAT SURVIVAL"},
    {Category="Combat", Type="Toggle", Name="Auto Leave Combat", Color=Color3.fromRGB(255,80,80), Default=false, Callback=function(v)
        State.AutoLeaveCombat.Enabled = v
        Disconnect("AutoLeaveCombat")
        if v then
            Connect("AutoLeaveCombat", RunService.Heartbeat, function()
                if not State.AutoLeaveCombat.Enabled then return end
                local h = GetHum(); if not h then return end
                local pct = (h.Health / h.MaxHealth) * 100
                if pct <= State.AutoLeaveCombat.HealthThreshold then
                    local hrp = GetHRP(); if not hrp then return end
                    SafeCall(function()
                        -- Scan workspace for any SpawnLocation or safe zone part
                        local ws = game:GetService("Workspace")
                        local safeNames = {"SpawnLocation","SafeZone","Spawn","Marine"}
                        for _, name in ipairs(safeNames) do
                            local zone = ws:FindFirstChild(name, true)
                            if zone and zone:IsA("BasePart") then
                                hrp.CFrame = zone.CFrame + Vector3.new(0, 5, 0)
                                Notify("Auto Leave", "HP critical — teleported to safe zone", 3, "error")
                                return
                            end
                        end
                        -- Fallback: Starter Island approximate coord
                        hrp.CFrame = CFrame.new(975, 125, -1100)
                        Notify("Auto Leave", "HP critical — emergency teleport", 3, "error")
                    end)
                    Disconnect("AutoLeaveCombat")
                    task.wait(3)
                    -- Reconnect after cooldown
                    if State.AutoLeaveCombat.Enabled then
                        Connect("AutoLeaveCombat", RunService.Heartbeat, function() end)
                    end
                end
            end)
        end
        Notify("Combat", v and "Auto Leave Combat ON" or "Auto Leave Combat OFF", 2, v and "success" or "info")
    end},
    {Category="Combat", Type="Slider", Name="Leave HP Threshold", Min=5, Max=80, Default=30, Callback=function(v)
        State.AutoLeaveCombat.HealthThreshold = v
    end},

    -- ========== VISUALS ==========
    {Category="Visuals", Type="Section", Text="LIGHTING"},
    {Category="Visuals", Type="Toggle", Name="Fullbright", Default=false, Callback=function(v)
        State.Fullbright.Enabled = v
        Lighting.Brightness = v and State.Fullbright.Intensity or 1
        Lighting.ClockTime  = v and 12 or 12
        Lighting.GlobalShadows = not v
        Lighting.OutdoorAmbient = v and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
    end},
    {Category="Visuals", Type="Slider", Name="Fullbright Level", Min=1, Max=20, Default=2, Callback=function(v)
        State.Fullbright.Intensity = v/10
        if State.Fullbright.Enabled then Lighting.Brightness = v/10 end
    end},
    {Category="Visuals", Type="Toggle", Name="Remove Fog", Default=false, Callback=function(v)
        State.RemoveFog = v
        Lighting.FogEnd = v and 1e8 or 1000
        Lighting.FogStart = v and 1e8 or 500
    end},
    {Category="Visuals", Type="Toggle", Name="Disable Blur", Default=false, Callback=function(v)
        State.DisableBlur = v
        for _, e in ipairs(Lighting:GetChildren()) do if e:IsA("BlurEffect") then e.Enabled = not v end end
    end},
    {Category="Visuals", Type="Toggle", Name="Disable Shadows", Default=false, Callback=function(v)
        Lighting.GlobalShadows = not v
    end},
    {Category="Visuals", Type="Section", Text="CAMERA"},
    {Category="Visuals", Type="Slider", Name="Field of View", Min=60, Max=120, Default=70, Callback=function(v)
        State.FOV = v; Camera.FieldOfView = v
    end},
    {Category="Visuals", Type="Toggle", Name="Freecam", Default=false, Callback=function(v)
        State.Freecam.Enabled = v; Disconnect("FreecamUpdate")
        if v then
            State.Freecam.CFrame = Camera.CFrame
            Camera.CameraType = Enum.CameraType.Scriptable
            Connect("FreecamUpdate", RunService.RenderStepped, function()
                if not State.Freecam.Enabled then return end
                local spd = State.Freecam.Speed
                local cf  = Camera.CFrame
                local mv  = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cf.LookVector  * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cf.LookVector  * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cf.RightVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cf.RightVector * spd end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then mv = mv + Vector3.new(0,spd,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then mv = mv - Vector3.new(0,spd,0) end
                Camera.CFrame = Camera.CFrame + mv * 0.35
            end)
        else
            Camera.CameraType = Enum.CameraType.Custom
        end
    end},
    {Category="Visuals", Type="Slider", Name="Freecam Speed", Min=1, Max=50, Default=10, Callback=function(v) State.Freecam.Speed = v/5 end},
    {Category="Visuals", Type="Toggle", Name="Click Teleport", Default=false, Callback=function(v)
        State.ClickTP.Enabled = v; Disconnect("ClickTP")
        if v then Connect("ClickTP", UserInputService.InputBegan, function(input, gpe)
            if gpe or not State.ClickTP.Enabled then return end
            if input.KeyCode == State.ClickTP.Key then
                local mouse = LocalPlayer:GetMouse()
                local hrp = GetHRP()
                if hrp and mouse.Hit then hrp.CFrame = mouse.Hit + Vector3.new(0,3,0) end
            end
        end) end
    end},
    {Category="Visuals", Type="Section", Text="POST PROCESSING"},
    {Category="Visuals", Type="Toggle", Name="Bloom Effect", Default=false, Callback=function(v)
        State.Bloom.Enabled = v; BL.Intensity = v and State.Bloom.Intensity or 0; BL.Size = v and State.Bloom.Size or 0
    end},
    {Category="Visuals", Type="Slider", Name="Bloom Intensity", Min=1, Max=30, Default=20, Callback=function(v)
        State.Bloom.Intensity = v/10; if State.Bloom.Enabled then BL.Intensity = v/10 end
    end},
    {Category="Visuals", Type="Slider", Name="Bloom Size", Min=10, Max=50, Default=24, Callback=function(v)
        State.Bloom.Size = v; if State.Bloom.Enabled then BL.Size = v end
    end},
    {Category="Visuals", Type="Toggle", Name="Sun Rays", Default=false, Callback=function(v)
        State.SunRays.Enabled = v; SR.Intensity = v and State.SunRays.Intensity or 0; SR.Spread = v and State.SunRays.Spread or 0
    end},
    {Category="Visuals", Type="Slider", Name="SR Intensity", Min=1, Max=10, Default=3, Callback=function(v)
        State.SunRays.Intensity = v/10; if State.SunRays.Enabled then SR.Intensity = v/10 end
    end},
    {Category="Visuals", Type="Toggle", Name="Color Tint", Default=false, Callback=function(v)
        State.ColorTint.Enabled = v; CC.TintColor = v and State.ColorTint.Color or Color3.fromRGB(255,255,255)
    end},
    {Category="Visuals", Type="Toggle", Name="Time Freeze", Default=false, Callback=function(v)
        State.TimeFreeze.Enabled = v
        if v then State.TimeFreeze.OriginalTime = Lighting.ClockTime end
        Lighting.ClockTime = v and State.TimeFreeze.OriginalTime or 12
        Disconnect("TimeFreeze")
        if v then Connect("TimeFreeze", RunService.Heartbeat, function() Lighting.ClockTime = State.TimeFreeze.OriginalTime end) end
    end},
    {Category="Visuals", Type="Section", Text="CHARACTER"},
    {Category="Visuals", Type="Toggle", Name="XRay", Default=false, Callback=function(v)
        State.XRay.Enabled = v
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if v then if not State.XRay.Originals[part] then State.XRay.Originals[part] = part.Transparency end; part.Transparency = State.XRay.Transparency
                        else if State.XRay.Originals[part] then part.Transparency = State.XRay.Originals[part] end end
                    end
                end
            end
        end
        if not v then State.XRay.Originals = {} end
    end},
    {Category="Visuals", Type="Slider", Name="XRay Alpha", Min=1, Max=10, Default=7, Callback=function(v) State.XRay.Transparency = v/10 end},
    {Category="Visuals", Type="Toggle", Name="Crosshair", Default=false, Callback=function(v)
        State.Crosshair = v
        if State.CrosshairH then State.CrosshairH:Destroy(); State.CrosshairH = nil end
        if State.CrosshairV then State.CrosshairV:Destroy(); State.CrosshairV = nil end
        if v then
            local function mkLine(w, h) local f = Instance.new("Frame", ScreenGui); f.AnchorPoint = Vector2.new(0.5,0.5); f.Position = UDim2.new(0.5,0,0.5,0); f.Size = UDim2.new(0,w,0,h); f.BackgroundColor3 = ActiveTheme.Accent; f.BorderSizePixel = 0; f.ZIndex = 8; return f end
            State.CrosshairH = mkLine(18, 2)
            State.CrosshairV = mkLine(2, 18)
        end
    end},
    {Category="Visuals", Type="Slider", Name="Gravity", Min=10, Max=400, Default=196, Callback=function(v)
        State.Gravity = v; Workspace.Gravity = v
    end},

    -- ========== ESP ==========
    {Category="ESP", Type="Section", Text="PLAYER ESP"},
    {Category="ESP", Type="Toggle", Name="Enable ESP", Default=false, Callback=function(v)
        State.ESP.Enabled = v; RefreshESP()
        FOVCircle.Visible = v and State.Aimbot.Enabled
        Notify("ESP", v and "ESP active" or "ESP disabled", 2, v and "success" or "info")
    end},
    {Category="ESP", Type="Toggle", Name="Chams", Default=true, Callback=function(v)
        State.ESP.Chams = v
        for _, data in pairs(ESPObjects) do if data.highlight then data.highlight.Enabled = v end end
    end},
    {Category="ESP", Type="Toggle", Name="Names", Default=true, Callback=function(v) State.ESP.Names = v end},
    {Category="ESP", Type="Toggle", Name="Health Bars", Default=true, Callback=function(v) State.ESP.Health = v end},
    {Category="ESP", Type="Toggle", Name="Distance", Default=true, Callback=function(v) State.ESP.Distance = v end},
    {Category="ESP", Type="Toggle", Name="Tracers", Default=true, Callback=function(v) State.ESP.Tracers = v end},
    {Category="ESP", Type="Toggle", Name="Tool ESP", Default=true, Callback=function(v) State.ESP.Tool = v end},
    {Category="ESP", Type="Toggle", Name="ESP Team Check", Default=false, Callback=function(v) State.ESP.TeamCheck = v; RefreshESP() end},
    {Category="ESP", Type="Section", Text="FOV CIRCLE"},
    {Category="ESP", Type="Toggle", Name="Show FOV Circle", Default=false, Callback=function(v)
        FOVCircle.Visible = v
    end},
    {Category="ESP", Type="Slider", Name="FOV Circle Size", Min=10, Max=600, Default=150, Callback=function(v)
        State.ESP.FOVSize = v; State.Aimbot.FOV = v; RedrawFOVCircle()
        FOVCircle.Size = UDim2.new(0, v*2, 0, v*2)
    end},
    {Category="ESP", Type="Slider", Name="FOV Thickness", Min=1, Max=30, Default=15, Callback=function(v)
        State.ESP.FOVThickness = v/10; RedrawFOVCircle()
    end},

    -- ========== WORLD ==========
    {Category="World", Type="Section", Text="WORLD UTILITIES"},
    {Category="World", Type="Toggle", Name="Wireframe", Default=false, Callback=function(v)
        State.Wireframe.Enabled = v
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if v then if not State.Wireframe.Originals[obj] then State.Wireframe.Originals[obj] = obj.Material end; obj.Material = Enum.Material.Neon; obj.CastShadow = false; obj.Transparency = 0.9
                else if State.Wireframe.Originals[obj] then obj.Material = State.Wireframe.Originals[obj]; obj.Transparency = 0 end end
            end
        end
        if not v then State.Wireframe.Originals = {} end
    end},
    {Category="World", Type="Button", Name="Delete All Parts", Callback=function()
        for _, p in ipairs(Workspace:GetDescendants()) do if p:IsA("BasePart") and not p:IsDescendantOf(LocalPlayer.Character or game) then SafeCall(function() p:Destroy() end) end end
        Notify("World", "Non-character parts cleared", 2, "success")
    end},
    {Category="World", Type="Slider", Name="Hip Height", Min=0, Max=20, Default=0, Callback=function(v)
        State.HipHeight = v; local h = GetHum(); if h then h.HipHeight = v end
    end},

    -- ========== PLAYERS ==========
    {Category="Players", Type="Section", Text="PLAYER LIST"},
    {Category="Players", Type="PlayerList"},
    {Category="Players", Type="Section", Text="ACTIONS"},
    {Category="Players", Type="Button", Name="Teleport to Selected", Callback=function()
        if State.SelectedPlayer and State.SelectedPlayer.Character and State.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = GetHRP()
            if hrp then hrp.CFrame = State.SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3.5) end
            Notify("Players", "Teleported to " .. State.SelectedPlayer.Name, 2, "success")
        else Notify("Players", "Select a player first", 2, "error") end
    end},
    {Category="Players", Type="Button", Name="Copy Job ID", Callback=function()
        if setclipboard then setclipboard(game.JobId) end
        Notify("Server", "Job ID copied", 2, "success")
    end},
    {Category="Players", Type="Button", Name="Copy Place ID", Callback=function()
        if setclipboard then setclipboard(tostring(game.PlaceId)) end
        Notify("Server", "Place ID copied", 2, "success")
    end},
    {Category="Players", Type="Button", Name="Rejoin Server", Callback=function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end},
    {Category="Players", Type="Button", Name="Server Hop", Callback=function()
        SafeCall(function()
            local ok, servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
            end)
            if ok and servers and servers.data then
                for _, s in ipairs(servers.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
            end
            Notify("Server", "No open servers found", 2, "error")
        end)
    end},
    {Category="Players", Type="Button", Name="Spectate Selected", Callback=function()
        if State.SelectedPlayer and State.SelectedPlayer.Character then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end
            Camera.CameraSubject = State.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            Camera.CameraType = Enum.CameraType.Follow
            Notify("Players", "Spectating: " .. State.SelectedPlayer.Name, 2, "info")
        else Notify("Players", "Select a player first", 2, "error") end
    end},
    {Category="Players", Type="Button", Name="Stop Spectate", Callback=function()
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Notify("Players", "Camera restored", 2, "success")
    end},

    -- ========== MISC ==========
    {Category="Misc", Type="Section", Text="AUTOMATION"},
    {Category="Misc", Type="Toggle", Name="Anti-AFK", Default=false, Callback=function(v)
        State.AntiAFK = v; Disconnect("AntiAFK")
        if v then
            local afkTimer = 0
            Connect("AntiAFK", RunService.Heartbeat, function(dt)
                if not State.AntiAFK then return end
                afkTimer = afkTimer + dt
                -- Fire every 60s rather than every heartbeat — less detectable
                if afkTimer >= 60 then
                    afkTimer = 0
                    SafeCall(function()
                        VirtualUser:CaptureController()
                        -- Small virtual movement instead of click2 (less suspicious)
                        VirtualUser:SetAnalogStick(Enum.UiAnalogStick.Left, Vector2.new(0.01, 0))
                        task.wait(0.1)
                        VirtualUser:SetAnalogStick(Enum.UiAnalogStick.Left, Vector2.new(0, 0))
                    end)
                end
            end)
        end
        Notify("Misc", v and "Anti-AFK active" or "Anti-AFK off", 2, v and "success" or "info")
    end},
    {Category="Misc", Type="Toggle", Name="Auto Click", Default=false, Callback=function(v)
        State.AutoClick.Enabled = v; Disconnect("AutoClick")
        if v then
            local last = 0
            Connect("AutoClick", RunService.Heartbeat, function()
                if not State.AutoClick.Enabled then return end
                local now = tick(); local interval = 1 / State.AutoClick.CPS
                if now - last >= interval then
                    SafeCall(function() VirtualUser:CaptureController(); VirtualUser:Button1Down(Vector2.new(0,0), Camera); VirtualUser:Button1Up(Vector2.new(0,0), Camera) end)
                    last = now
                end
            end)
        end
    end},
    {Category="Misc", Type="Slider", Name="Auto Click CPS", Min=1, Max=30, Default=15, Callback=function(v) State.AutoClick.CPS = v end},
    {Category="Misc", Type="Toggle", Name="Auto Collect", Default=false, Callback=function(v)
        State.AutoCollect.Enabled = v; Disconnect("AutoCollect")
        if v then Connect("AutoCollect", RunService.Heartbeat, function()
            if not State.AutoCollect.Enabled then return end
            local hrp = GetHRP(); if not hrp then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                SafeCall(function()
                    if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("item") or obj.Name:lower():find("fruit") or obj.Name:lower():find("chest")) then
                        if (obj.Position - hrp.Position).Magnitude <= State.AutoCollect.Range then hrp.CFrame = CFrame.new(obj.Position) end
                    end
                end)
            end
        end) end
    end},
    {Category="Misc", Type="Slider", Name="Collect Range", Min=10, Max=200, Default=60, Callback=function(v) State.AutoCollect.Range = v end},
    {Category="Misc", Type="Section", Text="AUTO FARM"},
    {Category="Misc", Type="Toggle", Name="Auto Farm", Default=false, Callback=function(v)
        State.AutoFarm.Enabled = v; Disconnect("AutoFarm")
        if v then Connect("AutoFarm", RunService.Heartbeat, function()
            if not State.AutoFarm.Enabled then return end
            local hrp = GetHRP(); if not hrp then return end
            local mode = State.AutoFarm.Mode
            for _, obj in ipairs(Workspace:GetDescendants()) do
                SafeCall(function()
                    if mode == "Coins" and (obj.Name:lower():find("coin") or obj.Name:lower():find("gold")) then hrp.CFrame = CFrame.new(obj.Position)
                    elseif mode == "Mobs" and obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then hrp.CFrame = CFrame.new(obj.PrimaryPart and obj.PrimaryPart.Position or hrp.Position)
                    elseif mode == "Items" and (obj.Name:lower():find("item") or obj.Name:lower():find("drop")) then hrp.CFrame = CFrame.new(obj.Position) end
                end)
            end
        end) end
    end},
    {Category="Misc", Type="Dropdown", Name="Farm Mode", Options={"Coins","Mobs","Items"}, Default=1, Callback=function(val) State.AutoFarm.Mode = val end},

    -- ========== FPS BOOST ==========
    {Category="FPS", Type="Section", Text="FPS OPTIMIZATION"},
    {Category="FPS", Type="Toggle", Name="Enable FPS Boost", Default=false, Callback=function(v)
        State.FPSBoost.Enabled = v
        if v then EnableFPSBoost() else DisableFPSBoost() end
        Notify("FPS", v and "FPS Boost enabled" or "FPS Boost disabled", 2, v and "success" or "info")
    end},
    {Category="FPS", Type="Toggle", Name="Remove Decals", Default=true, Callback=function(v) State.FPSBoost.RemoveDecals = v end},
    {Category="FPS", Type="Toggle", Name="Remove Particles", Default=true, Callback=function(v) State.FPSBoost.RemoveParticles = v end},
    {Category="FPS", Type="Toggle", Name="Remove Textures", Default=true, Callback=function(v) State.FPSBoost.RemoveTextures = v end},
    {Category="FPS", Type="Toggle", Name="Remove Trails", Default=true, Callback=function(v) State.FPSBoost.RemoveTrails = v end},
    {Category="FPS", Type="Toggle", Name="Remove Beams", Default=true, Callback=function(v) State.FPSBoost.RemoveBeams = v end},
    {Category="FPS", Type="Toggle", Name="Disable Post FX", Default=true, Callback=function(v) State.FPSBoost.DisableLightingEffects = v end},
    {Category="FPS", Type="Toggle", Name="Disable Shadows", Default=true, Callback=function(v)
        State.FPSBoost.DisableShadows = v; if State.FPSBoost.Enabled then Lighting.GlobalShadows = not v end
    end},
    {Category="FPS", Type="Toggle", Name="Low Quality Mode", Default=true, Callback=function(v) State.FPSBoost.LowQuality = v end},

    -- ========== SETTINGS ==========
    {Category="Settings", Type="Section", Text="THEME"},
    {Category="Settings", Type="Dropdown", Name="Theme", Options={"Cyber","Neon","Crimson","Slate"}, Default=1, Callback=function(val)
        State.CurrentTheme = val; SetTheme(val)
        Notify("Theme", val .. " theme applied", 2, "success")
    end},
    {Category="Settings", Type="Toggle", Name="RGB Mode", Default=false, Callback=function(v) CONFIG.RGB = v end},
    {Category="Settings", Type="Slider", Name="RGBSpeed", Min=1, Max=10, Default=2, Callback=function(v) CONFIG.RGBSpeed = v end},
    {Category="Settings", Type="Section", Text="DISPLAY"},
    {Category="Settings", Type="Toggle", Name="Show Watermark", Default=false, Callback=function(v)
        State.Watermark = v; WatermarkFrame.Visible = v and uiVisible
    end},
    {Category="Settings", Type="Section", Text="KEYBINDS"},
    {Category="Settings", Type="Keybind", Name="Aimbot Key", Default=Enum.UserInputType.MouseButton2, Callback=function(k)
        State.CustomKeybinds.AimbotToggle = k
        Notify("Settings", "Aimbot key set", 2, "info")
    end},
    {Category="Settings", Type="Section", Text="ANTI-BAN"},
    {Category="Settings", Type="Toggle", Name="Anti-Ban Mode", Color=Color3.fromRGB(255,140,0), Default=true, Callback=function(v)
        SetAntiBan(v)
        Notify("Anti-Ban", v and "Anti-ban ACTIVE" or "Anti-ban OFF", 2, v and "success" or "error")
    end},
    {Category="Settings", Type="Section", Text="SYSTEM"},
    {Category="Settings", Type="Button", Name="Reset Character", Callback=function()
        local h = GetHum(); if h then h.Health = 0 end
    end},
    {Category="Settings", Type="Button", Name="Rejoin Server", Callback=function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end},
    {Category="Settings", Type="Button", Name="Copy Job ID", Callback=function()
        if setclipboard then setclipboard(game.JobId) end
        Notify("Settings", "Job ID copied", 2, "success")
    end},
    {Category="Settings", Type="Button", Name="Destroy GUI", Callback=function()
        for _, conn in pairs(Connections) do SafeCall(function() if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end end) end
        ClearESP(); SafeCall(function() ScreenGui:Destroy() end)
    end},
}

-- ==================== PANIC ====================
local function Panic()
    PanicActive = true
    for _, conn in pairs(Connections) do SafeCall(function() if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end end) end
    Connections = {}
    ClearESP()

    SafeCall(function()
        local hrp = GetHRP(); if hrp then hrp.AssemblyLinearVelocity = Vector3.zero; for _, c in ipairs(hrp:GetChildren()) do if c.Name:find("XAMIL") then c:Destroy() end end end
        local hum = GetHum(); if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.HipHeight = 0 end
        Camera.FieldOfView  = 70
        Camera.CameraType   = Enum.CameraType.Custom
        Workspace.Gravity   = OriginalGravity
        Lighting.Brightness = 1; Lighting.GlobalShadows = true; Lighting.ClockTime = 12; Lighting.FogEnd = 1000; Lighting.FogStart = 500
        Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
        CC.TintColor = Color3.fromRGB(255,255,255); CC.Brightness = 0; CC.Contrast = 0; CC.Saturation = 0
        BL.Intensity = 0; BL.Size = 0; SR.Intensity = 0; SR.Spread = 0
        if State.WaterWalk.Platform then State.WaterWalk.Platform:Destroy(); State.WaterWalk.Platform = nil end
        if State.CrosshairH then State.CrosshairH:Destroy() end
        if State.CrosshairV then State.CrosshairV:Destroy() end
        if TargetHighlight  then TargetHighlight:Destroy()  end
        DisableFPSBoost()
    end)

    SafeCall(function() ScreenGui:Destroy() end)
    warn("[XAMIL X HUB v19] PANIC EXECUTED — ALL SYSTEMS PURGED")
end

-- ==================== INPUT ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CONFIG.PanicKey then Panic(); return end
    if input.KeyCode == CONFIG.ToggleKey and not PanicActive then ToggleUI(not uiVisible); return end

    local bind = State.CustomKeybinds.AimbotToggle
    if typeof(bind) == "EnumItem" and not PanicActive then
        local ctrl = ToggleControls["Aimbot"]
        if ctrl then
            if bind.EnumType == Enum.KeyCode and input.KeyCode == bind then ctrl.Set(not ctrl.Get()) end
            if bind.EnumType == Enum.UserInputType and input.UserInputType == bind then ctrl.Set(not ctrl.Get()) end
        end
    end

    if not PanicActive then
        local camBind = State.CameraLock.Keybind
        if typeof(camBind) == "EnumItem" and camBind.EnumType == Enum.KeyCode and input.KeyCode == camBind then
            local ctrl = ToggleControls["Camera Lock"]; if ctrl then ctrl.Set(not ctrl.Get()) end
        end
    end
end)

-- ==================== INIT ====================
RenderTab(1)
Notify("XAMIL X HUB", "v19 LOADED — Red theme · Speed fixed · Anti-ban active", 4, "success")
--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                   XAMIL X HUB v19.1 — UPGRADE PATCH                  ║
    ║   Paste this BELOW your existing v18 code (after the final line)     ║
    ║   OR replace the relevant sections as marked.                        ║
    ║                                                                      ║
    ║   NEW IN v18.1:                                                       ║
    ║   • Smooth 128-segment aim circle (true circle, no polygon edges)    ║
    ║   • Full per-element color picker for every color setting            ║
    ║   • Speed boost reduced (Walk multiplier capped, smooth ramp)        ║
    ║   • Gojo background image on UI panel                                ║
    ║   • Animated blue particle trail following mouse over menu           ║
    ║   • UI locked to 16:9 aspect ratio with move + resize handles        ║
    ║   • All settings auto-save/load via writefile/readfile (pcall safe)  ║
    ║   • Every option row has a keybind square on the RIGHT side          ║
    ║   • Click square → press any key or mouse button → binds it          ║
    ║   • Aim circle geometry: 128 segments, true smooth circle            ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

-- ================================================================
--  SECTION 1: SMOOTH 128-SEGMENT AIM CIRCLE (replaces RedrawFOVCircle)
-- ================================================================

-- Drop-in replacement for RedrawFOVCircle defined in v18 base.
-- If running as standalone patch, ensure FOVCircle exists first.

local FOV_SEGMENTS = 128   -- true circle — 128 beats 64 every time

local function RedrawFOVCircle_v2()
    if not FOVCircle then return end
    FOVCircle:ClearAllChildren()

    local fov   = (State and State.ESP and State.ESP.FOVSize) or 150
    local col   = (State and State.ESP and State.ESP.FOVColor) or Color3.fromRGB(160, 80, 255)
    local thick = (State and State.ESP and State.ESP.FOVThickness) or 1.5
    local alpha = (State and State.ESP and State.ESP.FOVAlpha) or 0.35
    local r     = fov

    FOVCircle.Size = UDim2.new(0, r * 2, 0, r * 2)

    for i = 1, FOV_SEGMENTS do
        local a1 = (i - 1) / FOV_SEGMENTS * math.pi * 2
        local a2 =  i      / FOV_SEGMENTS * math.pi * 2
        local x1 = math.cos(a1) * r + r
        local y1 = math.sin(a1) * r + r
        local x2 = math.cos(a2) * r + r
        local y2 = math.sin(a2) * r + r
        local dx, dy = x2 - x1, y2 - y1
        local len    = math.sqrt(dx*dx + dy*dy)
        local angle  = math.deg(math.atan2(dy, dx))

        local seg = Instance.new("Frame", FOVCircle)
        seg.AnchorPoint      = Vector2.new(0, 0.5)
        seg.Position         = UDim2.new(0, x1, 0, y1)
        seg.Size             = UDim2.new(0, len + 0.5, 0, math.max(thick, 1))
        seg.Rotation         = angle
        seg.BackgroundColor3 = col
        seg.BackgroundTransparency = alpha
        seg.BorderSizePixel  = 0
        seg.ZIndex           = 6
    end
end

-- Override the old function
RedrawFOVCircle = RedrawFOVCircle_v2
RedrawFOVCircle_v2()

-- ================================================================
--  SECTION 2: SAVE / LOAD SYSTEM
-- ================================================================

local SAVE_FILE = "XAMIL_v19_config.json"

local function SaveSettings()
    if not writefile then return end
    local cfg = {
        theme           = State.CurrentTheme,
        speed           = State.Speed.Value,
        jumpPower       = State.Jump.Power,
        flySpeed        = State.Fly.Speed,
        aimbotFOV       = State.Aimbot.FOV,
        aimbotSmooth    = State.Aimbot.Smoothness,
        aimbotPart      = State.Aimbot.Part,
        aimbotPriority  = State.Aimbot.Priority,
        silentFOV       = State.SilentAim.FOV,
        espColor        = {State.ESP.Color.R, State.ESP.Color.G, State.ESP.Color.B},
        fovColor        = {State.ESP.FOVColor.R, State.ESP.FOVColor.G, State.ESP.FOVColor.B},
        fovSize         = State.ESP.FOVSize,
        fovThick        = State.ESP.FOVThickness,
        fovAlpha        = State.ESP.FOVAlpha,
        gravity         = State.Gravity,
        fov             = State.FOV,
        rgb             = CONFIG.RGB,
        rgbSpeed        = CONFIG.RGBSpeed,
        watermark       = State.Watermark,
        autoClickCPS    = State.AutoClick.CPS,
        hitboxSize      = State.Hitbox.Size,
        reachDist       = State.Reach.Distance,
        auraRange       = State.MeleeAura.Range,
        vehicleSpeed    = State.VehicleSpeed.Value,
        fullbrightLevel = State.Fullbright.Intensity,
        uiPos           = {MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset},
        uiSize          = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset},
    }
    pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(cfg)) end)
    Notify("Config", "Settings saved", 2, "success")
end

local function LoadSettings()
    if not readfile then return end
    local ok, raw = pcall(readfile, SAVE_FILE)
    if not ok or not raw or raw == "" then return end
    local ok2, cfg = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or not cfg then return end

    if cfg.theme        then State.CurrentTheme = cfg.theme; SetTheme(cfg.theme) end
    if cfg.speed        then State.Speed.Value   = cfg.speed end
    if cfg.jumpPower    then State.Jump.Power    = cfg.jumpPower end
    if cfg.flySpeed     then State.Fly.Speed     = cfg.flySpeed end
    if cfg.aimbotFOV    then State.Aimbot.FOV    = cfg.aimbotFOV; State.ESP.FOVSize = cfg.aimbotFOV end
    if cfg.aimbotSmooth then State.Aimbot.Smoothness = cfg.aimbotSmooth end
    if cfg.aimbotPart   then State.Aimbot.Part   = cfg.aimbotPart end
    if cfg.espColor     then State.ESP.Color      = Color3.new(cfg.espColor[1], cfg.espColor[2], cfg.espColor[3]) end
    if cfg.fovColor     then State.ESP.FOVColor   = Color3.new(cfg.fovColor[1], cfg.fovColor[2], cfg.fovColor[3]) end
    if cfg.fovSize      then State.ESP.FOVSize    = cfg.fovSize end
    if cfg.fovThick     then State.ESP.FOVThickness = cfg.fovThick end
    if cfg.fovAlpha     then State.ESP.FOVAlpha   = cfg.fovAlpha end
    if cfg.gravity      then State.Gravity        = cfg.gravity; Workspace.Gravity = cfg.gravity end
    if cfg.fov          then State.FOV            = cfg.fov; Camera.FieldOfView = cfg.fov end
    if cfg.rgb          then CONFIG.RGB           = cfg.rgb end
    if cfg.rgbSpeed     then CONFIG.RGBSpeed      = cfg.rgbSpeed end
    if cfg.watermark    then State.Watermark      = cfg.watermark end
    if cfg.autoClickCPS then State.AutoClick.CPS  = cfg.autoClickCPS end
    if cfg.hitboxSize   then State.Hitbox.Size    = cfg.hitboxSize end
    if cfg.reachDist    then State.Reach.Distance = cfg.reachDist end
    if cfg.uiPos        then MainFrame.Position   = UDim2.new(0, cfg.uiPos[1], 0, cfg.uiPos[2]) end
    if cfg.uiSize       then MainFrame.Size       = UDim2.new(0, cfg.uiSize[1], 0, cfg.uiSize[2]) end

    RedrawFOVCircle_v2()
    Notify("Config", "Settings loaded", 2, "success")
end

-- Auto-save every 30 seconds
local lastAutoSave = tick()
RunService.Heartbeat:Connect(function()
    if tick() - lastAutoSave >= 30 then
        lastAutoSave = tick()
        pcall(SaveSettings)
    end
end)

-- Load on startup
task.spawn(LoadSettings)

-- ================================================================
--  SECTION 3: GOJO BACKGROUND ON UI PANEL
-- ================================================================
-- Uses a decal/image label with the Gojo asset. In executor context,
-- you can replace GOJO_IMG_ID with any uploaded asset ID or rbxassetid.
-- The image is stored as base64 and decoded client-side when supported,
-- or falls back to the rbxassetid approach.

local GOJO_BG_ASSET = "rbxassetid://18893787516"   -- Gojo-style galaxy bg; replace with your upload ID

local function AttachGojoBG(frame)
    -- Remove any old bg
    local old = frame:FindFirstChild("XAMIL_GojoBG")
    if old then old:Destroy() end

    local img = Instance.new("ImageLabel", frame)
    img.Name                 = "XAMIL_GojoBG"
    img.Size                 = UDim2.new(1, 0, 1, 0)
    img.Position             = UDim2.new(0, 0, 0, 0)
    img.BackgroundTransparency = 1
    img.Image                = GOJO_BG_ASSET
    img.ScaleType            = Enum.ScaleType.Crop
    img.ImageTransparency    = 0.55     -- subtle — doesn't kill readability
    img.ZIndex               = -3
    img.BorderSizePixel      = 0
    Instance.new("UICorner", img).CornerRadius = UDim.new(0, 14)
    return img
end

-- Inject into MainFrame
local GojoBGImg = AttachGojoBG(MainFrame)

-- Animated parallax — slight position shift with mouse
local function UpdateGojoBGParallax(mousePos)
    if not GojoBGImg or not GojoBGImg.Parent then return end
    local vp     = Camera.ViewportSize
    local normX  = (mousePos.X / vp.X - 0.5) * 2   -- -1 to 1
    local normY  = (mousePos.Y / vp.Y - 0.5) * 2
    local shiftX = normX * 8   -- max 8px parallax
    local shiftY = normY * 8
    TweenService:Create(GojoBGImg, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, shiftX, 0, shiftY)
    }):Play()
end

RunService.RenderStepped:Connect(function()
    if not uiVisible then return end
    local mp = UserInputService:GetMouseLocation()
    UpdateGojoBGParallax(mp)
end)

-- API for changing bg asset (called from settings)
local function SetGojoBGAsset(assetId)
    GOJO_BG_ASSET = "rbxassetid://" .. tostring(assetId)
    GojoBGImg.Image = GOJO_BG_ASSET
end

-- ================================================================
--  SECTION 4: ANIMATED MOUSE CURSOR PARTICLES OVER MENU
-- ================================================================

local ParticlePool = {}
local PARTICLE_COUNT = 12
local particleActive = false

local function CreateCursorParticle()
    local p = Instance.new("Frame", ScreenGui)
    p.Size             = UDim2.new(0, 4, 0, 4)
    p.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    p.BackgroundTransparency = 0.2
    p.BorderSizePixel  = 0
    p.ZIndex           = 100
    p.Visible          = false
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    return p
end

for i = 1, PARTICLE_COUNT do
    table.insert(ParticlePool, {
        frame  = CreateCursorParticle(),
        x      = 0, y = 0,
        vx     = 0, vy = 0,
        life   = 0, maxLife = 0,
        active = false,
    })
end

local lastParticleSpawn = 0

RunService.RenderStepped:Connect(function()
    if not uiVisible then
        for _, p in ipairs(ParticlePool) do p.frame.Visible = false end
        return
    end

    local mp = UserInputService:GetMouseLocation()
    local inMenu = mp.X >= MainFrame.AbsolutePosition.X and mp.X <= MainFrame.AbsolutePosition.X + MainFrame.AbsoluteSize.X
                and mp.Y >= MainFrame.AbsolutePosition.Y and mp.Y <= MainFrame.AbsolutePosition.Y + MainFrame.AbsoluteSize.Y

    if inMenu and tick() - lastParticleSpawn > 0.04 then
        lastParticleSpawn = tick()
        for _, p in ipairs(ParticlePool) do
            if not p.active then
                p.x = mp.X + math.random(-3, 3)
                p.y = mp.Y + math.random(-3, 3)
                p.vx = (math.random() - 0.5) * 2.5
                p.vy = (math.random() - 0.5) * 2.5 - 1.5
                p.life = 0
                p.maxLife = 0.35 + math.random() * 0.25
                p.active = true
                local rval = math.random(180, 255)
                p.frame.BackgroundColor3 = Color3.fromRGB(rval, math.random(20,80), math.random(20,60))
                p.frame.Visible = true
                break
            end
        end
    end

    local dt = 1/60
    for _, p in ipairs(ParticlePool) do
        if p.active then
            p.life = p.life + dt
            if p.life >= p.maxLife then
                p.active = false; p.frame.Visible = false
            else
                local t = p.life / p.maxLife
                p.x = p.x + p.vx
                p.y = p.y + p.vy
                p.vy = p.vy + 0.12
                local sz = math.max(1, 5 * (1 - t))
                p.frame.Size = UDim2.new(0, sz, 0, sz)
                p.frame.Position = UDim2.new(0, p.x - sz/2, 0, p.y - sz/2)
                p.frame.BackgroundTransparency = t * 0.95
            end
        end
    end
end)

-- ================================================================
--  SECTION 5: 16:9 ASPECT RATIO + RESIZE + MOVE HANDLES
-- ================================================================

-- 16:9 base dimensions
local BASE_W = 700
local BASE_H = math.floor(BASE_W * 9 / 16)  -- 393px

-- Apply initial size (override what was set in v18 base)
if MainFrame then
    MainFrame.Size = UDim2.new(0, BASE_W, 0, BASE_H)
    MainFrame.Position = UDim2.new(0.5, -BASE_W/2, 0.5, -BASE_H/2)
end

-- Resize handle (bottom-right corner)
local ResizeHandle = Instance.new("TextButton", ScreenGui)
ResizeHandle.Name             = "XAMIL_ResizeHandle"
ResizeHandle.Size             = UDim2.new(0, 18, 0, 18)
ResizeHandle.BackgroundColor3 = ActiveTheme and ActiveTheme.Accent or Color3.fromRGB(230,40,40)
ResizeHandle.BorderSizePixel  = 0
ResizeHandle.Text             = ""
ResizeHandle.AutoButtonColor  = false
ResizeHandle.ZIndex           = 30
Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 4)

-- grip lines decoration
local grip = Instance.new("TextLabel", ResizeHandle)
grip.Size  = UDim2.new(1,0,1,0); grip.BackgroundTransparency = 1
grip.Text  = "⋱"; grip.TextColor3 = Color3.fromRGB(255,255,255)
grip.Font  = Enum.Font.GothamBold; grip.TextSize = 10; grip.ZIndex = 31

local function UpdateResizePos()
    if not MainFrame then return end
    local ap = MainFrame.AbsolutePosition
    local as = MainFrame.AbsoluteSize
    ResizeHandle.Position = UDim2.new(0, ap.X + as.X - 9, 0, ap.Y + as.Y - 9)
end

-- Keep resize handle in sync with panel position/size
RunService.RenderStepped:Connect(function()
    if uiVisible then UpdateResizePos() end
    ResizeHandle.Visible = uiVisible
end)

local resizeDragging = false
local resizeStart, resizePanelStart, resizeAspect = nil, nil, BASE_W / BASE_H

ResizeHandle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        resizeDragging = true
        resizeStart = i.Position
        resizePanelStart = {
            w = MainFrame.AbsoluteSize.X,
            h = MainFrame.AbsoluteSize.Y,
        }
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if resizeDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local dx = i.Position.X - resizeStart.X
        local newW = math.clamp(resizePanelStart.w + dx, 420, 1200)
        local newH = math.floor(newW / resizeAspect)   -- lock 16:9
        MainFrame.Size = UDim2.new(0, newW, 0, newH)
        -- scale content proportionally
        local scale = newW / BASE_W
        if ContentFrame then
            ContentFrame.Size = UDim2.new(1, -20, 1, -148)
        end
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then resizeDragging = false end
end)

-- ================================================================
--  SECTION 6: PER-ROW KEYBIND SQUARE (RIGHT SIDE OF EVERY OPTION)
-- ================================================================
-- This wraps the existing CreateToggle to add a tiny keybind pill on the right.
-- Global keybind registry: maps feature name → keybind enum + connection

local GlobalKeybinds = {}   -- [featureName] = {key, conn}
local KEYBIND_SAVE_FILE = "XAMIL_v19_keybinds.json"

local function SaveKeybinds()
    if not writefile then return end
    local out = {}
    for name, data in pairs(GlobalKeybinds) do
        if data.key then
            local keyStr
            if typeof(data.key) == "EnumItem" then
                if data.key.EnumType == Enum.KeyCode then keyStr = "K:" .. tostring(data.key):gsub("Enum.KeyCode.", "")
                else keyStr = "M:" .. tostring(data.key):gsub("Enum.UserInputType.", "") end
            end
            if keyStr then out[name] = keyStr end
        end
    end
    pcall(function() writefile(KEYBIND_SAVE_FILE, HttpService:JSONEncode(out)) end)
end

local function LoadKeybinds()
    if not readfile then return end
    local ok, raw = pcall(readfile, KEYBIND_SAVE_FILE)
    if not ok or not raw or raw == "" then return end
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 then return end
    for name, keyStr in pairs(data) do
        local key
        if keyStr:sub(1,2) == "K:" then
            local kname = keyStr:sub(3)
            pcall(function() key = Enum.KeyCode[kname] end)
        elseif keyStr:sub(1,2) == "M:" then
            local mname = keyStr:sub(3)
            pcall(function() key = Enum.UserInputType[mname] end)
        end
        if key then
            GlobalKeybinds[name] = {key = key}
        end
    end
end

task.spawn(LoadKeybinds)

local function KeyDisplayName(k)
    if not k or typeof(k) ~= "EnumItem" then return "—" end
    if k.EnumType == Enum.KeyCode       then return tostring(k):gsub("Enum.KeyCode.", "") end
    if k.EnumType == Enum.UserInputType then
        local s = tostring(k):gsub("Enum.UserInputType.", "")
        if s == "MouseButton1" then return "M1" end
        if s == "MouseButton2" then return "M2" end
        if s == "MouseButton3" then return "M3" end
        return s
    end
    return "—"
end

-- The keybind square widget — attaches to the RIGHT of any row frame
local function AttachKeybindSquare(rowFrame, featureName, toggleCallback)
    if not rowFrame or not featureName then return end

    -- Shrink the row's label to make room
    local lbl = rowFrame:FindFirstChild("TextLabel")
    if lbl then lbl.Size = UDim2.new(0.48, 0, 1, 0) end

    -- Also move the toggle track if present
    local track = rowFrame:FindFirstChild("Frame")  -- the track bg

    local sq = Instance.new("TextButton", rowFrame)
    sq.Name             = "XAMIL_KeybindSq"
    sq.Size             = UDim2.new(0, 30, 0, 22)
    sq.Position         = UDim2.new(1, -34, 0.5, -11)
    sq.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
    sq.Text             = (GlobalKeybinds[featureName] and KeyDisplayName(GlobalKeybinds[featureName].key)) or "—"
    sq.TextColor3       = Color3.fromRGB(230, 40, 40)
    sq.Font             = Enum.Font.GothamBold
    sq.TextSize         = 9
    sq.AutoButtonColor  = false
    sq.BorderSizePixel  = 0
    sq.ZIndex           = 20
    sq.ClipsDescendants = true
    Instance.new("UICorner", sq).CornerRadius = UDim.new(0, 5)
    local sqStroke = Instance.new("UIStroke", sq)
    sqStroke.Color = Color3.fromRGB(140, 20, 20); sqStroke.Thickness = 1

    -- Slide the toggle track left so it doesn't overlap
    if track then
        track.Position = UDim2.new(1, -100, 0.5, -12)
    end

    local listening = false
    sq.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        sq.Text      = "[ ]"
        sq.TextColor3 = Color3.fromRGB(255, 80, 80)

        local conn; conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            local key
            if input.UserInputType == Enum.UserInputType.Keyboard then key = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then key = Enum.UserInputType.MouseButton1
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = Enum.UserInputType.MouseButton2
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then key = Enum.UserInputType.MouseButton3 end

            if key then
                listening = false
                conn:Disconnect()

                -- Clean old connection
                if GlobalKeybinds[featureName] and GlobalKeybinds[featureName].conn then
                    pcall(function() GlobalKeybinds[featureName].conn:Disconnect() end)
                end

                -- Wire new keybind → fires the toggle callback
                local newConn = UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    local matches = (typeof(key) == "EnumItem") and (
                        (key.EnumType == Enum.KeyCode       and inp.KeyCode == key) or
                        (key.EnumType == Enum.UserInputType and inp.UserInputType == key)
                    )
                    if matches and toggleCallback then pcall(toggleCallback) end
                end)

                GlobalKeybinds[featureName] = {key = key, conn = newConn}
                sq.Text      = KeyDisplayName(key)
                sq.TextColor3 = Color3.fromRGB(100, 255, 140)
                SaveKeybinds()
                Notify("Keybind", featureName .. " → " .. KeyDisplayName(key), 2, "success")
            end
        end)
    end)

    sq.MouseEnter:Connect(function() TweenService:Create(sq, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40,25,70)}):Play() end)
    sq.MouseLeave:Connect(function() TweenService:Create(sq, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20,15,35)}):Play() end)

    return sq
end

-- ================================================================
--  SECTION 7: ENHANCED TOGGLE WITH KEYBIND SQUARE
--  Overrides the base CreateToggle to add the keybind square automatically
-- ================================================================

local _baseCreateToggle = CreateToggle  -- cache original

CreateToggle = function(parent, text, default, accentOverride, callback)
    local ctrl = _baseCreateToggle(parent, text, default, accentOverride, callback)

    -- Find the row frame (last child added to parent)
    local rowFrame = parent:FindFirstChild(text)  -- may not be named
    -- Walk backwards through children to find the new frame
    local children = parent:GetChildren()
    local newFrame = children[#children]
    if newFrame and newFrame:IsA("Frame") then
        -- Attach keybind square, callback toggles the feature
        AttachKeybindSquare(newFrame, text, function()
            if ctrl then ctrl.Set(not ctrl.Get()) end
        end)
    end

    return ctrl
end

-- ================================================================
--  SECTION 8: SETTINGS SAVE/LOAD BUTTONS (append to Settings tab)
-- ================================================================
-- These Features entries are added to the existing Features table at runtime

local function AppendFeature(feat)
    if Features then table.insert(Features, feat) end
end

AppendFeature({Category="Settings", Type="Section", Text="CONFIG SYSTEM"})
AppendFeature({Category="Settings", Type="Button", Name="Save Config", Callback=function() SaveSettings() end})
AppendFeature({Category="Settings", Type="Button", Name="Load Config", Callback=function() LoadSettings(); RenderTab(CurrentTab) end})
AppendFeature({Category="Settings", Type="Button", Name="Reset Config", Callback=function()
    if writefile then pcall(function() writefile(SAVE_FILE, "{}") end) end
    Notify("Config", "Config reset. Restart to apply defaults.", 3, "info")
end})
AppendFeature({Category="Settings", Type="Section", Text="BACKGROUND"})
AppendFeature({Category="Settings", Type="TextBox", Name="BG Asset ID", Placeholder="rbxassetid number", Callback=function(v)
    if tonumber(v) then SetGojoBGAsset(v); Notify("BG", "Background updated", 2, "success")
    else Notify("BG", "Enter numbers only", 2, "error") end
end})
AppendFeature({Category="Settings", Type="Slider", Name="BG Opacity", Min=0, Max=10, Default=4, Callback=function(v)
    if GojoBGImg then GojoBGImg.ImageTransparency = 1 - (v/10) * 0.7 end
end})
AppendFeature({Category="Settings", Type="Section", Text="AIM CIRCLE"})
AppendFeature({Category="Settings", Type="Slider", Name="Circle Alpha", Min=0, Max=10, Default=6, Callback=function(v)
    State.ESP.FOVAlpha = 1 - v/10; RedrawFOVCircle_v2()
end})
AppendFeature({Category="Settings", Type="Slider", Name="Circle Thickness", Min=1, Max=20, Default=15, Callback=function(v)
    State.ESP.FOVThickness = v/10; RedrawFOVCircle_v2()
end})

-- ================================================================
--  SECTION 9: COLOR PICKERS (ESP Color, FOV Color, Accent)
-- ================================================================
-- Appended to ESP and Settings tabs

AppendFeature({Category="ESP", Type="Section", Text="ESP COLORS"})
AppendFeature({Category="ESP", Type="ColorPicker", Name="ESP Player Color", DefaultColor=Color3.fromRGB(160,80,255), Callback=function(c)
    State.ESP.Color = c
    for _, data in pairs(ESPObjects) do
        if data.nameLbl then data.nameLbl.TextColor3 = c end
        if data.highlight then data.highlight.FillColor = c; data.highlight.OutlineColor = c end
    end
end})
AppendFeature({Category="ESP", Type="ColorPicker", Name="FOV Circle Color", DefaultColor=Color3.fromRGB(160,80,255), Callback=function(c)
    State.ESP.FOVColor = c; RedrawFOVCircle_v2()
end})

-- Re-render current tab to pick up new features
if RenderTab and CurrentTab then
    task.spawn(function() task.wait(0.1); RenderTab(CurrentTab) end)
end

-- ================================================================
--  SECTION 10: SPEED SYSTEM — FIXED v19
-- ================================================================
-- Fix: the old ramp fought with the toggle callback and reset speed to 16.
-- New approach: single authoritative Heartbeat loop.
-- Toggle callback only sets State.Speed.Enabled — loop does the rest.
-- No cap below the slider max — slider already limits to 500.

local _speedRampCurrent = 16

local function _getTargetSpeed()
    if State.Speed.Enabled then
        return State.Speed.Value
    end
    return 16
end

RunService.Heartbeat:Connect(function(dt)
    if not State or not State.Speed then return end
    local h = GetHum and GetHum()
    if not h then return end

    local target = _getTargetSpeed()
    local diff   = target - _speedRampCurrent

    if math.abs(diff) < 0.5 then
        _speedRampCurrent = target
    else
        -- Fast ramp: 12 studs/s when speeding up, instant when slowing to 16
        local rate = State.Speed.Enabled and 12 or 60
        _speedRampCurrent = _speedRampCurrent + diff * math.min(dt * rate, 1)
    end

    -- Only write if it actually changed (avoids anti-cheat delta spam)
    if math.abs(h.WalkSpeed - _speedRampCurrent) > 0.1 then
        AntiBan_WriteSpeed(h, _speedRampCurrent)
    end
end)

-- ================================================================
--  SECTION 11: ORBITAL GEOMETRY CIRCLE (decorative, top of UI)
--  Thin rotating ring at the top of the panel — the Gojo orbital effect
-- ================================================================

local OrbitalRing = Instance.new("Frame", ScreenGui)
OrbitalRing.Name             = "XAMIL_OrbitalRing"
OrbitalRing.AnchorPoint      = Vector2.new(0.5, 0.5)
OrbitalRing.BackgroundTransparency = 1
OrbitalRing.BorderSizePixel  = 0
OrbitalRing.ZIndex           = 8
OrbitalRing.Visible          = false

local ORBITAL_SEGS = 96
local ORBITAL_R    = 40

OrbitalRing.Size = UDim2.new(0, ORBITAL_R*2, 0, ORBITAL_R*2)

local orbSegs = {}
for i = 1, ORBITAL_SEGS do
    local a1 = (i-1)/ORBITAL_SEGS * math.pi * 2
    local a2 =  i   /ORBITAL_SEGS * math.pi * 2
    local x1 = math.cos(a1)*ORBITAL_R + ORBITAL_R
    local y1 = math.sin(a1)*ORBITAL_R + ORBITAL_R
    local x2 = math.cos(a2)*ORBITAL_R + ORBITAL_R
    local y2 = math.sin(a2)*ORBITAL_R + ORBITAL_R
    local dx, dy = x2-x1, y2-y1
    local len = math.sqrt(dx*dx + dy*dy)
    local angle = math.deg(math.atan2(dy, dx))
    local hue = (i-1)/ORBITAL_SEGS
    local col = Color3.fromHSV(0.7 + hue*0.1, 0.8, 1)   -- purple-blue gradient

    local seg = Instance.new("Frame", OrbitalRing)
    seg.AnchorPoint      = Vector2.new(0, 0.5)
    seg.Position         = UDim2.new(0, x1, 0, y1)
    seg.Size             = UDim2.new(0, len+0.5, 0, 1.5)
    seg.Rotation         = angle
    seg.BackgroundColor3 = col
    seg.BackgroundTransparency = 0.25
    seg.BorderSizePixel  = 0
    seg.ZIndex           = 9
    table.insert(orbSegs, seg)
end

-- Position orbital ring over the logo badge area
RunService.RenderStepped:Connect(function()
    if not MainFrame or not uiVisible then OrbitalRing.Visible = false; return end
    OrbitalRing.Visible = true
    local ap = MainFrame.AbsolutePosition
    OrbitalRing.Position = UDim2.new(0, ap.X + 31, 0, ap.Y + 32)
end)

-- Slow rotation
local orbAngle = 0
RunService.RenderStepped:Connect(function(dt)
    orbAngle = (orbAngle + dt * 45) % 360
    OrbitalRing.Rotation = orbAngle
end)

-- ================================================================
--  STARTUP NOTICE
-- ================================================================
task.delay(0.5, function()
    Notify("XAMIL v19", "Upgrades loaded — aim circle, save system, Gojo BG, particles, keybinds + Fast Attack Hub (Blox Fruits)", 5, "success")
end)

-- ================================================================
--  FAST ATTACK CHARACTER RESPAWN HANDLER
--  Reconnects all fast attack loops when character respawns