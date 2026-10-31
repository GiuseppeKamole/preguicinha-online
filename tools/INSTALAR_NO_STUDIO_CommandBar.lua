-- SeaForge Hub v0.3: instalador somente para Command Bar do Roblox Studio.
-- Abrir um lugar SEU no Studio; colar e executar TODO este arquivo na Command Bar.
-- Substitui os scripts chamados SeaForgeServer e SeaForgeClient, se ja existirem.
-- Nao usa executor, nao e um carregador para Blox Fruits.
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local serverSource = [======[
-- SeaForge Hub | Servidor v0.3 | Roblox Studio
-- Coloque em ServerScriptService. Projeto original, nao e um exploit do Blox Fruits.
-- Toda recompensa e dano sao validados no servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local WORLD_NAME = "SeaForgeDemoWorld"
local REMOTE_NAME = "SeaForgeAction"
local oldWorld = Workspace:FindFirstChild(WORLD_NAME)
if oldWorld then oldWorld:Destroy() end
local world = Instance.new("Folder")
world.Name = WORLD_NAME
world.Parent = Workspace

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

local function part(name, size, position, color, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or world
    return p
end

local islandPos = {
    Porto = Vector3.new(0, 0, 0),
    Floresta = Vector3.new(110, 0, 0),
    Arena = Vector3.new(220, 0, 0),
}
for name, pos in pairs(islandPos) do
    part(name .. "_Solo", Vector3.new(88, 2, 88), pos, Color3.fromRGB(50, 135, 90))
    local pad = part("Portal_" .. name, Vector3.new(10, 0.7, 10), pos + Vector3.new(0, 1.6, 25), Color3.fromRGB(43, 180, 224))
    pad:SetAttribute("Island", name)
end
part("Ponte_Porto_Floresta", Vector3.new(26, 1, 12), Vector3.new(55, 1, 0), Color3.fromRGB(169, 129, 87))
part("Ponte_Floresta_Arena", Vector3.new(26, 1, 12), Vector3.new(165, 1, 0), Color3.fromRGB(169, 129, 87))
part("Oceano", Vector3.new(350, 1, 140), Vector3.new(108, -7, 0), Color3.fromRGB(43, 102, 182))

local mobs = Instance.new("Folder")
mobs.Name = "Mobs"
mobs.Parent = world
local fruits = Instance.new("Folder")
fruits.Name = "Frutas"
fruits.Parent = world

local MOB_DATA = {
    Bandido = {hp=60, reward=30, xp=16, color=Color3.fromRGB(212, 88, 88), pos=Vector3.new(-15, 3, 0), respawn=6},
    Pirata = {hp=95, reward=48, xp=25, color=Color3.fromRGB(235, 150, 80), pos=Vector3.new(105, 3, -14), respawn=8},
    Chefe = {hp=380, reward=350, xp=160, color=Color3.fromRGB(174, 94, 225), pos=Vector3.new(128, 5, 12), respawn=24},
}
local mobSequence = 0
local raidState = {}
local lastAction = {}
local playerQuest = {}
local lastRaidStart = {}

local function notify(player, msg)
    remote:FireClient(player, "Notice", msg)
end

local function makeMob(kind, overridePos, owner)
    local definition = MOB_DATA[kind]
    if not definition then return nil end
    mobSequence += 1
    local model = Instance.new("Model")
    model.Name = kind .. "_" .. tostring(mobSequence)
    model:SetAttribute("MobKind", kind)
    model:SetAttribute("Health", definition.hp)
    model:SetAttribute("MaxHealth", definition.hp)
    model:SetAttribute("MobOwner", owner and owner.UserId or 0)
    model:SetAttribute("Alive", true)
    model:SetAttribute("IsRaid", owner ~= nil)
    local root = part("HumanoidRootPart", Vector3.new(5, kind == "Chefe" and 9 or 6, 5),
        overridePos or definition.pos, definition.color, model)
    root.CanCollide = true
    model.PrimaryPart = root
    model.Parent = mobs
    local labelGui = Instance.new("BillboardGui")
    labelGui.Name = "HealthLabel"
    labelGui.AlwaysOnTop = false
    labelGui.Size = UDim2.fromOffset(138, 34)
    labelGui.StudsOffsetWorldSpace = Vector3.new(0, kind == "Chefe" and 7 or 5, 0)
    labelGui.Parent = root
    local status = Instance.new("TextLabel")
    status.Name = "Text"
    status.Size = UDim2.fromScale(1, 1)
    status.BackgroundTransparency = 0.30
    status.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.TextScaled = true
    status.Font = Enum.Font.GothamBold
    status.Text = kind .. " " .. tostring(definition.hp) .. " HP"
    status.Parent = labelGui
    return model
end

local function spawnFruit(name, at)
    local p = part(name .. "_Fruit", Vector3.new(3, 3, 3), at, Color3.fromRGB(255, 213, 75), fruits)
    p.Shape = Enum.PartType.Ball
    p:SetAttribute("Fruit", name)
    p:SetAttribute("Collected", false)
    p:SetAttribute("SpawnX", at.X)
    p:SetAttribute("SpawnY", at.Y)
    p:SetAttribute("SpawnZ", at.Z)
    return p
end

local function createFreshMob(kind)
    local active = 0
    for _, m in ipairs(mobs:GetChildren()) do
        if m:GetAttribute("MobKind") == kind and not m:GetAttribute("IsRaid") and m:GetAttribute("Alive") then
            active += 1
        end
    end
    if active < (kind == "Chefe" and 1 or 3) then
        local data = MOB_DATA[kind]
        local idx = active + 1
        makeMob(kind, data.pos + Vector3.new((idx - 2) * 10, 0, 0))
    end
end

for _, kind in ipairs({"Bandido", "Pirata", "Chefe"}) do
    for _ = 1, (kind == "Chefe" and 1 or 3) do createFreshMob(kind) end
end
spawnFruit("Demo", Vector3.new(-29, 3, 20))
spawnFruit("Estrela", Vector3.new(87, 3, 22))

local function getRoot(player)
    local char = player.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function distance(root, target)
    if not root or not target then return math.huge end
    return (root.Position - target.Position).Magnitude
end

local function addRewards(player, coins, xp)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end
    local money, level, experience = stats:FindFirstChild("Beli"), stats:FindFirstChild("Nivel"), stats:FindFirstChild("XP")
    if not money or not level or not experience then return end
    money.Value += coins
    experience.Value += xp
    while experience.Value >= (level.Value * 60) do
        experience.Value -= level.Value * 60
        level.Value += 1
        notify(player, "Subiu de nivel! Nivel " .. tostring(level.Value))
    end
end

local function updateQuest(player, kind)
    local quest = playerQuest[player]
    if not quest or quest.kind ~= kind then return end
    quest.progress += 1
    player:SetAttribute("QuestProgress", quest.progress)
    if quest.progress >= quest.goal then
        addRewards(player, 180, 80)
        notify(player, "Missao concluida! +180 Beli, +80 XP")
        playerQuest[player] = nil
        player:SetAttribute("QuestKind", "Nenhuma")
        player:SetAttribute("QuestProgress", 0)
    end
end

local function onMobDefeated(player, model)
    local kind = model:GetAttribute("MobKind")
    local raid = model:GetAttribute("IsRaid")
    local data = MOB_DATA[kind]
    model:SetAttribute("Alive", false)
    if not raid then
        addRewards(player, data.reward, data.xp)
        updateQuest(player, kind)
        notify(player, kind .. " derrotado! +" .. tostring(data.reward) .. " Beli")
    else
        local st = raidState[player]
        if st then
            st.kills += 1
            if st.kills >= st.goal then
                raidState[player] = nil
                addRewards(player, 800, 300)
                player:SetAttribute("RaidProgress", "Concluida")
                notify(player, "Raid concluida! +800 Beli, +300 XP")
            else
                player:SetAttribute("RaidProgress", tostring(st.kills) .. "/" .. tostring(st.goal))
            end
        end
    end
    task.delay(1, function()
        if model and model.Parent then model:Destroy() end
    end)
    if not raid then
        task.delay(data.respawn, function()
            if world.Parent then createFreshMob(kind) end
        end)
    end
end

remote.OnServerEvent:Connect(function(player, action, data)
    if type(action) ~= "string" then return end
    local now = os.clock()
    lastAction[player] = lastAction[player] or {}
    local cooldown = action == "Attack" and 0.35 or 0.4
    if now - (lastAction[player][action] or -100) < cooldown then return end
    lastAction[player][action] = now
    local root = getRoot(player)
    if not root then return end

    if action == "Attack" then
        if typeof(data) ~= "Instance" or not data:IsA("Model") or data.Parent ~= mobs then return end
        if not data:GetAttribute("Alive") then return end
        if data:GetAttribute("IsRaid") and data:GetAttribute("MobOwner") ~= player.UserId then return end
        local mobRoot = data.PrimaryPart
        if not mobRoot or distance(root, mobRoot) > 17 then return end
        local currentHP = data:GetAttribute("Health")
        if type(currentHP) ~= "number" or currentHP <= 0 then return end
        local hp = math.max(0, currentHP - 22)
        data:SetAttribute("Health", hp)
        local billboard = mobRoot:FindFirstChild("HealthLabel")
        local info = billboard and billboard:FindFirstChild("Text")
        if info then info.Text = tostring(data:GetAttribute("MobKind")) .. " " .. tostring(hp) .. " HP" end
        if hp <= 0 then onMobDefeated(player, data) end
    elseif action == "Quest" then
        if data ~= "Pirata" and data ~= "Bandido" then return end
        local kind = data
        playerQuest[player] = {kind=kind, goal=3, progress=0}
        player:SetAttribute("QuestKind", kind)
        player:SetAttribute("QuestProgress", 0)
        notify(player, "Missao iniciada: derrote 3 " .. kind .. "(s)")
    elseif action == "Teleport" then
        if type(data) ~= "string" or not islandPos[data] then return end
        -- Teleporte autorizado e restrito aos pontos deste proprio jogo.
        root.CFrame = CFrame.new(islandPos[data] + Vector3.new(0, 6, 25))
        notify(player, "Viagem: " .. data)
    elseif action == "Fruit" then
        if typeof(data) ~= "Instance" or not data:IsA("BasePart") or data.Parent ~= fruits then return end
        if data:GetAttribute("Collected") or distance(root, data) > 12 then return end
        data:SetAttribute("Collected", true)
        local name = data:GetAttribute("Fruit") or "Fruta"
        local originalPosition = Vector3.new(
            data:GetAttribute("SpawnX"), data:GetAttribute("SpawnY"), data:GetAttribute("SpawnZ"))
        local stats = player:FindFirstChild("leaderstats")
        local collected = stats and stats:FindFirstChild("Frutas")
        if collected then collected.Value += 1 end
        addRewards(player, 110, 40)
        notify(player, "Fruta " .. name .. " coletada! +110 Beli")
        data:Destroy()
        task.delay(32, function()
            if world.Parent then spawnFruit(name, originalPosition) end
        end)
    elseif action == "Raid" then
        if raidState[player] then notify(player, "Voce ja possui uma raid ativa") return end
        if now - (lastRaidStart[player] or -100) < 15 then
            notify(player, "Aguarde 15 segundos antes da proxima raid")
            return
        end
        lastRaidStart[player] = now
        player:SetAttribute("RaidProgress", "0/3")
        raidState[player] = {kills=0, goal=3}
        root.CFrame = CFrame.new(islandPos.Arena + Vector3.new(0, 6, 25))
        for i = 1, 3 do
            makeMob("Pirata", islandPos.Arena + Vector3.new(-15 + i * 12, 4, -12), player)
        end
        notify(player, "Raid iniciada: derrote 3 Piratas na Arena")
    end
end)

local function setupPlayer(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    for _, entry in ipairs({{"Nivel", 1}, {"Beli", 0}, {"XP", 0}, {"Frutas", 0}}) do
        local value = Instance.new("IntValue")
        value.Name, value.Value = entry[1], entry[2]
        value.Parent = stats
    end
    player:SetAttribute("QuestKind", "Nenhuma")
    player:SetAttribute("QuestProgress", 0)
    player:SetAttribute("RaidProgress", "Nao iniciada")
    local function onCharacter(character)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if root then root.CFrame = CFrame.new(islandPos.Porto + Vector3.new(0, 6, 25)) end
    end
    player.CharacterAdded:Connect(onCharacter)
    if player.Character then task.defer(onCharacter, player.Character) end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, existing in ipairs(Players:GetPlayers()) do setupPlayer(existing) end

Players.PlayerRemoving:Connect(function(player)
    raidState[player], playerQuest[player], lastAction[player], lastRaidStart[player] = nil, nil, nil, nil
    for _, mob in ipairs(mobs:GetChildren()) do
        if mob:GetAttribute("MobOwner") == player.UserId then mob:Destroy() end
    end
end)

print("[SeaForge v0.3] Servidor pronto | farm/quest/boss/raid/frutas/teleporte")
]======]
local clientSource = [======[
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
]======]
local function install(parent, name, kind, source)
    local previous = parent:FindFirstChild(name)
    if previous then
        assert(previous.ClassName == kind, "Nome ocupado: " .. name)
        previous:Destroy()
    end
    local scriptObject = Instance.new(kind)
    scriptObject.Name = name
    scriptObject.Source = source
    scriptObject.Parent = parent
end
install(ServerScriptService, "SeaForgeServer", "Script", serverSource)
install(StarterPlayerScripts, "SeaForgeClient", "LocalScript", clientSource)
print("[SeaForge v0.3] Instalacao concluida. Use Play (F5) na SUA experiencia.")
