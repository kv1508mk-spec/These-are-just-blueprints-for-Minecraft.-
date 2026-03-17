local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flying = false
local speed = 120 -- 🚀 меняй

local char, root, humanoid
local bv, bg

local function setup()
char = player.Character or player.CharacterAdded:Wait()
root = char:WaitForChild("HumanoidRootPart")
humanoid = char:WaitForChild("Humanoid")
end

setup()
player.CharacterAdded:Connect(setup)

-- 👻 постоянный ноуклип
RunService.Stepped:Connect(function()
if flying then
for _, p in pairs(char:GetDescendants()) do
if p:IsA("BasePart") then
p.CanCollide = false
end
end
end
end)

-- 🪽 старт
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

-- 🪶 стоп
local function stopFly()
flying = false
humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

if bv then bv:Destroy() end
if bg then bg:Destroy() end
end

-- 🎮 H toggle
UIS.InputBegan:Connect(function(input, gpe)
if gpe then return end

if input.KeyCode == Enum.KeyCode.H then
if flying then stopFly() else startFly() end
end
end)

-- 🚀 управление (ПРАВИЛЬНОЕ)
RunService.RenderStepped:Connect(function()
if not flying then return end

local cam = workspace.CurrentCamera

local dir = Vector3.zero

if UIS:IsKeyDown(Enum.KeyCode.W) then
dir += cam.CFrame.LookVector
end
if UIS:IsKeyDown(Enum.KeyCode.S) then
dir -= cam.CFrame.LookVector
end
if UIS:IsKeyDown(Enum.KeyCode.A) then
dir -= cam.CFrame.RightVector
end
if UIS:IsKeyDown(Enum.KeyCode.D) then
dir += cam.CFrame.RightVector
end

-- вверх/вниз
if UIS:IsKeyDown(Enum.KeyCode.Space) then
dir += Vector3.new(0,1,0)
end
if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
dir -= Vector3.new(0,1,0)
end

if dir.Magnitude > 0 then
dir = dir.Unit
end

bv.Velocity = dir * speed
bg.CFrame = cam.CFrame
end)