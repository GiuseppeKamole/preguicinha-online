-- SeaForge Hub v1.2 (movimento aereo e entrada de ataque experimental)
-- Implementacao original, sem codigo protegido, sem bypass de anticheat.
-- Automacoes de CLIENTE: dependem de objetos replicados, regras do servidor e do executor.
-- IMPORTANTE: Nao testado no Blox Fruits. Automacoes podem nao funcionar ou causar sancoes.
-- Pode ser carregado como Lua local no cliente. Nao ha garantia de compatibilidade.

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local Workspace = game:GetService('Workspace')
local Lighting = game:GetService('Lighting')
local UIS = game:GetService('UserInputService')
local LP = Players.LocalPlayer
if not LP then error('[SeaForge] Necessario contexto cliente') end
local PG = LP:WaitForChild('PlayerGui', 10)
if not PG then error('[SeaForge] PlayerGui indisponivel') end

-- Encerrar instancias anteriores (incluindo UI anterior).
local env
pcall(function() env = getgenv() end)
env = env or _G
if type(env.SeaForgeShutdown) == 'function' then pcall(env.SeaForgeShutdown) end
local oldGui = PG:FindFirstChild('SeaForgeClientPanel')
if oldGui then oldGui:Destroy() end

local alive = true
local flags = { farm=false, quest=false, boss=false, raid=false, fruit=false, esp=false, low=false, fly=true, click=true }
local settings = { radius=450, approach=8, raidType='Flame', targetBoss=nil, hoverHeight=5, flySpeed=160, attackDelay=0.28 }
local connections = {}
local refreshToggles = {}
local visualCache = {}
local marks = {}
local lastQuestAttempt = 0
local lastFruitScan = 0
local currentTarget = nil
local currentFruit = nil
local statusText = 'Inicializado. Automacoes desligadas.'
local statusAt = 0
local debugLines = {}
local reportBuilder
local stopMovement
local stats, stateLabel
local originalFov = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70
local initialShadows = Lighting.GlobalShadows
local changedEffects = {}

