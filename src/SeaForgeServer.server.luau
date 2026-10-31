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
