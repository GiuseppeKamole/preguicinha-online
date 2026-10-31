-- SeaForge Hub v0.3 | Interface e automacoes para a experiencia propria de demonstracao.
-- Coloque em StarterPlayer > StarterPlayerScripts. Nao usa executor nem explora jogos de terceiros.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("SeaForgeAction", 15)
if not remote then warn("[SeaForge] Instale o script de servidor primeiro.") return end
local world = workspace:WaitForChild("SeaForgeDemoWorld", 15)
if not world then warn("[SeaForge] Mundo de demonstracao ausente.") return end
local mobs = world:WaitForChild("Mobs")
local fruits = world:WaitForChild("Frutas")

local old = player.PlayerGui:FindFirstChild("SeaForgeHub")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(14, 23, 35),
    panel = Color3.fromRGB(25, 38, 57),
    action = Color3.fromRGB(40, 62, 88),
    accent = Color3.fromRGB(48, 188, 211),
    success = Color3.fromRGB(66, 190, 132),
    text = Color3.fromRGB(239, 247, 253),
    secondary = Color3.fromRGB(173, 195, 211),
}
local enabled = {farm=false, quest=false, boss=false, raid=false, fruit=false, esp=false}
local preferredQuest = "Bandido"
local lastRaidRequest = -100
local espObjects = {}
local minimized = false
local refreshToggles = {}

local function ui(class, props, parent)
    local object = Instance.new(class)
    for k, v in pairs(props) do object[k] = v end
    object.Parent = parent
    return object
end
local function rounded(obj, r)
    ui("UICorner", {CornerRadius=UDim.new(0, r or 9)}, obj)
end
local function text(parent, content, size, color, height)
    return ui("TextLabel", {
        Text=content, TextColor3=color or C.text, BackgroundTransparency=1,
        Font=Enum.Font.Gotham, TextSize=size or 13,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
        Size=UDim2.new(1,-8,0,height or 27),
    }, parent)
end
local gui = ui("ScreenGui", {
    Name="SeaForgeHub", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=25,
}, player:WaitForChild("PlayerGui"))
local frame = ui("Frame", {
    Name="Window", Position=UDim2.new(0,24,0.5,-215), Size=UDim2.new(0,340,0,430),
    BackgroundColor3=C.bg, BorderSizePixel=0,
}, gui)
rounded(frame, 13)
local camera = workspace.CurrentCamera
local guiScale = ui("UIScale", {Scale=1}, frame)
local function updateScale()
    camera = workspace.CurrentCamera or camera
    local viewport = camera and camera.ViewportSize or Vector2.new(1200, 700)
    guiScale.Scale = math.clamp(math.min(viewport.X / 390, viewport.Y / 500), 0.65, 1)
end
updateScale()
ui("UIStroke", {Color=C.accent, Thickness=1.5, Transparency=.35}, frame)

local header = ui("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,55)}, frame)
text(header, "  SEAFORGE  |  HUB 0.3", 17, C.accent, 42)
local minimize = ui("TextButton", {
    Text="—", TextColor3=C.text, Font=Enum.Font.GothamBold, TextSize=19,
    Size=UDim2.new(0,39,0,33), Position=UDim2.new(1,-45,0,9),
    BackgroundColor3=C.action,
}, header)
rounded(minimize, 8)

local scroller = ui("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0,
    Position=UDim2.new(0,12,0,58), Size=UDim2.new(1,-24,1,-72),
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=4, ScrollBarImageColor3=C.accent,
}, frame)
ui("UIListLayout", {Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder}, scroller)

local function section(name)
    local lbl = text(scroller, string.upper(name), 12, C.accent, 25)
    lbl.Font = Enum.Font.GothamBold
    return lbl
end
local function button(caption, fn)
    local b = ui("TextButton", {
        Text="  " .. caption, TextColor3=C.text, Font=Enum.Font.GothamMedium,
        TextSize=13, TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundColor3=C.action, Size=UDim2.new(1,-5,0,33),
        BorderSizePixel=0,
    }, scroller)
    rounded(b, 8)
    b.MouseButton1Click:Connect(fn)
    return b
