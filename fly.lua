local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local flying = false
local speed = 120
local speedOn = false
local walkspeed = 50
local fullbright = false
local oldLighting = {}

local char, root, humanoid
local bv, bg

local upBtn, downBtn -- кнопки для вертикального движения на мобильном
local moveUp, moveDown = false, false

-- 👤 Настройка персонажа
local function setup()
    char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end
setup()
player.CharacterAdded:Connect(setup)

-- 🌞 FullBright
local function enableFullbright()
    oldLighting.Brightness = Lighting.Brightness
    oldLighting.Ambient = Lighting.Ambient
    oldLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    oldLighting.FogEnd = Lighting.FogEnd
    oldLighting.GlobalShadows = Lighting.GlobalShadows

    Lighting.Brightness = 3
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end

local function disableFullbright()
    for i,v in pairs(oldLighting) do
        Lighting[i] = v
    end
end

-- 💤 Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
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
frame.Size = UDim2.new(0,220,0,180)
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

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1,0,0,30)
speedLabel.Position = UDim2.new(0,0,0,120)
speedLabel.Text = "Speed: "..walkspeed
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)

local plusBtn = makeButton("+",150)
local minusBtn = makeButton("-",190)

-- ❌ Close
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)

-- 🖱 Перетаскивание GUI
local dragging = false
local dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 🔹 GUI кнопки
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
plusBtn.MouseButton1Click:Connect(function()
    walkspeed += 5
    speedLabel.Text = "Speed: "..walkspeed
    if speedOn then humanoid.WalkSpeed = walkspeed end
end)
minusBtn.MouseButton1Click:Connect(function()
    walkspeed = math.max(5, walkspeed - 5)
    speedLabel.Text = "Speed: "..walkspeed
    if speedOn then humanoid.WalkSpeed = walkspeed end
end)
closeBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() flyBtn.Text = "Fly: OFF" end
    speedOn = false
    humanoid.WalkSpeed = 16
    speedBtn.Text = "Speed: OFF"
    if fullbright then disableFullbright() fullbright = false fbBtn.Text = "FullBright: OFF" end
    frame.Visible = false
end)

-- 🚀 Fly с камерой (ПК + телефон)
RunService.RenderStepped:Connect(function()
    if not flying then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero

    -- движение вперед/назад/влево/вправо по камере
    local move = humanoid.MoveDirection
    if move.Magnitude > 0 then
        dir += (cam.CFrame:VectorToWorldSpace(move)).Unit
    end

    -- вертикально ПК
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

    if dir.Magnitude > 0 then dir = dir.Unit end
    if bv and bg then
        bv.Velocity = dir * speed
        bg.CFrame = cam.CFrame
    end
end)