local function log(s)
    statusText = tostring(s)
    statusAt = os.clock()
    debugLines[#debugLines + 1] = tostring(s)
    if #debugLines > 60 then table.remove(debugLines, 1) end
    print('[SeaForge] ' .. statusText)
    if stateLabel and stateLabel.Parent then stateLabel.Text = '  ' .. statusText end
end

local function connect(signal, handler)
    local c = signal:Connect(handler)
    table.insert(connections, c)
    return c
end

local function make(kind, props, parent)
    local obj = Instance.new(kind)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local theme = {
    bg=Color3.fromRGB(16,21,31), card=Color3.fromRGB(30,39,56),
    muted=Color3.fromRGB(168,181,201), text=Color3.fromRGB(241,247,251),
    accent=Color3.fromRGB(75,177,210), border=Color3.fromRGB(55,70,90),
    on=Color3.fromRGB(36,96,72)
}
local gui = make('ScreenGui', { Name='SeaForgeClientPanel', ResetOnSpawn=false,
    IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling }, PG)
local panel = make('Frame', { Name='Panel', Position=UDim2.fromScale(0.5,0.5),
    AnchorPoint=Vector2.new(0.5,0.5), Size=UDim2.fromOffset(363,450),
    BackgroundColor3=theme.bg, BorderSizePixel=0 }, gui)
make('UICorner',{CornerRadius=UDim.new(0,12)},panel)
make('UIStroke',{Color=theme.border,Thickness=1},panel)
local header = make('Frame',{Size=UDim2.new(1,0,0,54),BackgroundTransparency=1},panel)
make('TextLabel',{Text='SEAFORGE HUB  v1.2',Size=UDim2.new(1,-102,0,26),
    Position=UDim2.fromOffset(14,5),Font=Enum.Font.GothamBold,TextSize=17,
    TextColor3=theme.text,TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1},header)
make('TextLabel',{Text='Original  |  Experimental  |  Sem key',Size=UDim2.new(1,-102,0,17),
    Position=UDim2.fromOffset(14,30),Font=Enum.Font.Gotham,TextSize=10,
    TextColor3=theme.muted,TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1},header)
local collapse = make('TextButton',{Text='_',Size=UDim2.fromOffset(32,30),
    Position=UDim2.new(1,-78,0,11),Font=Enum.Font.GothamBold,TextSize=17,
    TextColor3=theme.text,BackgroundColor3=theme.card,BorderSizePixel=0},header)
local close = make('TextButton',{Text='X',Size=UDim2.fromOffset(32,30),
    Position=UDim2.new(1,-39,0,11),Font=Enum.Font.GothamBold,TextSize=15,
    TextColor3=theme.text,BackgroundColor3=theme.card,BorderSizePixel=0},header)
make('UICorner',{CornerRadius=UDim.new(0,6)},collapse)
make('UICorner',{CornerRadius=UDim.new(0,6)},close)
local bubble = make('TextButton',{Name='Reabrir',Visible=false,
    Text='SEAFORGE',Size=UDim2.fromOffset(105,38),
    Position=UDim2.new(0,10,0.5,-19),BackgroundColor3=theme.accent,
    TextColor3=theme.bg,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0},gui)
make('UICorner',{CornerRadius=UDim.new(0,9)},bubble)
local scroll = make('ScrollingFrame',{Name='Controles',Position=UDim2.fromOffset(10,62),
    Size=UDim2.new(1,-20,1,-74),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    CanvasSize=UDim2.fromOffset(0,0),BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=theme.accent},panel)
make('UIListLayout',{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},scroll)

local function section(label)
    make('TextLabel',{Text=label,Size=UDim2.new(1,-9,0,25),TextSize=12,
        Font=Enum.Font.GothamBold,TextColor3=theme.accent,
        TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1},scroll)
end
local function label(text,height)
    local t=make('TextLabel',{Text='  '..text,Size=UDim2.new(1,-10,0,height or 30),
        TextSize=12,Font=Enum.Font.Gotham,TextColor3=theme.text,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
        BackgroundColor3=theme.card,BorderSizePixel=0},scroll)
    make('UICorner',{CornerRadius=UDim.new(0,7)},t)
    return t
end
local function button(text,cb)
    local b=make('TextButton',{Text=text,Size=UDim2.new(1,-10,0,35),
        Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=theme.text,
        BackgroundColor3=theme.card,BorderSizePixel=0},scroll)
    make('UICorner',{CornerRadius=UDim.new(0,7)},b)
    connect(b.MouseButton1Click,function()
        local ok,err=pcall(cb)
        if not ok then log('Erro: '..tostring(err):sub(1,90)) end
    end)
    return b
end
local function toggle(key,text)
    local b
    local function refresh()
        if not b or not b.Parent then return end
        b.Text=string.format('%s  %s',flags[key] and '[ON]' or '[OFF]',text)
        b.BackgroundColor3=flags[key] and theme.on or theme.card
    end
    b=button('',function()
        flags[key]=not flags[key]
        refresh()
        log(text..': '..(flags[key] and 'ativado' or 'desativado'))
        if not flags[key] then currentTarget=nil end
        if key == 'fly' and not flags.fly and stopMovement then stopMovement() end
    end)
    refresh()
    table.insert(refreshToggles, refresh)
    return refresh
end

section('JOGADOR')
stats=label('Carregando dados...',80)
stateLabel=label(statusText,42)
section('AUTOMACOES')
toggle('farm','Auto Farm (NPCs comuns proximos)')
toggle('quest','Auto Quest (conforme level)')
toggle('boss','Auto Boss (chefes visiveis)')
toggle('raid','Auto Raid (ajuda durante raid)')
toggle('fruit','Auto Fruit (frutas visiveis)')
toggle('esp','ESP de NPCs e frutas')
section('COMBATE E MOVIMENTACAO')
toggle('fly','Deslocamento aereo experimental (Tween)')
toggle('click','Tentar clique M1 automatico')
button('Velocidade aerea 160 / 90 / 220',function()
    local speeds={160,90,220}
    local i=table.find(speeds,settings.flySpeed) or 1
    settings.flySpeed=speeds[i % #speeds+1]
    log('Velocidade configurada: '..settings.flySpeed)
end)
button('Altura sobre NPC 5 / 3 / 8',function()
    local heights={5,3,8}
    local i=table.find(heights,settings.hoverHeight) or 1
    settings.hoverHeight=heights[i % #heights+1]
    log('Altura configurada: '..settings.hoverHeight)
end)
button('Alcance dos NPCs: 450 -> 800 -> 250',function()
    settings.radius = settings.radius==450 and 800 or (settings.radius==800 and 250 or 450)
    log('Alcance de busca: '..settings.radius..' studs')
end)
section('RAID')
local raidButton
raidButton=button('Trocar raid: '..settings.raidType,function()
    local chips={'Flame','Ice','Sand','Dark','Light','Magma','Quake','Buddha','Spider','Phoenix','Dough'}
    local i=table.find(chips,settings.raidType) or 1
    settings.raidType=chips[i%#chips+1]
    raidButton.Text='Trocar raid: '..settings.raidType
    log('Raid selecionada: '..settings.raidType)
end)
local function commF()
    local r=ReplicatedStorage:FindFirstChild('Remotes')
    local f=r and r:FindFirstChild('CommF_')
    return (f and f:IsA('RemoteFunction')) and f or nil
end
button('Selecionar/comprar chip de raid',function()
    local rf=commF()
    if not rf then log('CommF_ nao disponivel neste cliente') return end
    -- Acao explicita do usuario, nao compra em ciclo.
    local ok,result=pcall(function()
        return rf:InvokeServer('RaidsNpc','Select',settings.raidType)
    end)
    log(ok and ('Pedido enviado; confira no jogo: '..tostring(result))
        or ('Compra negada/indisponivel: '..tostring(result):sub(1,60)))
end)
section('DIAGNOSTICOS')
button('Verificar recursos / copiar relatorio', function()
    if not reportBuilder then return log('Relatorio indisponivel') end
    local info = reportBuilder()
    print('[SeaForge diagnostico]\n' .. info)
    local copied = false
    if type(setclipboard) == 'function' then copied = pcall(setclipboard, info) end
    log(copied and 'Relatorio copiado' or 'Relatorio enviado ao console')
end)
section('VISUAL')
toggle('low','Reduzir efeitos locais')
button('FOV: 70 / 90 / 110',function()
    local cam=Workspace.CurrentCamera
    if not cam then return end
    cam.FieldOfView=cam.FieldOfView<80 and 90 or (cam.FieldOfView<100 and 110 or 70)
    log('FOV = '..math.floor(cam.FieldOfView))
end)
button('Desligar todas as automacoes',function()
    for k in pairs(flags) do flags[k]=false end
    currentTarget=nil
    currentFruit=nil
    for _,refresh in ipairs(refreshToggles) do refresh() end
    log('Tudo desligado.')
end)
label('O servidor pode rejeitar quests, ataques, raids e coleta. Nao ha bypass de anticheat nem garantia de drops.',59)

-- Arraste do painel por mouse/touch.
local dragging=false
local dragStart,dragOrigin,draggingInput
connect(header.InputBegan,function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    dragging=true
    dragStart=input.Position
    dragOrigin=panel.Position
    local endConnection
    endConnection=input.Changed:Connect(function()
        if input.UserInputState==Enum.UserInputState.End then
            dragging=false
            if endConnection then endConnection:Disconnect() end
        end
    end)
end)
connect(header.InputChanged,function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch then draggingInput=input end
end)
connect(UIS.InputChanged,function(input)
    if not dragging or input~=draggingInput or not dragStart or not dragOrigin then return end
    local delta=input.Position-dragStart
    panel.Position=UDim2.new(dragOrigin.X.Scale,dragOrigin.X.Offset+delta.X,
        dragOrigin.Y.Scale,dragOrigin.Y.Offset+delta.Y)
end)
connect(collapse.MouseButton1Click,function() panel.Visible=false bubble.Visible=true end)
connect(bubble.MouseButton1Click,function() panel.Visible=true bubble.Visible=false end)

local function getChar()
    local char=LP.Character
    if not char then return nil end
    local hrp=char:FindFirstChild('HumanoidRootPart')
    local hum=char:FindFirstChildOfClass('Humanoid')
    if not hrp or not hum or hum.Health<=0 then return nil end
    return char,hrp,hum
end
local function enemyFolder()
    return Workspace:FindFirstChild('Enemies')
end
local function isBoss(name)
    name=string.lower(name or '')
    return name:find('%[boss%]')~=nil or name:find('%[raid boss%]')~=nil
end
local function activeRaid()
    local o=Workspace:FindFirstChild('_WorldOrigin')
    local loc=o and o:FindFirstChild('Locations')
    if loc then
        for _,node in ipairs(loc:GetChildren()) do
            if node.Name:match('^Island %d+$') then return true end
        end
    end
    return false
end
local function hasQuest()
    local main=PG:FindFirstChild('Main')
    local q=main and main:FindFirstChild('Quest')
    return q and q:IsA('GuiObject') and q.Visible or false
end
local function playerLevel()
    local data=LP:FindFirstChild('Data')
    local v=data and data:FindFirstChild('Level')
    if not v then
        local ls=LP:FindFirstChild('leaderstats')
        v=ls and (ls:FindFirstChild('Level') or ls:FindFirstChild('Lv'))
    end
    return (v and tonumber(v.Value)) or 1
end

-- Dados publicos de nomenclatura de quests; dependem da versao do jogo.
-- Cada entrada: nivel inicial, questId, indice, nome do inimigo.
-- Sem coordenadas de quest giver: chamadas podem falhar caso esteja distante.
local questData={
    {1,'BanditQuest1',1,'Bandit'}, {10,'JungleQuest',1,'Monkey'},
    {15,'JungleQuest',2,'Gorilla'}, {30,'BuggyQuest1',1,'Pirate'},
    {40,'BuggyQuest1',2,'Brute'}, {60,'DesertQuest',1,'Desert Bandit'},
    {75,'DesertQuest',2,'Desert Officer'}, {90,'SnowQuest',1,'Snow Bandit'},
    {100,'SnowQuest',2,'Snowman'}, {120,'MarineQuest2',1,'Chief Petty Officer'},
    {150,'SkyQuest',1,'Sky Bandit'}, {175,'SkyQuest',2,'Dark Master'},
    {190,'PrisonerQuest',1,'Prisoner'}, {210,'PrisonerQuest',2,'Dangerous Prisoner'},
    {250,'ColosseumQuest',1,'Toga Warrior'}, {275,'ColosseumQuest',2,'Gladiator'},
    {300,'MagmaQuest',1,'Military Soldier'}, {325,'MagmaQuest',2,'Military Spy'},
    {375,'FishmanQuest',1,'Fishman Warrior'}, {400,'FishmanQuest',2,'Fishman Commando'},
    {450,'SkyExp1Quest',1,"God's Guard"}, {475,'SkyExp1Quest',2,'Shanda'},
    {525,'SkyExp2Quest',1,'Royal Squad'}, {550,'SkyExp2Quest',2,'Royal Soldier'},
    {625,'FountainQuest',1,'Galley Pirate'}, {650,'FountainQuest',2,'Galley Captain'},
    {700,'Area1Quest',1,'Raider'}, {725,'Area1Quest',2,'Mercenary'},
    {775,'Area2Quest',1,'Swan Pirate'}, {800,'Area2Quest',2,'Factory Staff'},
    {875,'MarineQuest3',1,'Marine Lieutenant'}, {900,'MarineQuest3',2,'Marine Captain'},
    {950,'ZombieQuest',1,'Zombie'}, {975,'ZombieQuest',2,'Vampire'},
    {1000,'SnowMountainQuest',1,'Snow Trooper'}, {1050,'SnowMountainQuest',2,'Winter Warrior'},
    {1100,'IceSideQuest',1,'Lab Subordinate'}, {1125,'IceSideQuest',2,'Horned Warrior'},
    {1175,'FireSideQuest',1,'Magma Ninja'}, {1200,'FireSideQuest',2,'Lava Pirate'},
    {1250,'ShipQuest1',1,'Ship Deckhand'}, {1275,'ShipQuest1',2,'Ship Engineer'},
    {1300,'ShipQuest2',1,'Ship Steward'}, {1325,'ShipQuest2',2,'Ship Officer'},
    {1350,'FrostQuest',1,'Arctic Warrior'}, {1375,'FrostQuest',2,'Snow Lurker'},
    {1425,'ForgottenQuest',1,'Sea Soldier'}, {1450,'ForgottenQuest',2,'Water Fighter'},
    {1500,'PiratePortQuest',1,'Pirate Millionaire'}, {1525,'PiratePortQuest',2,'Pistol Billionaire'},
    {1575,'AmazonQuest',1,'Dragon Crew Warrior'}, {1600,'AmazonQuest',2,'Dragon Crew Archer'},
    {1625,'AmazonQuest2',1,'Female Islander'}, {1650,'AmazonQuest2',2,'Giant Islander'},
    {1700,'MarineTreeIsland',1,'Marine Commodore'}, {1725,'MarineTreeIsland',2,'Marine Rear Admiral'},
    {1775,'DeepForestIsland3',1,'Fishman Raider'}, {1800,'DeepForestIsland3',2,'Fishman Captain'},
    {1825,'DeepForestIsland',1,'Forest Pirate'}, {1850,'DeepForestIsland',2,'Mythological Pirate'},
    {1900,'DeepForestIsland2',1,'Jungle Pirate'}, {1925,'DeepForestIsland2',2,'Musketeer Pirate'},
    {1975,'HauntedQuest1',1,'Reborn Skeleton'}, {2000,'HauntedQuest1',2,'Living Zombie'},
    {2025,'HauntedQuest2',1,'Demonic Soul'}, {2050,'HauntedQuest2',2,'Posessed Mummy'},
    {2075,'NutsIslandQuest',1,'Peanut Scout'}, {2100,'NutsIslandQuest',2,'Peanut President'},
    {2125,'IceCreamIslandQuest',1,'Ice Cream Chef'}, {2150,'IceCreamIslandQuest',2,'Ice Cream Commander'},
    {2200,'CakeQuest1',1,'Cookie Crafter'}, {2225,'CakeQuest1',2,'Cake Guard'},
    {2250,'CakeQuest2',1,'Baking Staff'}, {2275,'CakeQuest2',2,'Head Baker'},
    {2300,'ChocQuest1',1,'Cocoa Warrior'}, {2325,'ChocQuest1',2,'Chocolate Bar Battler'},
    {2350,'ChocQuest2',1,'Sweet Thief'}, {2375,'ChocQuest2',2,'Candy Rebel'},
    {2400,'CandyQuest1',1,'Candy Pirate'}, {2425,'CandyQuest1',2,'Snow Demon'},
    {2450,'TikiQuest1',1,'Isle Outlaw'}, {2475,'TikiQuest1',2,'Island Boy'},
    {2500,'TikiQuest2',1,'Sun-kissed Warrior'}, {2525,'TikiQuest2',2,'Isle Champion'},
    {2550,'TikiQuest3',1,'Serpent Hunter'}, {2575,'TikiQuest3',2,'Skull Slayer'},
}
local function currentQuest()
    local lv=playerLevel()
    if lv >= 2600 then return nil end
    local q=nil
    for _,entry in ipairs(questData) do
        if entry[1]<=lv then q=entry else break end
    end
    return q
end

local function pickEnemy(bossOnly,requiredName,raidMode)
    local folder=enemyFolder()
    local char,root=getChar()
    if not folder or not root then return nil end
    local best,score
    local required=requiredName and string.lower(requiredName) or nil
    for _,obj in ipairs(folder:GetChildren()) do
        if obj:IsA('Model') then
            local er=obj:FindFirstChild('HumanoidRootPart') or obj.PrimaryPart
            local eh=obj:FindFirstChildOfClass('Humanoid')
            if er and eh and eh.Health>0 then
                local boss=isBoss(obj.Name)
                local skip=(bossOnly and not boss) or (not bossOnly and boss and not raidMode)
                if not skip and required and not string.find(string.lower(obj.Name),required,1,true) then skip=true end
                if not skip then
                    local distance=(er.Position-root.Position).Magnitude
                    if distance<settings.radius then
                        local lv=tonumber(obj.Name:match('%[Lv%.?%s*(%d+)%]')) or 0
                        -- Evita atacar inimigos muito mais fortes no modo normal.
                        if bossOnly or raidMode or lv<=playerLevel()+15 then
                            local sc=distance
                            if not required and not bossOnly and not raidMode then
                                sc=sc+math.max(0,playerLevel()-lv)*2
                            end
                            if not score or sc<score then best=obj score=sc end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function equipWeapon(char,hum)
    for _,item in ipairs(char:GetChildren()) do
        if item:IsA('Tool') and not item.Name:lower():find('fruit') then return item end
    end
    local pack=LP:FindFirstChildOfClass('Backpack')
    if pack then
        for _,item in ipairs(pack:GetChildren()) do
            if item:IsA('Tool') and not item.Name:lower():find('fruit') then
                hum:EquipTool(item)
                return item
            end
        end
    end
    for _,item in ipairs(char:GetChildren()) do if item:IsA('Tool') then return item end end
    return nil
end

local lastMove=0
local lastAttack=0
local lastMessage=0
local flightTween, flightGoal, hoverBody, hoverRoot
local lastFlightTick = 0
local hasVirtualInput, virtualInput = pcall(function() return game:GetService('VirtualInputManager') end)
local hasVirtualUser, virtualUser = pcall(function() return game:GetService('VirtualUser') end)
local observedTarget, observedHealth, observedAt, lastHealthNotice = nil, nil, 0, 0
stopMovement = function()
    if flightTween then pcall(function() flightTween:Cancel() end) end
    flightTween,flightGoal=nil,nil
    if hoverBody then pcall(function() hoverBody:Destroy() end) end
    hoverBody,hoverRoot=nil,nil
end
local function addHover(root)
    if hoverRoot ~= root then stopMovement() end
    if hoverBody and hoverBody.Parent == root then return end
    -- Compensa a gravidade durante o voo local, sem alterar outros personagens.
    local body=Instance.new('BodyVelocity')
    body.Name='SeaForgeHover'
    body.MaxForce=Vector3.new(0, 1000000, 0)
    body.P=2000
    body.Velocity=Vector3.zero
    body.Parent=root
    hoverBody,hoverRoot=body,root
end
local function approach(point,root,hum)
    local distance=(point-root.Position).Magnitude
    if flags.fly then
        addHover(root)
        local goal=point+Vector3.new(0,settings.hoverHeight,0)
        local distanceToGoal=(goal-root.Position).Magnitude
        -- Evita cancelar e reiniciar tween a cada ciclo, que impedia a chegada.
        if distanceToGoal>2 and (not flightGoal or (goal-flightGoal).Magnitude>5
                or not flightTween or flightTween.PlaybackState~=Enum.PlaybackState.Playing)
                and os.clock()-lastFlightTick>0.25 then
            if flightTween then pcall(function() flightTween:Cancel() end) end
            local seconds=math.clamp(distanceToGoal/settings.flySpeed,0.12,4)
            flightTween=TweenService:Create(root,TweenInfo.new(seconds,Enum.EasingStyle.Linear),
                {CFrame=CFrame.new(goal)})
            flightGoal=goal
            lastFlightTick=os.clock()
            local ok,err=pcall(function() flightTween:Play() end)
            if not ok then log('Voo nao permitido neste contexto: '..tostring(err):sub(1,75)) end
        end
    else
        if hoverBody or flightTween then stopMovement() end
        if distance>settings.approach+2 and os.clock()-lastMove>0.45 then
            local diff=root.Position-point
            local dir=diff.Magnitude>0.01 and diff.Unit or Vector3.new(1,0,0)
            local goal=point+dir*settings.approach
            hum:MoveTo(goal)
            lastMove=os.clock()
        end
    end
    return distance
end
local function clickM1()
    local camera=Workspace.CurrentCamera
    if not camera then return false,'sem camera' end
    local size=camera.ViewportSize
    -- Clica fora do painel central para evitar acionar botões por engano.
    local x=math.max(1,math.floor(size.X*0.93))
    local y=math.max(1,math.floor(size.Y*0.72))
    if hasVirtualInput and virtualInput then
        local ok=pcall(function()
            virtualInput:SendMouseButtonEvent(x,y,0,true,game,0)
            virtualInput:SendMouseButtonEvent(x,y,0,false,game,0)
        end)
        if ok then return true,'VirtualInputManager' end
    end
    if hasVirtualUser and virtualUser then
        local ok=pcall(function()
            virtualUser:Button1Down(Vector2.new(x,y),camera.CFrame)
            virtualUser:Button1Up(Vector2.new(x,y),camera.CFrame)
        end)
        if ok then return true,'VirtualUser' end
    end
    return false,'entrada de mouse indisponivel no cliente'
end
local function recordHealth(enemy,hum)
    if observedTarget ~= enemy then
        observedTarget=enemy
        observedHealth=hum.Health
        observedAt=os.clock()
        return
    end
    if observedHealth and hum.Health < observedHealth-0.1 then
        observedAt=os.clock()
        observedHealth=hum.Health
        -- A queda de HP e observavel, mas nao comprova qual jogador causou dano.
    elseif observedHealth and hum.Health>observedHealth then
        observedHealth=hum.Health
        observedAt=os.clock()
    end
    if os.clock()-observedAt>7 and os.clock()-lastHealthNotice>7 then
        log('Alvo nao perdeu HP observado em 7s. Clique pode ser ignorado pelo jogo.')
        lastHealthNotice=os.clock()
        observedAt=os.clock()
    end
end
local function attack(enemy)
    local char,root,hum=getChar()
    if not char then return end
    local er=enemy:FindFirstChild('HumanoidRootPart') or enemy.PrimaryPart
    local eh=enemy:FindFirstChildOfClass('Humanoid')
    if not er or not eh or eh.Health<=0 then return end
    local dist=approach(er.Position,root,hum)
    recordHealth(enemy,eh)
    -- Em voo, aguarda chegar a distancia de combate. A altura e configuravel.
    if dist>15 then
        if os.clock()-lastMessage>7 then log('Aproximando de '..enemy.Name) lastMessage=os.clock() end
        return
    end
    local tool=equipWeapon(char,hum)
    if tool and tool.Parent == char and os.clock()-lastAttack>settings.attackDelay then
        local aim=Vector3.new(er.Position.X,root.Position.Y,er.Position.Z)
        if (aim-root.Position).Magnitude>0.05 then
            -- Evita trocar CFrame enquanto tween de movimentacao estiver ativo.
            if not flightTween or flightTween.PlaybackState~=Enum.PlaybackState.Playing then
                root.CFrame=CFrame.lookAt(root.Position,aim)
            end
        end
        local clicked=false
        if flags.click then
            local reason
            clicked,reason=clickM1()
            if not clicked and os.clock()-lastMessage>6 then
                log('Clique automatico falhou: '..tostring(reason))
                lastMessage=os.clock()
            end
        end
        local ok=pcall(function() tool:Activate() end)
        if not ok and not clicked and os.clock()-lastMessage>6 then
            log('Nem clique M1 nem Tool:Activate foram aceitos pelo cliente')
            lastMessage=os.clock()
        end
        lastAttack=os.clock()
    elseif not tool and os.clock()-lastMessage>5 then
        log('Equipe estilo de luta ou espada na mochila.')
        lastMessage=os.clock()
    end
end

local function fruitPart(obj)
    if not (obj:IsA('Tool') or obj:IsA('Model')) then return nil end
    if not obj.Name:lower():find('fruit',1,true) then return nil end
    if not obj:IsDescendantOf(Workspace) then return nil end
    if LP.Character and obj:IsDescendantOf(LP.Character) then return nil end
    if obj.Parent and obj.Parent:IsA('Model')
        and obj.Parent:FindFirstChildOfClass('Humanoid') then return nil end
    local part = obj:FindFirstChild('Handle') or (obj:IsA('Model') and obj.PrimaryPart)
    return (part and part:IsA('BasePart')) and part or nil
end
local function validFruit(obj)
    return fruitPart(obj) ~= nil
end
local function findFruit()
    local _,root=getChar()
    if not root then return nil end
    local best,distance
    -- Busca objetos QUE JA ESTAO REPLICADOS no cliente; nao le outros servidores.
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if validFruit(obj) then
            local d=(fruitPart(obj).Position-root.Position).Magnitude
            if d<settings.radius and (not distance or d<distance) then
                best=obj distance=d
            end
        end
    end
    return best
end

local function runFruit()
    local _,root,hum=getChar()
    if not root then return false end
    if os.clock()-lastFruitScan>5 or not (currentFruit and currentFruit.Parent and validFruit(currentFruit)) then
        lastFruitScan=os.clock()
        currentFruit=findFruit()
        if currentFruit then log('Fruta no mapa: '..currentFruit.Name) end
    end
    if currentFruit and currentFruit.Parent then
        local handle=fruitPart(currentFruit)
        if handle then
            local d=approach(handle.Position,root,hum)
            if d<8 then
                -- Encostar no objeto tenta usar a coleta normal (Touch), sem forcar inventario.
                hum:MoveTo(handle.Position)
            end
            return true
        end
    end
    return false
end

local lastQuestWarn=0
local function questStep()
    if not flags.quest or hasQuest() then return end
    if os.clock()-lastQuestAttempt<12 then return end
    lastQuestAttempt=os.clock()
    local q=currentQuest()
    if not q then return end
    local rf=commF()
    if not rf then
        if os.clock()-lastQuestWarn>15 then log('Auto Quest: remote de quest indisponivel') lastQuestWarn=os.clock() end
        return
    end
    local ok,response=pcall(function() return rf:InvokeServer('StartQuest',q[2],q[3]) end)
    task.wait(0.5)
    if not ok then
        log('Quest negada: '..tostring(response):sub(1,70))
    elseif hasQuest() then
        log('Quest recebida: '..q[4])
    else
        log('Quest nao confirmada; aproxime-se do quest giver de '..q[4])
    end
end

local function createMark(target,color)
    if marks[target] and marks[target].Parent then return end
    local adorned = target
    if target:IsA('Tool') then
        adorned = fruitPart(target)
        if not adorned then return end
    end
    local h=make('Highlight',{Name='SeaForgeESP',FillTransparency=0.78,
        OutlineTransparency=0.12,OutlineColor=color,FillColor=color,
        Adornee=adorned,DepthMode=Enum.HighlightDepthMode.Occluded},adorned)
    marks[target]=h
end
local function clearMarks()
    for target,h in pairs(marks) do
        if h then pcall(function() h:Destroy() end) end
        marks[target]=nil
    end
end
local function espStep()
    if not flags.esp then
        if next(marks)~=nil then clearMarks() end
        return
    end
    local folder=enemyFolder()
    if folder then
        for _,enemy in ipairs(folder:GetChildren()) do
            if enemy:IsA('Model') and enemy:FindFirstChildOfClass('Humanoid') then
                createMark(enemy,isBoss(enemy.Name) and Color3.fromRGB(255,80,100) or Color3.fromRGB(76,177,210))
            end
        end
    end
    for _,child in ipairs(Workspace:GetDescendants()) do
        if validFruit(child) then createMark(child,Color3.fromRGB(255,210,80)) end
    end
    for target,h in pairs(marks) do
        if not target.Parent or not h.Parent then
            if h then pcall(function() h:Destroy() end) end
            marks[target]=nil
        end
    end
end

local function lowGraphicsStep()
    if flags.low then
        if not visualCache.enabled then
            visualCache.enabled=true
            initialShadows=Lighting.GlobalShadows
            Lighting.GlobalShadows=false
            for _,eff in ipairs(Lighting:GetChildren()) do
                if eff:IsA('PostEffect') then changedEffects[eff]=eff.Enabled eff.Enabled=false end
            end
        end
    elseif visualCache.enabled then
        Lighting.GlobalShadows=initialShadows
        for eff,was in pairs(changedEffects) do
            if eff and eff.Parent then eff.Enabled=was end
        end
        changedEffects={}
        visualCache.enabled=false
    end
end

local function valueOf(folder,names)
    if not folder then return 'n/d' end
    for _,name in ipairs(names) do
        local v=folder:FindFirstChild(name)
        if v and v:IsA('ValueBase') then return tostring(v.Value) end
    end
    return 'n/d'
end
local elapsed,frames=0,0
connect(RunService.RenderStepped,function(dt)
    if not alive then return end
    elapsed=elapsed+dt frames=frames+1
    if elapsed<0.6 then return end
    local char,root,hum=getChar()
    local data=LP:FindFirstChild('Data') or LP:FindFirstChild('leaderstats')
    local questInfo=currentQuest()
    local q=questInfo and questInfo[4] or 'nao catalogada'
    local hp=hum and string.format('%.0f/%.0f',hum.Health,hum.MaxHealth) or 'n/d'
    if stats.Parent then
        stats.Text=string.format('  Usuario: %s | FPS: %.0f\n  Level: %s | Beli: %s | Fragmentos: %s\n  HP: %s | Proxima quest: %s',
            LP.Name,frames/elapsed,tostring(playerLevel()),
            valueOf(data,{'Beli','Money','Cash'}),valueOf(data,{'Fragments','Fragmentos'}),hp,q)
    end
    elapsed=0 frames=0
    local camera=Workspace.CurrentCamera
    if camera then
        local v=camera.ViewportSize
        panel.Size=UDim2.fromOffset(math.min(363,math.max(245,v.X-16)),
            math.min(450,math.max(240,v.Y-16)))
    end
end)

-- Cada loop executa pcall para nao parar tudo apos uma falha isolada.
task.spawn(function()
    while alive do
        local ok,err=pcall(function()
            if flags.quest then questStep() end
            if not (flags.fly and (flags.farm or flags.boss or flags.raid or flags.fruit)) and hoverBody then stopMovement() end
            -- Fruta tem prioridade e nao disputa o Humanoid:MoveTo com o combate.
            local fruitBusy = flags.fruit and runFruit() or false
            local raidNow=flags.raid and activeRaid()
            local wantCombat=flags.boss or flags.farm or raidNow
            if wantCombat and not fruitBusy then
                local required=nil
                if flags.farm and flags.quest and hasQuest() then
                    local q=currentQuest()
                    required=q and q[4] or nil
                end
                local candidate
                if flags.boss then candidate=pickEnemy(true,nil,false) end
                if not candidate and raidNow then candidate=pickEnemy(false,nil,true) end
                if not candidate and flags.farm then
                    candidate=pickEnemy(false,required,false)
                    if not candidate and required and os.clock()-lastMessage>8 then
                        log('Inimigo da quest nao esta carregado/proximo: '..required)
                        lastMessage=os.clock()
                    end
                end
                currentTarget=candidate
                if candidate then attack(candidate) end
            end
        end)
        if not ok and os.clock()-lastMessage>8 then
            log('Erro interno do ciclo: '..tostring(err):sub(1,70))
            lastMessage=os.clock()
        end
        task.wait(0.35)
    end
end)
task.spawn(function()
    while alive do
        pcall(lowGraphicsStep)
        pcall(espStep)
        task.wait(3)
    end
end)

reportBuilder = function()
    local char, root, hum = getChar()
    local folder = enemyFolder()
    local npcCount, bossCount, fruitCount = 0, 0, 0
    if folder then
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy:IsA('Model') and enemy:FindFirstChildOfClass('Humanoid') then
                npcCount = npcCount + 1
                if isBoss(enemy.Name) then bossCount = bossCount + 1 end
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if validFruit(obj) then fruitCount = fruitCount + 1 end
    end
    local lines = {
        'SeaForge v1.1: relatorio LOCAL, nao confirma resultados no servidor',
        'Personagem disponivel: ' .. tostring(char ~= nil),
        'Humanoid vivo: ' .. tostring(hum ~= nil and hum.Health > 0),
        'HumanoidRootPart: ' .. tostring(root ~= nil),
        'NPCs visiveis: ' .. tostring(npcCount),
        'Chefes visiveis: ' .. tostring(bossCount),
        'Frutas visiveis: ' .. tostring(fruitCount),
        'RemoteFunction disponivel: ' .. tostring(commF() ~= nil),
        'Quest na interface: ' .. tostring(hasQuest()),
        'Quest de nivel catalogada: ' .. tostring(currentQuest() ~= nil),
        'Raid detectada: ' .. tostring(activeRaid()),
        'Modo Farm: ' .. tostring(flags.farm),
        'Modo Quest: ' .. tostring(flags.quest),
        'Modo Boss: ' .. tostring(flags.boss),
        'Modo Raid: ' .. tostring(flags.raid),
        'Modo Fruit: ' .. tostring(flags.fruit),
        'Modo ESP: ' .. tostring(flags.esp),
        'Movimento aereo: ' .. tostring(flags.fly),
        'AutoClique M1: ' .. tostring(flags.click),
        'VirtualInputManager: ' .. tostring(hasVirtualInput and virtualInput ~= nil),
        'VirtualUser: ' .. tostring(hasVirtualUser and virtualUser ~= nil),
        'Alvo com HP sem baixar (ultimo monitoramento): ' .. tostring(observedTarget ~= nil and os.clock()-observedAt>7),
        '--- Mensagens recentes ---',
    }
    for i=math.max(1,#debugLines-14),#debugLines do
        lines[#lines+1]=debugLines[i]
    end
    return table.concat(lines, '\n')
end

local function shutdown()
    if not alive then return end
    alive=false
    for k in pairs(flags) do flags[k]=false end
    clearMarks()
    stopMovement()
    lowGraphicsStep()
    for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    if gui.Parent then gui:Destroy() end
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=originalFov end
    if env.SeaForgeShutdown==shutdown then env.SeaForgeShutdown=nil end
end
connect(close.MouseButton1Click,shutdown)
env.SeaForgeShutdown=shutdown
log('SeaForge v1.2 movimento aereo e clique M1 experimental. Sem testes no servidor oficial.')
print('[SeaForge v1.2] Iniciado com diagnosticos. Funcoes sujeitas a validacao do servidor.')