end
local function toggle(label, key)
    local b
    local function refresh()
        b.Text = string.format("  %s %s", enabled[key] and "[ON]" or "[OFF]", label)
        b.BackgroundColor3 = enabled[key] and C.success or C.action
    end
    b = button(label, function()
        enabled[key] = not enabled[key]
        refresh()
    end)
    refresh()
    table.insert(refreshToggles, refresh)
    return b
end

section("Informacoes")
local playerInfo = text(scroller, "Carregando...", 13, C.secondary, 54)
local notification = text(scroller, "Pronto para jogar em seu mundo de teste.", 12, C.secondary, 48)
section("Farm, quests e combate")
toggle("Auto farm | Inimigos da missao", "farm")
toggle("Auto quest | 3 eliminacoes", "quest")
local questButton
questButton = button("Missao preferida: Bandido", function()
    preferredQuest = preferredQuest == "Bandido" and "Pirata" or "Bandido"
    questButton.Text = "  Missao preferida: " .. preferredQuest
end)
toggle("Auto boss | Chefe da Floresta", "boss")
button("Aceitar missao selecionada", function() remote:FireServer("Quest", preferredQuest) end)
button("Ataque manual | inimigo proximo", function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local target, best = nil, 17
    for _, m in ipairs(mobs:GetChildren()) do
        local part = m.PrimaryPart
        if part and m:GetAttribute("Alive") then
            local d = (root.Position - part.Position).Magnitude
            if d < best then target, best = m, d end
        end
    end
    if target then remote:FireServer("Attack", target) end
end)
section("Frutas e raids")
toggle("Auto coleta | Frutas demo", "fruit")
button("Iniciar raid demonstrativa", function()
    remote:FireServer("Raid")
end)
toggle("Auto combater | Raid", "raid")
section("Navegacao")
for _, place in ipairs({"Porto", "Floresta", "Arena"}) do
    button("Viajar para " .. place, function() remote:FireServer("Teleport", place) end)
end
section("Visuais")
toggle("Destaque visual de mobs e frutas", "esp")
button("Desativar todas as automacoes", function()
    for key in pairs(enabled) do enabled[key] = false end
    for _, refresh in ipairs(refreshToggles) do refresh() end
    notification.Text = "Todas as automacoes desativadas."
    -- Character lookup here stays local to the button to stop the last MoveTo.
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local here = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and here then humanoid:MoveTo(here.Position) end
end)

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    scroller.Visible = not minimized
    frame.Size = minimized and UDim2.new(0,340,0,55) or UDim2.new(0,340,0,430)
    minimize.Text = minimized and "+" or "—"
end)

-- Movimento opcional dentro de um mundo do proprio usuario: usa Humanoid:MoveTo.
local function characterParts()
    local ch = player.Character
    return ch and ch:FindFirstChildOfClass("Humanoid"), ch and ch:FindFirstChild("HumanoidRootPart")
end
local function nearestMob(kind, ownerOnly)
    local _, root = characterParts()
    if not root then return nil end
    local best, dist = nil, math.huge
    for _, mob in ipairs(mobs:GetChildren()) do
        if mob:GetAttribute("Alive") and mob:GetAttribute("MobKind") == kind then
            local isRaid = mob:GetAttribute("IsRaid")
            if (ownerOnly and isRaid and mob:GetAttribute("MobOwner") == player.UserId) or
                (not ownerOnly and not isRaid) then
                local part = mob.PrimaryPart
                if part then
                    local d = (root.Position - part.Position).Magnitude
                    if d < dist then best, dist = mob, d end
                end
            end
        end
    end
    return best
end
local function nearestFruit()
    local _, root = characterParts()
    if not root then return nil end
    local best, dist = nil, math.huge
    for _, f in ipairs(fruits:GetChildren()) do
        if f:IsA("BasePart") and not f:GetAttribute("Collected") then
            local d = (root.Position - f.Position).Magnitude
            if d < dist then best, dist = f, d end
        end
    end
    return best
end

local function approach(target, range, action, arg)
    local humanoid, root = characterParts()
    if not humanoid or not root or not target or not target.Parent then return end
    local point = target:IsA("Model") and target.PrimaryPart or target
    if not point then return end
    local dist = (root.Position - point.Position).Magnitude
    if dist > range then
        -- Tenta caminhar; nao teleporta ou ignora colisao do mapa.
        local direction = root.Position - point.Position
        direction = Vector3.new(direction.X, 0, direction.Z)
        if direction.Magnitude < 0.1 then direction = Vector3.new(0, 0, 1) end
        local destination = point.Position + direction.Unit * (range - 3)
        humanoid:MoveTo(Vector3.new(destination.X, root.Position.Y, destination.Z))
    else
        remote:FireServer(action, arg or target)
    end
