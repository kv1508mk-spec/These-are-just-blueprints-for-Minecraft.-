local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local flying = false
local speed = 120
local speedOn = false
local walkspeed = 50
local fullbright = false
local old = {}

local char, root, humanoid
local bv, bg

-- 👤 персонаж
local function setup()
    char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end
setup()
player.CharacterAdded:Connect(setup)

-- 🌞 FullBright
local function enableFullbright()
    old.Brightness = Lighting.Brightness
    old.Ambient = Lighting.Ambient
    old.OutdoorAmbient = Lighting.OutdoorAmbient
    old.FogEnd = Lighting.FogEnd
    old.GlobalShadows = Lighting.GlobalShadows

    Lighting.Brightness = 3
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end

local function disableFullbright()
    for i,v in pairs(old) do
        Lighting[i] = v
    end
end

-- 👻 ноуклип
RunService.Stepped:Connect(function()
    if flying and char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end)

-- 🪽 Fly
local function startFly()
    flying = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Parent = root

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.P = 10000
    bg.Parent = root
end

local function stopFly()
    flying = false
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

-- 🎛 GUI
local screen = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0,220,0,140)
frame.Position = UDim2.new(0,20,0,100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function makeButton(text, y)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Position = UDim2.new(0,0,0,y)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    return btn
end

local flyBtn = makeButton("Fly: OFF",0)
local fbBtn = makeButton("FullBright: OFF",40)
local speedBtn = makeButton("Speed: OFF",80)

-- GUI кнопки
flyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() flyBtn.Text = "Fly: OFF"
    else startFly() flyBtn.Text = "Fly: ON" end
end)

fbBtn.MouseButton1Click:Connect(function()
    fullbright = not fullbright
    if fullbright then enableFullbright() fbBtn.Text = "FullBright: ON"
    else disableFullbright() fbBtn.Text = "FullBright: OFF" end
end)

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    humanoid.WalkSpeed = speedOn and walkspeed or 16
    speedBtn.Text = speedOn and "Speed: ON" or "Speed: OFF"
end)

-- 🎮 клавиши
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.H then
        if flying then stopFly() else startFly() end
        flyBtn.Text = flying and "Fly: ON" or "Fly: OFF"
    end

    if input.KeyCode == Enum.KeyCode.Y then
        fullbright = not fullbright
        if fullbright then enableFullbright() else disableFullbright() end
        fbBtn.Text = fullbright and "FullBright: ON" or "FullBright: OFF"
    end

    if input.KeyCode == Enum.KeyCode.K then
        speedOn = not speedOn
        humanoid.WalkSpeed = speedOn and walkspeed or 16
        speedBtn.Text = speedOn and "Speed: ON" or "Speed: OFF"
    end

    if input.KeyCode == Enum.KeyCode.LeftControl then
        frame.Visible = not frame.Visible
    end
end)

-- 🚀 ИДЕАЛЬНЫЙ ПК ФЛАЙ
RunService.RenderStepped:Connect(function()
    if not flying then return end

    local cam = workspace.CurrentCamera
    local dir = Vector3.zero

    -- ВПЕРЁД / НАЗАД (исправлено)
    if UIS:IsKeyDown(Enum.KeyCode.W) then
        dir += cam.CFrame.LookVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.S) then
        dir += -cam.CFrame.LookVector
    end

    -- ВЛЕВО / ВПРАВО (исправлено)
    if UIS:IsKeyDown(Enum.KeyCode.A) then
        dir += -cam.CFrame.RightVector
    end
    if UIS:IsKeyDown(Enum.KeyCode.D) then
        dir += cam.CFrame.RightVector
    end

    -- ВВЕРХ / ВНИЗ
    if UIS:IsKeyDown(Enum.KeyCode.Space) then
        dir += Vector3.new(0,1,0)
    end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
        dir += Vector3.new(0,-1,0)
    end

    -- нормализация
    if dir.Magnitude > 0 then
        dir = dir.Unit
    end

    if bv and bg then
        bv.Velocity = dir * speed
        bg.CFrame = cam.CFrame
    end
end)