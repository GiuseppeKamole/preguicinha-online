-- SeaForge Hub | cliente local 0.5.0
-- Interface informativa para Roblox; nenhuma automacao de jogos de terceiros.
-- Uso por sua conta e risco em clientes de terceiros. Nao requer key.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then
    warn("[SeaForge] LocalPlayer indisponivel: execute em contexto de cliente.")
    return
end

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("[SeaForge] PlayerGui nao encontrado.")
    return
end

local previous = playerGui:FindFirstChild("SeaForgeClientPanel")
if previous then previous:Destroy() end

local function new(className, properties, parent)
    local object = Instance.new(className)
    for name, value in pairs(properties or {}) do
        object[name] = value
    end
    if parent then object.Parent = parent end
    return object
end

local theme = {
    bg = Color3.fromRGB(17, 21, 32),
    card = Color3.fromRGB(31, 38, 56),
    line = Color3.fromRGB(53, 63, 84),
    text = Color3.fromRGB(243, 246, 250),
    muted = Color3.fromRGB(176, 187, 207),
    accent = Color3.fromRGB(75, 177, 210)
}

local gui = new("ScreenGui", {
    Name = "SeaForgeClientPanel",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local viewportX = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize.X or 1200
local panelWidth = math.max(270, math.min(365, viewportX - 24))
local panel = new("Frame", {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(panelWidth, 425),
    BackgroundColor3 = theme.bg,
    BorderSizePixel = 0
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 14)}, panel)
new("UIStroke", {Color = theme.line, Thickness = 1}, panel)

local header = new("Frame", {
    Name = "Cabecalho",
    Size = UDim2.new(1, 0, 0, 57),
    BackgroundTransparency = 1
}, panel)

-- Permite arrastar o painel por mouse ou toque, sem acessos de executor.
local dragging, trackedInput, dragStart, startPosition = false, nil, nil, nil
local dragInputEnded = nil
header.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    dragging, dragStart, startPosition = true, input.Position, panel.Position
    if dragInputEnded then dragInputEnded:Disconnect() end
    dragInputEnded = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
    end)
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        trackedInput = input
    end
end)
local inputConnection = UserInputService.InputChanged:Connect(function(input)
    if not dragging or not trackedInput or input ~= trackedInput then return end
    local delta = input.Position - dragStart
    panel.Position = UDim2.new(
        startPosition.X.Scale, startPosition.X.Offset + delta.X,
        startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
    )
end)

new("TextLabel", {
    Text = "SEAFORGE HUB",
    Size = UDim2.new(1, -100, 0, 30),
    Position = UDim2.fromOffset(17, 7),
    TextColor3 = theme.text,
    TextSize = 19,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1
}, header)

new("TextLabel", {
    Text = "CLIENTE v0.5  |  SEM KEY",
    Size = UDim2.new(1, -100, 0, 17),
    Position = UDim2.fromOffset(17, 32),
    TextColor3 = theme.muted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1
}, header)

local bubble = new("TextButton", {
    Name = "Reabrir",
    Visible = false,
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 12, 0.5, 0),
    Size = UDim2.fromOffset(102, 42),
    BackgroundColor3 = theme.accent,
    TextColor3 = theme.bg,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    Text = "SEAFORGE",
    BorderSizePixel = 0
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, bubble)

local function headerButton(label, offset, callback)
    local b = new("TextButton", {
        Text = label,
        Position = UDim2.new(1, offset, 0, 12),
        Size = UDim2.fromOffset(32, 31),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = theme.text,
        BackgroundColor3 = theme.card,
        BorderSizePixel = 0
    }, header)
    new("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local alive = true
local updates
headerButton("_", -82, function()
    panel.Visible = false
    bubble.Visible = true
end)
headerButton("X", -43, function()
    alive = false
    if updates then updates:Disconnect() end
    gui:Destroy()
end)

bubble.MouseButton1Click:Connect(function()
    panel.Visible = true
    bubble.Visible = false
end)

new("Frame", {
    Position = UDim2.fromOffset(0, 56),
    Size = UDim2.new(1, 0, 0, 1),
    BorderSizePixel = 0,
    BackgroundColor3 = theme.line
}, panel)

local content = new("ScrollingFrame", {
    Name = "Conteudo",
    Position = UDim2.fromOffset(12, 67),
    Size = UDim2.new(1, -24, 1, -79),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = theme.accent,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, panel)
new("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
}, content)

local function heading(text)
    return new("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -8, 0, 26),
        Font = Enum.Font.GothamBold,
        TextColor3 = theme.accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    }, content)
end

local function infoLabel(text, height)
    local lbl = new("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -8, 0, height or 28),
        BackgroundColor3 = theme.card,
        TextColor3 = theme.text,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0
    }, content)
    new("UICorner", {CornerRadius = UDim.new(0, 6)}, lbl)
    new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8)}, lbl)
    return lbl