end

remote.OnClientEvent:Connect(function(kind, message)
    if kind == "Notice" then notification.Text = tostring(message) end
end)

task.spawn(function()
    while gui.Parent do
        local stats = player:FindFirstChild("leaderstats")
        local level = stats and stats:FindFirstChild("Nivel")
        local beli = stats and stats:FindFirstChild("Beli")
        local xp = stats and stats:FindFirstChild("XP")
        local fruitsFound = stats and stats:FindFirstChild("Frutas")
        local quest = player:GetAttribute("QuestKind") or "Nenhuma"
        playerInfo.Text = string.format("Nivel: %s  |  Beli: %s  |  XP: %s  |  Frutas: %s\nMissao: %s (%s/3)  |  Raid: %s",
            tostring(level and level.Value or "-"), tostring(beli and beli.Value or "-"),
            tostring(xp and xp.Value or "-"), tostring(fruitsFound and fruitsFound.Value or "-"), tostring(quest),
            tostring(player:GetAttribute("QuestProgress") or 0),
            tostring(player:GetAttribute("RaidProgress") or "-"))

        if enabled.quest and quest == "Nenhuma" then remote:FireServer("Quest", preferredQuest) end
        if enabled.raid and player:GetAttribute("RaidProgress") ~= "0/3"
            and player:GetAttribute("RaidProgress") ~= "1/3"
            and player:GetAttribute("RaidProgress") ~= "2/3"
            and os.clock() - lastRaidRequest > 16 then
            lastRaidRequest = os.clock()
            remote:FireServer("Raid")
        end
        local raidTarget = enabled.raid and nearestMob("Pirata", true) or nil
        local bossTarget = enabled.boss and nearestMob("Chefe", false) or nil
        local questTarget = enabled.quest and nearestMob(quest ~= "Nenhuma" and quest or preferredQuest, false) or nil
        local farmTarget = enabled.farm and nearestMob(preferredQuest, false) or nil
        local fruitTarget = enabled.fruit and nearestFruit() or nil
        local target = raidTarget or bossTarget or questTarget or farmTarget
        if target then
            approach(target, 14, "Attack", target)
        elseif fruitTarget then
            approach(fruitTarget, 9, "Fruit", fruitTarget)
        end
        task.wait(0.4)
    end
end)

local function removeEsp()
    for _, marker in pairs(espObjects) do
        if marker and marker.Parent then marker:Destroy() end
    end
    table.clear(espObjects)
end
local function updateEsp()
    if not enabled.esp then
        if next(espObjects) then removeEsp() end
        return
    end
    local seen = {}
    local count = 0
    for _, folder in ipairs({mobs, fruits}) do
        for _, item in ipairs(folder:GetChildren()) do
            if count >= 45 then break end
            if (item:IsA("Model") and item:GetAttribute("Alive")) or
                (item:IsA("BasePart") and not item:GetAttribute("Collected")) then
                seen[item] = true
                count += 1
                if not espObjects[item] then
                    local marker = Instance.new("Highlight")
                    marker.Name = "SeaForgeMarker"
                    marker.Adornee = item
                    marker.DepthMode = Enum.HighlightDepthMode.Occluded
                    marker.FillTransparency = 0.85
                    marker.OutlineTransparency = 0
                    marker.OutlineColor = folder == fruits and Color3.fromRGB(245,195,48) or C.accent
                    marker.Parent = gui
                    espObjects[item] = marker
                end
            end
        end
    end
    for item, marker in pairs(espObjects) do
        if not seen[item] or not item.Parent then
            marker:Destroy()
            espObjects[item] = nil
        end
    end
end
task.spawn(function()
    while gui.Parent do
        updateEsp()
        task.wait(1)
    end
    removeEsp()
end)

-- Pequeno suporte para arrastar no PC ou em tela sensivel ao toque.
local dragging = false
local dragStart, startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
        startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
end)

if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
print("[SeaForge v0.3] Interface conectada ao servidor de demonstracao")