end

local function action(label, callback)
    local btn = new("TextButton", {
        Text = label,
        Size = UDim2.new(1, -8, 0, 35),
        BorderSizePixel = 0,
        BackgroundColor3 = theme.card,
        TextColor3 = theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13
    }, content)
    new("UICorner", {CornerRadius = UDim.new(0, 7)}, btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

heading("INFORMACOES DO JOGADOR")
local stats = infoLabel("Carregando informacoes...", 89)
local state = infoLabel("Painel carregado. Nenhuma automacao ativada.", 37)

local function valueOf(folder, options)
    if not folder then return nil end
    for _, name in ipairs(options) do
        local v = folder:FindFirstChild(name)
        if v and v:IsA("ValueBase") then return tostring(v.Value) end
    end
    return nil
end

local function getStat(names)
    return valueOf(player:FindFirstChild("leaderstats"), names)
        or valueOf(player:FindFirstChild("Data"), names)
        or valueOf(player:FindFirstChild("Stats"), names)
        or "n/d"
end

heading("CONFIGURACOES LOCAIS")
local oldFov = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70
local fovModified = false
local originalShadows = Lighting.GlobalShadows
local postEffects = {}
local lowGraphics = false

local function restoreVisuals()
    if lowGraphics then
        Lighting.GlobalShadows = originalShadows
        for effect, wasEnabled in pairs(postEffects) do
            if effect and effect.Parent then
                effect.Enabled = wasEnabled
            end
        end
        postEffects = {}
        lowGraphics = false
    end
    if fovModified then
        local camera = Workspace.CurrentCamera
        if camera then camera.FieldOfView = oldFov end
        fovModified = false
    end
end


local function setFov(value)
    local cam = Workspace.CurrentCamera
    if cam then
        cam.FieldOfView = value
        fovModified = true
        state.Text = "  Campo de visao local: " .. tostring(value)
    end
end

action("Campo de visao: 70", function() setFov(70) end)
action("Campo de visao: 90", function() setFov(90) end)
action("Restaurar FOV inicial", function() setFov(oldFov) end)

action("Alternar efeitos visuais (local)", function()
    lowGraphics = not lowGraphics
    if lowGraphics then
        originalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                postEffects[effect] = effect.Enabled
                effect.Enabled = false
            end
        end
    else
        Lighting.GlobalShadows = originalShadows
        for effect, wasEnabled in pairs(postEffects) do
            if effect and effect.Parent then effect.Enabled = wasEnabled end
        end
        postEffects = {}
    end
    state.Text = lowGraphics and "  Efeitos locais reduzidos." or "  Efeitos locais restaurados."
end)

heading("SOBRE")
infoLabel("Painel cliente informativo. Sem Auto Farm, Auto Boss, Auto Quest ou alteracoes no servidor de outros jogos.", 72)
action("Restaurar aparencia original", function()
    restoreVisuals()
    state.Text = "  Aparencia local restaurada."
end)

local frameCount = 0
local frameTime = 0
updates = RunService.RenderStepped:Connect(function(dt)
    if not alive or not gui.Parent then return end
    frameCount = frameCount + 1
    frameTime = frameTime + dt
    if frameTime < 0.5 then return end
    local camera = Workspace.CurrentCamera
    if camera then
        local view = camera.ViewportSize
        local desiredWidth = math.min(365, math.max(250, view.X - 24))
        local desiredHeight = math.min(425, math.max(245, view.Y - 24))
        if panel.Size.X.Offset ~= desiredWidth or panel.Size.Y.Offset ~= desiredHeight then
            panel.Size = UDim2.fromOffset(desiredWidth, desiredHeight)
        end
    end
    local fps = frameCount / math.max(frameTime, 0.001)
    frameCount, frameTime = 0, 0

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hp = hum and string.format("%d/%d", hum.Health, hum.MaxHealth) or "n/d"
    local pos = root and string.format("%.0f, %.0f, %.0f", root.Position.X, root.Position.Y, root.Position.Z) or "n/d"

    stats.Text = string.format(
        "  Usuario: %s  |  FPS: %.0f\n  Level: %s  |  Beli: %s  |  Fragmentos: %s\n  HP: %s  |  Posicao: %s",
        player.Name, fps, getStat({"Level", "Lv"}),
        getStat({"Beli", "Money", "Cash"}),
        getStat({"Fragments", "Fragmentos"}),
        hp, pos
    )
end)

gui.Destroying:Connect(function()
    alive = false
    if updates then updates:Disconnect() end
    if inputConnection then inputConnection:Disconnect() end
    if dragInputEnded then dragInputEnded:Disconnect() end
    restoreVisuals()
end)
print("[SeaForge] Painel cliente v0.5 iniciado.")
